/*
1.a
    Las personas que no están activas deben tener establecida una fecha de baja,
    la cual se debe controlar que sea al menos 6 meses posterior a la de su alta
*/

ALTER TABLE Persona
    ADD CONSTRAINT Persona_fecha_baja
        CHECK ((activo = TRUE) OR (fecha_baja >= fecha_alta + interval '6 months'));



/*
REGLAS DE NEGOCIO DE ENUNCIADO PREVIO A LOS EJERCICIOS:

 - Pasados los 6 meses de su alta, en cualquier momento el cliente puede solicitar la baja,
   quedando entonces inactivo, siempre y cuando no adeude ningún servicio.

 - (posible) TipoComprobante: el atributo 'tipo' que solo pueda ser 'Factura', 'Recibo' o 'Remito'.
*/

CREATE OR REPLACE FUNCTION baja_voluntaria() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.activo = TRUE) THEN
        IF (NEW.fecha_alta + INTERVAL '6 months' > CURRENT_DATE) THEN
            IF (EXISTS (SELECT 1
                        FROM Cliente c
                        WHERE (c.id_cliente = NEW.id_persona) AND (c.saldo > 0)
            )
                ) THEN
                RAISE EXCEPTION 'No se puede dar de baja a una persona que adeuda servicios';
            END IF;
        ELSE
            RAISE EXCEPTION 'No se puede dar de baja a una persona que no haya pasado 6 meses desde su alta';
        END IF;
    END IF;
    RETURN NEW;
END $$ LANGUAGE 'plpgsql';

CREATE TRIGGER tr_baja_voluntaria
    BEFORE UPDATE OF activo ON Persona
    FOR EACH ROW
EXECUTE FUNCTION baja_voluntaria();

/*
1.b
    El importe de un comprobante debe coincidir con el total de los importes
    indicados en las líneas que lo conforman (si las tuviera).
*/

/*
 de forma declarativa. no funciona en postrgreSQL
create assertion importe_comprobantes
check (not exists (select 1 from comprobante c
                   where importe != (select sum(importe)
                                     from lineacomprobante lc
                                     where (c.id_comp = lc.id_comp) and (c.id_tcomp = lc.id_tcomp)
                                     )
                   )
       )
*/

create or replace function fn_actualizar_importe_comprobante()
    returns trigger as $$
begin
    if (exists (select 1 from lineacomprobante where id_comp = new.id_comp and id_tcomp = new.id_tcomp))
        and (new.importe != (select sum(importe) from lineacomprobante where id_comp = new.id_comp and id_tcomp = new.id_tcomp))
    then
        raise exception 'El importe ingresado no coincide con el total de importes de sus lineas';
    end if;
    return new;
end $$ language 'plpgsql';

create or replace trigger tri_actualiza_importe_comprobante
    after update of importe on comprobante
    for each row
execute function fn_actualizar_importe_comprobante();

create or replace function fn_actualizar_importe_linea()
    returns trigger as $$
begin
    if (tg_op = 'insert' or tg_op = 'update') then
        if (new.importe != 0) then
            raise exception 'El importe de la linea no es valido, ya que cambia el importe del comprobante';
        end if;
        return new;
    end if;
    if (tg_op = 'delete') then
        if (old.importe != 0) then
            raise exception 'No es posible eliminar la linea, ya que cambia el importe del comprobante';
        end if;
        return old;
    end if;
end $$ language 'plpgsql';

create or replace trigger tri_importes_lineacomprobante
    after insert or delete or update of importe,id_comp,id_tcomp on lineacomprobante
    for each row
execute function fn_actualizar_importe_linea();



/*INCISO C:
  Las IPs asignadas a los equipos no pueden ser compartidas entre diferentes clientes.
 */

/*
CREATE ASERTION direccion_ip
check ( not exists ( select ip from equipo e = (select ip from equipo e2 where e.id_cliente != e2.id_cliente)
*/

create or replace function fn_comp_ip()
    returns trigger as $$
begin
    if (exists (select 1
                from equipo
                where (ip = new.ip) AND (id_cliente != new.id_cliente)
    )
        ) then
        raise exception 'La IP pertenece ya se encuentra asignada en otro cliente';
    end if;
end $$ language 'plpgsql';

create or replace trigger tri_comp_ip
    after insert or update of ip on equipo
    for each row
execute function fn_comp_ip();


/*
 2-a. Al ser invocado (una vez por mes), para todos los servicios que son periódicos, se deben
      generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos
      clientes. Indicar si se deben proveer parámetros adicionales para su generación y, de ser así,
      cuales.
 */

/*hacer un comprobante por cada cliente que tenga un servicio periodico activo en el mes.*/
/*CREATE OR REPLACE FUNCTION generar_nro_comprobante()
    RETURNS INT AS $$
DECLARE
    max_comprobante INT;
    nuevo_comprobante INT;
BEGIN
    -- Obtener el máximo número de comprobante actual
    SELECT COALESCE(MAX(id_comp), 0) INTO max_comprobante
    FROM Comprobante;

    -- Generar el siguiente número de comprobante, incrementando de la secuencia
    nuevo_comprobante := max_comprobante + 1;

    -- Si la secuencia está fuera de sincronización, ajustar el valor
    IF nuevo_comprobante < currval('seq_comprobante') THEN
        -- Si el valor actual en la secuencia es mayor que el valor máximo, sincronizamos la secuencia
        PERFORM setval('seq_comprobante', nuevo_comprobante, false);
    END IF;

    -- Devuelve el nuevo número de comprobante
    RETURN nuevo_comprobante;
END;
$$ LANGUAGE plpgsql;
*/
CREATE OR REPLACE FUNCTION generar_nro_comprobante()
    RETURNS INT AS $$
DECLARE
    max_comprobante INT;
    nuevo_comprobante INT;
BEGIN
    -- Obtener el máximo número de comprobante actual
    SELECT COALESCE(MAX(id_comp), 0) INTO max_comprobante
    FROM Comprobante;

    -- Si max_comprobante es mayor al valor actual de la secuencia, reiniciarla
    IF max_comprobante >= nextval('seq_comprobante') THEN
        -- Ejecutar ALTER SEQUENCE para reiniciar la secuencia en un valor superior al máximo comprobante
        EXECUTE 'ALTER SEQUENCE seq_comprobante RESTART WITH ' || (max_comprobante + 1);
    END IF;

    -- Obtener el siguiente valor de la secuencia sincronizada
    RETURN nextval('seq_comprobante');
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE seq_comprobante START 1;

DELETE FROM comprobante where extract(year from fecha) = 2024;

CREATE OR REPLACE PROCEDURE cobrar_servicios_periodicos(in fecha_facturacion date)
    LANGUAGE 'plpgsql' AS $$
DECLARE
    comprob RECORD;
    id_comp_aux INT;
BEGIN
    FOR comprob IN (
        SELECT c.id_cliente
        FROM cliente c
                 JOIN equipo e USING (id_cliente)
                 JOIN SERVICIO s USING (id_servicio)
        WHERE (s.periodico = TRUE) AND (s.activo = TRUE)
        GROUP BY c.id_cliente
    )
        LOOP
            id_comp_aux :=generar_nro_comprobante();
            INSERT INTO comprobante (id_comp,id_tcomp,fecha,comentario,importe,id_cliente,id_lugar)
            VALUES (id_comp_aux, 1,fecha_facturacion,'Factura de servicio periodico',0,comprob.id_cliente,null/*agregar el lugar*/);
            INSERT INTO lineacomprobante(nro_linea, id_comp,id_tcomp,descripcion, cantidad,importe, id_servicio)
            SELECT
                        ROW_NUMBER() OVER(ORDER BY e.id_servicio),
                        id_comp_aux,
                        1,
                        'Servicio periódico',
                        count(e.id_servicio),
                        s.costo,
                        e.id_servicio
            FROM equipo e
                     JOIN SERVICIO s USING (id_Servicio)
            WHERE (e.id_cliente = comprob.id_cliente AND s.activo = TRUE AND s.periodico = TRUE)
            GROUP BY e.id_cliente, e.id_servicio, s.costo;
            --UPDATE
            UPDATE comprobante
            SET importe = (SELECT SUM(importe*cantidad) FROM lineacomprobante WHERE id_comp = id_comp_aux AND id_tcomp = 1)
            WHERE id_comp = id_comp_aux AND id_tcomp = 1;
        end loop;
    RAISE NOTICE 'Facturas correctamente generadas para servicios periodicos en el dia de la fecha';
END;
$$;

call cobrar_servicios_periodicos('2018-12-09');
-----------------------------------------------------------------------------------------------------------------------------------------------------------

/*
b. Al ser invocado entre dos fechas cualesquiera genere un informe de los empleados (personal) junto con
la cantidad de clientes distintos que cada uno ha atendido en tal periodo y los tiempos promedio y máximo
del conjunto de turnos atendidos en el periodo.
 */
drop function generar_informe_empleados(inicio timestamp, fin timestamp);

CREATE OR REPLACE FUNCTION generar_informe_empleados(inicio timestamp,fin timestamp)
RETURNS TABLE
        (   id_empleado             int,
            cant_clientes_atendidos bigint,
            tiempo_promedio_turnos  numeric,
            tiempo_maximo_turnos    numeric
        )
LANGUAGE 'plpgsql' AS $$
    DECLARE
    BEGIN
        RETURN QUERY
            SELECT
                pl.id_personal AS id_empleado,
                COUNT(DISTINCT co.id_cliente) AS cant_clientes_atendidos,
                EXTRACT(epoch FROM AVG (t.hasta - t.desde)) / 3600 AS tiempo_promedio_turnos, -- ACOMODAR. DA RARO
                EXTRACT(epoch FROM MAX (t.hasta - t.desde)) / 3600 AS tiempo_maximo_turnos
            FROM
                Personal pl
                    LEFT JOIN Turno t ON pl.id_personal = t.id_personal
                    LEFT JOIN Comprobante co ON t.id_turno = co.id_turno

            WHERE
                (t.desde >= inicio AND fin <= t.hasta) OR (pl.id_personal NOT IN (SELECT t2.id_personal
                                                                                  FROM TURNO t2))
            -- no incluye a personal sin turno porque los que no tienen turno no tienen fechas para comparar.
            GROUP BY
                pl.id_personal;
    end;
    $$;

select * FROM generar_informe_empleados('2014-1-1','2015-1-1');

/* 3a a. Vista1, que contenga el saldo de cada uno de los clientes menores de 30 años de la ciudad ‘Napoli, que posean más de 3 servicios. */

 CREATE OR REPLACE VIEW Vista1 AS
 SELECT c.id_cliente,c.saldo
 FROM cliente c
 WHERE c.id_cliente IN(
                    SELECT p.id_persona
                    FROM persona p
                    WHERE (EXTRACT(YEAR FROM AGE(p.fecha_nacimiento))<30)
                    AND p.id_persona IN(
                                    SELECT d.id_persona
                                    FROM direccion d
                                    WHERE d.id_barrio IN(
                                                    SELECT b.id_barrio
                                                    FROM barrio b
                                                    WHERE b.id_ciudad IN(
                                                                    SELECT ci.id_ciudad
                                                                    FROM ciudad ci
                                                                    WHERE ci.nombre = 'Napoli'
                                                                    )
                                                    )
                                    )
                    AND p.id_persona IN(
                        SELECT e.id_cliente
                        FROM equipo e
                        WHERE (SELECT COUNT(e2.id_cliente)
                               FROM equipo e2
                               WHERE e2.id_cliente = e.id_cliente) > 3)
                );

/*
 Se plantearon sentencias para la activacion del trigger instead of sobre la vista1 :
 */

INSERT INTO Vista1 (id_cliente, saldo) VALUES (30,3333);


/* 3b. Vista2, con los datos de los clientes activos del sistema que hayan sido dados de alta en el
    año actual y que poseen al menos un servicio activo, incluyendo el/los servicio/s activo/s que
    cada uno posee y su costo.*/

CREATE OR REPLACE VIEW Vista2 AS
    SELECT c.id_cliente, c.saldo, s.id_servicio, s.nombre as nombre_servicio, s.costo as costo_servicio
    FROM Cliente c
        JOIN Persona p on c.id_cliente = p.id_persona
        JOIN Equipo e USING (id_cliente)
        JOIN Servicio s USING (id_servicio)
    WHERE (p.activo = TRUE)
        AND (EXTRACT(YEAR FROM p.fecha_alta) = EXTRACT(YEAR FROM CURRENT_DATE))
        AND (s.activo = TRUE);

CREATE OR REPLACE FUNCTION fn_tri_act_vista2()
RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            DELETE FROM cliente WHERE id_cliente=old.id_cliente;
            DELETE FROM servicio WHERE id_servicio=old.id_servicio; --AND NOT EXISTS (SELECT 1 FROM Equipo WHERE id_servicio = OLD.id_servicio); --POR SI EL SERVICIO ESTA ASOCIADO A OTRO CLIENTE.
            RETURN OLD;
        ELSIF (TG_OP = 'INSERT') THEN
            RAISE EXCEPTION 'NO ES POSIBLE HACER UN INSERT';
        -- Decidimos rechazar la operacion insert ya que para la tabla servicio nos faltan valores para completar una fila.
        ELSIF (TG_OP = 'UPDATE') THEN
            UPDATE cliente
            SET id_cliente=new.id_cliente, saldo=new.saldo
            WHERE id_cliente=old.id_cliente;

            UPDATE servicio
            SET id_servicio=new.id_servicio, nombre=new.nombre_servicio, costo=new.costo_servicio
            WHERE id_servicio=old.id_servicio;
        END IF;
    RETURN NULL;
    end;
    $$LANGUAGE 'plpgsql';





CREATE OR REPLACE TRIGGER tri_act_vista2
    INSTEAD OF delete or insert or update on Vista2
    for each row
    execute function fn_tri_act_vista2();
/*
 Vista3, que contenga, por cada uno de los servicios periódicos registrados en el sistema,
 los datos del servicio y el monto facturado mensualmente durante los últimos 5 años, ordenado por servicio, año, mes y monto.
 */

CREATE OR REPLACE VIEW Vista3 AS
    SELECT s.*, EXTRACT(MONTH FROM c.fecha) AS mes, EXTRACT(YEAR FROM c.fecha) AS año, lc.importe AS monto_facturado
    FROM servicio s
             JOIN lineacomprobante lc ON s.id_servicio = lc.id_servicio
             JOIN comprobante c ON lc.id_comp = c.id_comp AND lc.id_tcomp=c.id_tcomp
    WHERE s.periodico = TRUE
      AND c.id_tcomp = 1 -- Solo facturas
      AND c.fecha >= NOW() - INTERVAL '5 years'
    ORDER BY s.id_servicio, año, mes, lc.importe;




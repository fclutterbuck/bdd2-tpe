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
                where (ip = new.ip) AND (id_cliente != new.id_cliente) -- ID CLIENTE no deberia prohibirse que sea null?
    )
        ) then --Verifico si el ip ya esta asignado en otro cliente. ¿UN CLIENTE PUEDE TENER MAS DE UNA IP? ¿O DOS EQUIPOS CON UNA IP?
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
CREATE OR REPLACE PROCEDURE cobrar_servicios_periodicos(in fecha_facturacion date)
LANGUAGE 'plpgsql' AS $$
DECLARE
    tupla_servicio RECORD;
    id_cliente_aux int;
    id_comp_aux int;
BEGIN
    for tupla_servicio in (
        select s.id_servicio,s.costo,s.nombre
        from servicio s
        where (s.activo=true and s.periodico=true) --se seleccionan todos los servicios activos y periodicos de la tabla servicios.
    )
    LOOP
        --se inserta un nuevo comprobante de tipo factura con la informacion del servicio y el cliente(tomado de la tabla Equipo)
        select id_cliente into id_cliente_aux
        from equipo e
        where tupla_servicio.id_servicio = e.id_servicio;

        --necesito el ultimo id_comp para agregar un nuevo registro con otro numero de id
        select max(id_comp) into id_comp_aux
        from comprobante;

        insert into comprobante (id_comp,id_tcomp,fecha,comentario,importe,id_cliente,id_lugar)
        --se asume que el tipo de comprobante 1 es 'Factura'
            values (id_comp_aux+1,1,fecha_facturacion,tupla_servicio.nombre,tupla_servicio.costo,id_cliente_aux,null);

        --VER SI INSERTAR EN LA TABLA LINEACOMPROBANTE EL DETALLE DE LA FACTURA.

        end loop;
        RAISE NOTICE 'Facturas correctamente generadas para servicios periodicos en el dia de la fecha';
END;
    $$;
-------------------------------------------------------------

/*
b. Al ser invocado entre dos fechas cualesquiera genere un informe de los empleados (personal) junto con
la cantidad de clientes distintos que cada uno ha atendido en tal periodo y los tiempos promedio y máximo
del conjunto de turnos atendidos en el periodo.
 */
CREATE OR REPLACE FUNCTION generar_informe_empleados(inicio DATE,fin DATE)
RETURNS TABLE
        (   id_empleado             varchar(40),
            cant_clientes_atendidos int,
            tiempo_promedio_turnos  int,
            tiempo_maximo_turnos    int
        )
LANGUAGE 'plpgsql' AS $$
    DECLARE
    BEGIN
        RETURN QUERY
            SELECT
                pl.id_personal AS id_empleado,                            -- Identificación del empleado
                COUNT(DISTINCT co.id_cliente) AS cant_clientes_atendidos, -- Contar clientes distintos
                AVG(t.hasta - t.desde)::int AS tiempo_promedio_turnos, -- Tiempo promedio
                MAX(t.hasta - t.desde)::int AS tiempo_maximo_turnos   -- Tiempo máximo
            FROM
                Turno t
                    JOIN Personal pl ON t.id_personal = pl.id_personal       -- Relacionar turnos con personal
                    JOIN Comprobante co ON t.id_turno = co.id_turno          -- Relacionar turnos con comprobantes (para obtener clientes)
            WHERE
                t.desde BETWEEN inicio AND fin                           -- Filtrar turnos entre las fechas dadas
            GROUP BY
                pl.id_personal;
    end;
    $$;

/* 3a a. Vista1, que contenga el saldo de cada uno de los clientes menores de 30 años de la ciudad ‘Napoli, que posean más de 3 servicios. */

CREATE OR REPLACE VIEW Vista1 AS
    SELECT c.id_cliente,c.saldo
    FROM persona p
        JOIN cliente c ON p.id_persona = c.id_cliente
        JOIN direccion d ON p.id_persona = D.id_persona
        JOIN barrio b ON d.id_barrio = b.id_barrio
        JOIN ciudad ci ON b.id_ciudad = ci.id_ciudad
    WHERE (ci.nombre='Napoli') AND (EXTRACT(YEAR FROM AGE(p.fecha_nacimiento))<30) AND (c.id_cliente IN
                                                                                        (SELECT e.id_cliente
                                                                                         FROM equipo e
                                                                                         GROUP BY e.id_cliente
                                                                                         HAVING COUNT(DISTINCT e.id_servicio) > 3)
        );

CREATE OR REPLACE FUNCTION fn_tri_Vista1()
RETURNS TRIGGER AS $$
    BEGIN
        /*
         Se toma accion depende de la operacion que se haya hecho sobre la vista, se busca dar consistencia a las tablas base,
         ya que en el script de creacion de las tablas no hay acciones referenciales ante baja, alta o modificaciones.
         */
        IF (TG_OP = 'DELETE') THEN
            DELETE FROM cliente WHERE id_cliente=old.id_cliente;
            RETURN OLD;
        end if;
        IF (TG_OP = 'UPDATE') THEN
            IF EXISTS (SELECT 1 FROM cliente WHERE new.id_cliente=id_cliente) THEN
                RAISE EXCEPTION 'No se permite actualizar el id_cliente';
            ELSE
                UPDATE cliente SET id_cliente=new.id_cliente,saldo=new.saldo WHERE id_cliente=new.id_cliente;
            END IF;
            RETURN NEW;
        end if;
        IF (TG_OP = 'INSERT') THEN
            IF EXISTS(SELECT 1 FROM cliente WHERE new.id_cliente=id_cliente) THEN
                RAISE EXCEPTION 'El cliente ya existe.';
            ELSE
                INSERT INTO cliente (id_cliente, saldo)
                VALUES (new.id_cliente, new.saldo);
            END IF;
            RETURN NEW;
        end if;
    END;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER tr_delete_vista1
    INSTEAD OF DELETE OR INSERT OR UPDATE ON Vista1
    FOR EACH ROW
    EXECUTE FUNCTION fn_tri_Vista1();

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



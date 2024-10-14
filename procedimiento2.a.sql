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
        RAISE NOTICE 'Facturas correctamente generadas para servicios periodicos en el dia de la fecha : ',fecha_facturacion;
END;
    $$;
-------------------------------------------------------------








INSERT INTO TipoComprobante (id_tcomp, nombre, tipo) VALUES
                                                         (1, 'Factura A', 'Venta'),
                                                         (2, 'Factura B', 'Venta'),
                                                         (3, 'Factura C', 'Venta'),
                                                         (4, 'Nota de Crédito A', 'Devolución'),
                                                         (5, 'Nota de Crédito B', 'Devolución'),
                                                         (6, 'Nota de Crédito C', 'Devolución'),
                                                         (7, 'Nota de Débito A', 'Ajuste'),
                                                         (8, 'Nota de Débito B', 'Ajuste'),
                                                         (9, 'Nota de Débito C', 'Ajuste');

INSERT INTO Persona (id_persona, tipo, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, activo) VALUES
    (1, 'Fisica', 'DNI', '12345678', 'Juan', 'Pérez', '1985-05-10', true);

INSERT INTO Cliente (id_cliente, saldo) VALUES
    (1, 1000.000);

INSERT INTO Lugar (id_lugar, nombre) VALUES
    (1, 'Sucursal Central');

INSERT INTO Comprobante (id_comp, id_tcomp, fecha, comentario, estado, fecha_vencimiento, importe, id_cliente, id_lugar) VALUES
                                                                                                                             (1, 1, '2024-09-01 10:00:00', 'Venta de productos', 'Pagado', '2024-10-01 10:00:00', 5000.50, 1, 1),
                                                                                                                             (2, 1, '2024-09-01 11:00:00', 'Venta de productos', 'Pendiente', '2024-10-01 11:00:00', 3000.00, 1, 1),
                                                                                                                             (3, 2, '2024-09-01 12:00:00', 'Venta de productos', 'Pagado', '2024-10-01 12:00:00', 4500.75, 1, 1),
                                                                                                                             (4, 3, '2024-09-01 13:00:00', 'Venta de productos', 'Anulado', '2024-10-01 13:00:00', 5500.10, 1, 1),
                                                                                                                             (5, 4, '2024-09-01 14:00:00', 'Devolución de productos', 'Pagado', '2024-10-01 14:00:00',  2500.25, 1, 1),
                                                                                                                             (6, 5, '2024-09-01 15:00:00', 'Devolución de productos', 'Pendiente', '2024-10-01 15:00:00',  1500.50, 1, 1),
                                                                                                                             (7, 6, '2024-09-01 16:00:00', 'Devolución de productos', 'Pagado', '2024-10-01 16:00:00',  3500.00, 1, 1),
                                                                                                                             (8, 7, '2024-09-01 17:00:00', 'Ajuste de cuenta', 'Pagado', '2024-10-01 17:00:00',  7000.25, 1, 1),
                                                                                                                             (9, 8, '2024-09-01 18:00:00', 'Ajuste de cuenta', 'Anulado', '2024-10-01 18:00:00',  4000.50, 1, 1),
                                                                                                                             (10, 9, '2024-09-01 19:00:00', 'Ajuste de cuenta', 'Pendiente', '2024-10-01 19:00:00',  6000.75, 1, 1),
                                                                                                                             (11, 1, '2024-09-01 20:00:00', 'Venta de productos', 'Pagado', '2024-10-01 20:00:00',  1000.50, 1, 1),
                                                                                                                             (12, 1, '2024-09-02 10:00:00', 'Venta de productos', 'Pendiente', '2024-10-02 10:00:00',  3500.75, 1, 1),
                                                                                                                             (13, 2, '2024-09-02 11:00:00', 'Venta de productos', 'Pagado', '2024-10-02 11:00:00',  1500.10, 1, 1),
                                                                                                                             (14, 3, '2024-09-02 12:00:00', 'Venta de productos', 'Anulado', '2024-10-02 12:00:00',  500.50, 1, 1),
                                                                                                                             (15, 4, '2024-09-02 13:00:00', 'Devolución de productos', 'Pagado', '2024-10-02 13:00:00',  3500.25, 1, 1),
                                                                                                                             (16, 5, '2024-09-02 14:00:00', 'Devolución de productos', 'Pendiente', '2024-10-02 14:00:00',  2000.75, 1, 1),
                                                                                                                             (17, 6, '2024-09-02 15:00:00', 'Devolución de productos', 'Pagado', '2024-10-02 15:00:00',  5000.10, 1, 1),
                                                                                                                             (18, 7, '2024-09-02 16:00:00', 'Ajuste de cuenta', 'Pagado', '2024-10-02 16:00:00',  6500.50, 1, 1),
                                                                                                                             (19, 8, '2024-09-02 17:00:00', 'Ajuste de cuenta', 'Anulado', '2024-10-02 17:00:00', 4500.25, 1, 1),
                                                                                                                             (20, 9, '2024-09-02 18:00:00', 'Ajuste de cuenta', 'Pendiente', '2024-10-02 18:00:00', 5500.75, 1, 1);


INSERT INTO LineaComprobante (nro_linea, id_comp, id_tcomp, descripcion, cantidad, importe) VALUES
                                                                                                (1, 1, 1, 'Producto A', 2, 1000.50),
                                                                                                (2, 2, 1, 'Producto B', 3, 1500.00),
                                                                                                (3, 3, 2, 'Producto C', 1, 4500.75),
                                                                                                (4, 4, 3, 'Producto D', 2, 2750.05),
                                                                                                (5, 5, 4, 'Producto E', 1, 2500.25),
                                                                                                (6, 6, 5, 'Producto F', 3, 500.50),
                                                                                                (7, 7, 6, 'Producto G', 1, 3500.00),
                                                                                                (8, 8, 7, 'Producto H', 4, 1750.25),
                                                                                                (9, 9, 8, 'Producto I', 2, 2000.50),
                                                                                                (10, 10, 9, 'Producto J', 1, 3000.75),
                                                                                                (11, 11, 1, 'Producto K', 3, 1000.50),
                                                                                                (12, 12, 1, 'Producto L', 2, 1750.00),
                                                                                                (13, 13, 2, 'Producto M', 4, 1000.10),
                                                                                                (14, 14, 3, 'Producto N', 2, 500.50),
                                                                                                (15, 15, 4, 'Producto O', 3, 1500.25),
                                                                                                (16, 16, 5, 'Producto P', 2, 1000.75),
                                                                                                (17, 17, 6, 'Producto Q', 1, 5000.10),
                                                                                                (18, 18, 7, 'Producto R', 3, 3250.50),
                                                                                                (19, 19, 8, 'Producto S', 1, 4500.25),
                                                                                                (20, 20, 9, 'Producto T', 4, 1375.75);
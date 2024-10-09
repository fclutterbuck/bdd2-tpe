--Las personas que no están activas deben tener establecida una fecha de baja,
--la cual se debe controlar que sea al menos 6 meses posterior a la de su alta

ALTER TABLE Persona
    ADD CONSTRAINT Persona_fecha_baja
        CHECK (activo = TRUE and fecha_baja >= fecha_alta + interval '6 months'); --NO ME SUENA. VER CON TRIGGER

/*
 El importe de un comprobante debe coincidir con el total de los importes
 indicados en las líneas que lo conforman (si las tuviera).
 */
/*
 de forma declarativa. no funciona en postrgreSQL

create assertion importe_comprobantes
check ( not exists ( select 1 from comprobante c
                     where importe != (select sum(importe)
                                        from lineacomprobante lc
                                        where c.id_comp = lc.id_comp and c.id_tcomp = lc.id_tcomp)
       ))
*/
create or replace function fn_actualizar_importe_comprobante()
    returns trigger as $$
begin
    if (exists(select 1 from lineacomprobante where id_comp=new.id_comp and id_tcomp=new.id_tcomp)) and
    (new.importe != (select sum(importe) from lineacomprobante where id_comp=new.id_comp and id_tcomp=new.id_tcomp))
        then
            raise exception 'El importe ingresado no coincide con el total de importes de sus lineas';
    end if;
end;
$$language 'plpgsql';

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
    end;
    $$language 'plpgsql';

create or replace trigger tri_importes_lineacomprobante
    after insert or delete or update of importe,id_comp,id_tcomp on lineacomprobante
    for each row
    execute function fn_actualizar_importe_linea();



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



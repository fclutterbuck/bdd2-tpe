--Las personas que no están activas deben tener establecida una fecha de baja,
--la cual se debe controlar que sea al menos 6 meses posterior a la de su alta

ALTER TABLE Persona
ADD CONSTRAINT Persona_fecha_baja
CHECK (activo = TRUE and fecha_baja >= fecha_alta + interval '6 months'); --NO ME SUENA. VER CON TRIGGER

ALTER TABLE Persona
ADD CONSTRAINT Persona_fecha_baja
CHECK ((activo = TRUE) OR (fecha_baja >= fecha_alta + interval '6 months'); -- VERSION FEDE. ME SUENA INCREIBLE

--Pasados los 6 meses de su alta, en cualquier momento el cliente puede solicitar la baja,
-- quedando entonces inactivo, siempre y cuando no adeude ningún servicio.

CREATE OR REPLACE FUNCTION check_baja_voluntaria() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.activo = TRUE THEN
        IF EXISTS (SELECT 1
                   FROM Equipo E
                   JOIN Cliente c USING(id_cliente) --NO SE SI ES LO EFICIENTE
                   WHERE E.id_cliente = NEW.id_persona AND E.fecha_baja IS NULL AND C.saldo > 0) THEN
            RAISE EXCEPTION 'No se puede dar de baja a una persona que adeuda servicios';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_baja_voluntaria
BEFORE UPDATE OF activo ON Persona
FOR EACH STATEMENT FUNCTION check_baja_voluntaria();

--El importe de un comprobante debe coincidir con el total de los importes
-- indicados en las líneas que lo conforman (si las tuviera).
ALTER TABLE Comprobante
ADD CONSTRAINT Comprobante_importe CHECK (importe = (SELECT SUM(l.importe)
                                                    FROM LineaComprobante l
                                                    JOIN COMPROBANTE c USING(id_comp, id_tcomp);

--El importe de un comprobante debe coincidir con el total
-- de los importes indicados en las líneas que lo conforman (si las tuviera).
CREATE OR REPLACE FUNCTION check_importe_comprobante() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.importe != (SELECT SUM(l.importe)
                       FROM LineaComprobante l
                       WHERE l.id_comp = NEW.id_comp AND l.id_tcomp = NEW.id_tcomp) AND EXISTS(SELECT 1
                                                                                               FROM lineacomprobante l
                                                                                               WHERE l.id_comp = NEW.id_comp AND l.id_tcomp = NEW.id_tcomp )--VER SI NO TUVIERA LINEAS
    THEN
        RAISE EXCEPTION 'El importe de un comprobante debe coincidir con el total de  los importes indicados en las líneas que lo conforman';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
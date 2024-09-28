--Las personas que no están activas deben tener establecida una fecha de baja,
--la cual se debe controlar que sea al menos 6 meses posterior a la de su alta

ALTER TABLE Persona
ADD CONSTRAINT Persona_fecha_baja CHECK (activo = TRUE and fecha_baja >= fecha_alta + interval '6 months');

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
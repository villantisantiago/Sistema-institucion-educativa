USE InstitucionEducativa;
GO




-- Tabla para registrar la auditoría de modificaciones en los recibos de sueldo.
IF OBJECT_ID('Administrativo.Auditoria_Sueldo_Recibo', 'U') IS NULL
BEGIN
    CREATE TABLE Administrativo.Auditoria_Sueldo_Recibo (
        id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
        id_recibo INT NOT NULL,
        id_profesor INT NULL,
        id_empleado INT NULL,
        sueldo_anterior DECIMAL(10, 2) NOT NULL,
        sueldo_nuevo DECIMAL(10, 2) NOT NULL,
        fecha_modificacion DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO




-- Validar que la nota esté entre 0 y 10, y si el examen final es >= 4 pasar la cursada a 'Aprobado'.
CREATE OR ALTER TRIGGER Academico.trgNota_insert
ON Academico.Nota
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE valor < 0 OR valor > 10)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50020, 'La nota debe estar entre 0 y 10.', 1;
    END;

    UPDATE c
    SET estado = 'Aprobado'
    FROM Academico.Cursada c INNER JOIN inserted i ON c.id_cursada = i.id_cursada
    WHERE i.instancia = 'Final' AND i.valor >= 4;
END;
GO




-- Evitar que un alumno se inscriba a dos cursos el mismo día y en el mismo turno dentro de un mismo cuatrimestre.
CREATE OR ALTER TRIGGER Academico.trgCursada_insert
ON Academico.Cursada
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i INNER JOIN Academico.Curso ci ON i.id_curso = ci.id_curso
        INNER JOIN Academico.Cursada c ON i.legajo = c.legajo AND i.id_cursada <> c.id_cursada
        INNER JOIN Academico.Curso cc ON c.id_curso = cc.id_curso
        WHERE ci.id_cuatrimestre = cc.id_cuatrimestre AND ci.dia = cc.dia AND ci.turno = cc.turno
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50021, 'El alumno ya está inscripto en un curso en ese día y turno.', 1;
    END;
END;
GO




-- Registrar en auditoría las modificaciones de sueldo realizadas en los recibos.
CREATE OR ALTER TRIGGER Administrativo.trgReciboSueldo_auditoria
ON Administrativo.Recibo_Sueldo
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Administrativo.Auditoria_Sueldo_Recibo (id_recibo, id_profesor, id_empleado, sueldo_anterior, sueldo_nuevo)
    SELECT i.id_recibo, i.id_profesor, i.id_empleado, d.sueldo_bruto, i.sueldo_bruto
    FROM inserted i INNER JOIN deleted d ON i.id_recibo = d.id_recibo
    WHERE d.sueldo_bruto <> i.sueldo_bruto;
END;
GO




-- Validar que la hora de salida sea estrictamente posterior a la de ingreso en los fichajes.
CREATE OR ALTER TRIGGER Administrativo.trgFichaje_insert
ON Administrativo.Fichaje
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE hora_salida <= hora_ingreso)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50022, 'La hora de salida debe ser posterior a la de ingreso.', 1;
    END;
END;
GO
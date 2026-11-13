USE InstitucionEducativa;
GO



-- Mostrar los alumnos inscriptos en un curso
DECLARE @id_curso INT = 1; 
SELECT
    a.legajo,
    a.apellido,
    a.nombre
FROM Academico.Cursada AS cu
JOIN Academico.Alumno AS a ON cu.legajo = a.legajo
WHERE cu.id_curso = @id_curso
ORDER BY a.apellido, a.nombre;


-- Contar la cantidad de cursadas en cada estado
SELECT
    estado,
    COUNT(*) AS cantidad_cursadas
FROM Academico.Cursada
GROUP BY estado
ORDER BY estado;


-- Mostrar empleados cuyo sueldo neto promedio supera el promedio de los empleados
;WITH SueldoPromedioPorEmpleado AS (
    SELECT
        e.id_empleado,
        e.apellido,
        e.nombre,
        AVG(r.sueldo_bruto - r.descuentos) AS sueldo_neto_promedio
    FROM Administrativo.Empleado AS e
    JOIN Administrativo.Recibo_Sueldo AS r ON r.id_empleado = e.id_empleado
    GROUP BY e.id_empleado, e.apellido, e.nombre
)
SELECT
    id_empleado,
    apellido,
    nombre,
    sueldo_neto_promedio
FROM SueldoPromedioPorEmpleado
WHERE sueldo_neto_promedio > (
    SELECT AVG(sueldo_neto_promedio)
    FROM SueldoPromedioPorEmpleado
)
ORDER BY sueldo_neto_promedio DESC;


-- Calcular el total neto pagado en cada liquidación
SELECT
    l.anio,
    l.mes,
    COALESCE(SUM(r.sueldo_bruto - r.descuentos), 0) AS total_neto_pagado
FROM Administrativo.Liquidacion AS l
LEFT JOIN Administrativo.Recibo_Sueldo AS r ON r.id_liquidacion = l.id_liquidacion
GROUP BY l.anio, l.mes
ORDER BY l.anio, l.mes;


GO
IF OBJECT_ID(N'Administrativo.Auditoria_Sueldo_Recibo', N'U') IS NULL
BEGIN
    CREATE TABLE Administrativo.Auditoria_Sueldo_Recibo (
        id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
        id_recibo INT NOT NULL,
        id_profesor INT NOT NULL,
        sueldo_anterior DECIMAL(10, 2) NOT NULL,
        sueldo_nuevo DECIMAL(10, 2) NOT NULL,
        fecha_modificacion DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
IF COL_LENGTH(N'Administrativo.Auditoria_Sueldo_Recibo', N'id_profesor') IS NULL
    ALTER TABLE Administrativo.Auditoria_Sueldo_Recibo ADD id_profesor INT NULL;
GO

CREATE OR ALTER TRIGGER Academico.trg_Nota_Insert
ON Academico.Nota
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE valor < 0 OR valor > 10)
    BEGIN
        RAISERROR('La nota debe estar entre 0 y 10.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    UPDATE c
    SET estado = 'Aprobado'
    FROM Academico.Cursada c
    JOIN inserted i ON i.id_cursada = c.id_cursada
    WHERE i.instancia = 'Final' AND i.valor >= 4;
END;
GO

CREATE OR ALTER TRIGGER Academico.trg_Cursada_Insert
ON Academico.Cursada
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Academico.Curso ci ON ci.id_curso = i.id_curso
        JOIN Academico.Cursada c ON c.legajo = i.legajo AND c.id_cursada <> i.id_cursada
        JOIN Academico.Curso cc ON cc.id_curso = c.id_curso
        WHERE ci.id_cuatrimestre = cc.id_cuatrimestre
          AND ci.dia = cc.dia
          AND ci.turno = cc.turno
    )
    BEGIN
        RAISERROR('El alumno ya está inscripto en un curso en ese día y turno.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

CREATE OR ALTER TRIGGER Administrativo.trg_ReciboSueldo_Auditoria
ON Administrativo.Recibo_Sueldo
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Administrativo.Auditoria_Sueldo_Recibo (id_recibo, id_profesor, sueldo_anterior, sueldo_nuevo)
    SELECT i.id_recibo, COALESCE(i.id_profesor, d.id_profesor), d.sueldo_bruto, i.sueldo_bruto
    FROM inserted i
    JOIN deleted d ON d.id_recibo = i.id_recibo
    WHERE d.sueldo_bruto <> i.sueldo_bruto
      AND COALESCE(i.id_profesor, d.id_profesor) IS NOT NULL;
END;
GO

CREATE OR ALTER TRIGGER Administrativo.trg_Fichaje_Insert
ON Administrativo.Fichaje
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE hora_salida <= hora_ingreso)
    BEGIN
        RAISERROR('La hora de salida debe ser posterior a la de ingreso.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO
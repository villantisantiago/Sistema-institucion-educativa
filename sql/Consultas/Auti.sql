USE InstitucionEducativa;
GO




-- Mostrar cada materia junto a sus materias correlativas (necesitás unir Materia consigo misma).
SELECT  m1.nombre AS Materia, m2.nombre AS MateriaCorrelativa
FROM Academico.Materia m1
INNER JOIN Academico.Correlativa c ON m1.id_materia = c.id_materia
INNER JOIN Academico.Materia m2 ON c.id_correlativa = m2.id_materia
GO





-- Mostrar los cursos que tienen más de cierta cantidad de alumnos inscriptos.
CREATE OR ALTER PROCEDURE Academico.spCursos_con_mas_alumnos @cantidad INT = 0
AS
BEGIN
SET NOCOUNT ON;
SELECT c.id_curso, m.nombre as materia, c.dia, c.turno, c.aula, COUNT(cu.legajo) AS cantidadInscriptos
FROM Academico.Curso c INNER JOIN Academico.Cursada cu ON c.id_curso = cu.id_curso
INNER JOIN Academico.Materia m ON c.id_materia = m.id_materia
GROUP BY c.id_curso, m.nombre, c.turno, c.dia, c.aula
HAVING COUNT(cu.legajo) > @cantidad
ORDER BY cantidadInscriptos DESC;
END;
GO


-- Contar cuántos cursos dicta cada profesor, incluyendo a los que no tienen ninguno.
CREATE OR ALTER VIEW Academico.vCursos_por_profesor
AS 
SELECT p.id_profesor, p.nombre, p.apellido, COUNT(c.id_curso) AS cantidadDeCursos
FROM Administrativo.Profesor p LEFT JOIN Academico.Curso c ON p.id_profesor = c.id_profesor
GROUP BY p.id_profesor, p.apellido, p.nombre
GO


-- Mostrar las materias que nunca se dictaron en ningún curso.
SELECT m.id_materia, m.nombre AS materia
FROM Academico.Materia m 
WHERE m.id_materia NOT IN(  
    SELECT DISTINCT id_materia 
    FROM Academico.Curso );
GO


-- Listar los recibos de una liquidación (mes y año dados) con el empleado, el sueldo bruto, los descuentos y el sueldo neto calculado.
CREATE OR ALTER PROCEDURE Administrativo.spRecibos_por_fecha @mes INT, @anio INT
AS
BEGIN
SET NOCOUNT ON;
SELECT r.id_recibo, r.id_empleado, r.id_profesor, (r.sueldo_bruto - r.descuentos) AS SueldoNeto,
COALESCE(e.apellido + ', ' + e.nombre, p.apellido + ', ' + p.nombre) AS Persona,
    CASE
        WHEN r.id_empleado IS NOT NULL THEN 'Personal Administrativo'
        ELSE 'Docente'
    END AS TipoPersonal
FROM Administrativo.Recibo_Sueldo r INNER JOIN
Administrativo.Liquidacion l ON r.id_liquidacion = l.id_liquidacion
LEFT JOIN Administrativo.Empleado e ON e.id_empleado = r.id_empleado
LEFT JOIN Administrativo.Profesor p on p.id_profesor = r.id_profesor
WHERE l.mes = @mes AND l.anio = @anio
END;
GO


CREATE OR ALTER PROCEDURE Academico.spInscribir_alumno_a_curso
@legajo INT, @id_curso INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Academico.Alumno WHERE @legajo = legajo)
            THROW 50001, 'El alumno no existe', 1;
        IF NOT EXISTS (SELECT 1 FROM Academico.Curso WHERE @id_curso = id_curso)
            THROW 50002, 'El curso no existe', 1;
        IF EXISTS (SELECT 1 FROM Academico.Cursada WHERE @legajo = legajo AND @id_curso = id_curso)
            THROW 50003, 'El alumno ya esta registrado en el curso', 1;
        DECLARE @id_materia INT;
        SELECT @id_materia = id_materia
        FROM Academico.Curso
        WHERE id_curso = @id_curso;
        IF EXISTS (
            SELECT c.id_correlativa
            FROM Academico.Correlativa c
            WHERE c.id_materia = @id_materia AND c.id_correlativa NOT IN (
                SELECT cur.id_materia
                FROM Academico.Cursada cd INNER JOIN Academico.Curso cur ON cd.id_curso = cur.id_curso
                WHERE cd.legajo = @legajo AND cd.estado = 'Aprobado')
        )
            THROW 50004, 'El alumno no cumple con las correlativas', 1;
        BEGIN TRANSACTION;
        INSERT INTO Academico.Cursada (legajo, id_curso, estado)
        VALUES (@legajo, @id_curso, 'Cursando');
        COMMIT TRANSACTION;
        PRINT 'Inscripción realizada exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Academico.spCargar_nota 
@id_cursada INT , @instancia VARCHAR(20) , @valor DECIMAL(3, 1), @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM Academico.cursada WHERE @id_cursada = id_cursada)
        THROW 50005, 'No existe la cursada', 1;
    IF (@valor < 0 OR @valor > 10)
        THROW 50006, 'El valor de la nota es incorrecto', 1;
    IF (@instancia NOT IN ('Parcial', 'Final', 'Recuperatorio'))
        THROW 50007, 'La instancia debe ser Parcial, Final o Recuperatorio.', 1;
    IF (@instancia = 'Final')
    BEGIN 
    DECLARE @estado_cursada NVARCHAR(20);
    SELECT @estado_cursada = estado
    FROM Academico.Cursada
    WHERE @id_cursada = id_cursada;
    IF NOT (@estado_cursada = 'Aprobado')
        THROW 50008, 'No se permite rendir un final sin tener la instancia aprobada', 1;
    END
    BEGIN TRANSACTION;
    INSERT INTO Academico.Nota(id_cursada, instancia, valor, fecha)
    VALUES (@id_cursada, @instancia, @valor, @fecha)
    COMMIT TRANSACTION;
    PRINT 'Se ha cargado la nota de forma correcta';

    END TRY
    BEGIN CATCH 
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE Administrativo.spGenerar_liquidacion
@mes INT, @anio INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY 
    IF (@mes <= 0 OR @mes >= 12)
        THROW 50010, 'El mes ingresado es incorrecto', 1;
    IF (@anio < 2000 OR @anio > 2100)
        THROW 50011, 'El año ingresado es incorrecto', 1;
    IF EXISTS (SELECT 1 FROM Administrativo.Liquidacion WHERE @mes = mes AND @anio = anio)
        THROW 50012, 'Ya existe una liquidacion para este mes', 1;
    BEGIN TRANSACTION;
    INSERT INTO Administrativo.Liquidacion(fecha_pago, mes, anio)
    VALUES (CAST(GETDATE() AS DATE), @mes, @anio);

    DECLARE @id_liquidacion INT;
    SET @id_liquidacion = SCOPE_IDENTITY();
    INSERT INTO Administrativo.Recibo_Sueldo(id_empleado, id_liquidacion, id_profesor, sueldo_bruto, descuentos, fecha, monto)
    SELECT e.id_empleado, @id_liquidacion, NULL, e.sueldo, ROUND(e.sueldo * 0.17, 2), CAST(GETDATE() AS DATE), ROUND(e.sueldo - (e.sueldo * 0.17), 2)
    FROM Administrativo.Empleado;
    INSERT INTO Administrativo.Recibo_Sueldo (id_liquidacion, id_empleado, id_profesor, sueldo_bruto, descuentos, fecha, monto)
    SELECT @id_liquidacion, NULL, p.id_profesor, p.sueldo, ROUND(p.sueldo * 0.17, 2), CAST(GETDATE() AS DATE), ROUND(p.sueldo - (p.sueldo * 0.17), 2) 
    FROM Administrativo.Profesor p;
    COMMIT TRANSACTION;
        PRINT 'Se han generado la liquidación y los recibos';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO





    






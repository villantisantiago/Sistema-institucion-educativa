USE InstitucionEducativa;
GO

-- fn_promedio_alumno(@legajo): devuelve el promedio de las notas del alumno.
CREATE FUNCTION Academico.fn_promedio_alumno(@legajo INT)
RETURNS DECIMAL(4,2) AS 
BEGIN
    DECLARE @promedio DECIMAL(4,2)

    SELECT @promedio = AVG(n.valor)
    FROM Academico.Nota AS n
    JOIN Academico.Cursada AS c ON c.id_cursada = n.id_cursada
    WHERE c.legajo = @legajo;

    RETURN @promedio
END
GO;


-- Calcular la cantidad total de materias que tiene aprobadas un alumno.
CREATE OR ALTER FUNCTION Academico.fnMaterias_aprobadas_alumno (@legajo INT)
RETURNS INT
AS
BEGIN
    DECLARE @cantidad INT;
    SELECT @cantidad = COUNT(DISTINCT cur.id_materia)
    FROM Academico.Cursada cd INNER JOIN Academico.Curso cur ON cd.id_curso = cur.id_curso
    WHERE cd.legajo = @legajo AND cd.estado = 'Aprobado';
    RETURN ISNULL(@cantidad, 0);
END;
GO
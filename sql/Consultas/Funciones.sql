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
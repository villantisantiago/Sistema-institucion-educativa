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
GO


-- Calcular el sueldo neto a cobrar de un recibo descontando las retenciones al sueldo bruto.
CREATE OR ALTER FUNCTION Administrativo.fnSueldo_neto_recibo (@id_recibo INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @neto DECIMAL(10, 2);
    SELECT @neto = (r.sueldo_bruto - r.descuentos)
    FROM Administrativo.Recibo_Sueldo r
    WHERE r.id_recibo = @id_recibo;
    RETURN ISNULL(@neto, 0);
END;
GO

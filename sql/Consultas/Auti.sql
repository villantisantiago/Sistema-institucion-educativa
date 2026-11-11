USE InstitucionEducativa;
GO




-- Mostrar cada materia junto a sus materias correlativas (necesitás unir Materia consigo misma).
SELECT  m1.nombre AS Materia, m2.nombre AS MateriaCorrelativa
FROM Academico.Materia m1
INNER JOIN Academico.Correlativa c ON m1.id_materia = c.id_materia
INNER JOIN Academico.Materia m2 ON c.id_correlativa = m2.id_materia
GO


-- Mostrar los cursos que tienen más de cierta cantidad de alumnos inscriptos.
CREATE OR ALTER PROCEDURE Academico.spCursosConMasAlumnos @cantidad INT = 0
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
CREATE OR ALTER VIEW Academico.vCursosPorProfesor
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
CREATE OR ALTER PROCEDURE Administrativo.spRecibosPorFecha @mes INT, @anio INT
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
G







USE InstitucionEducativa;
GO



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


CREATE OR ALTER VIEW Academico.vCursosPorProfesor
AS 
SELECT p.id_profesor, p.nombre, p.apellido, COUNT(c.id_curso) AS cantidadDeCursos
FROM Administrativo.Profesor p LEFT JOIN Academico.Curso c ON p.id_profesor = c.id_profesor
GROUP BY p.id_profesor, p.apellido, p.nombre
GO


SELECT m.id_materia, m.nombre AS materia
FROM Academico.Materia m 
WHERE m.id_materia NOT IN(  
    SELECT DISTINCT id_materia 
    FROM Academico.Curso );




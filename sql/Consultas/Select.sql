USE InstitucionEducativa;
GO



-- Mostrar cada materia junto a sus materias correlativas (necesitás unir Materia consigo misma).
SELECT  m1.nombre AS Materia, m2.nombre AS MateriaCorrelativa
FROM Academico.Materia m1
INNER JOIN Academico.Correlativa c ON m1.id_materia = c.id_materia
INNER JOIN Academico.Materia m2 ON c.id_correlativa = m2.id_materia
GO


-- Contar la cantidad de cursadas en cada estado
SELECT
    estado,
    COUNT(*) AS cantidad_cursadas
FROM Academico.Cursada
GROUP BY estado
ORDER BY estado;


-- Cantidad de alumnos por carrera

SELECT c.nombre AS carrera, COUNT(DISTINCT i.legajo) AS cantidad_alumnos
FROM Academico.Carrera c
LEFT JOIN Academico.Inscripcion i ON i.id_carrera = c.id_carrera
GROUP BY c.id_carrera, c.nombre
ORDER BY c.nombre;


-- Listar cada alumno con la carrera en la que está inscripto y el estado de esa inscripción
SELECT a.legajo, a.nombre, a.apellido, c.nombre, i.estado 
FROM Academico.Alumno AS a 
JOIN Academico.Inscripcion AS i ON a.legajo = i.legajo
JOIN Academico.Carrera AS c ON i.id_carrera = c.id_carrera;




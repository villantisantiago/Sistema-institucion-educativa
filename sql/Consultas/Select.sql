USE InstitucionEducativa;
GO

-- Mostrar cada materia junto a sus materias correlativas (necesitás unir Materia consigo misma).
SELECT  m1.nombre AS Materia, m2.nombre AS MateriaCorrelativa
FROM Academico.Materia m1
INNER JOIN Academico.Correlativa c ON m1.id_materia = c.id_materia
INNER JOIN Academico.Materia m2 ON c.id_correlativa = m2.id_materia
GO

-- Contar la cantidad de cursadas en cada estado
SELECT estado, COUNT(*) AS cantidad_cursadas
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

-- Listar las materias de cada carrera, con su carga horaria, ordenadas por carrera y materia.
SELECT c.nombre AS carrera, m.nombre AS materia, m.carga_horaria
FROM Academico.Carrera c
INNER JOIN Academico.Carrera_Materia cm ON c.id_carrera = cm.id_carrera
INNER JOIN Academico.Materia m ON cm.id_materia = m.id_materia
ORDER BY c.nombre, m.nombre;

--Profesores sin ningún curso asignado
SELECT p.id_profesor, p.apellido, p.nombre
FROM Administrativo.Profesor p
LEFT JOIN Academico.Curso c
    ON p.id_profesor = c.id_profesor
WHERE c.id_curso IS NULL;

--Cantidad de empleados por sector, incluyendo sectores vacíos
SELECT s.nombre AS sector, COUNT(e.id_empleado) AS cantidad_empleados
FROM Administrativo.Sector s
LEFT JOIN Administrativo.Empleado e ON e.id_sector = s.id_sector
GROUP BY s.id_sector, s.nombre
ORDER BY s.nombre;

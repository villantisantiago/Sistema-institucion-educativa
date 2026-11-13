USE InstitucionEducativa;
GO

-- Listar las materias de cada carrera, con su carga horaria, ordenadas por carrera y materia.

SELECT c.nombre AS carrera, m.nombre AS materia, m.carga_horaria
FROM Academico.Carrera c
JOIN Academico.Carrera_Materia cm ON cm.id_carrera = c.id_carrera
JOIN Academico.Materia m ON m.id_materia = cm.id_materia
ORDER BY c.nombre, m.nombre;

-- Cantidad de alumnos por carrera

SELECT c.nombre AS carrera, COUNT(DISTINCT i.legajo) AS cantidad_alumnos
FROM Academico.Carrera c
LEFT JOIN Academico.Inscripcion i ON i.id_carrera = c.id_carrera
GROUP BY c.id_carrera, c.nombre
ORDER BY c.nombre;

--Alumnos con promedio mayor al promedio general de todas las notas

SELECT a.legajo, a.apellido, a.nombre, AVG(CAST(n.valor AS DECIMAL(10, 4))) AS promedio
FROM Academico.Alumno a
JOIN Academico.Cursada cu ON cu.legajo = a.legajo
JOIN Academico.Nota n ON n.id_cursada = cu.id_cursada
GROUP BY a.legajo, a.apellido, a.nombre
HAVING AVG(CAST(n.valor AS DECIMAL(10, 4))) > (SELECT AVG(CAST(valor AS DECIMAL(10, 4))) FROM Academico.Nota)
ORDER BY promedio DESC;

--Profesores sin ningún curso asignado
SELECT p.id_profesor, p.apellido, p.nombre
FROM Administrativo.Profesor p
WHERE NOT EXISTS (
    SELECT 1
    FROM Academico.Curso cu
    WHERE cu.id_profesor = p.id_profesor
)
ORDER BY p.apellido, p.nombre;

--Cantidad de empleados por sector, incluyendo sectores vacíos

SELECT s.nombre AS sector, COUNT(e.id_empleado) AS cantidad_empleados
FROM Administrativo.Sector s
LEFT JOIN Administrativo.Empleado e ON e.id_sector = s.id_sector
GROUP BY s.id_sector, s.nombre
ORDER BY s.nombre;

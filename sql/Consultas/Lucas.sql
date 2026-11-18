USE InstitucionEducativa;
GO

-- Listar las materias de cada carrera, con su carga horaria, ordenadas por carrera y materia.

SELECT c.nombre AS carrera, m.nombre AS materia, m.carga_horaria
FROM Academico.Carrera c
INNER JOIN Academico.Carrera_Materia cm ON c.id_carrera = cm.id_carrera
INNER JOIN Academico.Materia m ON cm.id_materia = m.id_materia
ORDER BY c.nombre, m.nombre;

-- Cantidad de alumnos por carrera

SELECT c.nombre AS carrera, COUNT(DISTINCT i.legajo) AS cantidad_alumnos
FROM Academico.Carrera c
LEFT JOIN Academico.Inscripcion i ON i.id_carrera = c.id_carrera
GROUP BY c.id_carrera, c.nombre
ORDER BY c.nombre;

--Alumnos con promedio mayor al promedio general de todas las notas

SELECT a.legajo, a.apellido, a.nombre, AVG(n.valor) AS promedio
FROM Academico.Alumno a
JOIN Academico.Cursada cu ON cu.legajo = a.legajo
JOIN Academico.Nota n ON n.id_cursada = cu.id_cursada
GROUP BY a.legajo, a.apellido, a.nombre
HAVING AVG(n.valor) > (
    SELECT AVG(valor)
    FROM Academico.Nota
)
ORDER BY promedio DESC;

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

-- Alumnos inscriptos en cursos de materias que su carga horaria supera el promedio de todas las materias.

SELECT DISTINCT a.legajo, a.apellido, a.nombre
FROM Academico.Alumno a
JOIN Academico.Cursada cu ON a.legajo = cu.legajo
JOIN Academico.Curso c ON cu.id_curso = c.id_curso
JOIN Academico.Materia m ON c.id_materia = m.id_materia
WHERE m.carga_horaria > (
    SELECT AVG(CAST(carga_horaria AS DECIMAL(10, 2)))
    FROM Academico.Materia
)
ORDER BY a.apellido, a.nombre;

--Profesor (o profesores) con la mayor cantidad de cursos asignados

SELECT p.id_profesor, p.apellido, p.nombre, COUNT(c.id_curso) AS cantidad_cursos
FROM Administrativo.Profesor p
LEFT JOIN Academico.Curso c ON p.id_profesor = c.id_profesor
GROUP BY p.id_profesor, p.apellido, p.nombre
HAVING COUNT(c.id_curso) >= ALL (
    SELECT COUNT(c2.id_curso)
    FROM Administrativo.Profesor p2
    LEFT JOIN Academico.Curso c2 ON p2.id_profesor = c2.id_profesor
    GROUP BY p2.id_profesor
)
ORDER BY p.apellido, p.nombre;

--Materias cuyo promedio de notas es mayor al promedio general 

SELECT m.id_materia, m.nombre AS materia, AVG(n.valor) AS promedio_materia
FROM Academico.Materia m
JOIN Academico.Curso c ON m.id_materia = c.id_materia
JOIN Academico.Cursada cu ON c.id_curso = cu.id_curso
JOIN Academico.Nota n ON cu.id_cursada = n.id_cursada
GROUP BY m.id_materia, m.nombre
HAVING AVG(n.valor) > (
    SELECT AVG(valor)
    FROM Academico.Nota
)
ORDER BY promedio_materia DESC;

--Alumnos que no tienen ninguna cursada desaprobada

SELECT a.legajo, a.apellido, a.nombre
FROM Academico.Alumno a
WHERE NOT EXISTS (
    SELECT 1
    FROM Academico.Cursada cu
    WHERE cu.legajo = a.legajo AND cu.estado = 'Desaprobado'
)
ORDER BY a.apellido, a.nombre;

--Cursos con más inscriptos que el promedio de inscriptos por curso.

SELECT c.id_curso, m.nombre AS materia, COUNT(cu.id_cursada) AS cantidad_inscriptos
FROM Academico.Curso c
JOIN Academico.Materia m ON c.id_materia = m.id_materia
LEFT JOIN Academico.Cursada cu ON c.id_curso = cu.id_curso
GROUP BY c.id_curso, m.nombre
HAVING COUNT(cu.id_cursada) > (
    SELECT AVG(CAST(cantidad AS DECIMAL(10, 2)))
    FROM (
        SELECT COUNT(cu2.id_cursada) AS cantidad
        FROM Academico.Curso c2
        LEFT JOIN Academico.Cursada cu2 ON c2.id_curso = cu2.id_curso
        GROUP BY c2.id_curso
    ) AS conteo
)
ORDER BY cantidad_inscriptos DESC;


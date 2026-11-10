USE InstitucionEducativa;
GO

-- Listar cada alumno con la carrera en la que está inscripto y el estado de esa inscripción
SELECT a.legajo, a.nombre, a.apellido, c.nombre, i.estado 
FROM Academico.Alumno AS a 
JOIN Academico.Inscripcion AS i ON a.legajo = i.legajo
JOIN Academico.Carrera AS c ON i.id_carrera = c.id_carrera;


-- calcular el promedio de notas por materia
SELECT m.nombre, AVG(n.valor) as promedio
FROM Academico.Nota AS n
JOIN Academico.Cursada AS cursada ON n.id_cursada = cursada.id_cursada
JOIN Academico.Curso AS curso ON cursada.id_curso = curso.id_curso
JOIN Academico.Materia AS m ON curso.id_materia = m.id_materia
GROUP BY m.nombre
ORDER BY promedio DESC;


-- mostrar los alumnos que no tienen ninguna nota cargada
SELECT a.Legajo, a.apellido, a.nombre
FROM Academico.Alumno AS a 
WHERE NOT EXISTS(
    SELECT 1
    FROM Academico.cursada as cursada
    JOIN Academico.Nota as n ON cursada.id_cursada = n.id_cursada
    WHERE a.legajo = cursada.legajo
);
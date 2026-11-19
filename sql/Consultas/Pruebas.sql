USE InstitucionEducativa;
GO




SELECT m1.nombre AS Materia, m2.nombre AS MateriaCorrelativa
FROM Academico.Materia m1 INNER JOIN Academico.Correlativa c ON m1.id_materia = c.id_materia
INNER JOIN Academico.Materia m2 ON c.id_correlativa = m2.id_materia;
GO




SELECT c.nombre AS carrera, COUNT(DISTINCT i.legajo) AS cantidad_alumnos
FROM Academico.Carrera c LEFT JOIN Academico.Inscripcion i ON i.id_carrera = c.id_carrera
GROUP BY c.id_carrera, c.nombre
ORDER BY cantidad_alumnos DESC;
GO




SELECT m.id_materia, m.nombre AS materia
FROM Academico.Materia m 
WHERE m.id_materia NOT IN (SELECT DISTINCT id_materia FROM Academico.Curso);
GO




SELECT p.id_profesor, p.apellido, p.nombre
FROM Administrativo.Profesor p
WHERE NOT EXISTS (SELECT 1 FROM Academico.Curso cu WHERE cu.id_profesor = p.id_profesor);
GO




SELECT a.legajo, a.apellido, a.nombre, AVG(n.valor) AS promedio
FROM Academico.Alumno a INNER JOIN Academico.Cursada cu ON cu.legajo = a.legajo
INNER JOIN Academico.Nota n ON n.id_cursada = cu.id_cursada
GROUP BY a.legajo, a.apellido, a.nombre
HAVING AVG(n.valor) > (SELECT AVG(valor) FROM Academico.Nota)
ORDER BY promedio DESC;
GO




SELECT * FROM Academico.vCursos_por_profesor;
GO




SELECT * FROM Academico.Vista_Cursos_Detalle;
GO




SELECT * FROM Academico.Vista_Alumnos_Por_Curso WHERE id_curso = 1;
GO




SELECT * FROM Administrativo.vTotal_liquidaciones;
GO




SELECT legajo, apellido, nombre, Academico.fn_promedio_alumno(legajo) AS promedio
FROM Academico.Alumno;
GO




SELECT id_recibo, sueldo_bruto, descuentos, Administrativo.fnSueldo_neto_recibo(id_recibo) AS sueldo_neto
FROM Administrativo.Recibo_Sueldo;
GO




EXEC Academico.spCursos_con_mas_alumnos @cantidad = 1;
GO




EXEC Administrativo.spRecibos_por_fecha @mes = 5, @anio = 2024;
GO




EXEC Academico.spAlumnos_en_riesgo;
GO




EXEC Academico.spReporte_ocupacion_cursos @anio = 2024, @cuatrimestre = 1;
GO




BEGIN TRANSACTION;
INSERT INTO Academico.Nota (id_cursada, instancia, valor, fecha)
VALUES (1, 'Final', 8.0, CAST(GETDATE() AS DATE));

SELECT id_cursada, legajo, estado FROM Academico.Cursada WHERE id_cursada = 1;
ROLLBACK TRANSACTION;
GO

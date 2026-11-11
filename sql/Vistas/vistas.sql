USE InstitucionEducativa;
GO

-- 1. Alumnos inscriptos en cada curso
CREATE VIEW Academico.Vista_Alumnos_Por_Curso AS
SELECT cs.id_curso, a.legajo, a.apellido, a.nombre
FROM Academico.Cursada AS cs
JOIN Academico.Alumno AS a ON a.legajo = cs.legajo;
GO

-- 2. Historial académico (incluye cursadas sin notas)
CREATE VIEW Academico.Vista_Historial_Academico AS
SELECT a.legajo, a.apellido, a.nombre, m.nombre AS materia, cs.estado AS estado_cursada, n.instancia, n.valor, n.fecha AS fecha_nota
FROM Academico.Alumno AS a
JOIN Academico.Cursada AS cs ON cs.legajo = a.legajo
JOIN Academico.Curso AS cu ON cu.id_curso = cs.id_curso
JOIN Academico.Materia AS m ON m.id_materia = cu.id_materia
LEFT JOIN Academico.Nota AS n ON n.id_cursada = cs.id_cursada;
GO

-- 3. Detalle de cursos
CREATE VIEW Academico.Vista_Cursos_Detalle AS
SELECT cu.id_curso, m.nombre AS materia, p.apellido AS apellido_profesor, p.nombre AS nombre_profesor, cu.dia, cu.turno, cu.aula, cq.anio, cq.cuatrimestre
FROM Academico.Curso AS cu
JOIN Academico.Materia AS m ON m.id_materia = cu.id_materia
JOIN Administrativo.Profesor AS p ON p.id_profesor = cu.id_profesor
JOIN Academico.Cuatrimestre AS cq ON cq.id_cuatrimestre = cu.id_cuatrimestre;
GO

-- 4. Promedio de notas por materia
CREATE VIEW Academico.Vista_Promedios_Por_Materia AS
SELECT m.id_materia, m.nombre AS materia, COUNT(n.id_nota) AS cantidad_notas, AVG(n.valor) AS promedio
FROM Academico.Materia AS m
JOIN Academico.Curso AS cu ON cu.id_materia = m.id_materia
JOIN Academico.Cursada AS cs ON cs.id_curso = cu.id_curso
JOIN Academico.Nota AS n ON n.id_cursada = cs.id_cursada
GROUP BY m.id_materia, m.nombre;
GO

-- 5. Recibos con la persona, la liquidación y el neto calculado
CREATE VIEW Administrativo.Vista_Recibos_Detalle AS
SELECT r.id_recibo, COALESCE(e.apellido, p.apellido) AS apellido, COALESCE(e.nombre, p.nombre) AS nombre,
CASE WHEN e.id_empleado IS NOT NULL THEN 'Empleado' ELSE 'Profesor' END AS tipo_persona, l.mes, l.anio, r.sueldo_bruto, r.descuentos, r.sueldo_bruto - r.descuentos AS sueldo_neto
FROM Administrativo.Recibo_Sueldo AS r
JOIN Administrativo.Liquidacion AS l ON l.id_liquidacion = r.id_liquidacion
LEFT JOIN Administrativo.Empleado AS e ON e.id_empleado = r.id_empleado
LEFT JOIN Administrativo.Profesor AS p ON p.id_profesor = r.id_profesor;
GO
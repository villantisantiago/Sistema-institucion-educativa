USE institucionEducativa;
GO



-- Contar cuántos cursos dicta cada profesor, incluyendo a los que no tienen ninguno.
CREATE OR ALTER VIEW Academico.vCursos_por_profesor
AS 
SELECT p.id_profesor, p.nombre, p.apellido, COUNT(c.id_curso) AS cantidadDeCursos
FROM Administrativo.Profesor p LEFT JOIN Academico.Curso c ON p.id_profesor = c.id_profesor
GROUP BY p.id_profesor, p.apellido, p.nombre
GO


-- Total neto abonado en cada liquidación mensual.
CREATE OR ALTER VIEW Administrativo.vTotal_liquidaciones
AS 
SELECT l.id_liquidacion, l.anio, l.mes, l.fecha_pago, COALESCE(SUM(r.sueldo_bruto - r.descuentos), 0) AS total_neto_pagado
FROM Administrativo.Liquidacion l LEFT JOIN Administrativo.Recibo_Sueldo r ON r.id_liquidacion = l.id_liquidacion
GROUP BY l.id_liquidacion, l.anio, l.mes, l.fecha_pago
GO


-- Listar las materias de cada carrera con su carga horaria.
CREATE OR ALTER VIEW Academico.vPlan_estudios_carreras
AS 
SELECT c.id_carrera, c.nombre AS carrera, m.id_materia, m.nombre AS materia, m.carga_horaria
FROM Academico.Carrera c INNER JOIN Academico.Carrera_Materia cm ON cm.id_carrera = c.id_carrera
INNER JOIN Academico.Materia m ON m.id_materia = cm.id_materia
GO


-- Cantidad de empleados asignados a cada sector, incluyendo sectores sin personal.
CREATE OR ALTER VIEW Administrativo.vEmpleados_por_sector
AS 
SELECT s.id_sector, s.nombre AS sector, COUNT(e.id_empleado) AS cantidad_empleados
FROM Administrativo.Sector s LEFT JOIN Administrativo.Empleado e ON e.id_sector = s.id_sector
GROUP BY s.id_sector, s.nombre
GO



-- Alumnos inscriptos en cada curso
CREATE VIEW Academico.Vista_Alumnos_Por_Curso AS
SELECT cs.id_curso, a.legajo, a.apellido, a.nombre
FROM Academico.Cursada AS cs
JOIN Academico.Alumno AS a ON a.legajo = cs.legajo;
GO

-- Historial académico (incluye cursadas sin notas)
CREATE VIEW Academico.Vista_Historial_Academico AS
SELECT a.legajo, a.apellido, a.nombre, m.nombre AS materia, cs.estado AS estado_cursada, n.instancia, n.valor, n.fecha AS fecha_nota
FROM Academico.Alumno AS a
JOIN Academico.Cursada AS cs ON cs.legajo = a.legajo
JOIN Academico.Curso AS cu ON cu.id_curso = cs.id_curso
JOIN Academico.Materia AS m ON m.id_materia = cu.id_materia
LEFT JOIN Academico.Nota AS n ON n.id_cursada = cs.id_cursada;
GO

--  Detalle de cursos
CREATE VIEW Academico.Vista_Cursos_Detalle AS
SELECT cu.id_curso, m.nombre AS materia, p.apellido AS apellido_profesor, p.nombre AS nombre_profesor, cu.dia, cu.turno, cu.aula, cq.anio, cq.cuatrimestre
FROM Academico.Curso AS cu
JOIN Academico.Materia AS m ON m.id_materia = cu.id_materia
JOIN Administrativo.Profesor AS p ON p.id_profesor = cu.id_profesor
JOIN Academico.Cuatrimestre AS cq ON cq.id_cuatrimestre = cu.id_cuatrimestre;
GO

--  Promedio de notas por materia
CREATE VIEW Academico.Vista_Promedios_Por_Materia AS
SELECT m.id_materia, m.nombre AS materia, COUNT(n.id_nota) AS cantidad_notas, AVG(n.valor) AS promedio
FROM Academico.Materia AS m
JOIN Academico.Curso AS cu ON cu.id_materia = m.id_materia
JOIN Academico.Cursada AS cs ON cs.id_curso = cu.id_curso
JOIN Academico.Nota AS n ON n.id_cursada = cs.id_cursada
GROUP BY m.id_materia, m.nombre;
GO



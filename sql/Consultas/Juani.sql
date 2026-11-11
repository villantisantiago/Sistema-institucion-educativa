USE InstitucionEducativa;
GO

SELECT
    c.id_curso,
    m.nombre AS materia,
    p.apellido AS apellido_profesor,
    c.dia,
    c.turno,
    c.aula,
    cu.cuatrimestre,
    cu.anio
FROM Academico.Curso AS c
JOIN Academico.Materia AS m ON c.id_materia = m.id_materia
JOIN Administrativo.Profesor AS p ON c.id_profesor = p.id_profesor
JOIN Academico.Cuatrimestre AS cu ON c.id_cuatrimestre = cu.id_cuatrimestre
ORDER BY cu.anio, cu.cuatrimestre, c.dia, c.turno;


-- Mostrar los alumnos inscriptos en un curso
DECLARE @id_curso INT = 1; -- se cambia dependiendo del curso 
SELECT
    a.legajo,
    a.apellido,
    a.nombre
FROM Academico.Cursada AS cu
JOIN Academico.Alumno AS a ON cu.legajo = a.legajo
WHERE cu.id_curso = @id_curso
ORDER BY a.apellido, a.nombre;


-- Contar la cantidad de cursadas en cada estado
SELECT
    estado,
    COUNT(*) AS cantidad_cursadas
FROM Academico.Cursada
GROUP BY estado
ORDER BY estado;


-- Mostrar empleados cuyo sueldo neto promedio supera el promedio de los empleados
;WITH SueldoPromedioPorEmpleado AS (
    SELECT
        e.id_empleado,
        e.apellido,
        e.nombre,
        AVG(r.sueldo_bruto - r.descuentos) AS sueldo_neto_promedio
    FROM Administrativo.Empleado AS e
    JOIN Administrativo.Recibo_Sueldo AS r ON r.id_empleado = e.id_empleado
    GROUP BY e.id_empleado, e.apellido, e.nombre
)
SELECT
    id_empleado,
    apellido,
    nombre,
    sueldo_neto_promedio
FROM SueldoPromedioPorEmpleado
WHERE sueldo_neto_promedio > (
    SELECT AVG(sueldo_neto_promedio)
    FROM SueldoPromedioPorEmpleado
)
ORDER BY sueldo_neto_promedio DESC;


-- Calcular el total neto pagado en cada liquidación
SELECT
    l.anio,
    l.mes,
    COALESCE(SUM(r.sueldo_bruto - r.descuentos), 0) AS total_neto_pagado
FROM Administrativo.Liquidacion AS l
LEFT JOIN Administrativo.Recibo_Sueldo AS r ON r.id_liquidacion = l.id_liquidacion
GROUP BY l.anio, l.mes
ORDER BY l.anio, l.mes;
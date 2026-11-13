USE InstitucionEducativa;
GO



-- Mostrar las materias que nunca se dictaron en ningún curso.
SELECT m.id_materia, m.nombre AS materia
FROM Academico.Materia m 
WHERE m.id_materia NOT IN(  
    SELECT DISTINCT id_materia 
    FROM Academico.Curso );
GO



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



--Profesores sin ningún curso asignado
SELECT p.id_profesor, p.apellido, p.nombre
FROM Administrativo.Profesor p
WHERE NOT EXISTS (
    SELECT 1
    FROM Academico.Curso cu
    WHERE cu.id_profesor = p.id_profesor
)
ORDER BY p.apellido, p.nombre;



-- mostrar los alumnos que no tienen ninguna nota cargada
SELECT a.Legajo, a.apellido, a.nombre
FROM Academico.Alumno AS a 
WHERE NOT EXISTS(
    SELECT 1
    FROM Academico.cursada as cursada
    JOIN Academico.Nota as n ON cursada.id_cursada = n.id_cursada
    WHERE a.legajo = cursada.legajo
);


--Alumnos con promedio mayor al promedio general de todas las notas

SELECT a.legajo, a.apellido, a.nombre, AVG(CAST(n.valor AS DECIMAL(10, 4))) AS promedio
FROM Academico.Alumno a
JOIN Academico.Cursada cu ON cu.legajo = a.legajo
JOIN Academico.Nota n ON n.id_cursada = cu.id_cursada
GROUP BY a.legajo, a.apellido, a.nombre
HAVING AVG(CAST(n.valor AS DECIMAL(10, 4))) > (SELECT AVG(CAST(valor AS DECIMAL(10, 4))) FROM Academico.Nota)
ORDER BY promedio DESC;

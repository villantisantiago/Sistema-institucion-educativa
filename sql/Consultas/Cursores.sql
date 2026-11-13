USE InstitucionEducativa;
GO




--  evalúa las notas de cada alumno y define su estado final (Aprobado, Desaprobado o Libre).
CREATE OR ALTER PROCEDURE Academico.spCierre_cursadas
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_cursada INT, @legajo INT, @promedio DECIMAL(4, 2), @tiene_final INT;

    DECLARE curCursadas CURSOR FOR
    SELECT c.id_cursada, c.legajo, AVG(n.valor) AS promedio,
           SUM(CASE WHEN n.instancia = 'Final' AND n.valor >= 4 THEN 1 ELSE 0 END) AS tiene_final
    FROM Academico.Cursada c INNER JOIN Academico.Nota n ON c.id_cursada = n.id_cursada
    WHERE c.estado = 'Cursando'
    GROUP BY c.id_cursada, c.legajo;

    OPEN curCursadas;
    FETCH NEXT FROM curCursadas INTO @id_cursada, @legajo, @promedio, @tiene_final;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @tiene_final > 0
            UPDATE Academico.Cursada SET estado = 'Aprobado' WHERE id_cursada = @id_cursada;
        ELSE IF @promedio >= 4
            UPDATE Academico.Cursada SET estado = 'Aprobado' WHERE id_cursada = @id_cursada;
        ELSE
            UPDATE Academico.Cursada SET estado = 'Desaprobado' WHERE id_cursada = @id_cursada;

        FETCH NEXT FROM curCursadas INTO @id_cursada, @legajo, @promedio, @tiene_final;
    END;

    CLOSE curCursadas;
    DEALLOCATE curCursadas;
    PRINT 'Cierre de cursadas completado exitosamente.';
END;
GO




-- Ajuste salarial escalonado a empleados recorriendo cada sector con un porcentaje diferenciado.
CREATE OR ALTER PROCEDURE Administrativo.spAjuste_salarial_por_sector
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_sector INT, @nombre_sector NVARCHAR(100), @porcentaje DECIMAL(4, 2);

    DECLARE curSectores CURSOR FOR
    SELECT id_sector, nombre
    FROM Administrativo.Sector;

    OPEN curSectores;
    FETCH NEXT FROM curSectores INTO @id_sector, @nombre_sector;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @porcentaje = CASE
            WHEN @nombre_sector = 'Informatica' THEN 0.15
            WHEN @nombre_sector = 'Mantenimiento' THEN 0.12
            WHEN @nombre_sector = 'Secretaria Academica' THEN 0.10
            ELSE 0.08
        END;

        UPDATE Administrativo.Empleado
        SET sueldo = ROUND(sueldo * (1 + @porcentaje), 2)
        WHERE id_sector = @id_sector;

        PRINT 'Sector ' + @nombre_sector + ': aumento aplicado del ' + CAST((@porcentaje * 100) AS VARCHAR(5)) + '%.';

        FETCH NEXT FROM curSectores INTO @id_sector, @nombre_sector;
    END;

    CLOSE curSectores;
    DEALLOCATE curSectores;
END;
GO




-- Alertas de alumnos en riesgo académico: detecta alumnos con 2 o más cursadas desaprobadas o libres.
CREATE OR ALTER PROCEDURE Academico.spAlumnos_en_riesgo
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @legajo INT, @apellido NVARCHAR(50), @nombre NVARCHAR(50), @aplazos INT;

    DECLARE curRiesgo CURSOR FOR
    SELECT a.legajo, a.apellido, a.nombre, COUNT(c.id_cursada) AS aplazos
    FROM Academico.Alumno a INNER JOIN Academico.Cursada c ON a.legajo = c.legajo
    WHERE c.estado IN ('Desaprobado', 'Libre')
    GROUP BY a.legajo, a.apellido, a.nombre
    HAVING COUNT(c.id_cursada) >= 2;

    OPEN curRiesgo;
    FETCH NEXT FROM curRiesgo INTO @legajo, @apellido, @nombre, @aplazos;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'ALERTA RIESGO: Alumno ' + @apellido + ', ' + @nombre + ' (Legajo ' + CAST(@legajo AS VARCHAR(10)) + ') posee ' + CAST(@aplazos AS VARCHAR(5)) + ' materias reprobadas.';
        FETCH NEXT FROM curRiesgo INTO @legajo, @apellido, @nombre, @aplazos;
    END;

    CLOSE curRiesgo;
    DEALLOCATE curRiesgo;
END;
GO




-- Reporte estructurado de ocupación y balance de cursos para un cuatrimestre y año determinados.
CREATE OR ALTER PROCEDURE Academico.spReporte_ocupacion_cursos
@anio INT, @cuatrimestre INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_curso INT, @materia NVARCHAR(100), @aula VARCHAR(20), @turno VARCHAR(20), @inscriptos INT;

    DECLARE curCursos CURSOR FOR
    SELECT c.id_curso, m.nombre AS materia, c.aula, c.turno, COUNT(cu.legajo) AS inscriptos
    FROM Academico.Curso c INNER JOIN Academico.Materia m ON c.id_materia = m.id_materia
    INNER JOIN Academico.Cuatrimestre q ON c.id_cuatrimestre = q.id_cuatrimestre
    LEFT JOIN Academico.Cursada cu ON c.id_curso = cu.id_curso
    WHERE q.anio = @anio AND q.cuatrimestre = @cuatrimestre
    GROUP BY c.id_curso, m.nombre, c.aula, c.turno;

    OPEN curCursos;
    FETCH NEXT FROM curCursos INTO @id_curso, @materia, @aula, @turno, @inscriptos;

    PRINT '--- REPORTE DE OCUPACION DE CURSOS (' + CAST(@anio AS VARCHAR(4)) + ' - C' + CAST(@cuatrimestre AS VARCHAR(2)) + ') ---';

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @inscriptos < 5
            PRINT 'Curso ' + CAST(@id_curso AS VARCHAR(10)) + ' [' + @materia + ' - Aula: ' + @aula + ' - Turno: ' + @turno + ']: ' + CAST(@inscriptos AS VARCHAR(5)) + ' alumnos (BAJA DEMANDA).';
        ELSE IF @inscriptos > 25
            PRINT 'Curso ' + CAST(@id_curso AS VARCHAR(10)) + ' [' + @materia + ' - Aula: ' + @aula + ' - Turno: ' + @turno + ']: ' + CAST(@inscriptos AS VARCHAR(5)) + ' alumnos (CURSO COMPLETO).';
        ELSE
            PRINT 'Curso ' + CAST(@id_curso AS VARCHAR(10)) + ' [' + @materia + ' - Aula: ' + @aula + ' - Turno: ' + @turno + ']: ' + CAST(@inscriptos AS VARCHAR(5)) + ' alumnos (NORMAL).';

        FETCH NEXT FROM curCursos INTO @id_curso, @materia, @aula, @turno, @inscriptos;
    END;

    CLOSE curCursos;
    DEALLOCATE curCursos;
END;
GO




--  Liquidación individual con cálculo de presentismo según los fichajes registrados en el mes.
CREATE OR ALTER PROCEDURE Administrativo.spLiquidar_empleados_con_presentismo
@mes INT, @anio INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_liquidacion INT, @id_empleado INT, @sueldo_base DECIMAL(10, 2), @fichajes INT;
    DECLARE @bruto DECIMAL(10, 2), @descuento DECIMAL(10, 2), @neto DECIMAL(10, 2);

    IF EXISTS (SELECT 1 FROM Administrativo.Liquidacion WHERE mes = @mes AND anio = @anio)
    BEGIN
        SELECT @id_liquidacion = id_liquidacion FROM Administrativo.Liquidacion WHERE mes = @mes AND anio = @anio;
    END
    ELSE
    BEGIN
        INSERT INTO Administrativo.Liquidacion (fecha_pago, mes, anio) VALUES (CAST(GETDATE() AS DATE), @mes, @anio);
        SET @id_liquidacion = SCOPE_IDENTITY();
    END;

    DECLARE curLiquidacion CURSOR FOR
    SELECT e.id_empleado, e.sueldo, COUNT(f.id_fichaje) AS dias_trabajados
    FROM Administrativo.Empleado e
    LEFT JOIN Administrativo.Fichaje f ON e.id_empleado = f.id_empleado AND MONTH(f.fecha) = @mes AND YEAR(f.fecha) = @anio
    GROUP BY e.id_empleado, e.sueldo;

    OPEN curLiquidacion;
    FETCH NEXT FROM curLiquidacion INTO @id_empleado, @sueldo_base, @fichajes;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @fichajes >= 20
            SET @bruto = ROUND(@sueldo_base * 1.10, 2);
        ELSE
            SET @bruto = @sueldo_base;

        SET @descuento = ROUND(@bruto * 0.17, 2);
        SET @neto = ROUND(@bruto - @descuento, 2);

        INSERT INTO Administrativo.Recibo_Sueldo (id_liquidacion, id_empleado, id_profesor, sueldo_bruto, descuentos, fecha, monto)
        VALUES (@id_liquidacion, @id_empleado, NULL, @bruto, @descuento, CAST(GETDATE() AS DATE), @neto);

        FETCH NEXT FROM curLiquidacion INTO @id_empleado, @sueldo_base, @fichajes;
    END;

    CLOSE curLiquidacion;
    DEALLOCATE curLiquidacion;
    PRINT 'Liquidacion con presentismo generada exitosamente.';
END;
GO




-- verifica fila por fila si cada cursada activa cumple con las materias correlativas aprobadas.
CREATE OR ALTER PROCEDURE Academico.spAuditar_correlativas_cursadas
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @legajo INT, @id_curso INT, @materia NVARCHAR(100), @id_materia INT, @correlativas_pendientes INT;

    DECLARE curAuditoria CURSOR FOR
    SELECT c.legajo, c.id_curso, m.id_materia, m.nombre AS materia
    FROM Academico.Cursada c INNER JOIN Academico.Curso cur ON c.id_curso = cur.id_curso
    INNER JOIN Academico.Materia m ON cur.id_materia = m.id_materia
    WHERE c.estado = 'Cursando';

    OPEN curAuditoria;
    FETCH NEXT FROM curAuditoria INTO @legajo, @id_curso, @id_materia, @materia;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @correlativas_pendientes = COUNT(corr.id_correlativa)
        FROM Academico.Correlativa corr
        WHERE corr.id_materia = @id_materia
          AND corr.id_correlativa NOT IN (
              SELECT cur_ap.id_materia
              FROM Academico.Cursada c_ap INNER JOIN Academico.Curso cur_ap ON c_ap.id_curso = cur_ap.id_curso
              WHERE c_ap.legajo = @legajo AND c_ap.estado = 'Aprobado'
          );

        IF @correlativas_pendientes > 0
            PRINT 'INCONSISTENCIA: Alumno legajo ' + CAST(@legajo AS VARCHAR(10)) + ' cursando ' + @materia + ' adeuda ' + CAST(@correlativas_pendientes AS VARCHAR(5)) + ' correlativa/s.';

        FETCH NEXT FROM curAuditoria INTO @legajo, @id_curso, @id_materia, @materia;
    END;

    CLOSE curAuditoria;
    DEALLOCATE curAuditoria;
END;
GO
USE InstitucionEducativa;
GO

CREATE ROLE Rol_Alumno;
CREATE ROLE Rol_Profesor;
CREATE ROLE Rol_Secretaria_Academica;
CREATE ROLE Rol_RRHH;
CREATE ROLE Rol_Directivo;
GO


-- Alumno: solo puede consultar vistas públicas de información académica
GRANT SELECT ON Academico.vOferta_cursos TO Rol_Alumno;
GRANT SELECT ON Academico.vPlan_estudios_carreras TO Rol_Alumno;
GRANT SELECT ON Academico.Vista_Alumnos_Por_Curso TO Rol_Alumno;
DENY SELECT ON SCHEMA::Administrativo TO Rol_Alumno;
GO


-- Profesor: puede ver las materias, cursos y alumnos
GRANT SELECT ON Academico.Curso TO Rol_Profesor;
GRANT SELECT ON Academico.Cursada TO Rol_Profesor;
GRANT SELECT ON Academico.Materia TO Rol_Profesor;
GRANT EXECUTE ON Academico.spCargar_nota TO Rol_Profesor;
GO


-- Secretaria academica: control completo (lectura, alta, modificación) sobre todo el esquema Académico
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Academico TO Rol_Secretaria_Academica;
GRANT EXECUTE ON Academico.spInscribir_alumno_a_curso TO Rol_Secretaria_Academica;
GRANT EXECUTE ON Academico.spCursos_con_mas_alumnos TO Rol_Secretaria_Academica;
GO


-- Recursos humanos: control completo sobre todo el esquema Administrativo (sueldos, fichajes, sectores)
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Administrativo TO Rol_RRHH;
GRANT EXECUTE ON Administrativo.spGenerar_liquidacion TO Rol_RRHH;
GRANT EXECUTE ON Administrativo.spRecibos_por_fecha TO Rol_RRHH;
GO


-- Directivos: lectura global de ambos esquemas y vistas para auditar y ver reportes
GRANT SELECT ON SCHEMA::Academico TO Rol_Directivo;
GRANT SELECT ON SCHEMA::Administrativo TO Rol_Directivo;
GRANT EXECUTE ON Academico.spAlumnos_en_riesgo TO Rol_Directivo;
GRANT EXECUTE ON Academico.spReporte_ocupacion_cursos TO Rol_Directivo;
GO
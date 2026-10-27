# Sistema-institucion-educativa
Sistema de gestión de una institución educativa.

El sistema está destinado a una universidad. Unifica en una única base de datos la información académica, administrativa y de personal, para que sea accesible y la institución se organice mejor.

### Actores
* Alumnos: cursan materias y reciben notas.
* Profesores: dictan materias y cargan notas.
* Directivos: gestionan y supervisan la institución, y consultan estadísticas.
* Personal de mantenimiento: se ocupa de la infraestructura y las instalaciones.
* Personal de seguridad: controla el acceso y la seguridad de los edificios.

### Información que se necesita almacenar
* Alumno: legajo, DNI, nombre y apellido, fecha de nacimiento, teléfono, mail.
* Inscripción a carrera: alumno, carrera, fecha de ingreso, estado.
* Profesor: DNI, nombre y apellido, contacto, título, fecha de ingreso.
* Directivo: DNI, nombre y apellido, teléfono, cargo, sueldo.
* Personal (mantenimiento y seguridad): DNI, nombre y apellido, teléfono, tipo (mantenimiento o seguridad), cargo, turno, sueldo, fecha de ingreso.
* Turno: código, nombre (mañana, tarde o noche), hora de inicio, hora de fin.
* Carrera: código, nombre, duración.
* Materia: código, nombre, carga horaria.
* Plan de estudio: carrera, materia, cuatrimestre de la carrera en que se cursa.
* Cuatrimestre: código, nombre (1er o 2do cuatrimestre).
* Cursada: alumno, materia, año, cuatrimestre, estado (cursando, aprobada, desaprobada, libre).
* Nota: cursada, tipo de instancia (parcial, recuperatorio, final), valor, fecha.
* Fichaje: fecha, hora de ingreso y la persona que ingresó (directivo, profesor o personal).

### Reglas de negocio
1. Cada alumno tiene un legajo único.
2. Un alumno puede estar inscripto en más de una carrera.
3. Cada materia es dictada por al menos un profesor, y un profesor puede dictar varias materias.
4. Las notas van de 0 a 10 y se aprueba con 4 o más.
5. Un alumno puede tener más de una nota en una misma cursada (parcial, recuperatorio y final).
6. Un alumno solo puede rendir el final de una materia si tiene la cursada aprobada.
7. Un alumno no puede cursar una materia si no aprobó sus correlativas.
8. Solo los profesores asignados a una materia pueden cargar notas en ella.
9. Una persona tiene un único rol principal (alumno, profesor, directivo o personal).
10. Cada empleado de mantenimiento o seguridad tiene un único turno (mañana, tarde o noche) y un único cargo.
11. El cargo del personal debe corresponder a su tipo. Mantenimiento: electricista, plomero, jardinero, personal de limpieza. Seguridad: guardia de acceso y/o supervisor de seguridad.
12. Cada ingreso de un directivo, profesor o empleado se registra en el fichaje con fecha y hora, y cada registro corresponde a una sola persona.
13. Una materia puede pertenecer a más de una carrera, y una carrera tiene muchas materias. El cuatrimestre en que se cursa depende de la carrera.

### Procesos principales
* Alta, baja y modificación de alumnos, profesores, directivos y personal.
* Inscripción de alumnos a carreras.
* Inscripción de alumnos a materias (cursada).
* Carga y modificación de notas por parte de los profesores.
* Consulta del historial académico de un alumno.
* Asignación de profesores a materias.
* Asignación de turno y cargo al personal.
* Registro diario del ingreso de directivos, profesores y personal (fichaje).
* Generación de estadísticas: cantidad de alumnos, profesores, directivos y personal, y promedios por materia.

### Restricciones del sistema
* Los DNI y los legajos no pueden repetirse.
* Los directivos pueden consultar toda la información.
* Los profesores solo editan notas de sus materias.
* Los alumnos solo consultan sus propios datos.
* El turno y el cargo del personal son obligatorios, y el turno debe ser uno de los definidos en la tabla Turno.
* El cuatrimestre de una cursada debe ser uno de los definidos en la tabla Cuatrimestre.
* Cada registro de fichaje debe tener fecha, hora de ingreso y una única persona asociada.
* Debe mantenerse la integridad referencial entre todas las tablas.

### Cardinalidad
| Entidad A | Relación | Entidad B | Cardinalidad | Implementación |
|---|---|---|---|---|
| Carrera | tiene | Materia | N:M | Tabla **Plan_Estudio** (`id_carrera`, `id_materia`, `cuatrimestre`) |
| Alumno | se inscribe en | Carrera | N:M | Tabla **Inscripcion_Carrera** (`legajo`, `id_carrera`, `fecha_ingreso`, `estado`) |
| Alumno | cursa | Materia | N:M | Tabla **Cursada** (`id_cursada`, `legajo`, `id_materia`, `id_cuatrimestre`, `anio`, `estado`) |
| Cuatrimestre | se cursa en | Cursada | 1:N | `id_cuatrimestre` como FK en Cursada |
| Cursada | tiene | Nota | 1:N | `id_cursada` como FK en Nota |
| Profesor | dicta | Materia | N:M | Tabla **Dicta** (`id_profesor`, `id_materia`) |
| Materia | es correlativa de | Materia | N:M | Tabla **Correlativa** (`id_materia`, `id_materia_correlativa`) |
| Turno | se asigna a | Personal | 1:N | `id_turno` como FK en Personal |
| Directivo | ficha | Fichaje | 1:N | `id_directivo` como FK en Fichaje |
| Profesor | ficha | Fichaje | 1:N | `id_profesor` como FK en Fichaje |
| Personal | ficha | Fichaje | 1:N | `id_personal` como FK en Fichaje |

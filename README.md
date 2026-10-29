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
* Alumno: legajo, DNI, nombre y apellido, fecha de nacimiento, contacto, mail, carrera, fecha de ingreso y estado.
* Personal (mantenimiento, seguridad, directivos y docentes): idEmpleado, DNI, nombre, apellido, turno, fecha de ingreso, cargo, titulo, sector, telefono y sueldo.
* Carrera: código, nombre y duración.
* Materia: código, nombre, carga horaria, cuatrimestre y carrera.
* Cursada: alumno, materia, turno, año/cuatrimestre y estado (cursando, aprobada, desaprobada, libre).
* Nota: cursada, tipo de instancia (parcial, recuperatorio, final), valor y fecha.
* Fichaje: hora de ingreso, hora de salida, fecha y idEmpleado
* Recibo de sueldo: sueldo liquidado, mes, anio y fecha de pago.

### Reglas de negocio
1. Cada alumno tiene un legajo único.
2. Cada materia es dictada por al menos un profesor, y un profesor puede dictar varias materias.
3. Las notas van de 0 a 10 y se aprueba con 4 o más.
4. Un alumno solo puede rendir el final de una materia si tiene la cursada aprobada.
5. Un alumno no puede cursar una materia si no aprobó sus correlativas.
6. Solo los profesores asignados a una materia pueden cargar notas en ella.
7. El recibo de sueldo surge del proceso de liquidacion de sueldo.
8. No hay materias anuales, una cursada tiene un unico cuatrimestre.
9. Todos los empleados sin importar el cargo deben fichar a la entrada y a la salida.
10. Un profesor puede dictar la misma materia varias veces por día y varios días por semana.
11. Un profesor no puede tener 2 clases que se superpongan el mismo día y horario.
12. Cada profesor tiene como máximo 48 horas de clases trabajadas por semana.



### Procesos principales
* Alta, baja y modificación de alumnos, profesores, directivos y personal.
* Inscripción de alumnos a materias.
* Carga y modificación de notas por parte de los profesores.
* Consulta del historial académico de un alumno.
* Asignación de profesores a materias.
* Generación de estadísticas: cantidad de alumnos, profesores, directivos y personal, y promedios por materia.

### Restricciones del sistema
* Los DNI y los legajos no pueden repetirse.
* Los directivos pueden consultar toda la información.
* Los profesores solo editan notas de sus materias.
* Los alumnos solo consultan sus propios datos.
* Debe mantenerse la integridad referencial entre todas las tablas.

### Cardinalidad
| Entidad A | Relación | Entidad B | Cardinalidad | Implementación |
|---|---|---|---|---|
| Carrera | tiene | Materia | N:M | `id_carrera` como FK en Materia |
| Alumno | se inscribe en | Carrera | N:M | Tabla **Inscripcion_Carrera** (`legajo`, `id_carrera`, `fecha_ingreso`, `estado`) |
| Alumno | cursa | Materia | N:M | Tabla **Cursada** (`legajo`, `id_materia`) |
| Cursada | tiene | Nota | 1:N | `id_cursada` como FK en Nota |
| Profesor | dicta | Materia | N:M | Tabla **Dicta** (`id_profesor`, `id_materia`) |
| Materia | es correlativa de | Materia | N:M | Tabla **Correlativa** (`id_materia`, `id_materia_correlativa`) |
| Directivo | está a cargo de | Área | N:1 | `id_area` como FK en Directivo |
| Personal (mantenimiento y seguridad) | pertenece a | Área | N:1 | `id_area` como FK en Personal |

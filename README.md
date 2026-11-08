# Sistema-institucion-educativa
 
Sistema de gestión de una institución educativa.
 
El sistema está destinado a una universidad. Unifica en una base de datos la información académica, administrativa, del personal y contable, para una mejor accesibilidad y organización en la institución.
 
### Actores
* **Alumnos:** se inscriben en carreras, cursan cursos y reciben notas. Pueden consultar a sus compañeros de curso.
* **Profesores:** dictan cursos y cargan notas.
* **Directivos:** gestionan y supervisan la institución, y consultan estadísticas.
* **Personal:** se ocupa de la infraestructura, el acceso a los edificios y la gestión administrativa.
Directivos y personal se registran como empleados.
 
### Información que se necesita almacenar
* **Alumno:** legajo, DNI, nombre, apellido, fecha de nacimiento, teléfono y mail.
* **Carrera:** código, nombre y duración.
* **Inscripción a carrera** (relación Alumno–Carrera): fecha de ingreso y estado.
* **Materia:** código, nombre y carga horaria.
* **Cuatrimestre:** código, nombre (1er o 2do cuatrimestre) y año.
* **Curso:** código, día de la semana, turno y aula. Cada curso pertenece a una materia, a un profesor y a un cuatrimestre.
* **Cursada:** código, alumno, curso y estado (cursando, aprobada, desaprobada, libre). Es la inscripción de un alumno a un curso.
* **Nota** (entidad dependiente de Cursada): código, tipo de instancia (parcial, recuperatorio, final), valor y fecha.
* **Profesor:** código, DNI, nombre, apellido, título, fecha de ingreso y sueldo.
* **Empleado** (directivos y personal): código, DNI, nombre, apellido, teléfono, título, fecha de ingreso y sueldo.
* **Sector:** código y nombre del sector al que pertenece cada empleado o profesor.
* **Fichaje:** código, fecha, hora de ingreso y hora de salida de la persona que fichó.
* **Liquidación:** código, mes, año y fecha de pago.
* **Recibo de sueldo:** código, sueldo bruto y descuentos.
### Reglas de negocio
1. Cada alumno tiene un legajo único.
2. Un alumno puede estar inscripto en más de una carrera. La inscripción registra su fecha de ingreso y su estado.
3. Una materia puede pertenecer a más de una carrera, y una carrera tiene muchas materias.
4. Una materia puede ser correlativa de otras materias.
5. Cada materia se dicta mediante uno o más cursos. Cada curso pertenece a una sola materia, tiene un único profesor y se dicta en un solo cuatrimestre.
6. **Un curso se dicta una sola vez por semana**, en un único día, turno y aula.
7. Un profesor puede dictar varios cursos.
8. Un alumno cursa muchos cursos, y un curso tiene muchos alumnos. La inscripción de un alumno a un curso es una cursada, con su estado. Un alumno no puede inscribirse dos veces al mismo curso.
9. Las notas van de 0 a 10 y se aprueba con 4 o más.
10. Un alumno puede tener más de una nota en una misma cursada (parcial, recuperatorio y final). Una nota no existe sin su cursada.
11. Un alumno solo puede rendir el final de una materia si tiene la cursada aprobada.
12. Un alumno no puede cursar una materia si no aprobó sus correlativas.
13. Solo el profesor asignado a un curso puede cargar notas en él.
14. Un alumno puede ver a todos sus compañeros de un curso, mediante una vista o un stored procedure.
15. Cada empleado y cada profesor pertenece a un sector.
16. Cada ingreso de un empleado o profesor se registra en el fichaje con fecha, hora de ingreso y hora de salida, y cada registro corresponde a una sola persona.
17. Cada mes se genera una liquidación, que emite recibos de sueldo. Un empleado o profesor cobra muchos recibos a lo largo del tiempo, y cada recibo corresponde a una sola persona y a una sola liquidación.
18. El sueldo neto de un recibo es el sueldo bruto menos los descuentos. Se calcula, no se almacena.
### Procesos principales
* Alta, baja y modificación de alumnos, profesores y empleados.
* Inscripción de alumnos a carreras.
* Creación de cursos y asignación de profesores, día, turno y aula.
* Inscripción de alumnos a cursos (cursada).
* Carga y modificación de notas por parte de los profesores.
* Consulta del historial académico de un alumno y de sus compañeros de curso.
* Asignación de empleados y profesores a sectores.
* Registro del ingreso y la salida del personal (fichaje).
* Liquidación mensual de sueldos y emisión de recibos.
* Generación de estadísticas: cantidad de alumnos, profesores y empleados, y promedios por materia.
### Restricciones del sistema
* Los DNI y los legajos no pueden repetirse.
* Los directivos pueden consultar toda la información.
* Los profesores solo editan notas de los cursos que dictan.
* Los alumnos solo consultan sus propios datos y la lista de compañeros de sus cursos.
* El cuatrimestre de un curso debe ser uno de los definidos en la tabla Cuatrimestre.
* Cada curso tiene un único día, turno y aula.
* Cada registro de fichaje debe tener fecha, hora de ingreso y una única persona asociada.
* Cada recibo de sueldo pertenece a una única liquidación y a una única persona.
* Debe mantenerse la integridad referencial entre todas las tablas.
### Cardinalidad
| Entidad A | Relación | Entidad B | Cardinalidad | Implementación |
|---|---|---|---|---|
| Carrera | tiene | Materia | N:M | Tabla intermedia (`id_carrera`, `id_materia`) |
| Alumno | se inscribe en | Carrera | N:M | Tabla intermedia (`legajo`, `id_carrera`, `fecha_ingreso`, `estado`) |
| Materia | es correlativa de | Materia | N:M | Tabla intermedia (`id_materia`, `id_materia_correlativa`) |
| Materia | se dicta en | Curso | 1:N | `id_materia` como FK en Curso |
| Profesor | dicta | Curso | 1:N | `id_profesor` como FK en Curso |
| Cuatrimestre | se dicta en | Curso | 1:N | `id_cuatrimestre` como FK en Curso |
| Alumno | realiza | Cursada | 1:N | `legajo` como FK en Cursada |
| Curso | se cursa en | Cursada | 1:N | `id_curso` como FK en Cursada |
| Cursada | obtiene | Nota | 1:N (Nota es dependiente) | `id_cursada` como FK en Nota |
| Sector | pertenece | Empleado / Profesor | 1:N | `id_sector` como FK |
| Empleado | ficha | Fichaje | 1:N | `id_empleado` como FK en Fichaje |
| Profesor | ficha | Fichaje | 1:N | `id_profesor` como FK en Fichaje |
| Liquidación | genera | Recibo de sueldo | 1:N | `id_liquidacion` como FK en Recibo_Sueldo |
| Empleado / Profesor | cobra | Recibo de sueldo | 1:N | `id_empleado` o `id_profesor` como FK en Recibo_Sueldo |

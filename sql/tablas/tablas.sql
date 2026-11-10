USE InstitucionEducativa;
GO

CREATE TABLE Administrativo.Sector (
    id_sector INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL
);

CREATE TABLE Academico.Carrera (
    id_carrera INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    duracion INT NOT NULL
);

CREATE TABLE Academico.Materia (
    id_materia INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    carga_horaria INT NOT NULL
);

CREATE TABLE Academico.Cuatrimestre (
    id_cuatrimestre INT IDENTITY(1,1) PRIMARY KEY,
    anio INT NOT NULL,
    cuatrimestre NVARCHAR(20) NOT NULL CHECK (cuatrimestre IN ('1', '2'))
);

CREATE TABLE Administrativo.Liquidacion (
    id_liquidacion INT IDENTITY(1,1) PRIMARY KEY,
    fecha_pago DATE NOT NULL,
    mes INT NOT NULL CHECK (mes >= 1 AND mes <= 12),
    anio INT NOT NULL
);

CREATE TABLE Academico.Alumno (
    legajo INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(50) NOT NULL,
    apellido NVARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    correo_electronico NVARCHAR(100) NOT NULL
);

CREATE TABLE Administrativo.Profesor (
    id_profesor INT IDENTITY(1,1) PRIMARY KEY,
    id_sector INT FOREIGN KEY REFERENCES Administrativo.Sector(id_sector),
    dni VARCHAR(20) NOT NULL,
    nombre NVARCHAR(50) NOT NULL,
    apellido NVARCHAR(50) NOT NULL,
    titulo NVARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    correo_electronico NVARCHAR(100) NOT NULL
);

CREATE TABLE Administrativo.Empleado (
    id_empleado INT IDENTITY(1,1) PRIMARY KEY,
    id_sector INT FOREIGN KEY REFERENCES Administrativo.Sector(id_sector),
    dni VARCHAR(20) NOT NULL,
    nombre NVARCHAR(50) NOT NULL,
    apellido NVARCHAR(50) NOT NULL,
    cargo NVARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    correo_electronico NVARCHAR(100) NOT NULL,
    titulo NVARCHAR(100) NOT NULL
);

CREATE TABLE Academico.Carrera_Materia (
    id_carrera INT NOT NULL FOREIGN KEY REFERENCES Academico.Carrera(id_carrera),
    id_materia INT NOT NULL FOREIGN KEY REFERENCES Academico.Materia(id_materia),
    PRIMARY KEY (id_carrera, id_materia)
);

CREATE TABLE Academico.Correlativa (
    id_materia INT NOT NULL FOREIGN KEY REFERENCES Academico.Materia(id_materia),
    id_correlativa INT NOT NULL FOREIGN KEY REFERENCES Academico.Materia(id_materia),
    PRIMARY KEY (id_materia, id_correlativa)
);

CREATE TABLE Academico.Inscripcion (
    legajo INT NOT NULL FOREIGN KEY REFERENCES Academico.Alumno(legajo),
    id_carrera INT NOT NULL FOREIGN KEY REFERENCES Academico.Carrera(id_carrera),
    id_cuatrimestre INT NOT NULL FOREIGN KEY REFERENCES Academico.Cuatrimestre(id_cuatrimestre),
    estado NVARCHAR(20) NOT NULL CHECK (estado IN ('Cursando', 'Recibido', 'Baja')),
    PRIMARY KEY (legajo, id_carrera, id_cuatrimestre)
);

CREATE TABLE Academico.Curso (
    id_curso INT IDENTITY(1,1) PRIMARY KEY,
    id_materia INT NOT NULL FOREIGN KEY REFERENCES Academico.Materia(id_materia),
    id_profesor INT NOT NULL FOREIGN KEY REFERENCES Administrativo.Profesor(id_profesor),
    id_cuatrimestre INT NOT NULL FOREIGN KEY REFERENCES Academico.Cuatrimestre(id_cuatrimestre),
    turno NVARCHAR(20) NOT NULL CHECK (turno IN ('Mañana', 'Tarde', 'Noche')),
    dia NVARCHAR(20) NOT NULL CHECK (dia IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado')),
    aula VARCHAR(30) NOT NULL,
    CONSTRAINT restriccion_Curso_Aula UNIQUE (id_cuatrimestre, dia, turno, aula),
    CONSTRAINT restriccion_Curso_Profesor UNIQUE (id_profesor, id_cuatrimestre, dia, turno)
);

CREATE TABLE Academico.Cursada (
    id_cursada INT IDENTITY(1,1) PRIMARY KEY,
    legajo INT NOT NULL FOREIGN KEY REFERENCES Academico.Alumno(legajo),
    id_curso INT NOT NULL FOREIGN KEY REFERENCES Academico.Curso(id_curso),
    estado NVARCHAR(20) NOT NULL CHECK (estado IN ('Aprobado', 'Desaprobado', 'Cursando', 'Final')),
    CONSTRAINT restriccion_cursada UNIQUE (legajo, id_curso) --para que un mismo alumno no se pueda anotar en la misma cursada que ya esta
);

CREATE TABLE Academico.Nota (
    id_nota INT IDENTITY(1,1) PRIMARY KEY,
    id_cursada INT NOT NULL FOREIGN KEY REFERENCES Academico.Cursada(id_cursada),
    instancia VARCHAR(20) NOT NULL CHECK (instancia IN ('Parcial', 'Final', 'Recuperatorio')),
    valor DECIMAL(3, 1) CHECK (valor >= 0 AND valor <= 10),
    fecha DATE NOT NULL
);

CREATE TABLE Administrativo.Fichaje (
    id_fichaje INT IDENTITY(1,1) PRIMARY KEY,
    id_profesor INT FOREIGN KEY REFERENCES Administrativo.Profesor(id_profesor),
    id_empleado INT FOREIGN KEY REFERENCES Administrativo.Empleado(id_empleado),
    fecha DATE NOT NULL,
    hora_ingreso TIME NOT NULL,
    hora_salida TIME NOT NULL,
    CONSTRAINT CK_Fichaje_Persona CHECK ((id_profesor IS NOT NULL AND id_empleado IS NULL) OR (id_profesor IS NULL AND id_empleado IS NOT NULL))
);

CREATE TABLE Administrativo.Recibo_Sueldo (
    id_recibo INT IDENTITY(1,1) PRIMARY KEY,
    id_empleado INT FOREIGN KEY REFERENCES Administrativo.Empleado(id_empleado),
    id_liquidacion INT FOREIGN KEY REFERENCES Administrativo.Liquidacion(id_liquidacion),
    id_profesor INT FOREIGN KEY REFERENCES Administrativo.Profesor(id_profesor),
    sueldo_bruto DECIMAL(10, 2) NOT NULL,
    descuentos DECIMAL(10, 2) NOT NULL,
    fecha DATE NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    CONSTRAINT CK_Recibo_Persona CHECK ((id_profesor IS NOT NULL AND id_empleado IS NULL) OR (id_profesor IS NULL AND id_empleado IS NOT NULL))
);
GO
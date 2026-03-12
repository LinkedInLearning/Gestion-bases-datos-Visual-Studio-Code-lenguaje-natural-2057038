-- ============================================
-- Seccion 1: Creacion y seleccion de la base
-- ============================================
USE master;
GO

IF DB_ID(N'CursosFavoritosLL') IS NULL
BEGIN
  CREATE DATABASE CursosFavoritosLL;
END;
GO

USE CursosFavoritosLL;
GO

-- ============================================
-- Seccion 2: Limpieza de objetos existentes
-- ============================================
IF OBJECT_ID(N'dbo.Valoraciones', N'U') IS NOT NULL DROP TABLE dbo.Valoraciones;
IF OBJECT_ID(N'dbo.Progreso', N'U') IS NOT NULL DROP TABLE dbo.Progreso;
IF OBJECT_ID(N'dbo.CursosCategorias', N'U') IS NOT NULL DROP TABLE dbo.CursosCategorias;
IF OBJECT_ID(N'dbo.Cursos', N'U') IS NOT NULL DROP TABLE dbo.Cursos;
IF OBJECT_ID(N'dbo.Categorias', N'U') IS NOT NULL DROP TABLE dbo.Categorias;
IF OBJECT_ID(N'dbo.Autores', N'U') IS NOT NULL DROP TABLE dbo.Autores;
IF OBJECT_ID(N'dbo.Plataformas', N'U') IS NOT NULL DROP TABLE dbo.Plataformas;
GO

-- ============================================
-- Seccion 3: Creacion de tablas y restricciones
-- ============================================
CREATE TABLE dbo.Plataformas
(
  PlataformaID INT IDENTITY(1,1) NOT NULL,
  Nombre NVARCHAR(120) NOT NULL,
  UrlOficial NVARCHAR(300) NOT NULL,
  CONSTRAINT PK_Plataformas PRIMARY KEY (PlataformaID),
  CONSTRAINT UQ_Plataformas_Nombre UNIQUE (Nombre),
  CONSTRAINT UQ_Plataformas_UrlOficial UNIQUE (UrlOficial),
  CONSTRAINT CK_Plataformas_Url CHECK (UrlOficial LIKE N'https://%')
);
GO

CREATE TABLE dbo.Autores
(
  AutorID INT IDENTITY(1,1) NOT NULL,
  NombreCompleto NVARCHAR(150) NOT NULL,
  Pais NVARCHAR(80) NOT NULL,
  PerfilUrl NVARCHAR(300) NULL,
  CONSTRAINT PK_Autores PRIMARY KEY (AutorID),
  CONSTRAINT UQ_Autores_NombreCompleto UNIQUE (NombreCompleto),
  CONSTRAINT UQ_Autores_PerfilUrl UNIQUE (PerfilUrl),
  CONSTRAINT CK_Autores_PerfilUrl CHECK (PerfilUrl IS NULL OR PerfilUrl LIKE N'https://%')
);
GO

CREATE TABLE dbo.Categorias
(
  CategoriaID INT IDENTITY(1,1) NOT NULL,
  Nombre NVARCHAR(100) NOT NULL,
  Descripcion NVARCHAR(250) NULL,
  CONSTRAINT PK_Categorias PRIMARY KEY (CategoriaID),
  CONSTRAINT UQ_Categorias_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE dbo.Cursos
(
  CursoID INT IDENTITY(1,1) NOT NULL,
  PlataformaID INT NOT NULL,
  AutorID INT NOT NULL,
  Titulo NVARCHAR(200) NOT NULL,
  UrlCurso NVARCHAR(300) NOT NULL,
  Nivel NVARCHAR(20) NOT NULL,
  DuracionMinutos INT NOT NULL,
  FechaPublicacion DATE NOT NULL,
  Activo BIT NOT NULL CONSTRAINT DF_Cursos_Activo DEFAULT (1),
  CONSTRAINT PK_Cursos PRIMARY KEY (CursoID),
  CONSTRAINT UQ_Cursos_Plataforma_Titulo UNIQUE (PlataformaID, Titulo),
  CONSTRAINT UQ_Cursos_UrlCurso UNIQUE (UrlCurso),
  CONSTRAINT CK_Cursos_Nivel CHECK (Nivel IN (N'Basico', N'Intermedio', N'Avanzado')),
  CONSTRAINT CK_Cursos_Duracion CHECK (DuracionMinutos > 0),
  CONSTRAINT CK_Cursos_FechaPublicacion CHECK (FechaPublicacion >= '2000-01-01'),
  CONSTRAINT FK_Cursos_Plataformas FOREIGN KEY (PlataformaID) REFERENCES dbo.Plataformas(PlataformaID),
  CONSTRAINT FK_Cursos_Autores FOREIGN KEY (AutorID) REFERENCES dbo.Autores(AutorID)
);
GO

CREATE TABLE dbo.CursosCategorias
(
  CursoID INT NOT NULL,
  CategoriaID INT NOT NULL,
  CONSTRAINT PK_CursosCategorias PRIMARY KEY (CursoID, CategoriaID),
  CONSTRAINT FK_CursosCategorias_Cursos FOREIGN KEY (CursoID) REFERENCES dbo.Cursos(CursoID),
  CONSTRAINT FK_CursosCategorias_Categorias FOREIGN KEY (CategoriaID) REFERENCES dbo.Categorias(CategoriaID)
);
GO

CREATE TABLE dbo.Progreso
(
  ProgresoID INT IDENTITY(1,1) NOT NULL,
  CursoID INT NOT NULL,
  Estado NVARCHAR(20) NOT NULL,
  Porcentaje DECIMAL(5,2) NOT NULL,
  FechaInicio DATE NULL,
  FechaUltimoAvance DATE NULL,
  FechaCompletado DATE NULL,
  CONSTRAINT PK_Progreso PRIMARY KEY (ProgresoID),
  CONSTRAINT UQ_Progreso_CursoID UNIQUE (CursoID),
  CONSTRAINT FK_Progreso_Cursos FOREIGN KEY (CursoID) REFERENCES dbo.Cursos(CursoID),
  CONSTRAINT CK_Progreso_Estado CHECK (Estado IN (N'Pendiente', N'En progreso', N'Completado')),
  CONSTRAINT CK_Progreso_Porcentaje CHECK (Porcentaje >= 0 AND Porcentaje <= 100),
  CONSTRAINT CK_Progreso_EstadoPorcentaje CHECK
    (
        (Estado = N'Pendiente' AND Porcentaje = 0 AND FechaCompletado IS NULL)
    OR (Estado = N'En progreso' AND Porcentaje > 0 AND Porcentaje < 100 AND FechaCompletado IS NULL)
    OR (Estado = N'Completado' AND Porcentaje = 100 AND FechaCompletado IS NOT NULL)
    ),
  CONSTRAINT CK_Progreso_Fechas CHECK
    (
        (FechaInicio IS NULL OR FechaUltimoAvance IS NULL OR FechaInicio <= FechaUltimoAvance)
    AND (FechaUltimoAvance IS NULL OR FechaCompletado IS NULL OR FechaUltimoAvance <= FechaCompletado)
    )
);
GO

CREATE TABLE dbo.Valoraciones
(
  ValoracionID INT IDENTITY(1,1) NOT NULL,
  CursoID INT NOT NULL,
  Puntuacion TINYINT NOT NULL,
  Recomendado BIT NOT NULL CONSTRAINT DF_Valoraciones_Recomendado DEFAULT (1),
  Comentario NVARCHAR(500) NULL,
  FechaValoracion DATE NOT NULL CONSTRAINT DF_Valoraciones_FechaValoracion DEFAULT (CONVERT(DATE, GETDATE())),
  CONSTRAINT PK_Valoraciones PRIMARY KEY (ValoracionID),
  CONSTRAINT UQ_Valoraciones_CursoID UNIQUE (CursoID),
  CONSTRAINT FK_Valoraciones_Cursos FOREIGN KEY (CursoID) REFERENCES dbo.Cursos(CursoID),
  CONSTRAINT CK_Valoraciones_Puntuacion CHECK (Puntuacion BETWEEN 1 AND 5)
);
GO

-- ============================================
-- Seccion 4: Indices iniciales para busqueda
-- ============================================
CREATE INDEX IX_Cursos_Titulo ON dbo.Cursos (Titulo);
CREATE INDEX IX_Cursos_AutorID ON dbo.Cursos (AutorID);
CREATE INDEX IX_Cursos_PlataformaID ON dbo.Cursos (PlataformaID);
CREATE INDEX IX_CursosCategorias_CategoriaID ON dbo.CursosCategorias (CategoriaID, CursoID);
CREATE INDEX IX_Progreso_Estado_Porcentaje ON dbo.Progreso (Estado, Porcentaje);
CREATE INDEX IX_Valoraciones_Puntuacion ON dbo.Valoraciones (Puntuacion DESC);
GO

-- ============================================
-- Seccion 5: Datos de ejemplo
-- ============================================
INSERT INTO dbo.Plataformas
  (Nombre, UrlOficial)
VALUES
  (N'LinkedIn Learning', N'https://www.linkedin.com/learning'),
  (N'Microsoft Learn', N'https://learn.microsoft.com/training');

INSERT INTO dbo.Autores
  (NombreCompleto, Pais, PerfilUrl)
VALUES
  (N'Jess Stratton', N'Estados Unidos', N'https://www.linkedin.com/learning/instructors/jess-stratton'),
  (N'Morten Rand-Hendriksen', N'Canada', N'https://www.linkedin.com/learning/instructors/morten-rand-hendriksen'),
  (N'Ray Villalobos', N'Estados Unidos', N'https://www.linkedin.com/learning/instructors/ray-villalobos'),
  (N'Gini von Courter', N'Estados Unidos', N'https://www.linkedin.com/learning/instructors/gini-von-courter');

INSERT INTO dbo.Categorias
  (Nombre, Descripcion)
VALUES
  (N'SQL Server', N'Administracion, consulta y optimizacion en SQL Server.'),
  (N'Administracion de BD', N'Buenas practicas de administracion y mantenimiento.'),
  (N'Analisis de Datos', N'Modelado, exploracion y consumo de datos para decisiones.'),
  (N'Desarrollo Backend', N'Construccion de soluciones y servicios de datos.'),
  (N'Productividad Tecnica', N'Herramientas y practicas para trabajar mejor en equipo.');

INSERT INTO dbo.Cursos
  (
  PlataformaID,
  AutorID,
  Titulo,
  UrlCurso,
  Nivel,
  DuracionMinutos,
  FechaPublicacion,
  Activo
  )
VALUES
  (1, 1, N'SQL Server: Fundamentos Esenciales', N'https://www.linkedin.com/learning/sql-server-fundamentos-esenciales', N'Basico', 190, '2024-01-15', 1),
  (1, 1, N'T-SQL para Consultas Avanzadas', N'https://www.linkedin.com/learning/t-sql-para-consultas-avanzadas', N'Avanzado', 240, '2024-05-20', 1),
  (1, 4, N'Administracion de SQL Server: Backup y Restore', N'https://www.linkedin.com/learning/administracion-sql-server-backup-restore', N'Intermedio', 150, '2023-11-10', 1),
  (1, 2, N'Diseno de Bases de Datos Relacionales', N'https://www.linkedin.com/learning/diseno-bases-datos-relacionales', N'Intermedio', 210, '2022-09-07', 1),
  (1, 3, N'Power BI para Analisis de Datos', N'https://www.linkedin.com/learning/power-bi-para-analisis-de-datos', N'Basico', 180, '2024-03-12', 1),
  (2, 4, N'Azure SQL Database: Implementacion', N'https://learn.microsoft.com/training/azure-sql-database-implementacion', N'Intermedio', 130, '2025-02-01', 1),
  (1, 4, N'Optimizacion de Consultas en SQL Server', N'https://www.linkedin.com/learning/optimizacion-consultas-sql-server', N'Avanzado', 220, '2024-08-25', 1),
  (1, 2, N'Git para Equipos de Datos', N'https://www.linkedin.com/learning/git-para-equipos-de-datos', N'Basico', 95, '2023-06-18', 1);

INSERT INTO dbo.CursosCategorias
  (CursoID, CategoriaID)
VALUES
  (1, 1),
  (1, 4),
  (2, 1),
  (2, 3),
  (3, 1),
  (3, 2),
  (4, 2),
  (4, 4),
  (5, 3),
  (5, 5),
  (6, 1),
  (6, 4),
  (7, 1),
  (7, 2),
  (8, 4),
  (8, 5);

INSERT INTO dbo.Progreso
  (
  CursoID,
  Estado,
  Porcentaje,
  FechaInicio,
  FechaUltimoAvance,
  FechaCompletado
  )
VALUES
  (1, N'Completado', 100, '2026-01-03', '2026-01-18', '2026-01-18'),
  (2, N'En progreso', 65, '2026-02-02', '2026-03-10', NULL),
  (3, N'Pendiente', 0, NULL, NULL, NULL),
  (4, N'Completado', 100, '2025-12-15', '2026-01-05', '2026-01-05'),
  (5, N'En progreso', 40, '2026-02-20', '2026-03-11', NULL),
  (6, N'Pendiente', 0, NULL, NULL, NULL),
  (7, N'Completado', 100, '2026-01-25', '2026-02-12', '2026-02-12'),
  (8, N'En progreso', 20, '2026-03-01', '2026-03-09', NULL);

INSERT INTO dbo.Valoraciones
  (
  CursoID,
  Puntuacion,
  Recomendado,
  Comentario,
  FechaValoracion
  )
VALUES
  (1, 5, 1, N'Muy claro y practico para comenzar con SQL Server.', '2026-01-18'),
  (2, 4, 1, N'Excelente profundidad en consultas y rendimiento.', '2026-03-10'),
  (3, 4, 1, N'Contenido relevante para continuidad operativa.', '2026-03-01'),
  (4, 5, 1, N'Base solida para modelar esquemas relacionales.', '2026-01-05'),
  (5, 4, 1, N'Buen equilibrio entre teoria y casos aplicados.', '2026-03-11'),
  (6, 3, 0, N'Util, pero aun debo terminar practicas.', '2026-03-05'),
  (7, 5, 1, N'Imprescindible para mejorar tiempos de respuesta.', '2026-02-12'),
  (8, 4, 1, N'Ayuda mucho a ordenar el trabajo en equipo.', '2026-03-09');
GO

-- ============================================
-- Seccion 6: Consultas utiles
-- ============================================

-- Cursos pendientes
SELECT
  c.CursoID,
  c.Titulo,
  a.NombreCompleto AS Autor,
  pl.Nombre AS Plataforma,
  p.Estado,
  p.Porcentaje
FROM dbo.Cursos AS c
  INNER JOIN dbo.Progreso AS p ON p.CursoID = c.CursoID
  INNER JOIN dbo.Autores AS a ON a.AutorID = c.AutorID
  INNER JOIN dbo.Plataformas AS pl ON pl.PlataformaID = c.PlataformaID
WHERE p.Estado = N'Pendiente'
ORDER BY c.Titulo;

-- Cursos completados
SELECT
  c.CursoID,
  c.Titulo,
  a.NombreCompleto AS Autor,
  p.FechaCompletado
FROM dbo.Cursos AS c
  INNER JOIN dbo.Progreso AS p ON p.CursoID = c.CursoID
  INNER JOIN dbo.Autores AS a ON a.AutorID = c.AutorID
WHERE p.Estado = N'Completado'
ORDER BY p.FechaCompletado DESC, c.Titulo;

-- Cursos mejor valorados
SELECT
  c.CursoID,
  c.Titulo,
  v.Puntuacion,
  v.Recomendado,
  v.FechaValoracion
FROM dbo.Cursos AS c
  INNER JOIN dbo.Valoraciones AS v ON v.CursoID = c.CursoID
WHERE v.Puntuacion >= 4
ORDER BY v.Puntuacion DESC, v.FechaValoracion DESC, c.Titulo;

-- Progreso medio por categoria
SELECT
  cat.CategoriaID,
  cat.Nombre AS Categoria,
  CAST(AVG(p.Porcentaje) AS DECIMAL(5,2)) AS ProgresoMedioPorcentaje
FROM dbo.Categorias AS cat
  INNER JOIN dbo.CursosCategorias AS cc ON cc.CategoriaID = cat.CategoriaID
  INNER JOIN dbo.Progreso AS p ON p.CursoID = cc.CursoID
GROUP BY cat.CategoriaID, cat.Nombre
ORDER BY ProgresoMedioPorcentaje DESC, cat.Nombre;

-- Cursos por autor
SELECT
  a.AutorID,
  a.NombreCompleto AS Autor,
  c.CursoID,
  c.Titulo,
  p.Estado,
  p.Porcentaje
FROM dbo.Autores AS a
  INNER JOIN dbo.Cursos AS c ON c.AutorID = a.AutorID
  INNER JOIN dbo.Progreso AS p ON p.CursoID = c.CursoID
ORDER BY a.NombreCompleto, c.Titulo;

-- ============================================
-- Seccion 7: Validaciones finales
-- ============================================

-- Conteos por tabla
  SELECT N'Plataformas' AS Tabla, COUNT(*) AS TotalRegistros
  FROM dbo.Plataformas
UNION ALL
  SELECT N'Autores', COUNT(*)
  FROM dbo.Autores
UNION ALL
  SELECT N'Categorias', COUNT(*)
  FROM dbo.Categorias
UNION ALL
  SELECT N'Cursos', COUNT(*)
  FROM dbo.Cursos
UNION ALL
  SELECT N'CursosCategorias', COUNT(*)
  FROM dbo.CursosCategorias
UNION ALL
  SELECT N'Progreso', COUNT(*)
  FROM dbo.Progreso
UNION ALL
  SELECT N'Valoraciones', COUNT(*)
  FROM dbo.Valoraciones;

-- Integridad referencial: cursos sin autor valido
SELECT COUNT(*) AS CursosSinAutorValido
FROM dbo.Cursos AS c
  LEFT JOIN dbo.Autores AS a ON a.AutorID = c.AutorID
WHERE a.AutorID IS NULL;

-- Integridad referencial: cursos sin plataforma valida
SELECT COUNT(*) AS CursosSinPlataformaValida
FROM dbo.Cursos AS c
  LEFT JOIN dbo.Plataformas AS p ON p.PlataformaID = c.PlataformaID
WHERE p.PlataformaID IS NULL;

-- Integridad referencial: enlaces curso-categoria invalidos
SELECT COUNT(*) AS EnlacesCursoCategoriaInvalidos
FROM dbo.CursosCategorias AS cc
  LEFT JOIN dbo.Cursos AS c ON c.CursoID = cc.CursoID
  LEFT JOIN dbo.Categorias AS cat ON cat.CategoriaID = cc.CategoriaID
WHERE c.CursoID IS NULL OR cat.CategoriaID IS NULL;

-- Integridad referencial: progreso sin curso valido
SELECT COUNT(*) AS ProgresoSinCursoValido
FROM dbo.Progreso AS pr
  LEFT JOIN dbo.Cursos AS c ON c.CursoID = pr.CursoID
WHERE c.CursoID IS NULL;

-- Integridad referencial: valoraciones sin curso valido
SELECT COUNT(*) AS ValoracionesSinCursoValido
FROM dbo.Valoraciones AS v
  LEFT JOIN dbo.Cursos AS c ON c.CursoID = v.CursoID
WHERE c.CursoID IS NULL;
GO

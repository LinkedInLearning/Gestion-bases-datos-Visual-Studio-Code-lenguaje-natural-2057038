IF DB_ID(N'GestorDocumentalDb') IS NULL
BEGIN
  CREATE DATABASE GestorDocumentalDb;
END;
GO

USE GestorDocumentalDb;
GO

CREATE TABLE dbo.Usuarios
(
  UsuarioId INT IDENTITY(1,1) NOT NULL,
  NombreCompleto NVARCHAR(150) NOT NULL,
  Email NVARCHAR(320) NOT NULL,
  HashContrasena NVARCHAR(255) NOT NULL,
  Activo BIT NOT NULL CONSTRAINT DF_Usuarios_Activo DEFAULT (1),
  FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Usuarios_FechaCreacion DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT PK_Usuarios PRIMARY KEY CLUSTERED (UsuarioId),
  CONSTRAINT UQ_Usuarios_Email UNIQUE (Email)
);
GO

CREATE TABLE dbo.Categorias
(
  CategoriaId INT IDENTITY(1,1) NOT NULL,
  Nombre NVARCHAR(120) NOT NULL,
  Descripcion NVARCHAR(400) NULL,
  CategoriaPadreId INT NULL,
  Activa BIT NOT NULL CONSTRAINT DF_Categorias_Activa DEFAULT (1),
  FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Categorias_FechaCreacion DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT PK_Categorias PRIMARY KEY CLUSTERED (CategoriaId),
  CONSTRAINT UQ_Categorias_Nombre UNIQUE (Nombre),
  CONSTRAINT FK_Categorias_CategoriaPadre FOREIGN KEY (CategoriaPadreId)
        REFERENCES dbo.Categorias (CategoriaId)
);
GO

CREATE TABLE dbo.Documentos
(
  DocumentoId BIGINT IDENTITY(1,1) NOT NULL,
  Titulo NVARCHAR(250) NOT NULL,
  Descripcion NVARCHAR(MAX) NULL,
  CategoriaId INT NULL,
  PropietarioUsuarioId INT NOT NULL,
  Estado VARCHAR(20) NOT NULL CONSTRAINT DF_Documentos_Estado DEFAULT ('BORRADOR'),
  FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Documentos_FechaCreacion DEFAULT (SYSUTCDATETIME()),
  FechaActualizacion DATETIME2(0) NOT NULL CONSTRAINT DF_Documentos_FechaActualizacion DEFAULT (SYSUTCDATETIME()),
  VersionFila ROWVERSION,
  CONSTRAINT PK_Documentos PRIMARY KEY CLUSTERED (DocumentoId),
  CONSTRAINT CK_Documentos_Estado CHECK (Estado IN ('BORRADOR', 'PUBLICADO', 'ARCHIVADO')),
  CONSTRAINT FK_Documentos_Categorias FOREIGN KEY (CategoriaId)
        REFERENCES dbo.Categorias (CategoriaId),
  CONSTRAINT FK_Documentos_Usuarios_Propietario FOREIGN KEY (PropietarioUsuarioId)
        REFERENCES dbo.Usuarios (UsuarioId)
);
GO

CREATE TABLE dbo.Etiquetas
(
  EtiquetaId INT IDENTITY(1,1) NOT NULL,
  Nombre NVARCHAR(80) NOT NULL,
  FechaCreacion DATETIME2(0) NOT NULL CONSTRAINT DF_Etiquetas_FechaCreacion DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT PK_Etiquetas PRIMARY KEY CLUSTERED (EtiquetaId),
  CONSTRAINT UQ_Etiquetas_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE dbo.DocumentoEtiquetas
(
  DocumentoId BIGINT NOT NULL,
  EtiquetaId INT NOT NULL,
  FechaAsignacion DATETIME2(0) NOT NULL CONSTRAINT DF_DocumentoEtiquetas_FechaAsignacion DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT PK_DocumentoEtiquetas PRIMARY KEY CLUSTERED (DocumentoId, EtiquetaId),
  CONSTRAINT FK_DocumentoEtiquetas_Documentos FOREIGN KEY (DocumentoId)
        REFERENCES dbo.Documentos (DocumentoId)
        ON DELETE CASCADE,
  CONSTRAINT FK_DocumentoEtiquetas_Etiquetas FOREIGN KEY (EtiquetaId)
        REFERENCES dbo.Etiquetas (EtiquetaId)
        ON DELETE CASCADE
);
GO

CREATE TABLE dbo.Versiones
(
  VersionId BIGINT IDENTITY(1,1) NOT NULL,
  DocumentoId BIGINT NOT NULL,
  NumeroVersion INT NOT NULL,
  NombreArchivo NVARCHAR(260) NOT NULL,
  Extension NVARCHAR(20) NULL,
  TamanoBytes BIGINT NOT NULL,
  HashContenido CHAR(64) NULL,
  Comentario NVARCHAR(500) NULL,
  CargadoPorUsuarioId INT NOT NULL,
  FechaCarga DATETIME2(0) NOT NULL CONSTRAINT DF_Versiones_FechaCarga DEFAULT (SYSUTCDATETIME()),
  EsActual BIT NOT NULL CONSTRAINT DF_Versiones_EsActual DEFAULT (1),
  CONSTRAINT PK_Versiones PRIMARY KEY CLUSTERED (VersionId),
  CONSTRAINT UQ_Versiones_Documento_Numero UNIQUE (DocumentoId, NumeroVersion),
  CONSTRAINT CK_Versiones_TamanoBytes CHECK (TamanoBytes >= 0),
  CONSTRAINT CK_Versiones_NumeroVersion CHECK (NumeroVersion > 0),
  CONSTRAINT FK_Versiones_Documentos FOREIGN KEY (DocumentoId)
        REFERENCES dbo.Documentos (DocumentoId)
        ON DELETE CASCADE,
  CONSTRAINT FK_Versiones_Usuarios FOREIGN KEY (CargadoPorUsuarioId)
        REFERENCES dbo.Usuarios (UsuarioId)
);
GO

CREATE TABLE dbo.Permisos
(
  PermisoId BIGINT IDENTITY(1,1) NOT NULL,
  DocumentoId BIGINT NOT NULL,
  UsuarioId INT NOT NULL,
  NivelPermiso VARCHAR(20) NOT NULL,
  OtorgadoPorUsuarioId INT NULL,
  FechaOtorgamiento DATETIME2(0) NOT NULL CONSTRAINT DF_Permisos_FechaOtorgamiento DEFAULT (SYSUTCDATETIME()),
  FechaExpiracion DATETIME2(0) NULL,
  CONSTRAINT PK_Permisos PRIMARY KEY CLUSTERED (PermisoId),
  CONSTRAINT UQ_Permisos_Documento_Usuario UNIQUE (DocumentoId, UsuarioId),
  CONSTRAINT CK_Permisos_Nivel CHECK (NivelPermiso IN ('LECTURA', 'COMENTARIO', 'EDICION', 'ADMIN')),
  CONSTRAINT CK_Permisos_FechaExpiracion CHECK (FechaExpiracion IS NULL OR FechaExpiracion >= FechaOtorgamiento),
  CONSTRAINT FK_Permisos_Documentos FOREIGN KEY (DocumentoId)
        REFERENCES dbo.Documentos (DocumentoId)
        ON DELETE CASCADE,
  CONSTRAINT FK_Permisos_Usuarios FOREIGN KEY (UsuarioId)
        REFERENCES dbo.Usuarios (UsuarioId),
  CONSTRAINT FK_Permisos_Usuarios_Otorga FOREIGN KEY (OtorgadoPorUsuarioId)
        REFERENCES dbo.Usuarios (UsuarioId)
);
GO

CREATE INDEX IX_Categorias_CategoriaPadreId
    ON dbo.Categorias (CategoriaPadreId);
GO

CREATE INDEX IX_Documentos_CategoriaId
    ON dbo.Documentos (CategoriaId);
GO

CREATE INDEX IX_Documentos_Propietario_Estado_Fecha
    ON dbo.Documentos (PropietarioUsuarioId, Estado, FechaActualizacion DESC);
GO

CREATE INDEX IX_Documentos_FechaCreacion
    ON dbo.Documentos (FechaCreacion DESC);
GO

CREATE INDEX IX_DocumentoEtiquetas_EtiquetaId
    ON dbo.DocumentoEtiquetas (EtiquetaId, DocumentoId);
GO

CREATE INDEX IX_Versiones_Documento_Fecha
    ON dbo.Versiones (DocumentoId, FechaCarga DESC);
GO

CREATE UNIQUE INDEX UX_Versiones_Documento_EsActual
    ON dbo.Versiones (DocumentoId)
    WHERE EsActual = 1;
GO

CREATE INDEX IX_Permisos_Usuario_Nivel
    ON dbo.Permisos (UsuarioId, NivelPermiso);
GO

CREATE INDEX IX_Permisos_Documento_Nivel
    ON dbo.Permisos (DocumentoId, NivelPermiso);
GO

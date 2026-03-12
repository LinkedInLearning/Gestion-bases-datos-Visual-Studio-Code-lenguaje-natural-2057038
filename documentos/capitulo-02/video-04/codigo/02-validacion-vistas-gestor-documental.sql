IF DB_ID(N'GestorDocumentalDb') IS NULL
BEGIN
THROW 50001, 'La base de datos GestorDocumentalDb no existe. Ejecuta primero los scripts de esquema y datos.', 1;
END;
GO

USE GestorDocumentalDb;
GO

SET NOCOUNT ON;

SELECT TOP (20)
  DocumentoId,
  Titulo,
  Estado,
  Categoria,
  Propietario,
  VersionActual,
  ArchivoVersionActual,
  Etiquetas,
  FechaActualizacion
FROM dbo.vw_DocumentosConsulta
ORDER BY FechaActualizacion DESC;

SELECT
  Estado,
  CantidadDocumentos,
  CantidadPropietarios,
  UltimaActualizacion
FROM dbo.vw_EstadosDocumentos
ORDER BY Estado;

SELECT TOP (30)
  FechaActividad,
  TipoActividad,
  DocumentoId,
  Titulo,
  UsuarioRelacionado,
  Detalle
FROM dbo.vw_ActividadRecienteDocumentos
ORDER BY FechaActividad DESC;

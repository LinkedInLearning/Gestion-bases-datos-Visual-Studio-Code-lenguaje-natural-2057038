IF DB_ID(N'GestorDocumentalDb') IS NULL
BEGIN
THROW 50001, 'La base de datos GestorDocumentalDb no existe. Ejecuta primero los scripts de esquema y datos.', 1;
END;
GO

USE GestorDocumentalDb;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW dbo.vw_DocumentosConsulta
AS
  SELECT
    d.DocumentoId,
    d.Titulo,
    d.Estado,
    c.Nombre AS Categoria,
    u.NombreCompleto AS Propietario,
    d.FechaCreacion,
    d.FechaActualizacion,
    v.NumeroVersion AS VersionActual,
    v.NombreArchivo AS ArchivoVersionActual,
    ISNULL(et.Etiquetas, N'') AS Etiquetas
  FROM dbo.Documentos d
    LEFT JOIN dbo.Categorias c ON c.CategoriaId = d.CategoriaId
    INNER JOIN dbo.Usuarios u ON u.UsuarioId = d.PropietarioUsuarioId
OUTER APPLY
(
  SELECT TOP (1)
      v1.NumeroVersion,
      v1.NombreArchivo
    FROM dbo.Versiones v1
    WHERE v1.DocumentoId = d.DocumentoId
    ORDER BY v1.EsActual DESC, v1.NumeroVersion DESC
) v
OUTER APPLY
(
  SELECT STRING_AGG(e.Nombre, N', ') AS Etiquetas
    FROM dbo.DocumentoEtiquetas de
      INNER JOIN dbo.Etiquetas e ON e.EtiquetaId = de.EtiquetaId
    WHERE de.DocumentoId = d.DocumentoId
) et;
GO

CREATE OR ALTER VIEW dbo.vw_EstadosDocumentos
AS
  SELECT
    d.Estado,
    COUNT_BIG(*) AS CantidadDocumentos,
    COUNT_BIG(DISTINCT d.PropietarioUsuarioId) AS CantidadPropietarios,
    MAX(d.FechaActualizacion) AS UltimaActualizacion
  FROM dbo.Documentos d
  GROUP BY d.Estado;
GO

CREATE OR ALTER VIEW dbo.vw_ActividadRecienteDocumentos
AS
        SELECT
      d.FechaActualizacion AS FechaActividad,
      CAST('ACTUALIZACION_DOCUMENTO' AS VARCHAR(40)) AS TipoActividad,
      d.DocumentoId,
      d.Titulo,
      u.NombreCompleto AS UsuarioRelacionado,
      CONCAT(N'Estado actual: ', d.Estado) AS Detalle
    FROM dbo.Documentos d
      INNER JOIN dbo.Usuarios u ON u.UsuarioId = d.PropietarioUsuarioId

  UNION ALL

    SELECT
      v.FechaCarga AS FechaActividad,
      CAST('CARGA_VERSION' AS VARCHAR(40)) AS TipoActividad,
      d.DocumentoId,
      d.Titulo,
      uc.NombreCompleto AS UsuarioRelacionado,
      CONCAT(N'Version ', v.NumeroVersion, N' - ', v.NombreArchivo) AS Detalle
    FROM dbo.Versiones v
      INNER JOIN dbo.Documentos d ON d.DocumentoId = v.DocumentoId
      INNER JOIN dbo.Usuarios uc ON uc.UsuarioId = v.CargadoPorUsuarioId

  UNION ALL

    SELECT
      p.FechaOtorgamiento AS FechaActividad,
      CAST('OTORGAMIENTO_PERMISO' AS VARCHAR(40)) AS TipoActividad,
      d.DocumentoId,
      d.Titulo,
      COALESCE(uo.NombreCompleto, N'SISTEMA') AS UsuarioRelacionado,
      CONCAT(N'Permiso ', p.NivelPermiso, N' para ', ub.NombreCompleto) AS Detalle
    FROM dbo.Permisos p
      INNER JOIN dbo.Documentos d ON d.DocumentoId = p.DocumentoId
      INNER JOIN dbo.Usuarios ub ON ub.UsuarioId = p.UsuarioId
      LEFT JOIN dbo.Usuarios uo ON uo.UsuarioId = p.OtorgadoPorUsuarioId;
GO

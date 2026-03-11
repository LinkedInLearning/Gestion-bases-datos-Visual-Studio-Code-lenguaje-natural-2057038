IF DB_ID(N'GestorDocumentalDb') IS NULL
BEGIN
THROW 50001, 'La base de datos GestorDocumentalDb no existe. Ejecuta primero el script de esquema.', 1;
END;
GO

USE GestorDocumentalDb;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  -- 1) Usuarios
  INSERT INTO dbo.Usuarios
  (NombreCompleto, Email, HashContrasena, Activo)
SELECT N'Ana Perez', N'ana.perez@empresa.local', N'hash_demo_ana', 1
WHERE NOT EXISTS (SELECT 1
FROM dbo.Usuarios
WHERE Email = N'ana.perez@empresa.local');

  INSERT INTO dbo.Usuarios
  (NombreCompleto, Email, HashContrasena, Activo)
SELECT N'Luis Gomez', N'luis.gomez@empresa.local', N'hash_demo_luis', 1
WHERE NOT EXISTS (SELECT 1
FROM dbo.Usuarios
WHERE Email = N'luis.gomez@empresa.local');

  INSERT INTO dbo.Usuarios
  (NombreCompleto, Email, HashContrasena, Activo)
SELECT N'Marta Ruiz', N'marta.ruiz@empresa.local', N'hash_demo_marta', 1
WHERE NOT EXISTS (SELECT 1
FROM dbo.Usuarios
WHERE Email = N'marta.ruiz@empresa.local');

  INSERT INTO dbo.Usuarios
  (NombreCompleto, Email, HashContrasena, Activo)
SELECT N'Carlos Diaz', N'carlos.diaz@empresa.local', N'hash_demo_carlos', 0
WHERE NOT EXISTS (SELECT 1
FROM dbo.Usuarios
WHERE Email = N'carlos.diaz@empresa.local');

  -- 2) Categorias (raiz)
  INSERT INTO dbo.Categorias
  (Nombre, Descripcion, CategoriaPadreId, Activa)
SELECT N'Recursos Humanos', N'Documentos de gestion de personal', NULL, 1
WHERE NOT EXISTS (SELECT 1
FROM dbo.Categorias
WHERE Nombre = N'Recursos Humanos');

  INSERT INTO dbo.Categorias
  (Nombre, Descripcion, CategoriaPadreId, Activa)
SELECT N'Finanzas', N'Documentos contables y financieros', NULL, 1
WHERE NOT EXISTS (SELECT 1
FROM dbo.Categorias
WHERE Nombre = N'Finanzas');

  INSERT INTO dbo.Categorias
  (Nombre, Descripcion, CategoriaPadreId, Activa)
SELECT N'Legal', N'Contratos y documentos legales', NULL, 1
WHERE NOT EXISTS (SELECT 1
FROM dbo.Categorias
WHERE Nombre = N'Legal');

  -- 3) Categorias (hijas)
  INSERT INTO dbo.Categorias
  (Nombre, Descripcion, CategoriaPadreId, Activa)
SELECT N'Nomina', N'Liquidaciones y recibos', c.CategoriaId, 1
FROM dbo.Categorias c
WHERE c.Nombre = N'Recursos Humanos'
  AND NOT EXISTS (SELECT 1
  FROM dbo.Categorias
  WHERE Nombre = N'Nomina');

  INSERT INTO dbo.Categorias
  (Nombre, Descripcion, CategoriaPadreId, Activa)
SELECT N'Facturacion', N'Facturas emitidas y recibidas', c.CategoriaId, 1
FROM dbo.Categorias c
WHERE c.Nombre = N'Finanzas'
  AND NOT EXISTS (SELECT 1
  FROM dbo.Categorias
  WHERE Nombre = N'Facturacion');

  INSERT INTO dbo.Categorias
  (Nombre, Descripcion, CategoriaPadreId, Activa)
SELECT N'Contratos', N'Acuerdos con clientes y proveedores', c.CategoriaId, 1
FROM dbo.Categorias c
WHERE c.Nombre = N'Legal'
  AND NOT EXISTS (SELECT 1
  FROM dbo.Categorias
  WHERE Nombre = N'Contratos');

  -- 4) Etiquetas
  INSERT INTO dbo.Etiquetas
  (Nombre)
SELECT N'urgente'
WHERE NOT EXISTS (SELECT 1
FROM dbo.Etiquetas
WHERE Nombre = N'urgente');

  INSERT INTO dbo.Etiquetas
  (Nombre)
SELECT N'auditoria'
WHERE NOT EXISTS (SELECT 1
FROM dbo.Etiquetas
WHERE Nombre = N'auditoria');

  INSERT INTO dbo.Etiquetas
  (Nombre)
SELECT N'confidencial'
WHERE NOT EXISTS (SELECT 1
FROM dbo.Etiquetas
WHERE Nombre = N'confidencial');

  INSERT INTO dbo.Etiquetas
  (Nombre)
SELECT N'2026'
WHERE NOT EXISTS (SELECT 1
FROM dbo.Etiquetas
WHERE Nombre = N'2026');

  -- 5) Documentos
  INSERT INTO dbo.Documentos
  (Titulo, Descripcion, CategoriaId, PropietarioUsuarioId, Estado)
SELECT
  N'Politica de vacaciones 2026',
  N'Politica corporativa actualizada para el periodo 2026.',
  c.CategoriaId,
  u.UsuarioId,
  'PUBLICADO'
FROM dbo.Categorias c
  INNER JOIN dbo.Usuarios u ON u.Email = N'ana.perez@empresa.local'
WHERE c.Nombre = N'Nomina'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.Documentos d
  WHERE d.Titulo = N'Politica de vacaciones 2026'
    AND d.PropietarioUsuarioId = u.UsuarioId
    );

  INSERT INTO dbo.Documentos
  (Titulo, Descripcion, CategoriaId, PropietarioUsuarioId, Estado)
SELECT
  N'Procedimiento de facturacion Q1',
  N'Flujo operativo para registro y validacion de facturas del primer trimestre.',
  c.CategoriaId,
  u.UsuarioId,
  'BORRADOR'
FROM dbo.Categorias c
  INNER JOIN dbo.Usuarios u ON u.Email = N'luis.gomez@empresa.local'
WHERE c.Nombre = N'Facturacion'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.Documentos d
  WHERE d.Titulo = N'Procedimiento de facturacion Q1'
    AND d.PropietarioUsuarioId = u.UsuarioId
    );

  INSERT INTO dbo.Documentos
  (Titulo, Descripcion, CategoriaId, PropietarioUsuarioId, Estado)
SELECT
  N'Contrato marco proveedor TI',
  N'Condiciones generales para servicios de tecnologia.',
  c.CategoriaId,
  u.UsuarioId,
  'ARCHIVADO'
FROM dbo.Categorias c
  INNER JOIN dbo.Usuarios u ON u.Email = N'marta.ruiz@empresa.local'
WHERE c.Nombre = N'Contratos'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.Documentos d
  WHERE d.Titulo = N'Contrato marco proveedor TI'
    AND d.PropietarioUsuarioId = u.UsuarioId
    );

  -- 6) Relacion Documento-Etiquetas
  INSERT INTO dbo.DocumentoEtiquetas
  (DocumentoId, EtiquetaId)
SELECT d.DocumentoId, e.EtiquetaId
FROM dbo.Documentos d
  INNER JOIN dbo.Etiquetas e ON e.Nombre = N'2026'
WHERE d.Titulo = N'Politica de vacaciones 2026'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.DocumentoEtiquetas de
  WHERE de.DocumentoId = d.DocumentoId
    AND de.EtiquetaId = e.EtiquetaId
    );

  INSERT INTO dbo.DocumentoEtiquetas
  (DocumentoId, EtiquetaId)
SELECT d.DocumentoId, e.EtiquetaId
FROM dbo.Documentos d
  INNER JOIN dbo.Etiquetas e ON e.Nombre = N'urgente'
WHERE d.Titulo = N'Procedimiento de facturacion Q1'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.DocumentoEtiquetas de
  WHERE de.DocumentoId = d.DocumentoId
    AND de.EtiquetaId = e.EtiquetaId
    );

  INSERT INTO dbo.DocumentoEtiquetas
  (DocumentoId, EtiquetaId)
SELECT d.DocumentoId, e.EtiquetaId
FROM dbo.Documentos d
  INNER JOIN dbo.Etiquetas e ON e.Nombre = N'confidencial'
WHERE d.Titulo = N'Contrato marco proveedor TI'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.DocumentoEtiquetas de
  WHERE de.DocumentoId = d.DocumentoId
    AND de.EtiquetaId = e.EtiquetaId
    );

  INSERT INTO dbo.DocumentoEtiquetas
  (DocumentoId, EtiquetaId)
SELECT d.DocumentoId, e.EtiquetaId
FROM dbo.Documentos d
  INNER JOIN dbo.Etiquetas e ON e.Nombre = N'auditoria'
WHERE d.Titulo = N'Contrato marco proveedor TI'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.DocumentoEtiquetas de
  WHERE de.DocumentoId = d.DocumentoId
    AND de.EtiquetaId = e.EtiquetaId
    );

  -- 7) Versiones (1 version actual por documento)
  INSERT INTO dbo.Versiones
  (
  DocumentoId,
  NumeroVersion,
  NombreArchivo,
  Extension,
  TamanoBytes,
  HashContenido,
  Comentario,
  CargadoPorUsuarioId,
  EsActual
  )
SELECT
  d.DocumentoId,
  1,
  N'politica_vacaciones_2026_v1.pdf',
  N'.pdf',
  245760,
  '1111111111111111111111111111111111111111111111111111111111111111',
  N'Primera publicacion',
  u.UsuarioId,
  1
FROM dbo.Documentos d
  INNER JOIN dbo.Usuarios u ON u.Email = N'ana.perez@empresa.local'
WHERE d.Titulo = N'Politica de vacaciones 2026'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.Versiones v
  WHERE v.DocumentoId = d.DocumentoId
    AND v.NumeroVersion = 1
    );

  INSERT INTO dbo.Versiones
  (
  DocumentoId,
  NumeroVersion,
  NombreArchivo,
  Extension,
  TamanoBytes,
  HashContenido,
  Comentario,
  CargadoPorUsuarioId,
  EsActual
  )
SELECT
  d.DocumentoId,
  1,
  N'procedimiento_facturacion_q1_v1.docx',
  N'.docx',
  98304,
  '2222222222222222222222222222222222222222222222222222222222222222',
  N'Borrador inicial',
  u.UsuarioId,
  1
FROM dbo.Documentos d
  INNER JOIN dbo.Usuarios u ON u.Email = N'luis.gomez@empresa.local'
WHERE d.Titulo = N'Procedimiento de facturacion Q1'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.Versiones v
  WHERE v.DocumentoId = d.DocumentoId
    AND v.NumeroVersion = 1
    );

  INSERT INTO dbo.Versiones
  (
  DocumentoId,
  NumeroVersion,
  NombreArchivo,
  Extension,
  TamanoBytes,
  HashContenido,
  Comentario,
  CargadoPorUsuarioId,
  EsActual
  )
SELECT
  d.DocumentoId,
  1,
  N'contrato_marco_ti_v1.pdf',
  N'.pdf',
  331776,
  '3333333333333333333333333333333333333333333333333333333333333333',
  N'Version contractual original',
  u.UsuarioId,
  0
FROM dbo.Documentos d
  INNER JOIN dbo.Usuarios u ON u.Email = N'marta.ruiz@empresa.local'
WHERE d.Titulo = N'Contrato marco proveedor TI'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.Versiones v
  WHERE v.DocumentoId = d.DocumentoId
    AND v.NumeroVersion = 1
    );

  INSERT INTO dbo.Versiones
  (
  DocumentoId,
  NumeroVersion,
  NombreArchivo,
  Extension,
  TamanoBytes,
  HashContenido,
  Comentario,
  CargadoPorUsuarioId,
  EsActual
  )
SELECT
  d.DocumentoId,
  2,
  N'contrato_marco_ti_v2.pdf',
  N'.pdf',
  352256,
  '4444444444444444444444444444444444444444444444444444444444444444',
  N'Anexo de condiciones actualizado',
  u.UsuarioId,
  1
FROM dbo.Documentos d
  INNER JOIN dbo.Usuarios u ON u.Email = N'marta.ruiz@empresa.local'
WHERE d.Titulo = N'Contrato marco proveedor TI'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.Versiones v
  WHERE v.DocumentoId = d.DocumentoId
    AND v.NumeroVersion = 2
    );

  -- Garantiza una sola version actual por documento.
  ;WITH
  UltimaVersion
  AS
  (
    SELECT
      v.DocumentoId,
      MAX(v.NumeroVersion) AS NumeroMaximo
    FROM dbo.Versiones v
    GROUP BY v.DocumentoId
  )
  UPDATE v
  SET v.EsActual = CASE WHEN v.NumeroVersion = uv.NumeroMaximo THEN 1 ELSE 0 END
  FROM dbo.Versiones v
  INNER JOIN UltimaVersion uv ON uv.DocumentoId = v.DocumentoId;

  -- 8) Permisos
  INSERT INTO dbo.Permisos
  (
  DocumentoId,
  UsuarioId,
  NivelPermiso,
  OtorgadoPorUsuarioId,
  FechaExpiracion
  )
SELECT d.DocumentoId, uProp.UsuarioId, 'ADMIN', uProp.UsuarioId, NULL
FROM dbo.Documentos d
  INNER JOIN dbo.Usuarios uProp ON uProp.UsuarioId = d.PropietarioUsuarioId
WHERE NOT EXISTS (
      SELECT 1
FROM dbo.Permisos p
WHERE p.DocumentoId = d.DocumentoId
  AND p.UsuarioId = uProp.UsuarioId
  );

  INSERT INTO dbo.Permisos
  (
  DocumentoId,
  UsuarioId,
  NivelPermiso,
  OtorgadoPorUsuarioId,
  FechaExpiracion
  )
SELECT d.DocumentoId, uDestino.UsuarioId, 'LECTURA', uOtorga.UsuarioId, DATEADD(DAY, 90, SYSUTCDATETIME())
FROM dbo.Documentos d
  INNER JOIN dbo.Usuarios uOtorga ON uOtorga.Email = N'ana.perez@empresa.local'
  INNER JOIN dbo.Usuarios uDestino ON uDestino.Email = N'luis.gomez@empresa.local'
WHERE d.Titulo = N'Politica de vacaciones 2026'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.Permisos p
  WHERE p.DocumentoId = d.DocumentoId
    AND p.UsuarioId = uDestino.UsuarioId
    );

  INSERT INTO dbo.Permisos
  (
  DocumentoId,
  UsuarioId,
  NivelPermiso,
  OtorgadoPorUsuarioId,
  FechaExpiracion
  )
SELECT d.DocumentoId, uDestino.UsuarioId, 'EDICION', uOtorga.UsuarioId, NULL
FROM dbo.Documentos d
  INNER JOIN dbo.Usuarios uOtorga ON uOtorga.Email = N'marta.ruiz@empresa.local'
  INNER JOIN dbo.Usuarios uDestino ON uDestino.Email = N'ana.perez@empresa.local'
WHERE d.Titulo = N'Contrato marco proveedor TI'
  AND NOT EXISTS (
      SELECT 1
  FROM dbo.Permisos p
  WHERE p.DocumentoId = d.DocumentoId
    AND p.UsuarioId = uDestino.UsuarioId
    );

  COMMIT TRAN;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0
    ROLLBACK TRAN;

  THROW;
END CATCH;
GO

-- 9) Consultas de validacion rapida
  SELECT 'Usuarios' AS Entidad, COUNT(*) AS TotalRegistros
  FROM dbo.Usuarios
UNION ALL
  SELECT 'Categorias', COUNT(*)
  FROM dbo.Categorias
UNION ALL
  SELECT 'Documentos', COUNT(*)
  FROM dbo.Documentos
UNION ALL
  SELECT 'Etiquetas', COUNT(*)
  FROM dbo.Etiquetas
UNION ALL
  SELECT 'DocumentoEtiquetas', COUNT(*)
  FROM dbo.DocumentoEtiquetas
UNION ALL
  SELECT 'Versiones', COUNT(*)
  FROM dbo.Versiones
UNION ALL
  SELECT 'Permisos', COUNT(*)
  FROM dbo.Permisos;
GO

SELECT
  d.DocumentoId,
  d.Titulo,
  d.Estado,
  c.Nombre AS Categoria,
  u.NombreCompleto AS Propietario,
  v.NumeroVersion AS VersionActual,
  v.NombreArchivo
FROM dbo.Documentos d
  INNER JOIN dbo.Categorias c ON c.CategoriaId = d.CategoriaId
  INNER JOIN dbo.Usuarios u ON u.UsuarioId = d.PropietarioUsuarioId
  INNER JOIN dbo.Versiones v ON v.DocumentoId = d.DocumentoId AND v.EsActual = 1
ORDER BY d.DocumentoId;
GO

SELECT
  d.Titulo,
  u.NombreCompleto AS Usuario,
  p.NivelPermiso,
  p.FechaOtorgamiento,
  p.FechaExpiracion
FROM dbo.Permisos p
  INNER JOIN dbo.Documentos d ON d.DocumentoId = p.DocumentoId
  INNER JOIN dbo.Usuarios u ON u.UsuarioId = p.UsuarioId
ORDER BY d.DocumentoId, p.NivelPermiso;
GO

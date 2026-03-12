# GestionDocumentalMd

## 1. Propósito
GestorDocumentalDb implementa un modelo relacional para administrar documentos corporativos con trazabilidad, control de versiones, etiquetas, categorías y permisos por usuario.

Su objetivo es soportar:
- consulta operativa de documentos
- seguimiento de actividad reciente
- control de acceso por documento
- integridad de datos en el ciclo de vida documental

## 2. Modelo de datos

### 2.1 Entidades principales
- dbo.Usuarios: usuarios del sistema, correo electrónico único, estado activo.
- dbo.Categorias: clasificación documental con jerarquía padre-hijo.
- dbo.Documentos: entidad central (título, estado, propietario, categoría, fechas).
- dbo.Etiquetas: catálogo de etiquetas.
- dbo.DocumentoEtiquetas: relación N:M entre documentos y etiquetas.
- dbo.Versiones: historial de archivos por documento y marca de versión actual.
- dbo.Permisos: nivel de permiso por usuario para cada documento.

### 2.2 Reglas de integridad
- Estados de documento válidos: BORRADOR, PUBLICADO, ARCHIVADO.
- Niveles de permiso válidos: LECTURA, COMENTARIO, EDICION, ADMIN.
- Unicidad de email en usuarios.
- Unicidad de nombre en categorías y etiquetas.
- FechaExpiracion de permisos no puede ser menor que FechaOtorgamiento.
- Solo una versión actual por documento mediante índice filtrado (EsActual = 1).

### 2.3 Índices relevantes
- Documentos por propietario, estado y fecha de actualización.
- Versiones por documento y fecha de carga.
- Permisos por usuario/nivel y documento/nivel.
- Categorías por CategoriaPadreId.

## 3. Relaciones
- Usuarios (1) -> (N) Documentos (PropietarioUsuarioId).
- Categorías (1) -> (N) Documentos (CategoriaId).
- Categorías (1) -> (N) Categorías (CategoriaPadreId).
- Documentos (1) -> (N) Versiones.
- Documentos (N) <-> (N) Etiquetas mediante DocumentoEtiquetas.
- Documentos (1) -> (N) Permisos.
- Usuarios (1) -> (N) Versiones (CargadoPorUsuarioId).
- Usuarios (1) -> (N) Permisos como receptor y otorgante.

## 4. Vistas

### 4.1 dbo.vw_DocumentosConsulta
Consolida documento, categoría, propietario, versión actual y etiquetas para consumo operativo.

### 4.2 dbo.vw_EstadosDocumentos
Resume cantidad de documentos por estado, cantidad de propietarios y última actualización por estado.

### 4.3 dbo.vw_ActividadRecienteDocumentos
Unifica eventos en una sola línea temporal:
- actualización de documentos
- cargas de versiones
- otorgamiento de permisos

## 5. Despliegue
Ejecución manual recomendada en SQL Server:

1. Crear esquema:
   - documentos/capitulo-02/video-02/codigo/01-esquema-gestor-documental.sql
2. Cargar datos de ejemplo:
   - documentos/capitulo-02/video-03/codigo/02-datos-ejemplo-gestor-documental.sql
3. Crear vistas:
   - documentos/capitulo-02/video-04/codigo/01-vistas-consulta-gestor-documental.sql
4. Validar vistas:
   - documentos/capitulo-02/video-04/codigo/02-validacion-vistas-gestor-documental.sql

Recomendaciones:
- ejecutar por bloques GO y revisar mensajes en cada etapa
- conservar XACT_ABORT ON en cargas transaccionales
- repetir despliegue en ambiente limpio tras cambios estructurales

## 6. Ejemplos de consultas

### 6.1 Listado operativo de documentos
```sql
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
```

### 6.2 Resumen por estado
```sql
SELECT
  Estado,
  CantidadDocumentos,
  CantidadPropietarios,
  UltimaActualizacion
FROM dbo.vw_EstadosDocumentos
ORDER BY Estado;
```

### 6.3 Actividad reciente
```sql
SELECT TOP (30)
  FechaActividad,
  TipoActividad,
  DocumentoId,
  Titulo,
  UsuarioRelacionado,
  Detalle
FROM dbo.vw_ActividadRecienteDocumentos
ORDER BY FechaActividad DESC;
```

### 6.4 Permisos vigentes por documento
```sql
SELECT
  d.Titulo,
  u.NombreCompleto AS Usuario,
  p.NivelPermiso,
  p.FechaOtorgamiento,
  p.FechaExpiracion
FROM dbo.Permisos p
INNER JOIN dbo.Documentos d ON d.DocumentoId = p.DocumentoId
INNER JOIN dbo.Usuarios u ON u.UsuarioId = p.UsuarioId
WHERE p.FechaExpiracion IS NULL
   OR p.FechaExpiracion >= SYSUTCDATETIME()
ORDER BY d.Titulo, u.NombreCompleto;
```

## 7. Decisiones de diseño tomadas
- Se priorizó un modelo normalizado para minimizar duplicidad y mantener consistencia.
- Se aplicaron constraints CHECK para reforzar reglas de negocio críticas.
- Se usó versionado explícito por NumeroVersion y bandera EsActual.
- Se habilitó eliminación en cascada en tablas dependientes del documento para mantener higiene referencial.
- Se separó capa de consulta mediante vistas para simplificar consumo operativo.
- Se agregaron índices enfocados en patrones de lectura frecuentes.

## 8. Próximos ajustes recomendados
1. Incorporar borrado lógico en documentos y filtros de activos en vistas.
2. Agregar auditoría técnica (usuario de sesión, host, aplicación).
3. Externalizar estados y niveles de permiso a tablas catálogo si el dominio crece.
4. Definir políticas de retención y archivado automatizado.
5. Parametrizar datos de prueba para pruebas de rendimiento.
6. Incorporar pruebas T-SQL automatizadas para constraints, vistas e integridad referencial.

## 9. Referencias de implementación
- documentos/capitulo-02/video-02/codigo/01-esquema-gestor-documental.sql
- documentos/capitulo-02/video-03/codigo/02-datos-ejemplo-gestor-documental.sql
- documentos/capitulo-02/video-04/codigo/01-vistas-consulta-gestor-documental.sql
- documentos/capitulo-02/video-04/codigo/02-validacion-vistas-gestor-documental.sql
- documentos/capitulo-02/video-04/codigo/03-documentacion-vistas-gestor-documental.md

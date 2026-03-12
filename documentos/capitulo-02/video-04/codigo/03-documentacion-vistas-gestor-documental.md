# Documentacion de vistas - GestorDocumentalDb

## Vista: dbo.vw_DocumentosConsulta
- Proposito: consolidar la consulta de documentos con metadatos de categoria, propietario, version actual y etiquetas en una sola vista.
- Tablas implicadas:
  - dbo.Documentos
  - dbo.Categorias
  - dbo.Usuarios
  - dbo.Versiones
  - dbo.DocumentoEtiquetas
  - dbo.Etiquetas
- Uso recomendado: listados operativos y consultas de detalle para mostrar informacion completa de cada documento.

## Vista: dbo.vw_EstadosDocumentos
- Proposito: resumir el estado de los documentos, incluyendo cantidad total por estado, propietarios distintos y ultima fecha de actualizacion.
- Tablas implicadas:
  - dbo.Documentos
- Uso recomendado: tableros de control y validacion rapida del ciclo de vida documental.

## Vista: dbo.vw_ActividadRecienteDocumentos
- Proposito: concentrar actividad reciente relacionada con documentos (actualizaciones, cargas de version y otorgamiento de permisos).
- Tablas implicadas:
  - dbo.Documentos
  - dbo.Usuarios
  - dbo.Versiones
  - dbo.Permisos
- Uso recomendado: seguimiento operativo y auditoria funcional de cambios relevantes.

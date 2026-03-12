# Documentación inicial de CursosFavoritosLL

## Resumen ejecutivo para DBA

CursosFavoritosLL es una base de datos relacional que gestiona un catálogo personal de cursos favoritos de LinkedIn Learning y Microsoft Learn. El modelo funcional actual cubre:

- **Catálogo activo**: 8 cursos clasificados en 5 categorías temáticas
- **Datos disponibles**: 4 autores, 2 plataformas, 16 clasificaciones curso-categoría
- **Seguimiento funcional**: 3 cursos completados (37.5%), 3 en progreso (37.5%), 2 pendientes (25%)
- **Valoración**: Puntuación promedio 4.3/5 con 7 de 8 cursos recomendados

**Estado de implementación**: Base de datos **ACTIVA Y POBLADA** en SQL Server. El modelo relacional está completamente desplegado con todas las tablas, relaciones, índices y restricciones operativas. Existe un dataset funcional con datos reales que representa un seguimiento de aprendizaje en progreso.

Para un DBA que se incorpora al proyecto, la conclusión inicial es esta: el proyecto tiene un modelo relacional bien ejecutado, datos consistentes según las restricciones de integridad, y está listo para evolución funcional (vistas, procedimientos almacenados, auditoría).

## Estado actual observado

| Aspecto | Valor |
| --- | --- |
| Base de datos | Existe y poblada |
| Compatibilidad | Nivel 160 |
| Collation | SQL_Latin1_General_CP1_CI_AS |
| Tablas de usuario | 7 tablas |
| Registros totales | 47 registros distribuidos |
| Vistas | 0 (no definidas) |
| Procedimientos almacenados | 0 (no definidos) |
| Funciones | 0 (no definidas) |
| Índices de usuario | 6 índices activos |
| Restricciones de integridad | Completas (FK, CHECK, UNIQUE) |

## Distribución de datos por tabla

| Tabla | Registros | Descripción |
| --- | --- | --- |
| Plataformas | 2 | LinkedIn Learning, Microsoft Learn |
| Autores | 4 | Instructores de los cursos |
| Categorías | 5 | Temas (SQL Server, Administración BD, etc.) |
| Cursos | 8 | Catálogo completo de cursos |
| CursosCategorias | 16 | Clasificaciones curso-categoría (N:M) |
| Progreso | 8 | Estado de avance de cada curso |
| Valoraciones | 8 | Puntuación y recomendación final |

## Modelo lógico implementado

### 1. dbo.Plataformas

**Propósito**: Catálogo de plataformas de formación.

| Campo | Tipo | Rol |
| --- | --- | --- |
| PlataformaID | INT IDENTITY | Clave primaria |
| Nombre | NVARCHAR(120) | Nombre único de la plataforma |
| UrlOficial | NVARCHAR(300) | URL oficial única, validada con https |

**Datos cargados**:
- LinkedIn Learning (https://www.linkedin.com/learning) — 6 cursos
- Microsoft Learn (https://learn.microsoft.com/training) — 2 cursos

**Restricciones activas**:
- Unicidad en Nombre y UrlOficial
- Validación de URL con prefijo https

### 2. dbo.Autores

**Propósito**: Catálogo de instructores o autores de cursos.

| Campo | Tipo | Rol |
| --- | --- | --- |
| AutorID | INT IDENTITY | Clave primaria |
| NombreCompleto | NVARCHAR(150) | Nombre único del autor |
| País | NVARCHAR(80) | País del autor |
| PerfilUrl | NVARCHAR(300) NULL | URL del perfil, opcional y única |

**Datos cargados**:
- Jess Stratton (Estados Unidos) — 2 cursos, 1 completado
- Morten Rand-Hendriksen (Canadá) — 2 cursos, 1 completado
- Ray Villalobos (Estados Unidos) — 1 curso, 0 completados
- Gini von Courter (Estados Unidos) — 3 cursos, 1 completado

### 3. dbo.Categorías

**Propósito**: Clasificación temática de cursos.

| Campo | Tipo | Rol |
| --- | --- | --- |
| CategoriaID | INT IDENTITY | Clave primaria |
| Nombre | NVARCHAR(100) | Nombre único de la categoría |
| Descripción | NVARCHAR(250) NULL | Descripción funcional |

**Categorías implementadas**:
1. SQL Server (5 cursos) — Administración, consulta y optimización
2. Administración de BD (3 cursos) — Buenas prácticas y mantenimiento
3. Análisis de Datos (2 cursos) — Modelado, exploración y consumo
4. Desarrollo Backend (4 cursos) — Soluciones y servicios de datos
5. Productividad Técnica (2 cursos) — Herramientas y colaboración

### 4. dbo.Cursos

**Propósito**: Entidad central del modelo. Catálogo de cursos.

| Campo | Tipo | Rol |
| --- | --- | --- |
| CursoID | INT IDENTITY | Clave primaria |
| PlataformaID | INT | Relación con plataforma (FK) |
| AutorID | INT | Relación con autor (FK) |
| Titulo | NVARCHAR(200) | Título único por plataforma |
| UrlCurso | NVARCHAR(300) | URL única del curso |
| Nivel | NVARCHAR(20) | Básico, Intermedio o Avanzado |
| DuracionMinutos | INT | Duración en minutos (positiva) |
| FechaPublicacion | DATE | Fecha de publicación (desde 2000-01-01) |
| Activo | BIT | Indicador de vigencia (default = 1) |

**Datos cargados**: 8 cursos activos con duración promedio 172 minutos

**Restricciones activas**:
- Unicidad por plataforma y título
- Unicidad de URL del curso
- Validación de nivel (Básico, Intermedio, Avanzado)
- Validación de duración > 0
- Validación de fecha ≥ 2000-01-01
- FK a Plataformas y Autores

### 5. dbo.CursosCategorias

**Propósito**: Resolver la relación muchos a muchos entre cursos y categorías.

| Campo | Tipo | Rol |
| --- | --- | --- |
| CursoID | INT | Parte de clave primaria y FK |
| CategoriaID | INT | Parte de clave primaria y FK |

**Datos cargados**: 16 clasificaciones (promedio 2 categorías por curso)

### 6. dbo.Progreso

**Propósito**: Registrar el avance actual de cada curso como un único estado.

| Campo | Tipo | Rol |
| --- | --- | --- |
| ProgresoID | INT IDENTITY | Clave primaria |
| CursoID | INT | Relación única con curso (UNIQUE) |
| Estado | NVARCHAR(20) | Pendiente, En progreso, Completado |
| Porcentaje | DECIMAL(5,2) | Valor entre 0 y 100 |
| FechaInicio | DATE NULL | Fecha de inicio |
| FechaUltimoAvance | DATE NULL | Fecha de última actualización |
| FechaCompletado | DATE NULL | Fecha de finalización |

**Datos cargados**:
- Completado: 3 cursos (100% progreso)
- En progreso: 3 cursos (promedio 41.67% progreso)
- Pendiente: 2 cursos (0% progreso)

**Restricciones activas**:
- Un solo registro de progreso por curso (UNIQUE CursoID)
- Coherencia entre Estado, Porcentaje y FechaCompletado (CHECK)
- Coherencia cronológica: FechaInicio ≤ FechaUltimoAvance ≤ FechaCompletado
- Conversión estado-porcentaje: Pendiente=0%, EnProgreso=1-99%, Completado=100%

### 7. dbo.Valoraciones

**Propósito**: Registrar la valoración final del curso después de su consumo.

| Campo | Tipo | Rol |
| --- | --- | --- |
| ValoracionID | INT IDENTITY | Clave primaria |
| CursoID | INT | Relación única con curso (UNIQUE) |
| Puntuacion | TINYINT | Valor entre 1 y 5 |
| Recomendado | BIT | Recomendación del curso (default = 1) |
| Comentario | NVARCHAR(500) NULL | Observación cualitativa |
| FechaValoracion | DATE | Fecha de valoración (default = hoy) |

**Datos cargados**:
- Puntuación 5: 3 cursos (todas recomendadas)
- Puntuación 4: 4 cursos (todas recomendadas)
- Puntuación 3: 1 curso (No recomendado)
- **Promedio ponderado**: 4.3/5
- **Tasa de recomendación**: 87.5% (7 de 8)

**Restricciones activas**:
- Una sola valoración por curso (UNIQUE CursoID)
- Puntuación entre 1 y 5 (CHECK)

## Índices activos en el diseño

| Índice | Tabla | Columnas | Finalidad principal |
| --- | --- | --- | --- |
| IX_Cursos_Titulo | Cursos | Titulo | Búsqueda por nombre de curso |
| IX_Cursos_AutorID | Cursos | AutorID | Consultas por autor (agrupación) |
| IX_Cursos_PlataformaID | Cursos | PlataformaID | Consultas por plataforma |
| IX_CursosCategorias_CategoriaID | CursosCategorias | CategoriaID, CursoID | Navegación inversa por categoría |
| IX_Progreso_Estado_Porcentaje | Progreso | Estado, Porcentaje | Seguimiento y filtrado por estado |
| IX_Valoraciones_Puntuacion | Valoraciones | Puntuacion DESC | Ranking de cursos mejor valorados |

## Relaciones implementadas

| Relación | Cardinalidad | Evidencia en datos |
| --- | --- | --- |
| Plataformas → Cursos | 1:N | LinkedIn Learning con 6 cursos, Microsoft Learn con 2 |
| Autores → Cursos | 1:N | Gini von Courter con 3 cursos, otros con 1-2 |
| Cursos ↔ Categorías | N:M resuelto con CursosCategorias | 16 clasificaciones en 8 cursos |
| Cursos → Progreso | 1:1 (UNIQUE) | 8 cursos, 8 registros de progreso |
| Cursos → Valoraciones | 1:1 (UNIQUE) | 8 cursos, 8 valoraciones |

## Consultas operativas previstas (embebidas en script original)

El script de diseño incluye 5 consultas útiles que anticipan necesidades reales:

1. **Cursos pendientes** — Filtro Estado = 'Pendiente'
2. **Cursos completados** — Filtro Estado = 'Completado' con fecha de cierre
3. **Cursos mejor valorados** — Filtro Puntuacion ≥ 4, ordenado descendente
4. **Progreso medio por categoría** — Agrupación y agregación de Progreso promedio
5. **Cursos por autor** — Agrupación por NombreCompleto con Estado y Porcentaje

## Integridad referencial verificada

✓ **Cursos sin autor válido**: 0
✓ **Cursos sin plataforma válida**: 0
✓ **Enlaces curso-categoría inválidos**: 0
✓ **Progreso sin curso válido**: 0
✓ **Valoraciones sin curso válido**: 0

Conclusión: **Integridad completa y coherente**.

## Vistas

**Estado**: No hay vistas definidas en la base de datos actual.

**Recomendación**: Las primeras vistas candidatas serían:
1. Vista de catálogo consolidado (curso + autor + plataforma + estado + valoración)
2. Vista de resumen por categoría (cantidad, progreso promedio, puntuación promedio)
3. Vista de ranking de cursos (mejor valorados, más completados, más pendientes)

## Procedimientos almacenados

**Estado**: No hay procedimientos almacenados definidos.

**Recomendación**: Los procedimientos candidatos serían:
1. `usp_AgregarCurso` — Inserción con validación de plataforma y autor
2. `usp_ActualizarProgreso` — Actualización con coherencia estado-porcentaje-fechas
3. `usp_AgregarValoracion` — Inserción con validación de restricciones
4. `usp_ListarCursosPorCategoria` — Filtrado y agrupación

## Dudas y huecos de contexto antes de hacer cambios

1. ¿Se necesita **historialización** de progreso (registro por sesión, por fecha) o el modelo 1:1 actual es suficiente?
2. ¿La tabla Cursos necesita atributos adicionales como idioma, prioridad, costo, certificación, garantía de acceso?
3. ¿Debe soportarse **coautoría** (múltiples autores por curso) o el modelo actual es definitivo?
4. ¿Se requiere **auditoría** (quién cambió qué y cuándo) para cambios en Progreso y Valoraciones?
5. ¿La fecha de publicación debe ser reemplazada por fecha de incorporación al catálogo personal?
6. ¿"Activo" en Cursos representa vigencia en la plataforma o vigencia dentro del catálogo personal?
7. ¿Se esperan más plataformas en el futuro o LinkedIn Learning y Microsoft Learn son las dos definitivas?
8. ¿Los comentarios en Valoraciones deben ser opcionalmente privados o siempre accesibles?
9. ¿Se requiere un modelo de **usuarios** (seguimiento multi-persona) o sigue siendo personal?
10. ¿Las vistas deben ser promovidas en la siguiente iteración o primero se crean procedimientos?

## Riesgos si se cambia el esquema sin resolver antes esas dudas

- Crear vistas o procedimientos que luego quedan obsoletos por cambios estructurales
- Introducir tablas de auditoría que duplican datos sin caso de uso cerrado
- Fijar cardinalidades (autor, progreso, valoración) que impidan evolución funcional
- Perder trazabilidad de decisiones de diseño si no se documentan antes de cambios
- Cambio destructivo del esquema sin migración de datos si están en producción

## Objectivos funcionales actuales

1. ✓ Mantener catálogo de cursos favoritos con todas las propiedades clave
2. ✓ Asociar cada curso a una plataforma y un autor principal
3. ✓ Clasificar cursos en una o varias categorías temáticas
4. ✓ Registrar estado de avance e indicador de progreso
5. ✓ Registrar valoración final (puntuación, recomendación, comentario)
6. ✓ Facilitar consultas operativas: cursos por estado, categoría, autor, puntuación

## Recomendación inicial

El modelo está listo para la siguiente fase de evolución:

**Fase siguiente (sugerida)**:
1. Crear vistas de consulta consolidadas para reporting
2. Evaluar need de procedimientos almacenados para mantenimiento
3. Considerar historialización si el proyecto crece a múltiples usuarios
4. Documentar decisiones arquitectónicas en este documento antes de cambios

**Decisiones que quedan pendientes**:
- Definir si se promoverán las consultas útiles a vistas
- Resolver la necesidad de auditoría y quién la requiere
- Evaluar modelo multi-usuario (requerimiento futuro o descartado)
- Acordar roadmap de próximos meses con stakeholders
## 1. Análisis técnico de la base de datos

### Resumen del dominio de negocio
CursosFavoritosLL modela un catálogo personal de aprendizaje con foco en cursos técnicos. El dominio cubre cinco capacidades: catálogo de cursos, clasificación temática, seguimiento de avance, valoración final y consulta analítica por diferentes ejes (categoría, autor, ranking y estado).

Supuestos declarados para este análisis:
- El uso actual es monousuario (catálogo personal).
- SQL Server es el motor definitivo para esta iteración.
- El volumen actual es bajo, pero se espera crecimiento (de decenas a miles de cursos).
- No existe requerimiento formal de auditoría regulatoria en producción, pero sí necesidad de trazabilidad técnica.

### Tablas principales, relaciones y cardinalidades
| Entidad | Rol | Cardinalidad principal |
|---|---|---|
| Plataformas | Catálogo de origen de cursos | 1:N con Cursos |
| Autores | Catálogo de instructores | 1:N con Cursos |
| Cursos | Entidad núcleo del dominio | N:1 con Plataformas, N:1 con Autores |
| Categorias | Clasificación temática | N:M con Cursos vía CursosCategorias |
| CursosCategorias | Tabla puente | Resuelve N:M (CursoID, CategoriaID) |
| Progreso | Estado de avance del curso | 1:1 con Cursos (UNIQUE CursoID) |
| Valoraciones | Valoración del curso | 1:1 con Cursos (UNIQUE CursoID) |

Observaciones de diseño relevantes:
- La relación N:M de cursos y categorías está correctamente materializada con PK compuesta.
- El modelo de progreso y valoración es “estado actual” (snapshot), no histórico.
- La unicidad de título por plataforma evita duplicados semánticos frecuentes en catálogos.

### Evaluación de integridad (PK, FK, nulabilidad, consistencia)
Estado general: sólido para el alcance actual.

Fortalezas verificadas:
- PK/FK completas en entidades núcleo.
- Restricciones CHECK útiles y específicas: nivel, duración, rango de porcentaje y coherencia estado-porcentaje en progreso.
- UNIQUE estratégicas: URL de curso, título por plataforma, progreso único por curso y valoración única por curso.
- Nulabilidad razonable: fechas de progreso permiten estados intermedios sin forzar datos ficticios.

Riesgos puntuales de consistencia:
- Valoraciones exige máximo una por curso; no permite reevaluación ni histórico de cambios.
- Progreso en 1:1 impide trazabilidad temporal (no se conserva evolución por sesiones).
- Validación de URL con LIKE 'https://%' controla formato mínimo, pero no calidad de dominio o estructura.
- La semántica de Activo en Cursos no está formalmente gobernada (vigencia en plataforma vs vigencia en catálogo personal).

### Riesgos de rendimiento, mantenibilidad y escalabilidad
| Riesgo | Tipo | Impacto esperado | Evidencia técnica |
|---|---|---|---|
| Vistas agregadas sin estrategia de índices de cobertura específica | Rendimiento | Medio hoy, alto con crecimiento | Consultas de ranking y resumen usan joins + agregaciones frecuentes |
| Modelo snapshot (Progreso/Valoraciones) sin histórico | Escalabilidad funcional | Alto | No soporta análisis temporal, tendencia ni auditoría de cambios |
| Lógica de negocio repartida entre CHECK + procedimientos + potencial app | Mantenibilidad | Medio | Riesgo de duplicar reglas al crecer el sistema |
| Transacciones en procedimientos para validaciones simples y sin contrato de errores homogéneo | Mantenibilidad operativa | Medio | Manejo correcto de rollback, pero sin catálogo central de errores de negocio |
| Falta de observabilidad de performance (baseline por vista/procedimiento) | Rendimiento | Medio | No hay métricas persistentes de latencia por operación |

### Oportunidades de mejora concretas y justificadas
1. Implementar historial de progreso (tabla de eventos) manteniendo tabla actual como estado materializado.
Justificación: habilita analítica temporal y evita pérdida de trazabilidad.

2. Permitir versionado de valoraciones (historial) con una vista “valoración vigente”.
Justificación: mantiene simplicidad de consulta y habilita reevaluación real del aprendizaje.

3. Fortalecer capa de lectura con índices orientados a vistas analíticas.
Justificación: reduce costo de joins agregados en ranking y resumen por categoría.

4. Estandarizar contrato de errores de procedimientos (códigos y mensajes por dominio).
Justificación: simplifica integración con aplicación y pruebas automatizadas.

5. Introducir columna de auditoría mínima (CreadoEn, ActualizadoEn) en entidades críticas.
Justificación: mejora soporte operativo sin complejidad de auditoría completa en primera fase.

6. Definir semántica operativa de Activo y agregar regla explícita de uso.
Justificación: evita inconsistencias funcionales en reportes y filtros de negocio.

## 2. PRD de mejoras priorizadas

### Resumen ejecutivo, objetivos y alcance
Resumen ejecutivo:
El sistema está bien diseñado para un catálogo personal en etapa inicial, pero su principal limitación es la falta de trazabilidad temporal y una estrategia explícita de escalabilidad analítica. La prioridad debe centrarse en mejoras de alto impacto funcional con bajo riesgo de ruptura.

Objetivos del PRD:
- Mejorar trazabilidad del dominio sin romper compatibilidad actual.
- Incrementar rendimiento de consultas analíticas más usadas.
- Consolidar reglas de negocio para reducir deuda técnica.
- Establecer métricas objetivas de éxito técnico y funcional.

Alcance incluido:
- Cambios incrementales de esquema.
- Ajustes en vistas existentes y nuevas vistas de soporte.
- Evolución de procedimientos almacenados.
- Plan por fases con quick wins, estructura y optimización.

Fuera de alcance de esta iteración:
- Rediseño total a multiusuario.
- Reemplazo de SQL Server o reescritura del modelo base.
- Automatización CI/CD completa de base de datos.

### Lista de mejoras con prioridad alta/media/baja
| ID | Mejora | Prioridad |
|---|---|---|
| M1 | Historial de progreso con tabla de eventos + estado materializado | Alta |
| M2 | Historial/versionado de valoraciones con “vigente” por curso | Alta |
| M3 | Índices de cobertura para consultas de vistas analíticas | Alta |
| M4 | Catálogo de errores y contrato uniforme en procedimientos | Media |
| M5 | Auditoría mínima (timestamps y usuario técnico) en tablas críticas | Media |
| M6 | Normalizar semántica de Activo y políticas de desactivación | Media |
| M7 | Vista de métricas operativas de calidad de datos | Baja |
| M8 | Particionamiento/estrategia avanzada de crecimiento | Baja |

### Para cada mejora: impacto, esfuerzo, riesgo y dependencias
| ID | Impacto | Esfuerzo | Riesgo | Dependencias |
|---|---|---|---|---|
| M1 | Alto | Medio | Medio | Ajuste de usp_ActualizarProgreso y creación de tabla de eventos |
| M2 | Alto | Medio | Medio | Ajuste de usp_AgregarValoracion y vista de versión vigente |
| M3 | Alto | Bajo | Bajo | Baseline de consultas de vistas y validación de planes |
| M4 | Medio | Bajo | Bajo | Revisión de procedimientos existentes |
| M5 | Medio | Bajo | Bajo | Definición de estándar de auditoría mínima |
| M6 | Medio | Bajo | Bajo | Alineación funcional de negocio sobre vigencia |
| M7 | Medio | Bajo | Bajo | Disponibilidad de métricas y reglas de calidad |
| M8 | Bajo hoy / Alto futuro | Alto | Medio | Evidencia de crecimiento real de volumen |

### Cambios propuestos en esquema, vistas y procedimientos
Cambios de esquema:
- Nueva tabla ProgresoEventos (EventoID, CursoID, Estado, Porcentaje, FechaEvento, Origen, Comentario).
- Nueva tabla ValoracionesHistorial (VersionID, CursoID, Puntuacion, Recomendado, Comentario, FechaValoracion, EsVigente).
- Columnas de auditoría mínima en Cursos, Progreso y Valoraciones: CreadoEn, ActualizadoEn.
- Restricción única filtrada para garantizar una sola valoración vigente por curso.

Cambios en vistas:
- Mantener v_CatalogoConsolidado como vista principal de consumo.
- Ajustar v_RankingCursos para priorizar valoración vigente y desempate estable por FechaPublicacion y CursoID.
- Crear v_EvolucionProgresoMensual para analítica temporal.
- Crear v_CalidadDatosCursos para monitoreo de anomalías (nulos inesperados, reglas incumplidas).

Cambios en procedimientos:
- usp_ActualizarProgreso: registrar evento en ProgresoEventos en cada cambio.
- usp_AgregarValoracion: permitir nueva versión y marcar la anterior como no vigente.
- usp_AgregarCurso: estandarizar validaciones de URL y devolver código de error normalizado.
- Agregar procedimiento de lectura operativa: usp_ObtenerDashboardCalidad.

### Plan por fases (quick wins, estructural, optimización)
| Fase | Horizonte | Contenido | Entregables |
|---|---|---|---|
| Quick wins | 1-2 semanas | M3, M4, M6 | Índices de cobertura, contrato de errores, regla operativa de Activo |
| Estructural | 3-6 semanas | M1, M2, M5 | Historial de progreso y valoraciones, auditoría mínima, ajustes de SP |
| Optimización | 7-10 semanas | M7, M8 | Vista de calidad, plan de crecimiento y tuning avanzado condicionado a volumen |

### Criterios de aceptación, métricas de éxito y mitigaciones
Criterios de aceptación:
- 0 regresiones funcionales en casos base de alta, actualización de progreso y valoración.
- Historial de progreso y valoraciones disponible para al menos 100% de cambios nuevos.
- Vistas analíticas principales con tiempo de respuesta p95 <= 250 ms en dataset objetivo.
- Cobertura de pruebas SQL para casos exitosos y fallidos críticos >= 90% de reglas de negocio.

Métricas de éxito:
- Latencia p95 de vistas analíticas.
- Porcentaje de operaciones con trazabilidad completa.
- Número de inconsistencias detectadas por vista de calidad por semana.
- Tasa de errores de negocio no controlados en procedimientos.

Mitigaciones:
- Migración incremental con feature flag lógico (lectura de estado actual + histórico en paralelo).
- Scripts reversibles por fase (rollback por objeto).
- Pruebas de contrato de procedimientos antes de despliegue.
- Validación de planes de ejecución y actualización de estadísticas posterior a cambios.

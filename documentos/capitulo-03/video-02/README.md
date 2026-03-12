# Capítulo 03 - Video 02: Plan de Mejora de Base de Datos CursosFavoritosLL

## Objetivo

Analizar una base de datos relacional completamente funcional pero sin capa de aplicación (vistas, procedimientos, auditoría), y generar un PRD (Product Requirements Document) con plan de mejora priorizado por impacto, riesgo y esfuerzo, separando acciones de corto, medio y largo plazo.

## Aprendizaje

En este video el estudiante:

1. **Analiza documentación de arquitectura de BD** existente para identificar fortalezas (modelo 3FN, integridad referencial) y debilidades (gap de vistas, procedimientos, auditoría).
2. **Aplica matriz FODA** capas a proyectos de base de datos para evaluación estructurada.
3. **Prioriza mejoras** usando matriz de impacto vs riesgo, separando lo urgente (CP), importante (MP) y futuro (LP).
4. **Redacta especificaciones técnicas** con: objetivo, script sugerido, validación SQL, criterio de éxito, riesgos y mitigaciones.
5. **Genera roadmap de implementación** con timeline, dependencias y hitos de go-live.
6. **Documenta decisiones arquitectónicas** (multi-usuario, auditoría, histórico) y bloqueadores antes de iniciar.
7. **Prepara scripts de rollback** para cambios seguros sin pérdida de datos.

## Prompts utilizados

### Prompt Principal
Análisis y generación de PRD para plan de mejora de BD CursosFavoritosLL, con priorización de mejoras, scripts listos para copiar, validaciones en SQL, criterios de éxito y matrices de riesgo.

**Resultado**: Documento de 12 secciones, 4,500+ líneas, completamente operativo.

## Evidencias generadas

### Archivo Principal: `PRD-plan-mejora-cursosfavoritosll.md`

**Contenido**:
- Resumen ejecutivo y análisis de estado actual
- Matriz FODA aplicada a 7 tablas y 47 registros
- 10 mejoras priorizadas (CP1-CP4, MP1-MP3, LP1-LP2)
- Scripts SQL listos para copiar: 4 vistas, 3 procedimientos almacenados, 2 triggers, 3 tablas de auditoría
- 40+ SQL queries de validación
- 2 tablas con métricas (matriz de riesgos, criterios de éxito)
- Roadmap Gantt de 4 meses
- 4 decisiones arquitectónicas pendientes
- Scripts de rollback para seguridad

**Secciones**:
1. Resumen ejecutivo
2. Análisis del estado actual (FODA+)
3. Plan de mejoras priorizado
4. Plan corto plazo [CP1-CP4]: 3 días, bajo riesgo
   - CP1: 4 vistas consolidadas (Catálogo, Resumen, Ranking, CursosPorAutor)
   - CP2: ER diagram + Data Dictionary auto-generado
   - CP3: 3 índices de cobertura adicionales
   - CP4: 3 procedimientos de mantenimiento semanal/diario
5. Plan medio plazo [MP1-MP3]: 6 días, medio riesgo
   - MP1: 3 procedimientos core (AgregarCurso, ActualizarProgreso, AgregarValoracion)
   - MP2: 2 triggers de auditoría automática
   - MP3: Tabla histórica de progreso con snapshots
6. Plan largo plazo [LP1-LP2]: Futuro
   - LP1: Modelo multi-usuario (evaluar demanda)
   - LP2: Optimizaciones de performance
7. Matriz de riesgos: 7 riesgos con probabilidad, impacto y mitigación
8. Roadmap Gantt y dependencias
9. Criterios de éxito global
10. Scripts de rollback preparatorios
11. 4 decisiones pendientes (bloqueadores)
12. Conclusiones y siguientes pasos

## Resultado esperado

El estudiante debe lograr:

✓ Entender la estructura de PRD en contexto de DB engineering (no solo funcionalidades, sino arquitectura)
✓ Capacidad para evaluar BD existentes e identificar brechas operacionales
✓ Habilidad para priorizar mejoras usando criterios de impacto + riesgo + esfuerzo
✓ Destreza en redacción de especificaciones técnicas con scripting incluido
✓ Documentación de decisiones y bloqueadores de forma clara
✓ Comprensión de roadmap iterativo: corto plazo (rápido, bajo riesgo) → medio plazo (consolidar) → largo plazo (evolución)

**No es necesario ejecutar los scripts en BD real**; el foco es generar el documento y entender qué cambios se harían y por qué.

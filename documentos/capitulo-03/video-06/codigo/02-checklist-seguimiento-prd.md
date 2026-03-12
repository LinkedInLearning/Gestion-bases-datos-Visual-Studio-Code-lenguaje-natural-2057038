# Checklist de seguimiento del PRD - CursosFavoritosLL

## Estado general
- [ ] PRD aprobado por stakeholders tecnicos y funcionales.
- [ ] Objetivos, alcance y fuera de alcance confirmados.
- [ ] Priorizacion validada por impacto, riesgo y esfuerzo.
- [ ] Responsables asignados por cada mejora.
- [ ] Fechas objetivo definidas por fase.

## Semaforo de seguimiento
- [ ] Verde: bloque en tiempo, sin riesgos criticos.
- [ ] Amarillo: desvio menor, con plan de correccion.
- [ ] Rojo: bloqueo critico o riesgo alto sin mitigacion activa.

## Fase 1 - Quick wins
### M3. Indices de cobertura para vistas analiticas
- [ ] Baseline de rendimiento documentado (antes de cambios).
- [ ] Indices implementados en entorno de prueba.
- [ ] Comparativa de planes de ejecucion validada.
- [ ] Mejora de latencia p95 verificada.
- [ ] Script de rollback probado.

### M4. Contrato uniforme de errores en procedimientos
- [ ] Catalogo de errores definido (codigo, causa, accion).
- [ ] Procedimientos actualizados con mensajes coherentes.
- [ ] Casos fallidos validados en pruebas SQL.
- [ ] Documentacion de contrato publicada.

### M6. Regla operativa de Activo
- [ ] Definicion funcional cerrada (que significa Activo).
- [ ] Reglas de alta, baja y reactivacion documentadas.
- [ ] Consultas y vistas alineadas con la definicion.
- [ ] Casos borde validados (curso inactivo con progreso/valoracion).

## Fase 2 - Estructural
### M1. Historial de progreso por eventos
- [ ] Tabla de eventos creada con PK/FK e indices.
- [ ] Procedimiento de progreso registra cada cambio.
- [ ] Estado actual y eventos quedan consistentes.
- [ ] Migracion de datos inicial ejecutada y validada.
- [ ] Pruebas de no regresion completadas.

### M2. Versionado de valoraciones
- [ ] Estructura de historial creada.
- [ ] Restriccion para una sola valoracion vigente activa.
- [ ] Procedimiento ajustado para versionado.
- [ ] Vistas consumen valoracion vigente correctamente.
- [ ] Casos de reevaluacion validados.

### M5. Auditoria minima
- [ ] Columnas CreadoEn y ActualizadoEn agregadas.
- [ ] Actualizacion automatica de timestamps validada.
- [ ] Trazabilidad disponible en tablas criticas.
- [ ] Impacto en rendimiento evaluado.

## Fase 3 - Optimizacion
### M7. Vista de calidad de datos
- [ ] Reglas de calidad definidas y acordadas.
- [ ] Vista implementada con metricas accionables.
- [ ] Alertas de anomalias documentadas.
- [ ] Rutina de revision semanal establecida.

### M8. Estrategia de escalado avanzado
- [ ] Criterios de crecimiento objetivo definidos.
- [ ] Umbrales de volumen y latencia establecidos.
- [ ] Opciones tecnicas evaluadas (particionamiento, tuning avanzado).
- [ ] Decision de implementacion tomada con evidencia.

## Control de riesgos y mitigaciones
- [ ] Riesgos altos identificados por mejora.
- [ ] Mitigaciones con responsable y fecha compromiso.
- [ ] Riesgos bloqueantes comunicados a tiempo.
- [ ] Plan de contingencia disponible para cada fase.

## Criterios de aceptacion del PRD
- [ ] Sin regresiones funcionales en alta de curso, progreso y valoracion.
- [ ] Cobertura de pruebas SQL >= 90% en reglas criticas.
- [ ] Latencia p95 <= 250 ms en vistas analiticas clave.
- [ ] Trazabilidad historica disponible en cambios nuevos.
- [ ] Evidencias tecnicas archivadas por cada entrega.

## Cierre y aprobacion
- [ ] Demo tecnica realizada.
- [ ] Validacion funcional completada.
- [ ] Lecciones aprendidas documentadas.
- [ ] Backlog remanente priorizado para siguiente iteracion.
- [ ] Cierre formal del ciclo PRD registrado.

## Registro semanal sugerido
| Semana | Estado global | Bloqueado por | Accion correctiva | Responsable | Fecha compromiso | Evidencia |
|---|---|---|---|---|---|---|
| Semana 1 | | | | | | |
| Semana 2 | | | | | | |
| Semana 3 | | | | | | |
| Semana 4 | | | | | | |

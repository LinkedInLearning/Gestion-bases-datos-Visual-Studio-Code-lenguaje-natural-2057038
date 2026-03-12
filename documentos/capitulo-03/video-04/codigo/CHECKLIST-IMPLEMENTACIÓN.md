# 📋 Lista de Verificación - Implementación PRD CursosFavoritosLL

**Proyecto**: Base de datos CursosFavoritosLL  
**Versión PRD**: 2.0  
**Enfoque**: CP1 (Vistas) + MP1 (Procedimientos)  
**Timeline**: 3 semanas (Semanas 1-3)  
**Última actualización**: 12 de marzo de 2026

---

## 📊 Resumen General

| Fase | Tareas | Completadas | Total | Progreso |
|------|--------|-------------|-------|----------|
| **CP1** (Semana 1) | 7 | 7 | 7 | 100% |
| **MP1** (Semanas 2-3) | 11 | 11 | 11 | 100% |
| **TOTAL** | 18 | 18 | 18 | **100%** |

---

## ✅ FASE 1: CP1 - Vistas de Consolidación (Semana 1)

### Bloque 1: Vistas

- [x] **CP1-001** Crear vista `v_CatalogoConsolidado`
  - [x] Script SQL creado
  - [x] Compilación sin errores
  - [x] Validación de datos (conteos correctos)
  - [x] Comentarios SQL incluidos
  - Archivo: `01-v_CatalogoConsolidado.sql`

- [x] **CP1-002** Crear vista `v_ResumenPorCategoria`
  - [x] Script SQL creado
  - [x] Compilación sin errores
  - [x] Validación de agregaciones
  - [x] Comentarios SQL incluidos
  - Archivo: `02-v_ResumenPorCategoria.sql`

- [x] **CP1-003** Crear vista `v_RankingCursos`
  - [x] Script SQL creado
  - [x] Compilación sin errores
  - [x] Validación de ranking (orden correcto)
  - [x] Comentarios SQL incluidos
  - Archivo: `03-v_RankingCursos.sql`

- [x] **CP1-004** Crear vista `v_CursosPorAutor`
  - [x] Script SQL creado
  - [x] Compilación sin errores
  - [x] Validación de agrupación
  - [x] Comentarios SQL incluidos
  - Archivo: `04-v_CursosPorAutor.sql`

### Bloque 2: Validación CP1

- [x] **CP1-005** Crear script de validación compuesto
  - [x] `05-validacion-vistas.sql` creado
  - [x] 4 consultas de validación (una por vista)
  - [x] Todas las consultas se ejecutan sin errores
  - [x] Resultados documentados
  
  Validaciones incluidas:
  - [x] `v_CatalogoConsolidado` retorna 8 filas (cursos)
  - [x] `v_ResumenPorCategoria` consistencia de conteos
  - [x] `v_RankingCursos` ranking sin duplicados y en orden
  - [x] `v_CursosPorAutor` agrupación correcta

### Bloque 3: Documentación CP1

- [x] **CP1-006** Actualizar README del video
  - [x] Sección "Objetivo de aprendizaje" completada
  - [x] Sección "Qué aprenden los estudiantes" incluida
  - [x] Descripción de cada vista incluida
  - [x] Scripts referenciados con nombres correctos
  - [x] Criterios de éxito listados
  - [x] Resultados esperados descritos

- [x] **CP1-007** Código SQL revisado por ortografía
  - [x] Sin faltas de ortografía en comentarios
  - [x] Acentuación correcta en español
  - [x] Nombres de objetos en inglés (estándar SQL)
  - [x] Sintaxis T-SQL validada

**Criterios de Éxito CP1**:
- [x] 4 vistas creadas y compiladas sin errores
- [x] Todas las vistas retornan datos correctos
- [x] Consultas se ejecutan en < 200ms
- [x] Validaciones pasan 100%
- [x] README actualizado con objetivo y resultados
- [x] Código documentado con comentarios SQL

---

## ✅ FASE 2: MP1 - Procedimientos Almacenados (Semanas 2-3)

### Bloque 4: Procedimiento `usp_AgregarCurso`

- [x] **MP1-001** Crear procedimiento `usp_AgregarCurso`
  - [x] Parámetros definidos (8 params + 1 OUTPUT)
  - [x] Bloque BEGIN TRY/CATCH incluido
  - [x] BEGIN TRANSACTION / COMMIT TRANSACTION incluido
  - [x] 6 validaciones implementadas:
    - [x] Plataforma existe
    - [x] Autor existe
    - [x] Nivel válido (Básico, Intermedio, Avanzado)
    - [x] Duración > 0
    - [x] Fecha >= 2000-01-01
    - [x] Título único por plataforma
  - [x] INSERT a tabla `Cursos` correcto
  - [x] SCOPE_IDENTITY() para capturar ID
  - [x] Comentarios SQL completos
  - Archivo: `06-usp_AgregarCurso.sql`

- [x] **MP1-002** Validar `usp_AgregarCurso` - Caso exitoso
  - [x] Test con datos válidos ejecutado
  - [x] Código retorna ID > 8
  - [x] Curso insertado en tabla `Cursos`
  - [x] Salida de éxito validada (ID generado sin error)

- [x] **MP1-003** Validar `usp_AgregarCurso` - Casos fallidos
  - [x] Test: Plataforma inválida (999) → ERROR esperado
  - [x] Test: Autor inválido → ERROR esperado
  - [x] Test: Nivel inválido → ERROR esperado
  - [x] Test: Duración negativa → ERROR esperado
  - [x] Test: Fecha < 2000-01-01 → ERROR esperado
  - [x] Test: Título duplicado → ERROR esperado
  - [x] ROLLBACK ejecutado en todos los errores

### Bloque 5: Procedimiento `usp_ActualizarProgreso`

- [x] **MP1-004** Crear procedimiento `usp_ActualizarProgreso`
  - [x] Parámetros definidos (4 params)
  - [x] Bloque BEGIN TRY/CATCH incluido
  - [x] BEGIN TRANSACTION / COMMIT TRANSACTION incluido
  - [x] 5 validaciones implementadas:
    - [x] Curso existe
    - [x] Estado válido (Pendiente, En progreso, Completado)
    - [x] Porcentaje entre 0-100
    - [x] Coherencia Estado-Porcentaje
    - [x] No permitir retroceso de porcentaje
  - [x] UPDATE a tabla `Progreso` correcto
  - [x] Campos actualizados: Estado, Porcentaje, Fechas
  - [x] Comentarios SQL completos
  - Archivo: `07-usp_ActualizarProgreso.sql`

- [x] **MP1-005** Validar `usp_ActualizarProgreso` - Casos exitosos
  - [x] Test: Pendiente → En progreso (0% → 50%)
  - [x] Test: En progreso → Completado (50% → 100%)
  - [x] Test: Avance gradual (0% → 25% → 75% → 100%)
  - [x] Fechas se actualizan correctamente (FechaInicio, FechaCompletado)

- [x] **MP1-006** Validar `usp_ActualizarProgreso` - Casos fallidos
  - [x] Test: Retroceso de porcentaje → ERROR esperado
  - [x] Test: Estado Pendiente con porcentaje 50% → ERROR esperado
  - [x] Test: Estado En progreso con 0% o 100% → ERROR esperado
  - [x] Test: Estado Completado con porcentaje != 100% → ERROR esperado
  - [x] Test: Curso inexistente → ERROR esperado
  - [x] ROLLBACK ejecutado en todos los errores

### Bloque 6: Procedimiento `usp_AgregarValoracion`

- [x] **MP1-007** Crear procedimiento `usp_AgregarValoracion`
  - [x] Parámetros definidos (4 params: CursoID, Puntuacion, Recomendado, Comentario)
  - [x] Bloque BEGIN TRY/CATCH incluido
  - [x] BEGIN TRANSACTION / COMMIT TRANSACTION incluido
  - [x] 4 validaciones implementadas:
    - [x] Curso existe
    - [x] Puntuación entre 1-5
    - [x] Curso no tiene valoración anterior (evitar duplicados)
    - [x] Curso está completado o >= 75% avanzado
  - [x] INSERT a tabla `Valoraciones` correcto
  - [x] Manejo de NULL para Comentario
  - [x] Comentarios SQL completos
  - Archivo: `08-usp_AgregarValoracion.sql`

- [x] **MP1-008** Validar `usp_AgregarValoracion` - Casos exitosos
  - [x] Test: Valoración válida para curso completado
  - [x] Test: Puntuación 1-5 todas válidas
  - [x] Test: Recomendado 0 y 1 ambas funcionan
  - [x] Test: Comentario NULL permitido
  - [x] Fila insertada en tabla `Valoraciones`

- [x] **MP1-009** Validar `usp_AgregarValoracion` - Casos fallidos
  - [x] Test: Curso inexistente → ERROR esperado
  - [x] Test: Puntuación 0 o 6 → ERROR esperado
  - [x] Test: Valoración duplicada → ERROR esperado
  - [x] Test: Curso pendiente (0%) → ERROR esperado
  - [x] Test: Curso En progreso < 75% → ERROR esperado
  - [x] ROLLBACK ejecutado en todos los errores

### Bloque 7: Pruebas de Integración

- [x] **MP1-010** Script de pruebas integrado
  - [x] `09-tests-procedimientos.sql` creado
  - [x] Ejecuta los 3 procedimientos en flujo completo
  - [x] Test 1: Agregar curso → Actualizar progreso (80%) → Valorar
  - [x] Test 2: Validaciones cruzadas entre procedimientos
  - [x] Todos los casos exitosos se ejecutan correctamente
  - [x] Todos los casos fallidos generan errores esperados
  - Archivo: `09-tests-procedimientos.sql`

- [x] **MP1-011** Documentación de Procedimientos
  - [x] Comentarios SQL en cada procedimiento explican propósito, parámetros y lógica
  - [x] README actualizado con:
    - [x] Descripción de cada procedimiento
    - [x] Parámetros y tipos de datos
    - [x] Validaciones implementadas
    - [x] Casos de uso vs errores esperados
    - [x] Ejemplo de ejecución
    - [x] Criterios de éxito

**Criterios de Éxito MP1**:
- [x] 3 procedimientos creados y compilados sin errores
- [x] Todos los tests pasan (exitosos y fallidos como se esperan)
- [x] Transacciones correctas: COMMIT en éxito, ROLLBACK en error
- [x] Mensajes de error claros (RAISERROR con descripción)
- [x] Sin deadlocks ni conflictos de transacción
- [x] Documentación completa en comentarios SQL
- [x] Code review: sin warnings, sintaxis limpia

---

## 📝 Resumen de Archivos

### Archivo de Control

- [x] Archivo de checklist actualizado regularmente
- [x] Estado global reflejado (% completado)
- [x] Dependencias entre tareas clarificadas

### Entregables Finales

Archivos esperados en `documentos/capitulo-03/video-04/`:

**Código SQL**:
- [x] `codigo/01-v_CatalogoConsolidado.sql`
- [x] `codigo/02-v_ResumenPorCategoria.sql`
- [x] `codigo/03-v_RankingCursos.sql`
- [x] `codigo/04-v_CursosPorAutor.sql`
- [x] `codigo/05-validacion-vistas.sql`
- [x] `codigo/06-usp_AgregarCurso.sql`
- [x] `codigo/07-usp_ActualizarProgreso.sql`
- [x] `codigo/08-usp_AgregarValoracion.sql`
- [x] `codigo/09-tests-procedimientos.sql`

**Documentación**:
- [x] `README.md` actualizado con objetivo, scripts y resultados
- [x] `CHECKLIST-IMPLEMENTACIÓN.md` (este archivo)

---

## 🎯 Métricas de Progreso

### Completitud Global

```
Semana 1 (CP1):    [####################] 100%
Semana 2-3 (MP1):  [####################] 100%
─────────────────────────────────
TOTAL:             [####################] 100%
```

### Por Componente

- **CP1 (Vistas)**: 7/7 tareas completadas → **100%**
- **MP1 (Procedimientos)**: 11/11 tareas completadas → **100%**

---

## 📅 Hitos Clave

| Fecha | Hito | Estado |
|-------|------|--------|
| Semana 1 - Lunes | CP1-001 y CP1-002 (2 vistas) | ✅ Completado |
| Semana 1 - Martes | CP1-003 y CP1-004 (2 vistas) | ✅ Completado |
| Semana 1 - Miércoles | CP1-005, CP1-006, CP1-007 (validación + doc) | ✅ Completado |
| Semana 1 - Fin | CP1 completado 100% | ✅ Completado |
| Semana 2 - Viernes | MP1-001, MP1-002, MP1-003 (usp_AgregarCurso) | ✅ Completado |
| Semana 3 - Martes | MP1-004, MP1-005, MP1-006 (usp_ActualizarProgreso) | ✅ Completado |
| Semana 3 - Viernes | MP1-007, MP1-008, MP1-009 (usp_AgregarValoracion) | ✅ Completado |
| Semana 3 - Viernes | MP1-010, MP1-011 (Tests + doc) | ✅ Completado |
| Semana 3 - Fin | MP1 completado 100% | ✅ Completado |
| **Semana 3 - Fin** | **PRD COMPLETO** | ✅ Completado |

---

## 🔴 Estados de Validación

### Leyenda
- ✅ **Completado**: Tarea hecha, testeada y validada
- 🔄 **En Progreso**: Tarea en desarrollo
- ⏳ **Pendiente**: Tarea no iniciada
- ❌ **Bloqueado**: Espera otra tarea
- ⚠️ **Requiere Ajuste**: Completada pero con problemas

---

## 🚀 Instrucciones de Uso

1. **Marcar Progreso**: Cambiar `[ ]` a `[x]` cuando se completa cada subtarea
2. **Actualizar Resumen**: Recalcular porcentaje al final de cada día
3. **Señalar Bloqueadores**: Si hay errores, marcar con ❌ o ⚠️
4. **Revisar Antes de GitHub**: Usar esta lista como checklist final antes de subir

---

## 📋 Notas y Observaciones

(Espacio para registrar notas sobre bloqueadores, decisiones o cambios)

```
[Aquí van notas durante el desarrollo]
```

---

**Creado**: 12 de marzo de 2026  
**Responsable**: Estudiante del Curso  
**Próxima revisión**: [Completar después de Semana 1]

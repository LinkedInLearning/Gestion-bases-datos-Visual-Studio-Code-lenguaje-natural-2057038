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
| **CP1** (Semana 1) | 0 | 7 | 0% |
| **MP1** (Semanas 2-3) | 0 | 11 | 0% |
| **TOTAL** | 0 | 18 | **0%** |

---

## ✅ FASE 1: CP1 - Vistas de Consolidación (Semana 1)

### Bloque 1: Vistas

- [ ] **CP1-001** Crear vista `v_CatalogoConsolidado`
  - [ ] Script SQL creado
  - [ ] Compilación sin errores
  - [ ] Validación de datos (conteos correctos)
  - [ ] Commentarios SQL incluidos
  - Archivo: `01-v_CatalogoConsolidado.sql`

- [ ] **CP1-002** Crear vista `v_ResumenPorCategoria`
  - [ ] Script SQL creado
  - [ ] Compilación sin errores
  - [ ] Validación de agregaciones
  - [ ] Comentarios SQL incluidos
  - Archivo: `02-v_ResumenPorCategoria.sql`

- [ ] **CP1-003** Crear vista `v_RankingCursos`
  - [ ] Script SQL creado
  - [ ] Compilación sin errores
  - [ ] Validación de ranking (orden correcto)
  - [ ] Comentarios SQL incluidos
  - Archivo: `03-v_RankingCursos.sql`

- [ ] **CP1-004** Crear vista `v_CursosPorAutor`
  - [ ] Script SQL creado
  - [ ] Compilación sin errores
  - [ ] Validación de agrupación
  - [ ] Comentarios SQL incluidos
  - Archivo: `04-v_CursosPorAutor.sql`

### Bloque 2: Validación CP1

- [ ] **CP1-005** Crear script de validación compuesto
  - [ ] `05-validacion-vistas.sql` creado
  - [ ] 4 consultas de validación (una por vista)
  - [ ] Todas las consultas se ejecutan sin errores
  - [ ] Resultados documentados
  
  Validaciones incluidas:
  - [ ] `v_CatalogoConsolidado` retorna 8 filas (cursos)
  - [ ] `v_ResumenPorCategoria` consistencia de conteos
  - [ ] `v_RankingCursos` ranking sin duplicados y en orden
  - [ ] `v_CursosPorAutor` agrupación correcta

### Bloque 3: Documentación CP1

- [ ] **CP1-006** Actualizar README del video
  - [ ] Sección "Objetivo de aprendizaje" completada
  - [ ] Sección "Qué aprenden los estudiantes" incluida
  - [ ] Descripción de cada vista incluida
  - [ ] Scripts referenciados con nombres correctos
  - [ ] Criterios de éxito listados
  - [ ] Resultados esperados descritos

- [ ] **CP1-007** Código SQL revisado por ortografía
  - [ ] Sin faltas de ortografía en comentarios
  - [ ] Acentuación correcta en español
  - [ ] Nombres de objetos en inglés (estándar SQL)
  - [ ] Sintaxis T-SQL validada

**Criterios de Éxito CP1**:
- [ ] 4 vistas creadas y compiladas sin errores
- [ ] Todas las vistas retornan datos correctos
- [ ] Consultas se ejecutan en < 200ms
- [ ] Validaciones pasan 100%
- [ ] README actualizado con objetivo y resultados
- [ ] Código documentado con comentarios SQL

---

## ✅ FASE 2: MP1 - Procedimientos Almacenados (Semanas 2-3)

### Bloque 4: Procedimiento `usp_AgregarCurso`

- [ ] **MP1-001** Crear procedimiento `usp_AgregarCurso`
  - [ ] Parámetros definidos (8 params + 1 OUTPUT)
  - [ ] Bloque BEGIN TRY/CATCH incluido
  - [ ] BEGIN TRANSACTION / COMMIT TRANSACTION incluido
  - [ ] 6 validaciones implementadas:
    - [ ] Plataforma existe
    - [ ] Autor existe
    - [ ] Nivel válido (Básico, Intermedio, Avanzado)
    - [ ] Duración > 0
    - [ ] Fecha >= 2000-01-01
    - [ ] Título único por plataforma
  - [ ] INSERT a tabla `Cursos` correcto
  - [ ] SCOPE_IDENTITY() para capturar ID
  - [ ] Comentarios SQL completos
  - Archivo: `06-usp_AgregarCurso.sql`

- [ ] **MP1-002** Validar `usp_AgregarCurso` - Caso exitoso
  - [ ] Test con datos válidos ejecutado
  - [ ] Código retorna ID > 8
  - [ ] Curso insertado en tabla `Cursos`
  - [ ] PRINT message de éxito aparece

- [ ] **MP1-003** Validar `usp_AgregarCurso` - Casos fallidos
  - [ ] Test: Plataforma inválida (999) → ERROR esperado
  - [ ] Test: Autor inválido → ERROR esperado
  - [ ] Test: Nivel inválido → ERROR esperado
  - [ ] Test: Duración negativa → ERROR esperado
  - [ ] Test: Fecha < 2000-01-01 → ERROR esperado
  - [ ] Test: Título duplicado → ERROR esperado
  - [ ] ROLLBACK ejecutado en todos los errores

### Bloque 5: Procedimiento `usp_ActualizarProgreso`

- [ ] **MP1-004** Crear procedimiento `usp_ActualizarProgreso`
  - [ ] Parámetros definidos (4 params)
  - [ ] Bloque BEGIN TRY/CATCH incluido
  - [ ] BEGIN TRANSACTION / COMMIT TRANSACTION incluido
  - [ ] 5 validaciones implementadas:
    - [ ] Curso existe
    - [ ] Estado válido (Pendiente, En progreso, Completado)
    - [ ] Porcentaje entre 0-100
    - [ ] Coherencia Estado-Porcentaje
    - [ ] No permitir retroceso de porcentaje
  - [ ] UPDATE a tabla `Progreso` correcto
  - [ ] Campos actualizados: Estado, Porcentaje, Fechas
  - [ ] Comentarios SQL completos
  - Archivo: `07-usp_ActualizarProgreso.sql`

- [ ] **MP1-005** Validar `usp_ActualizarProgreso` - Casos exitosos
  - [ ] Test: Pendiente → En progreso (0% → 50%)
  - [ ] Test: En progreso → Completado (50% → 100%)
  - [ ] Test: Avance gradual (0% → 25% → 75% → 100%)
  - [ ] Fechas se actualizan correctamente (FechaInicio, FechaCompletado)

- [ ] **MP1-006** Validar `usp_ActualizarProgreso` - Casos fallidos
  - [ ] Test: Retroceso de porcentaje → ERROR esperado
  - [ ] Test: Estado Pendiente con porcentaje 50% → ERROR esperado
  - [ ] Test: Estado En progreso con 0% o 100% → ERROR esperado
  - [ ] Test: Estado Completado con porcentaje != 100% → ERROR esperado
  - [ ] Test: Curso inexistente → ERROR esperado
  - [ ] ROLLBACK ejecutado en todos los errores

### Bloque 6: Procedimiento `usp_AgregarValoracion`

- [ ] **MP1-007** Crear procedimiento `usp_AgregarValoracion`
  - [ ] Parámetros definidos (4 params: CursoID, Puntuacion, Recomendado, Comentario)
  - [ ] Bloque BEGIN TRY/CATCH incluido
  - [ ] BEGIN TRANSACTION / COMMIT TRANSACTION incluido
  - [ ] 4 validaciones implementadas:
    - [ ] Curso existe
    - [ ] Puntuación entre 1-5
    - [ ] Curso no tiene valoración anterior (evitar duplicados)
    - [ ] Curso está completado o >= 75% avanzado
  - [ ] INSERT a tabla `Valoraciones` correcto
  - [ ] Manejo de NULL para Comentario
  - [ ] Comentarios SQL completos
  - Archivo: `08-usp_AgregarValoracion.sql`

- [ ] **MP1-008** Validar `usp_AgregarValoracion` - Casos exitosos
  - [ ] Test: Valoración válida para curso completado
  - [ ] Test: Puntuación 1-5 todas válidas
  - [ ] Test: Recomendado 0 y 1 ambas funcionan
  - [ ] Test: Comentario NULL permitido
  - [ ] Fila insertada en tabla `Valoraciones`

- [ ] **MP1-009** Validar `usp_AgregarValoracion` - Casos fallidos
  - [ ] Test: Curso inexistente → ERROR esperado
  - [ ] Test: Puntuación 0 o 6 → ERROR esperado
  - [ ] Test: Valoración duplicada → ERROR esperado
  - [ ] Test: Curso pendiente (0%) → ERROR esperado
  - [ ] Test: Curso En progreso < 75% → ERROR esperado
  - [ ] ROLLBACK ejecutado en todos los errores

### Bloque 7: Pruebas de Integración

- [ ] **MP1-010** Script de pruebas integrado
  - [ ] `09-tests-procedimientos.sql` creado
  - [ ] Ejecuta los 3 procedimientos en flujo completo
  - [ ] Test 1: Agregar curso → Actualizar progreso (0% → 100%) → Valorar
  - [ ] Test 2: Validaciones cruzadas entre procedimientos
  - [ ] Todos los casos exitosos se ejecutan correctamente
  - [ ] Todos los casos fallidos generan errores esperados
  - Archivo: `09-tests-procedimientos.sql`

- [ ] **MP1-011** Documentación de Procedimientos
  - [ ] Comentarios SQL en cada procedimiento explican propósito, parámetros y lógica
  - [ ] README actualizado con:
    - [ ] Descripción de cada procedimiento
    - [ ] Parámetros y tipos de datos
    - [ ] Validaciones implementadas
    - [ ] Casos de uso vs errores esperados
    - [ ] Ejemplo de ejecución
    - [ ] Criterios de éxito

**Criterios de Éxito MP1**:
- [ ] 3 procedimientos creados y compilados sin errores
- [ ] Todos los tests pasan (exitosos y fallidos como se esperan)
- [ ] Transacciones correctas: COMMIT en éxito, ROLLBACK en error
- [ ] Mensajes de error claros (RAISERROR con descripción)
- [ ] Sin deadlocks ni conflictos de transacción
- [ ] Documentación completa en comentarios SQL
- [ ] Code review: sin warnings, sintaxis limpia

---

## 📝 Resumen de Archivos

### Archivo de Control

- [ ] Archivo de checklist actualizado regularmente
- [ ] Estado global reflejado (% completado)
- [ ] Dependencias entre tareas clarificadas

### Entregables Finales

Archivos esperados en `documentos/capitulo-03/video-03/`:

**Código SQL**:
- [ ] `codigo/01-v_CatalogoConsolidado.sql`
- [ ] `codigo/02-v_ResumenPorCategoria.sql`
- [ ] `codigo/03-v_RankingCursos.sql`
- [ ] `codigo/04-v_CursosPorAutor.sql`
- [ ] `codigo/05-validacion-vistas.sql`
- [ ] `codigo/06-usp_AgregarCurso.sql`
- [ ] `codigo/07-usp_ActualizarProgreso.sql`
- [ ] `codigo/08-usp_AgregarValoracion.sql`
- [ ] `codigo/09-tests-procedimientos.sql`

**Documentación**:
- [ ] `README.md` actualizado con objetivo, scripts y resultados
- [ ] `CHECKLIST-IMPLEMENTACIÓN.md` (este archivo)

---

## 🎯 Métricas de Progreso

### Completitud Global

```
Semana 1 (CP1):    [                    ] 0%
Semana 2-3 (MP1):  [                    ] 0%
─────────────────────────────────
TOTAL:             [                    ] 0%
```

### Por Componente

- **CP1 (Vistas)**: 0/7 tareas completadas → **0%**
- **MP1 (Procedimientos)**: 0/11 tareas completadas → **0%**

---

## 📅 Hitos Clave

| Fecha | Hito | Estado |
|-------|------|--------|
| Semana 1 - Lunes | CP1-001 y CP1-002 (2 vistas) | ⏳ Pendiente |
| Semana 1 - Martes | CP1-003 y CP1-004 (2 vistas) | ⏳ Pendiente |
| Semana 1 - Miércoles | CP1-005, CP1-006, CP1-007 (validación + doc) | ⏳ Pendiente |
| Semana 1 - Fin | CP1 completado 100% | ⏳ Pendiente |
| Semana 2 - Viernes | MP1-001, MP1-002, MP1-003 (usp_AgregarCurso) | ⏳ Pendiente |
| Semana 3 - Martes | MP1-004, MP1-005, MP1-006 (usp_ActualizarProgreso) | ⏳ Pendiente |
| Semana 3 - Viernes | MP1-007, MP1-008, MP1-009 (usp_AgregarValoracion) | ⏳ Pendiente |
| Semana 3 - Viernes | MP1-010, MP1-011 (Tests + doc) | ⏳ Pendiente |
| Semana 3 - Fin | MP1 completado 100% | ⏳ Pendiente |
| **Semana 3 - Fin** | **PRD COMPLETO** | ⏳ Pendiente |

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

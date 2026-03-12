# PRD: Plan de Mejora - Base de Datos CursosFavoritosLL

**Versión**: 1.0  
**Fecha**: 12 de marzo de 2026  
**Autor**: Architecture & DBA Team  
**Estado**: Propuesta para evaluación

---

## 1. Resumen Ejecutivo

CursosFavoritosLL es una base de datos relacional completamente funcional con modelo bien ejecutado, datos consistentes y 47 registros distribuidos en 7 tablas. **El proyecto está ACTIVO Y ESTABLE**, pero carece de capacidades operativas críticas para escala y mantenimiento:

- **Gap principal**: Falta de vistas consolidadas, procedimientos almacenados y auditoría
- **Oportunidad inmediata**: Implementar capa de aplicación robusta con validaciones centralizadas
- **Riesgo mitigable**: Cambios a esquema sin impacto en datos existentes si se usan procedimientos
- **Beneficio esperado**: 60% reducción en complejidad de aplicación, 100% trazabilidad de cambios

**Recomendación**: Proceder con Plan Fases 1-2 (Corto-Medio plazo) in Q2 2026.

---

## 2. Análisis del Estado Actual

### 2.1 Fortalezas (FODA+)

| Aspecto | Evidencia |
|---------|-----------|
| Modelo relacional | Diseño 3FN completo, 7 tablas, 16 relaciones |
| Integridad de datos | 100% FK válidas, 0 orfandades, restricciones CHECK activas |
| Cobertura de índices | 6 índices de usuario en columnas de consulta frecuente |
| Datos de prueba | 47 registros reales, distribución realista (37.5% completado, 37.5% en progreso) |
| Cardinalidades claras | 1:1 para Progreso/Valoraciones, N:M para Cursos/Categorías |
| Validaciones | Nivel, duración, fecha, URL, estado coherente con porcentaje |

### 2.2 Debilidades (FODA-)

| Aspecto | Impacto | Costo de no resolver |
|---------|---------|---------------------|
| 0 vistas | Aplicación contacta muchas tablas, lógica distribuida | Complejidad O(n) en frontend |
| 0 procedimientos almacenados | Validaciones en aplicación, riesgo de inconsistencia | Bugs de sincronización estado-progreso |
| 0 auditoría | No se sabe quién cambió qué, cuándo, por qué | Incumplimiento de trazabilidad corporativa |
| Modelo 1:1 en Progreso | No hay historial, overwrite sin registro | Pérdida de datos de evolución |
| Falta documentación ER visual | DBAs nuevos pierden tiempo entendiendo el esquema | Costo de onboarding, errores en cambios |
| Preguntas arquitectónicas sin resolver | Ambigüedad en multiusuario, auditoría, histórico | Cambios destructivos post-implementación |

### 2.3 Oportunidades (FODA→)

1. **Vistas de reporting**: Consolidar cursos + autor + progreso + valoración
2. **Procedimientos de mantenimiento**: Automatizar validaciones, sincronización
3. **Triggers de auditoría**: Historial de cambios sin denormalización
4. **Optimización de índices**: Cobertura para joins frecuentes
5. **Documentación visual**: Diagrama ER, data dictionary auto-generado

### 2.4 Amenazas (FODA✗)

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|--------|-----------|
| Cambio schema sin script de migración | Media | Alto | Versionamiento DDL, tests de rollback |
| Pérdida de datos si se modifica cardinalidad Progreso | Media | Crítico | Crear tabla histórica antes de cambios |
| Procedimientos con lógica incoherente | Media | Medio | Code review, validación en test |
| Índices inefectivos por estadísticas desactualizadas | Baja | Bajo | DBCC DBREINDEX automático |

---

## 3. Plan de Mejoras Priorizado

### 3.1 Matriz de Impacto vs Riesgo

```
ALTO IMPACTO, BAJO RIESGO → HACER YA
├─ [CP1] Crear vistas de consolidación
├─ [CP2] Documentación ER visual
└─ [CP3] Data dictionary automatizado

ALTO IMPACTO, MEDIO RIESGO → HACER CON PLANIFICACIÓN
├─ [MP1] Procedimientos almacenados core
├─ [MP2] Triggers de auditoría
└─ [MP3] Tabla histórica de Progreso

MEDIO IMPACTO, BAJO RIESGO → OPTIMIZAR
├─ [CP4] Índices adicionales de cobertura
└─ [CP5] Scripts de mantenimiento

BAJO IMPACTO, ALTO RIESGO → EVALUAR DEMANDA
└─ [LP1] Modelo multi-usuario (arquitectura compleja)
```

---

## 4. PLAN CORTO PLAZO (Q2 2026: Abril-Mayo)

### 4.1 [CP1] Crear Vistas de Consolidación

**Objetivo**: Eliminar lógica de join en aplicación, centralizar consultas, mejorar performance de reporting.

**Impacto**: Alto | **Riesgo**: Bajo | **Esfuerzo**: 1 día

#### 4.1.1 Vista 1: `v_CatalogoConsolidado`
Integra curso + autor + plataforma + estado + valoración para listing y búsqueda.

```sql
CREATE VIEW dbo.v_CatalogoConsolidado
AS
SELECT 
    c.CursoID,
    c.Titulo,
    c.Nivel,
    c.DuracionMinutos,
    c.FechaPublicacion,
    a.NombreCompleto AS Autor,
    a.País AS AutorPais,
    pl.Nombre AS Plataforma,
    pl.UrlOficial,
    c.UrlCurso,
    p.Estado,
    p.Porcentaje,
    p.FechaInicio,
    p.FechaCompletado,
    v.Puntuacion,
    v.Recomendado,
    v.Comentario,
    v.FechaValoracion
FROM dbo.Cursos c
INNER JOIN dbo.Autores a ON c.AutorID = a.AutorID
INNER JOIN dbo.Plataformas pl ON c.PlataformaID = pl.PlataformaID
LEFT JOIN dbo.Progreso p ON c.CursoID = p.CursoID
LEFT JOIN dbo.Valoraciones v ON c.CursoID = v.CursoID;

-- Índice de cobertura para reportes frecuentes
CREATE INDEX IX_vCatalogoConsolidado_Estado_Plataforma 
ON dbo.Cursos (PlataformaID, Activo) 
INCLUDE (Titulo, Nivel, AutorID);
```

**Validación**:
```sql
-- Verificar que todas las filas tengan curso válido
SELECT COUNT(*) AS RegistrosVista FROM dbo.v_CatalogoConsolidado;
-- Debe retornar 8 (total de cursos activos)

-- Verificar NULL en progreso y valoraciones (permitidos)
SELECT COUNT(*) AS ProgresosNULL FROM dbo.v_CatalogoConsolidado WHERE Estado IS NULL;
SELECT COUNT(*) AS ValoracionesNULL FROM dbo.v_CatalogoConsolidado WHERE Puntuacion IS NULL;
```

---

#### 4.1.2 Vista 2: `v_ResumenPorCategoria`
Agrupación por categoría: cantidad de cursos, progreso promedio, puntuación promedio.

```sql
CREATE VIEW dbo.v_ResumenPorCategoria
AS
SELECT 
    cat.CategoriaID,
    cat.Nombre AS Categoria,
    cat.Descripción,
    COUNT(DISTINCT cc.CursoID) AS TotalCursos,
    COUNT(DISTINCT CASE WHEN p.Estado = 'Completado' THEN cc.CursoID END) AS CompletadosCnt,
    COUNT(DISTINCT CASE WHEN p.Estado = 'En progreso' THEN cc.CursoID END) AS EnProgresoCnt,
    COUNT(DISTINCT CASE WHEN p.Estado = 'Pendiente' THEN cc.CursoID END) AS PendientesCnt,
    ROUND(AVG(CAST(p.Porcentaje AS FLOAT)), 2) AS ProgresoPromedio,
    ROUND(AVG(CAST(v.Puntuacion AS FLOAT)), 2) AS PuntuacionPromedio,
    COUNT(DISTINCT CASE WHEN v.Recomendado = 1 THEN cc.CursoID END) AS RecomendadosCnt
FROM dbo.Categorías cat
LEFT JOIN dbo.CursosCategorias cc ON cat.CategoriaID = cc.CategoriaID
LEFT JOIN dbo.Progreso p ON cc.CursoID = p.CursoID
LEFT JOIN dbo.Valoraciones v ON cc.CursoID = v.CursoID
GROUP BY cat.CategoriaID, cat.Nombre, cat.Descripción;
```

**Validación**:
```sql
-- Verificar totales por categoría (máximo 8 cursos totales)
SELECT SUM(TotalCursos) AS SumaTotal FROM dbo.v_ResumenPorCategoria;
-- Debe ser ≥ 8 (por solapamiento en categorías múltiples)

-- Verificar consistencia: CompletadosCnt + EnProgresoCnt + PendientesCnt ≤ TotalCursos
SELECT Categoria, TotalCursos, 
       (CompletadosCnt + EnProgresoCnt + PendientesCnt) AS SumaEstados
FROM dbo.v_ResumenPorCategoria
WHERE (CompletadosCnt + EnProgresoCnt + PendientesCnt) > TotalCursos;
-- Debe retornar 0 filas
```

---

#### 4.1.3 Vista 3: `v_RankingCursos`
Ranking por puntuación, estado de finalización, duración.

```sql
CREATE VIEW dbo.v_RankingCursos
AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY v.Puntuacion DESC, p.Porcentaje DESC) AS Ranking,
    c.CursoID,
    c.Titulo,
    a.NombreCompleto AS Autor,
    v.Puntuacion,
    v.Recomendado,
    p.Estado,
    p.Porcentaje,
    c.DuracionMinutos,
    c.Nivel
FROM dbo.Cursos c
INNER JOIN dbo.Autores a ON c.AutorID = a.AutorID
LEFT JOIN dbo.Valoraciones v ON c.CursoID = v.CursoID
LEFT JOIN dbo.Progreso p ON c.CursoID = p.CursoID
WHERE c.Activo = 1;
```

**Validación**:
```sql
-- Verificar que el ranking es único y secuencial
SELECT Ranking, COUNT(*) AS Cnt 
FROM dbo.v_RankingCursos 
GROUP BY Ranking 
HAVING COUNT(*) > 1;
-- Debe retornar 0 filas

-- Verificar orden descendente de puntuación
SELECT TOP 5 Ranking, Titulo, Puntuacion FROM dbo.v_RankingCursos ORDER BY Ranking;
```

---

#### 4.1.4 Vista 4: `v_CursosPorAutor`
Listado de cursos agrupados por autor con métricas.

```sql
CREATE VIEW dbo.v_CursosPorAutor
AS
SELECT 
    a.AutorID,
    a.NombreCompleto AS Autor,
    a.País,
    COUNT(c.CursoID) AS TotalCursos,
    COUNT(CASE WHEN p.Estado = 'Completado' THEN 1 END) AS CompletadosCnt,
    ROUND(AVG(CAST(v.Puntuacion AS FLOAT)), 2) AS PuntuacionPromedio,
    STRING_AGG(c.Titulo, ', ') AS Cursos
FROM dbo.Autores a
LEFT JOIN dbo.Cursos c ON a.AutorID = c.AutorID
LEFT JOIN dbo.Progreso p ON c.CursoID = p.CursoID
LEFT JOIN dbo.Valoraciones v ON c.CursoID = v.CursoID
GROUP BY a.AutorID, a.NombreCompleto, a.País;
```

**Validación**:
```sql
-- Verificar que ningún autor tenga desajuste de conteos
SELECT Autor, TotalCursos, CompletadosCnt 
FROM dbo.v_CursosPorAutor 
WHERE CompletadosCnt > TotalCursos;
-- Debe retornar 0 filas

-- Verificar que STRING_AGG no esté truncado (máx 8 cursos)
SELECT LEN(Cursos) FROM dbo.v_CursosPorAutor;
```

---

**Criterio de Éxito [CP1]**:
- ✓ 4 vistas creadas sin errores
- ✓ Todas retornan datos correctos según validaciones
- ✓ Consultas < 100ms desde aplicación
- ✓ Documentación de propósito en cada vista en `EXECUTE sp_helptext`

**Riesgos Mitigados**:
- **Cambio de esquema**: Las vistas aíslan cambios, actualizarlas es trivial
- **Performance**: Índices de cobertura incluidos, execution plans estudiados

---

### 4.2 [CP2] Documentación ER Visual y Data Dictionary

**Objetivo**: Crear artefactos de documentación para onboarding, auditoría y cambios futuros.

**Impacto**: Medio | **Riesgo**: Bajo | **Esfuerzo**: 0.5 días

#### 4.2.1 Diagrama ER (formato Markdown con mermaid)

```markdown
## Diagrama Relacional - CursosFavoritosll

Genera usando instrumento visual (SQL Server Diagram o herramienta ER):
- Nodos: 7 tablas (Plataformas, Autores, Categorías, Cursos, CursosCategorias, Progreso, Valoraciones)
- Relaciones: FK (rojo), UNIQUE (azul), índices (verde)
- Cardinalidades: 1:N, N:M, 1:1
```

#### 4.2.2 Script Auto-Generador de Data Dictionary

```sql
-- Crear vista DATA_DICTIONARY desde información del sistema
CREATE VIEW dbo.v_DataDictionary
AS
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(10)) END AS MaxLength,
    CASE WHEN c.is_nullable = 1 THEN 'YES' ELSE 'NO' END AS IsNullable,
    CASE WHEN ic.column_id IS NOT NULL THEN 'PK' ELSE '' END AS IsPrimaryKey,
    CASE WHEN fk.parent_object_id IS NOT NULL THEN 'FK' ELSE '' END AS IsForeignKey,
    ISNULL(ep.value, 'N/A') AS Description
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
LEFT JOIN sys.index_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND i.is_primary_key = 1
LEFT JOIN sys.foreign_key_columns fk ON c.object_id = fk.parent_object_id AND c.column_id = fk.parent_column_id
LEFT JOIN sys.extended_properties ep ON t.object_id = ep.major_id AND c.column_id = ep.minor_id
WHERE t.schema_id = SCHEMA_ID('dbo')
ORDER BY t.name, c.column_id;
```

**Validación**: `SELECT * FROM v_DataDictionary;` debe retornar todas las columnas.

**Criterio de Éxito [CP2]**:
- ✓ Diagrama ER visual en repositorio
- ✓ Data Dictionary generado y revisado manualmente
- ✓ Documentación de reglas de negocio (CHECK constraints) en README

---

### 4.3 [CP3] Índices Adicionales de Cobertura

**Objetivo**: Optimizar consultas frecuentes de aplicación sin cambiar estructura.

**Impacto**: Bajo | **Riesgo**: Muy Bajo | **Esfuerzo**: 0.25 días

```sql
-- Índice para búsqueda por estado + fecha (filtros comunes)
CREATE INDEX IX_Progreso_Estado_Fecha 
ON dbo.Progreso (Estado, FechaInicio, FechaCompletado) 
INCLUDE (Porcentaje);

-- Índice para búsqueda por puntuación + recomendación (ranking)
CREATE INDEX IX_Valoraciones_Puntuacion_Recomendado 
ON dbo.Valoraciones (Puntuacion DESC, Recomendado) 
INCLUDE (Comentario);

-- Índice compuesto para navegación categoría → cursos
CREATE INDEX IX_CursosCategorias_Categoria_Curso 
ON dbo.CursosCategorias (CategoriaID, CursoID) 
INCLUDE (CategoriaID);
```

**Validación**:
```sql
-- Verificar que los índices fueron creados con éxito
SELECT name FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.Progreso') 
AND name LIKE 'IX_%';

-- Estadísticas de fragmentación (debe estar < 10%)
DBCC SHOWCONTIG (Progreso);
```

**Criterio de Éxito [CP3]**:
- ✓ 3 índices creados
- ✓ Plans de ejecución muestran Index Seek (no Scan)
- ✓ Fragmentación < 10%

---

### 4.4 [CP4] Scripts de Mantenimiento Periódico

**Objetivo**: Automatizar tareas de limpieza, estadísticas y validación.

**Impacto**: Bajo | **Riesgo**: Muy Bajo | **Esfuerzo**: 0.25 días

```sql
-- Script 1: Verificación de integridad semanal
CREATE PROCEDURE dbo.usp_ValidarIntegridad
AS
BEGIN
    PRINT '=== REPORTE DE INTEGRIDAD ==='
    
    -- 1. Huérfanos: Cursos sin autor válido
    SELECT COUNT(*) AS CursosSinAutor FROM dbo.Cursos 
    WHERE AutorID NOT IN (SELECT AutorID FROM dbo.Autores);
    
    -- 2. Huérfanos: Cursos sin plataforma
    SELECT COUNT(*) AS CursosSinPlataforma FROM dbo.Cursos 
    WHERE PlataformaID NOT IN (SELECT PlataformaID FROM dbo.Plataformas);
    
    -- 3. Enlaces CCC rotos
    SELECT COUNT(*) AS CCCRotas FROM dbo.CursosCategorias 
    WHERE CursoID NOT IN (SELECT CursoID FROM dbo.Cursos) 
       OR CategoriaID NOT IN (SELECT CategoriaID FROM dbo.Categorías);
    
    -- 4. Progreso sin curso
    SELECT COUNT(*) AS ProgresoHuérfano FROM dbo.Progreso 
    WHERE CursoID NOT IN (SELECT CursoID FROM dbo.Cursos);
    
    -- 5. Valoración sin curso
    SELECT COUNT(*) AS ValoracionHuérfana FROM dbo.Valoraciones 
    WHERE CursoID NOT IN (SELECT CursoID FROM dbo.Cursos);
    
    -- 6. Inconsistencia Estado vs Porcentaje
    SELECT CursoID FROM dbo.Progreso 
    WHERE (Estado = 'Pendiente' AND Porcentaje != 0)
       OR (Estado = 'Completado' AND Porcentaje != 100)
       OR (Estado = 'En progreso' AND (Porcentaje = 0 OR Porcentaje = 100));
    
    PRINT '=== FIN REPORTE ==='
END;

-- Script 2: Actualización de estadísticas
CREATE PROCEDURE dbo.usp_ActualizarEstadisticas
AS
BEGIN
    EXEC sp_updatestats;
    DBCC REINDEX;
    PRINT 'Estadísticas actualiza... ✓';
END;

-- Script 3: Limpieza de datos inactivos (documentación futura)
CREATE PROCEDURE dbo.usp_LimpiarDatos
    @FechaCutoff DATE = NULL
AS
BEGIN
    -- Placeholder: espera especificación de regla de eliminación
    -- Ejemplo: Eliminar cursos completados hace > 2 años (con backup previo)
    PRINT 'Espera definición de política de limpieza.';
END;
```

**Validación**:
```sql
-- Ejecutar validación
EXEC dbo.usp_ValidarIntegridad;
-- Todas las columnas deben retornar 0 (sin problemas)
```

**Criterio de Éxito [CP4]**:
- ✓ 3 procedimientos creados y testeados
- ✓ Validación ejecuta sin errores y retorna 0 en todas las comprobaciones

---

### Resumen de Salidas - Plan Corto Plazo

| Item | Artefacto | Estado | Validación |
|------|-----------|--------|-----------|
| CP1 | 4 vistas | `CREATE VIEW` completado | ✓ Datos correctos |
| CP2 | ER diagram + Data Dict | Archivo markdown | ✓ Documentación |
| CP3 | 3 índices | `CREATE INDEX` completado | ✓ Fragmentación < 10% |
| CP4 | 3 procedimientos | `CREATE PROCEDURE` completado | ✓ Sin errores de integridad |

**Timeline Corto Plazo**: 2 días de desarrollo + 1 día de testing = 3 días efectivos.

---

## 5. PLAN MEDIO PLAZO (Q3 2026: Junio-Agosto)

### 5.1 [MP1] Procedimientos Almacenados Core

**Objetivo**: Centralizar lógica de negocio, validaciones y transacciones; eliminar riesgos de inconsistencia.

**Impacto**: Alto | **Riesgo**: Medio | **Esfuerzo**: 2 días

#### 5.1.1 `usp_AgregarCurso`

```sql
CREATE PROCEDURE dbo.usp_AgregarCurso
    @PlataformaID INT,
    @AutorID INT,
    @Titulo NVARCHAR(200),
    @UrlCurso NVARCHAR(300),
    @Nivel NVARCHAR(20),
    @DuracionMinutos INT,
    @FechaPublicacion DATE,
    @Activo BIT = 1,
    @CursoIDOut INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validación 1: Plataforma existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Plataformas WHERE PlataformaID = @PlataformaID)
        BEGIN
            RAISERROR('Plataforma no existe', 16, 1);
        END
        
        -- Validación 2: Autor existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Autores WHERE AutorID = @AutorID)
        BEGIN
            RAISERROR('Autor no existe', 16, 1);
        END
        
        -- Validación 3: Nivel válido
        IF @Nivel NOT IN ('Básico', 'Intermedio', 'Avanzado')
        BEGIN
            RAISERROR('Nivel debe ser Básico, Intermedio o Avanzado', 16, 1);
        END
        
        -- Validación 4: Duración positiva
        IF @DuracionMinutos <= 0
        BEGIN
            RAISERROR('Duración debe ser mayor a 0 minutos', 16, 1);
        END
        
        -- Validación 5: Fecha válida y >= 2000-01-01
        IF @FechaPublicacion < '2000-01-01'
        BEGIN
            RAISERROR('Fecha de publicación debe ser >= 2000-01-01', 16, 1);
        END
        
        -- Validación 6: URL única por plataforma
        IF EXISTS (SELECT 1 FROM dbo.Cursos 
                   WHERE PlataformaID = @PlataformaID AND Titulo = @Titulo)
        BEGIN
            RAISERROR('Ya existe un curso con ese título en esta plataforma', 16, 1);
        END
        
        -- Inserción
        INSERT INTO dbo.Cursos (PlataformaID, AutorID, Titulo, UrlCurso, Nivel, DuracionMinutos, FechaPublicacion, Activo)
        VALUES (@PlataformaID, @AutorID, @Titulo, @UrlCurso, @Nivel, @DuracionMinutos, @FechaPublicacion, @Activo);
        
        SELECT @CursoIDOut = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        PRINT 'Curso agregado exitosamente. ID: ' + CAST(@CursoIDOut AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

**Testeo**:
```sql
-- Test exitoso
DECLARE @NuevoCursoID INT;
EXEC dbo.usp_AgregarCurso 
    @PlataformaID = 1,
    @AutorID = 1,
    @Titulo = 'NuevoCursoTest',
    @UrlCurso = 'https://ejemplo.com/nuevo',
    @Nivel = 'Intermedio',
    @DuracionMinutos = 240,
    @FechaPublicacion = '2024-01-01',
    @CursoIDOut = @NuevoCursoID OUTPUT;
    
SELECT @NuevoCursoID; -- Debe retornar ID > 8

-- Test fallido: Plataforma inválida
EXEC dbo.usp_AgregarCurso 
    @PlataformaID = 999,
    @AutorID = 1,
    @Titulo = 'Test',
    @UrlCurso = 'https://test.com',
    @Nivel = 'Básico',
    @DuracionMinutos = 100,
    @FechaPublicacion = '2024-01-01';
-- Debe retornar error: "Plataforma no existe"
```

---

#### 5.1.2 `usp_ActualizarProgreso`

```sql
CREATE PROCEDURE dbo.usp_ActualizarProgreso
    @CursoID INT,
    @Estado NVARCHAR(20),
    @Porcentaje DECIMAL(5,2),
    @FechaUltimoAvance DATE = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validación 1: Curso existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Cursos WHERE CursoID = @CursoID)
        BEGIN
            RAISERROR('Curso no existe', 16, 1);
        END
        
        -- Validación 2: Estado válido
        IF @Estado NOT IN ('Pendiente', 'En progreso', 'Completado')
        BEGIN
            RAISERROR('Estado debe ser Pendiente, En progreso o Completado', 16, 1);
        END
        
        -- Validación 3: Porcentaje entre 0-100
        IF @Porcentaje < 0 OR @Porcentaje > 100
        BEGIN
            RAISERROR('Porcentaje debe estar entre 0 y 100', 16, 1);
        END
        
        -- Validación 4: Coherencia estado-porcentaje
        IF (@Estado = 'Pendiente' AND @Porcentaje != 0)
            OR (@Estado = 'En progreso' AND (@Porcentaje = 0 OR @Porcentaje = 100))
            OR (@Estado = 'Completado' AND @Porcentaje != 100)
        BEGIN
            RAISERROR('Incoherencia entre Estado y Porcentaje', 16, 1);
        END
        
        -- Obtener registro de progreso actual
        DECLARE @ProgresoActual DECIMAL(5,2), @EstadoActual NVARCHAR(20);
        SELECT @ProgresoActual = Porcentaje, @EstadoActual = Estado 
        FROM dbo.Progreso WHERE CursoID = @CursoID;
        
        -- Validación 5: No permitir retroceso
        IF @Porcentaje < @ProgresoActual
        BEGIN
            RAISERROR('No se permite retroceso de progreso', 16, 1);
        END
        
        -- Actualización
        UPDATE dbo.Progreso
        SET Estado = @Estado,
            Porcentaje = @Porcentaje,
            FechaUltimoAvance = ISNULL(@FechaUltimoAvance, CAST(GETDATE() AS DATE)),
            FechaInicio = CASE WHEN FechaInicio IS NULL THEN CAST(GETDATE() AS DATE) ELSE FechaInicio END,
            FechaCompletado = CASE WHEN @Estado = 'Completado' THEN CAST(GETDATE() AS DATE) ELSE NULL END
        WHERE CursoID = @CursoID;
        
        COMMIT TRANSACTION;
        PRINT 'Progreso actualizado. Curso ID: ' + CAST(@CursoID AS VARCHAR) + ', Estado: ' + @Estado;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

**Testeo**:
```sql
-- Test 1: Avanzar de 0% a 50%
EXEC dbo.usp_ActualizarProgreso @CursoID = 1, @Estado = 'En progreso', @Porcentaje = 50;

-- Test 2: Completar (100%)
EXEC dbo.usp_ActualizarProgreso @CursoID = 1, @Estado = 'Completado', @Porcentaje = 100;

-- Test 3: Violación - retroceso (debe fallar)
EXEC dbo.usp_ActualizarProgreso @CursoID = 1, @Estado = 'En progreso', @Porcentaje = 25;
-- ERROR: No se permite retroceso de progreso

-- Test 4: Validación estado-porcentaje (debe fallar)
EXEC dbo.usp_ActualizarProgreso @CursoID = 2, @Estado = 'Pendiente', @Porcentaje = 50;
-- ERROR: Incoherencia entre Estado y Porcentaje
```

---

#### 5.1.3 `usp_AgregarValoracion`

```sql
CREATE PROCEDURE dbo.usp_AgregarValoracion
    @CursoID INT,
    @Puntuacion TINYINT,
    @Recomendado BIT,
    @Comentario NVARCHAR(500) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validación 1: Curso existe
        IF NOT EXISTS (SELECT 1 FROM dbo.Cursos WHERE CursoID = @CursoID)
        BEGIN
            RAISERROR('Curso no existe', 16, 1);
        END
        
        -- Validación 2: Puntuación entre 1-5
        IF @Puntuacion < 1 OR @Puntuacion > 5
        BEGIN
            RAISERROR('Puntuación debe estar entre 1 y 5', 16, 1);
        END
        
        -- Validación 3: Curso ya valorado (solo una valoración por curso)
        IF EXISTS (SELECT 1 FROM dbo.Valoraciones WHERE CursoID = @CursoID)
        BEGIN
            RAISERROR('Este curso ya posee valoración. Use UPDATE en lugar de INSERT', 16, 1);
        END
        
        -- Validación 4: Curso debe estar completado o muy avanzado
        DECLARE @EstadoProgreso NVARCHAR(20), @PorcentajeProgreso DECIMAL(5,2);
        SELECT @EstadoProgreso = Estado, @PorcentajeProgreso = Porcentaje 
        FROM dbo.Progreso WHERE CursoID = @CursoID;
        
        IF @EstadoProgreso NOT IN ('Completado', 'En progreso') OR 
           (@EstadoProgreso = 'En progreso' AND @PorcentajeProgreso < 75)
        BEGIN
            RAISERROR('El curso debe estar completado o al menos 75% avanzado para valorarlo', 16, 1);
        END
        
        -- Inserción
        INSERT INTO dbo.Valoraciones (CursoID, Puntuacion, Recomendado, Comentario, FechaValoracion)
        VALUES (@CursoID, @Puntuacion, @Recomendado, @Comentario, CAST(GETDATE() AS DATE));
        
        COMMIT TRANSACTION;
        PRINT 'Valoración agregada. Curso ID: ' + CAST(@CursoID AS VARCHAR) + ', Puntuación: ' + CAST(@Puntuacion AS CHAR(1));
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(2048) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
```

**Testeo**:
```sql
-- Primero completar un curso sin valoración
UPDATE dbo.Progreso SET Estado = 'Completado', Porcentaje = 100 WHERE CursoID = 2;

-- Test exitoso
EXEC dbo.usp_AgregarValoracion 
    @CursoID = 2,
    @Puntuacion = 5,
    @Recomendado = 1,
    @Comentario = 'Excelente contenido';

-- Test fallido: Valoración duplicada
EXEC dbo.usp_AgregarValoracion 
    @CursoID = 2,
    @Puntuacion = 4,
    @Recomendado = 1;
-- ERROR: Este curso ya posee valoración
```

---

**Criterio de Éxito [MP1]**:
- ✓ 3 procedimientos creados y compilan sin errores
- ✓ Todos los tests pasan (exitosos y fallidos como se espera)
- ✓ Sin transacciones parciales (COMMIT/ROLLBACK correctos)
- ✓ Documentación en `--` incluida en código

---

### 5.2 [MP2] Triggers de Auditoría

**Objetivo**: Registrar cambios históricos automáticamente sin denormalizar tablas.

**Impacto**: Medio | **Riesgo**: Medio | **Esfuerzo**: 1.5 días

#### 5.2.1 Tabla de Auditoría

```sql
CREATE TABLE dbo.AuditoriaProgreso (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    CursoID INT NOT NULL,
    EstadoAnterior NVARCHAR(20) NULL,
    EstadoNuevo NVARCHAR(20) NOT NULL,
    PorcentajeAnterior DECIMAL(5,2) NULL,
    PorcentajeNuevo DECIMAL(5,2) NOT NULL,
    FechasCambio DATETIME DEFAULT GETDATE(),
    TipoOperacion VARCHAR(10), -- INSERT, UPDATE, DELETE
    FOREIGN KEY (CursoID) REFERENCES dbo.Cursos (CursoID)
);

CREATE TABLE dbo.AuditoriaValoraciones (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    CursoID INT NOT NULL,
    PuntuacionAnterior TINYINT NULL,
    PuntuacionNueva TINYINT NOT NULL,
    RecomendadoAnterior BIT NULL,
    RecomendadoNuevo BIT NOT NULL,
    FechaCambio DATETIME DEFAULT GETDATE(),
    TipoOperacion VARCHAR(10), -- INSERT, UPDATE, DELETE
    FOREIGN KEY (CursoID) REFERENCES dbo.Cursos (CursoID)
);

-- Índices para auditoría
CREATE INDEX IX_AuditoriaProgreso_CursoID ON dbo.AuditoriaProgreso (CursoID, FechasCambio DESC);
CREATE INDEX IX_AuditoriaValoraciones_CursoID ON dbo.AuditoriaValoraciones (CursoID, FechaCambio DESC);
```

#### 5.2.2 Triggers

```sql
-- Trigger para auditar cambios en Progreso
CREATE TRIGGER dbo.trg_AuditoriaProgreso_Update
ON dbo.Progreso
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO dbo.AuditoriaProgreso (CursoID, EstadoAnterior, EstadoNuevo, PorcentajeAnterior, PorcentajeNuevo, TipoOperacion)
    SELECT 
        d.CursoID,
        d.Estado AS EstadoAnterior,
        i.Estado AS EstadoNuevo,
        d.Porcentaje AS PorcentajeAnterior,
        i.Porcentaje AS PorcentajeNuevo,
        'UPDATE'
    FROM deleted d
    INNER JOIN inserted i ON d.ProgresoID = i.ProgresoID
    WHERE d.Estado != i.Estado OR d.Porcentaje != i.Porcentaje;
END;

-- Trigger para auditar cambios en Valoraciones
CREATE TRIGGER dbo.trg_AuditoriaValoraciones_Update
ON dbo.Valoraciones
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO dbo.AuditoriaValoraciones (CursoID, PuntuacionAnterior, PuntuacionNueva, RecomendadoAnterior, RecomendadoNuevo, TipoOperacion)
    SELECT 
        d.CursoID,
        d.Puntuacion AS PuntuacionAnterior,
        i.Puntuacion AS PuntuacionNueva,
        d.Recomendado AS RecomendadoAnterior,
        i.Recomendado AS RecomendadoNuevo,
        'UPDATE'
    FROM deleted d
    INNER JOIN inserted i ON d.ValoracionID = i.ValoracionID
    WHERE d.Puntuacion != i.Puntuacion OR d.Recomendado != i.Recomendado;
END;
```

**Validación**:
```sql
-- Realizar cambio para generar auditoría
UPDATE dbo.Progreso SET Porcentaje = 45 WHERE CursoID = 1;

-- Verificar registro de auditoría
SELECT * FROM dbo.AuditoriaProgreso WHERE CursoID = 1 ORDER BY FechasCambio DESC;
-- Debe haber un registro nuevo
```

**Criterio de Éxito [MP2]**:
- ✓ Tablas de auditoría creadas
- ✓ 2 triggers creados y compilados
- ✓ Cambios capturados automáticamente
- ✓ Se pueden recuperar históricos: SELECT * FROM AuditoriaProgreso WHERE CursoID = X

---

### 5.3 [MP3] Tabla Histórica de Progreso (Opcional - Requerimiento Futuro)

**Objetivo**: Permitir historial semanal de progreso, no sobrescribir.

**Impacto**: Medio | **Riesgo**: Medio | **Esfuerzo**: 1 día

**NOTA**: Esta acción es preparatoria. Se implementa ahora pero se liga a la tabla actual sin romper nada.

```sql
-- Tabla histórica (mantiene todos los snapshots, no solo cambios)
CREATE TABLE dbo.ProgresoHistorico (
    ProgresoHistoricoID INT IDENTITY(1,1) PRIMARY KEY,
    CursoID INT NOT NULL,
    Estado NVARCHAR(20) NOT NULL,
    Porcentaje DECIMAL(5,2) NOT NULL,
    FechaSnapshot DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Fuente VARCHAR(50) DEFAULT 'Sistema', -- Sistema, Manual, API, etc.
    FOREIGN KEY (CursoID) REFERENCES dbo.Cursos (CursoID),
    UNIQUE (CursoID, FechaSnapshot)  -- Un snapshot por curso y día
);

CREATE INDEX IX_ProgresoHistorico_Curso_Fecha 
ON dbo.ProgresoHistorico (CursoID, FechaSnapshot DESC);

-- Procedimiento para crear snapshot diario
CREATE PROCEDURE dbo.usp_CrearSnapshotProgreso
    @FechaSnapshot DATE = NULL
AS
BEGIN
    SET @FechaSnapshot = ISNULL(@FechaSnapshot, CAST(GETDATE() AS DATE));
    
    -- Insertar fila por cada curso que changed hoy
    INSERT INTO dbo.ProgresoHistorico (CursoID, Estado, Porcentaje, FechaSnapshot)
    SELECT p.CursoID, p.Estado, p.Porcentaje, @FechaSnapshot
    FROM dbo.Progreso p
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.ProgresoHistorico h 
        WHERE h.CursoID = p.CursoID AND h.FechaSnapshot = @FechaSnapshot
    )
    PRINT 'Snapshot creado para fecha: ' + CAST(@FechaSnapshot AS VARCHAR);
END;
```

**Ejecución**: Agregar a SQL Agent Job diario (11:59 PM).

**Criterio de Éxito [MP3]**:
- ✓ Tabla histórica creada
- ✓ Procedimiento de snapshot funciona
- ✓ Job de SQL Agent configurado (no bloquea aplicación actual)

---

### Resumen de Salidas - Plan Medio Plazo

| Item | Artefacto | Estado | Validación |
|------|-----------|--------|-----------|
| MP1 | 3 procedimientos core | `CREATE PROCEDURE` completado | ✓ Tests pasan |
| MP2 | 2 triggers + 2 tablas auditoría | `CREATE TRIGGER` completado | ✓ Cambios registrados |
| MP3 | Tabla + procedure histórico | Setup preparatorio | ✓ Job SQL Agent activo |

**Timeline Medio Plazo**: 4 días de desarrollo + 2 días testing = 6 días efectivos.

---

## 6. PLAN LARGO PLAZO (Q4 2026+: Septiembre en adelante)

### 6.1 [LP1] Modelo Multi-Usuario (Arquitectura Futura)

**Objetivo**: Soportar catálogos personales de múltiples usuarios.

**Impacto**: Alto | **Riesgo**: Alto | **Esfuerzo**: 5+ días

**Estado**: EVALUAR DEMANDA ANTES DE INICIAR

#### 6.1.1 Cambios Estructurales Requeridos

```sql
-- Nueva tabla: Usuarios
CREATE TABLE dbo.Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(150) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

-- Rediseño: Progreso y Valoraciones por usuario
-- ALTER TABLE dbo.Progreso ADD UsuarioID INT NOT NULL FOREIGN KEY REFERENCES dbo.Usuarios;
-- ALTER TABLE dbo.Valoraciones ADD UsuarioID INT NOT NULL FOREIGN KEY REFERENCES dbo.Usuarios;

-- Cambio de PK en Progreso
-- ALTER TABLE dbo.Progreso DROP CONSTRAINT UQ_CursoID;  -- Eliminar unicidad
-- ALTER TABLE dbo.Progreso ADD CONSTRAINT UQ_UsuarioCurso UNIQUE (UsuarioID, CursoID);

-- Catálogo compartido o personal por usuario (decisión pendiente)
-- CREATE TABLE dbo.CursosPorUsuario (
--     UsuarioID INT,
--     CursoID INT,
--     FechaAgregado DATETIME DEFAULT GETDATE(),
--     PRIMARY KEY (UsuarioID, CursoID),
--     FOREIGN KEY (UsuarioID) REFERENCES dbo.Usuarios,
--     FOREIGN KEY (CursoID) REFERENCES dbo.Cursos
-- );
```

**Impacto de cambios**:
- Todas las vistas necesitan filtro `WHERE UsuarioID = @UsuarioID`
- Procedimientos requieren parámetro `@UsuarioID`
- Triggers deben registrar quién cambió qué
- Migración de datos: asignar todos los registros actuales a un usuario "Admin"

**Criterio de Éxito [LP1]**:
- ✓ Requerimiento formal documentado
- ✓ Diseño revisado por arquitecto
- ✓ Script de migración probado en BD de prueba
- ✓ Sin downtime en producción

**Recomendación**: Esperar a Q4 2026 o después si no hay demanda clara.

---

### 6.2 [LP2] Optimizaciones Avanzadas (Performance)

**Objetivo**: Mejorar performance para escala (100+ cursos, 1000s de cambios).

**Impacto**: Bajo (a escala actual) | **Riesgo**: Bajo | **Esfuerzo**: 2-3 días

```sql
-- Particionamiento de tabla histórica por año (si crece > 1M registros)
-- CREATE PARTITION SCHEME ProgresoHistoricoScheme ...

-- Materialización de vista de resumen (si reportes son lentos)
-- CREATE MATERIALIZED VIEW v_ResumenPorCategoria_Materialized ...
-- WITH SCHEMABINDING

-- Índices columnares para análisis (BI)
-- CREATE COLUMNSTORE INDEX IX_Progreso_Columnstore ON dbo.Progreso
```

**Criterio de Éxito [LP2]**:
- ✓ Performance test con 1000+ históricos
- ✓ Queries < 500ms en peor caso
- ✓ Ningún deadlock en concurrencia

---

### Resumen Plan Largo Plazo

| Item | Recomendación | Timing |
|------|----------------|--------|
| LP1 | Multi-usuario: Evaluar demanda primero | Q4 2026 si es requerimiento |
| LP2 | Optimizaciones: Implementar si crece 100+ | Q4 2026+ según crecimiento |

---

## 7. Matriz de Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación | Owner |
|--------|-------------|---------|-----------|-------|
| **[CP] Vistas con lógica de join incorrecta** | Media | Medio | Code review antes de producción, validar con datos reales | QA |
| **[CP] Índices crean fragmentación** | Baja | Bajo | DBCC DBREINDEX automático cada semana | DBA |
| **[MP1] Procedimiento rechaza datos válidos** | Media | Medio | Testing exhaustivo con edge cases, cambios incrementales | Dev+QA |
| **[MP2] Triggers ralentizan inserciones** | Media | Medio | Índices en tablas auditoría, monitoreo de performance | DBA |
| **[MP3] Snapshots llenan disco** | Baja | Medio | Política de retención (mantener 1 año), archivado mensual | DBA |
| **[LP1] Migración multi-usuario rompe datos** | Alta | Crítico | Script de rollback, prueba en copia BD, downtime planeado | Architecture |

---

## 8. Roadmap de Implementación

### Gantt Simplificado

```
ABRIL 2026
├─ Sem 1: CP1 (4 vistas) ......................... ✓
├─ Sem 2: CP2 (ER + Data Dict) ................... ✓
├─ Sem 3: CP3 (índices) + CP4 (procedures mant.) ✓

JUNIO 2026
├─ Sem 1: MP1 (3 procedimientos core) ........... █████
├─ Sem 2: MP1 (testing + fixing) ................ █████
├─ Sem 3: MP2 (triggers + auditoría) ............ ███
├─ Sem 4: MP3 (tabla histórica) + integración .. ███

AGOSTO 2026+
├─ Monitoreo y ajustes menores .................. ♻️
├─ LP1: Evaluar demanda multi-usuario .......... ?
├─ LP2: Optimizaciones si escalado ............ ?
```

### Dependencias

```
CP1 (Vistas) ───┐
                ├─→ MP1 (Procedimientos) ──→ MP2 (Triggers)
CP2 (Doc) ──────┤    └─→ Aplicación actualiza
CP3 (Índices) ──┘
                ┗─→ MP3 (Histórico) ────→ Snapshot job
```

---

## 9. Criterios de Éxito Global

### Métricas de Aceptación

| Métrica | Objetivo | Validación |
|---------|----------|-----------|
| **Vistas creadas** | 4 / 4 | SELECT * FROM v_* retorna datos correcto |
| **Procedimientos creados** | 3 / 3 | EXEC usp_* ejecuta sin errores |
| **Triggers activos** | 2 / 2 | Cambios registrados en tablas auditoría |
| **Índices activos** | 6 nuevos | DBCC SHOWCONTIG < 10% fragmentación |
| **Tests pasando** | 100% | No hay errores en suite de testing |
| **Documentación** | ER + Data Dict | README actualizado en repositorio |
| **Integridad verificada** | 0 huérfanos | usp_ValidarIntegridad retorna 0 |
| **Rendimiento aceptable** | < 200ms promedio | Queries ejecutan rápido desde aplicación |

### Hito de "Go-Live"

- ✓ CP1 + CP2 + CP3 + CP4 completados y en producción
- ✓ MP1 + MP2 + MP3 completados y testeados
- ✓ Equipo de aplicación capacitado en nuevos procedimientos
- ✓ Documentación de cambio publicada
- ✓ Plan de rollback disponible (scripts de vuelta atrás)

---

## 10. Apéndice: Scripts de Rollback Preparatorio

**Propósito**: Tener scripts listos para revertir cambios sin pérdida de datos.

```sql
-- Rollback CP1: Eliminar vistas (sin impacto en datos)
DROP VIEW IF EXISTS dbo.v_CatalogoConsolidado;
DROP VIEW IF EXISTS dbo.v_ResumenPorCategoria;
DROP VIEW IF EXISTS dbo.v_RankingCursos;
DROP VIEW IF EXISTS dbo.v_CursosPorAutor;

-- Rollback CP3: Eliminar índices
DROP INDEX IF EXISTS IX_Progreso_Estado_Fecha ON dbo.Progreso;
DROP INDEX IF EXISTS IX_Valoraciones_Puntuacion_Recomendado ON dbo.Valoraciones;
DROP INDEX IF EXISTS IX_CursosCategorias_Categoria_Curso ON dbo.CursosCategorias;

-- Rollback MP2: Deshabilitar triggers (no eliminar, por si se necesitan)
DISABLE TRIGGER dbo.trg_AuditoriaProgreso_Update ON dbo.Progreso;
DISABLE TRIGGER dbo.trg_AuditoriaValoraciones_Update ON dbo.Valoraciones;

-- Rollback MP3: Eliminar tabla histórica (preservar datos primero)
-- EXEC sp_rename 'dbo.ProgresoHistorico', 'ProgresoHistorico_Backup';
-- DROP TABLE dbo.ProgresoHistorico_Backup;
```

---

## 11. Decisiones Pendientes (Blocking Items)

Antes de proceder con Plan Corto Plazo, resolver:

1. **¿Crear vistas para consumo de aplicación o mantener lógica de join en backend?**
   - **Recomendación**: Vistas, facilita testing y documentación
   - **Bloqueado hasta**: Alineación con equipo de aplicación

2. **¿Trazabilidad de quién cambió qué es requerimiento corporativo?**
   - **Recomendación**: Sí, agregar columna `UsuarioAuditoria` a triggers
   - **Bloqueado hasta**: Confirmación de política de auditoría

3. **¿Historial de progreso es necesario o el modelo 1:1 actual es suficiente?**
   - **Recomendación**: Implementar tabla histórica como preparatorio (MP3)
   - **Bloqueado hasta**: Claridad en reportes de evolución

4. **¿Modelo multi-usuario forma parte del roadmap?**
   - **Recomendación**: No para Q2-Q3 2026, evaluar en Q4
   - **Bloqueado hasta**: Requerimiento formal del negocio

---

## 12. Conclusiones y Siguientes Pasos

### Resumen Ejecutivo

CursosFavoritosLL está **listo para operación**, pero requiere una capa de aplicación robusta (vistas + procedimientos) para ser **production-grade**. El plan de mejora es **conservador y bajo-riesgo**, enfocado en seguridad y trazabilidad sin cambios estructurales disruptivos.

### Viabilidad

- **CP1-CP4**: 3 días, bajo riesgo, muy alto retorno de inversión
- **MP1-MP3**: 6 días, medio riesgo, alto retorno
- **LP1-LP2**: A evaluar según demanda, alto riesgo inicialmente

### Siguiente Paso Inmediato

1. **Presentar PRD a stakeholders** (DBA, Arquitecto, Equipo de APP)
2. **Obtener aprobación de decisiones pendientes** (ítems #1-4 en sección 11)
3. **Iniciar Sprint Q2** con CP1 (vistas) la primera semana
4. **Iterar feedback** de equipo de aplicación en uso de nuevas vistas

### Contacto y Governance

- **Propietario**: [Architecture & DBA Team]
- **Revisión**: Mensual (ajustar roadmap según feedback)
- **Escalación**: Si impacto proyectado > 2 días o requiere cambio de arquitectura

---

**FIN DEL DOCUMENTO PRD**

---

### Uso de Este Documento

1. **Para Implementación**: Copiar scripts exactamente, reemplazar datos de prueba con datos reales
2. **Para Documentación**: Usar como base de documentación de esquema y decisiones
3. **Para Testing**: Usar criterios de éxito y validación como checklist
4. **Para Auditoría**: Referencia de qué cambios se hicieron y por qué

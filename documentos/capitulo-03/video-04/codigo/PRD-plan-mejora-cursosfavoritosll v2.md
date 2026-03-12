# PRD: Plan de Mejora - Base de Datos CursosFavoritosLL

**Version**: 2.0  
**Fecha**: 12 de marzo de 2026  
**Autor**: Architecture y DBA Team  
**Estado**: Lanzado - En ejecucion

---

## 1. Resumen Ejecutivo

Este PRD se lanza con un alcance controlado y pedagogico para el curso. El objetivo es fortalecer la capa SQL de CursosFavoritosLL mediante dos iniciativas concretas:

1. Implementacion de vistas de consolidacion (CP1).
2. Implementacion de procedimientos almacenados core (MP1).

El trabajo se centra en scripts listos para revisar por el estudiante y ejecutar manualmente en SQL Server.

---

## 2. Alcance del Lanzamiento

### Incluido
- CP1: 4 vistas de consolidacion y 1 script de validacion.
- MP1: 3 procedimientos almacenados y 1 script de pruebas.

### Fuera de Alcance
- Auditoria avanzada (triggers y tablas historicas).
- Historico de progreso y snapshots.
- Multiusuario.
- Optimizaciones avanzadas de rendimiento.
- Automatizacion de ejecucion; la ejecucion es manual del estudiante.

---

## 3. Bloque A: Vistas (Corto Plazo)

### Objetivo
Crear una capa de consultas reutilizable y legible para reportes funcionales sin duplicar joins en la aplicacion.

### Alcance funcional
- Vista de catalogo consolidado.
- Vista de resumen por categoria.
- Vista de ranking de cursos.
- Vista de cursos por autor.

### Script sugerido (SQL Server)

#### A.1 v_CatalogoConsolidado
```sql
CREATE OR ALTER VIEW dbo.v_CatalogoConsolidado
AS
SELECT
    c.CursoID,
    c.Titulo,
    c.Nivel,
    c.DuracionMinutos,
    c.FechaPublicacion,
    a.NombreCompleto AS Autor,
    a.[Pais] AS AutorPais,
    p.Nombre AS Plataforma,
    p.UrlOficial,
    c.UrlCurso,
    pr.Estado,
    pr.Porcentaje,
    pr.FechaInicio,
    pr.FechaCompletado,
    v.Puntuacion,
    v.Recomendado,
    v.Comentario,
    v.FechaValoracion
FROM dbo.Cursos c
INNER JOIN dbo.Autores a ON a.AutorID = c.AutorID
INNER JOIN dbo.Plataformas p ON p.PlataformaID = c.PlataformaID
LEFT JOIN dbo.Progreso pr ON pr.CursoID = c.CursoID
LEFT JOIN dbo.Valoraciones v ON v.CursoID = c.CursoID;
GO
```

#### A.2 v_ResumenPorCategoria
```sql
CREATE OR ALTER VIEW dbo.v_ResumenPorCategoria
AS
SELECT
    cat.CategoriaID,
    cat.Nombre AS Categoria,
    cat.[Descripcion],
    COUNT(DISTINCT cc.CursoID) AS TotalCursos,
    COUNT(DISTINCT CASE WHEN pr.Estado = 'Completado' THEN cc.CursoID END) AS CompletadosCnt,
    COUNT(DISTINCT CASE WHEN pr.Estado = 'En progreso' THEN cc.CursoID END) AS EnProgresoCnt,
    COUNT(DISTINCT CASE WHEN pr.Estado = 'Pendiente' THEN cc.CursoID END) AS PendientesCnt,
    CAST(ROUND(AVG(CAST(pr.Porcentaje AS FLOAT)), 2) AS DECIMAL(5,2)) AS ProgresoPromedio,
    CAST(ROUND(AVG(CAST(v.Puntuacion AS FLOAT)), 2) AS DECIMAL(5,2)) AS PuntuacionPromedio
FROM dbo.[Categorias] cat
LEFT JOIN dbo.CursosCategorias cc ON cc.CategoriaID = cat.CategoriaID
LEFT JOIN dbo.Progreso pr ON pr.CursoID = cc.CursoID
LEFT JOIN dbo.Valoraciones v ON v.CursoID = cc.CursoID
GROUP BY
    cat.CategoriaID,
    cat.Nombre,
    cat.[Descripcion];
GO
```

#### A.3 v_RankingCursos
```sql
CREATE OR ALTER VIEW dbo.v_RankingCursos
AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ISNULL(v.Puntuacion, 0) DESC, ISNULL(pr.Porcentaje, 0) DESC, c.Titulo ASC) AS Ranking,
    c.CursoID,
    c.Titulo,
    a.NombreCompleto AS Autor,
    ISNULL(v.Puntuacion, 0) AS Puntuacion,
    ISNULL(pr.Porcentaje, 0) AS Porcentaje,
    ISNULL(pr.Estado, 'Pendiente') AS Estado,
    c.DuracionMinutos,
    c.Nivel
FROM dbo.Cursos c
INNER JOIN dbo.Autores a ON a.AutorID = c.AutorID
LEFT JOIN dbo.Valoraciones v ON v.CursoID = c.CursoID
LEFT JOIN dbo.Progreso pr ON pr.CursoID = c.CursoID
WHERE c.Activo = 1;
GO
```

#### A.4 v_CursosPorAutor
```sql
CREATE OR ALTER VIEW dbo.v_CursosPorAutor
AS
SELECT
    a.AutorID,
    a.NombreCompleto AS Autor,
    a.[Pais],
    COUNT(c.CursoID) AS TotalCursos,
    COUNT(CASE WHEN pr.Estado = 'Completado' THEN 1 END) AS CompletadosCnt,
    CAST(ROUND(AVG(CAST(v.Puntuacion AS FLOAT)), 2) AS DECIMAL(5,2)) AS PuntuacionPromedio,
    STRING_AGG(c.Titulo, ', ') WITHIN GROUP (ORDER BY c.Titulo) AS Cursos
FROM dbo.Autores a
LEFT JOIN dbo.Cursos c ON c.AutorID = a.AutorID
LEFT JOIN dbo.Progreso pr ON pr.CursoID = c.CursoID
LEFT JOIN dbo.Valoraciones v ON v.CursoID = c.CursoID
GROUP BY
    a.AutorID,
    a.NombreCompleto,
    a.[Pais];
GO
```

### Validacion (consultas de prueba)
```sql
SELECT COUNT(*) AS TotalCatalogo FROM dbo.v_CatalogoConsolidado;

SELECT Categoria, TotalCursos,
       (CompletadosCnt + EnProgresoCnt + PendientesCnt) AS SumaEstados
FROM dbo.v_ResumenPorCategoria
WHERE (CompletadosCnt + EnProgresoCnt + PendientesCnt) > TotalCursos;

SELECT Ranking, COUNT(*) AS Repeticiones
FROM dbo.v_RankingCursos
GROUP BY Ranking
HAVING COUNT(*) > 1;

SELECT Autor, TotalCursos, CompletadosCnt
FROM dbo.v_CursosPorAutor
WHERE CompletadosCnt > TotalCursos;
```

### Criterios de exito medibles
- 4 vistas creadas y compiladas sin error.
- 100% de consultas de validacion sin inconsistencias.
- Tiempo de respuesta promedio menor a 200 ms en dataset del curso.
- Sin columnas clave nulas no esperadas en v_CatalogoConsolidado.

### Riesgos y mitigaciones
- Riesgo: joins incorrectos que dupliquen filas.
  Mitigacion: validacion de conteos por vista y revision por pares.
- Riesgo: diferencias de nombres por acentos en objetos.
  Mitigacion: uso de corchetes en identificadores sensibles.
- Riesgo: consultas lentas por volumen.
  Mitigacion: revisar plan de ejecucion y ajustar indices en fase DBA.

### Roadmap de implementacion
- Semana 1, Dia 1: crear v_CatalogoConsolidado y v_ResumenPorCategoria.
- Semana 1, Dia 2: crear v_RankingCursos y v_CursosPorAutor.
- Semana 1, Dia 3: ejecutar validaciones, documentar hallazgos y ajustes.
- Dependencia: ninguna con MP1 para comenzar.

---

## 4. Bloque B: Procedimientos (Medio Plazo)

### Objetivo
Centralizar reglas de negocio y asegurar consistencia transaccional en operaciones de insercion y actualizacion.

### Alcance funcional
- Procedimiento para alta de curso con validaciones de dominio.
- Procedimiento para avance de progreso con reglas de estado.
- Procedimiento para registro de valoracion con controles de elegibilidad.

### Script sugerido (SQL Server)

#### B.1 usp_AgregarCurso
```sql
CREATE OR ALTER PROCEDURE dbo.usp_AgregarCurso
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
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Plataformas WHERE PlataformaID = @PlataformaID)
            THROW 50001, 'Plataforma no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Autores WHERE AutorID = @AutorID)
            THROW 50002, 'Autor no existe.', 1;

        IF @Nivel NOT IN ('Basico', 'Intermedio', 'Avanzado')
            THROW 50003, 'Nivel invalido.', 1;

        IF @DuracionMinutos <= 0
            THROW 50004, 'La duracion debe ser mayor que cero.', 1;

        IF @FechaPublicacion < '2000-01-01'
            THROW 50005, 'La fecha de publicacion es invalida.', 1;

        IF EXISTS (
            SELECT 1
            FROM dbo.Cursos
            WHERE PlataformaID = @PlataformaID
              AND Titulo = @Titulo
        )
            THROW 50006, 'Ya existe un curso con ese titulo en la plataforma.', 1;

        INSERT INTO dbo.Cursos
        (
            PlataformaID,
            AutorID,
            Titulo,
            UrlCurso,
            Nivel,
            DuracionMinutos,
            FechaPublicacion,
            Activo
        )
        VALUES
        (
            @PlataformaID,
            @AutorID,
            @Titulo,
            @UrlCurso,
            @Nivel,
            @DuracionMinutos,
            @FechaPublicacion,
            @Activo
        );

        SET @CursoIDOut = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO
```

#### B.2 usp_ActualizarProgreso
```sql
CREATE OR ALTER PROCEDURE dbo.usp_ActualizarProgreso
    @CursoID INT,
    @Estado NVARCHAR(20),
    @Porcentaje DECIMAL(5,2),
    @FechaUltimoAvance DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EstadoActual NVARCHAR(20);
    DECLARE @PorcentajeActual DECIMAL(5,2);

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Cursos WHERE CursoID = @CursoID)
            THROW 50011, 'Curso no existe.', 1;

        IF @Estado NOT IN ('Pendiente', 'En progreso', 'Completado')
            THROW 50012, 'Estado invalido.', 1;

        IF @Porcentaje < 0 OR @Porcentaje > 100
            THROW 50013, 'Porcentaje fuera de rango.', 1;

        IF (@Estado = 'Pendiente' AND @Porcentaje <> 0)
           OR (@Estado = 'En progreso' AND (@Porcentaje = 0 OR @Porcentaje = 100))
           OR (@Estado = 'Completado' AND @Porcentaje <> 100)
            THROW 50014, 'Incoherencia entre estado y porcentaje.', 1;

        SELECT
            @EstadoActual = Estado,
            @PorcentajeActual = Porcentaje
        FROM dbo.Progreso
        WHERE CursoID = @CursoID;

        IF @PorcentajeActual IS NOT NULL AND @Porcentaje < @PorcentajeActual
            THROW 50015, 'No se permite retroceso de progreso.', 1;

        IF @EstadoActual IS NULL
        BEGIN
            INSERT INTO dbo.Progreso
            (
                CursoID,
                Estado,
                Porcentaje,
                FechaInicio,
                FechaUltimoAvance,
                FechaCompletado
            )
            VALUES
            (
                @CursoID,
                @Estado,
                @Porcentaje,
                CAST(GETDATE() AS DATE),
                ISNULL(@FechaUltimoAvance, CAST(GETDATE() AS DATE)),
                CASE WHEN @Estado = 'Completado' THEN CAST(GETDATE() AS DATE) END
            );
        END
        ELSE
        BEGIN
            UPDATE dbo.Progreso
            SET Estado = @Estado,
                Porcentaje = @Porcentaje,
                FechaUltimoAvance = ISNULL(@FechaUltimoAvance, CAST(GETDATE() AS DATE)),
                FechaInicio = ISNULL(FechaInicio, CAST(GETDATE() AS DATE)),
                FechaCompletado = CASE WHEN @Estado = 'Completado' THEN CAST(GETDATE() AS DATE) ELSE NULL END
            WHERE CursoID = @CursoID;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO
```

#### B.3 usp_AgregarValoracion
```sql
CREATE OR ALTER PROCEDURE dbo.usp_AgregarValoracion
    @CursoID INT,
    @Puntuacion TINYINT,
    @Recomendado BIT,
    @Comentario NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Estado NVARCHAR(20);
    DECLARE @Porcentaje DECIMAL(5,2);

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Cursos WHERE CursoID = @CursoID)
            THROW 50021, 'Curso no existe.', 1;

        IF @Puntuacion NOT BETWEEN 1 AND 5
            THROW 50022, 'La puntuacion debe estar entre 1 y 5.', 1;

        IF EXISTS (SELECT 1 FROM dbo.Valoraciones WHERE CursoID = @CursoID)
            THROW 50023, 'El curso ya tiene valoracion registrada.', 1;

        SELECT
            @Estado = Estado,
            @Porcentaje = Porcentaje
        FROM dbo.Progreso
        WHERE CursoID = @CursoID;

        IF @Estado IS NULL
            THROW 50024, 'El curso no tiene progreso registrado.', 1;

        IF NOT (@Estado = 'Completado' OR (@Estado = 'En progreso' AND @Porcentaje >= 75))
            THROW 50025, 'Solo se puede valorar un curso completado o con avance >= 75%.', 1;

        INSERT INTO dbo.Valoraciones
        (
            CursoID,
            Puntuacion,
            Recomendado,
            Comentario,
            FechaValoracion
        )
        VALUES
        (
            @CursoID,
            @Puntuacion,
            @Recomendado,
            @Comentario,
            CAST(GETDATE() AS DATE)
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO
```

### Validacion (consultas de prueba)
```sql
DECLARE @CursoIDNuevo INT;

EXEC dbo.usp_AgregarCurso
    @PlataformaID = 1,
    @AutorID = 1,
    @Titulo = 'Curso Lanzamiento PRD',
    @UrlCurso = 'https://ejemplo.com/curso-lanzamiento-prd',
    @Nivel = 'Intermedio',
    @DuracionMinutos = 180,
    @FechaPublicacion = '2025-10-10',
    @Activo = 1,
    @CursoIDOut = @CursoIDNuevo OUTPUT;

SELECT @CursoIDNuevo AS CursoIDNuevo;

EXEC dbo.usp_ActualizarProgreso
    @CursoID = @CursoIDNuevo,
    @Estado = 'En progreso',
    @Porcentaje = 80,
    @FechaUltimoAvance = NULL;

EXEC dbo.usp_AgregarValoracion
    @CursoID = @CursoIDNuevo,
    @Puntuacion = 5,
    @Recomendado = 1,
    @Comentario = 'Validacion de lanzamiento PRD';
```

### Criterios de exito medibles
- 3 procedimientos compilados sin errores.
- 100% de pruebas de caso exitoso y fallido con resultado esperado.
- 0 cambios parciales en errores (rollback efectivo).
- Mensajes de error claros para estudiantes.

### Riesgos y mitigaciones
- Riesgo: reglas demasiado restrictivas.
  Mitigacion: casos de prueba de borde en script 09.
- Riesgo: errores por transacciones abiertas.
  Mitigacion: TRY/CATCH con XACT_STATE y ROLLBACK.
- Riesgo: conflicto por datos existentes.
  Mitigacion: pruebas en entorno de estudio y datos de ejemplo.

### Roadmap de implementacion
- Semana 2: construir usp_AgregarCurso y usp_ActualizarProgreso.
- Semana 3: construir usp_AgregarValoracion y pruebas integradas.
- Dependencia: las vistas CP1 no bloquean MP1, pero facilitan revision de resultados.

---

## 5. Plan Final Aprobado

### Iniciativas aprobadas
1. CP1 - Vistas de consolidacion (corto plazo).
2. MP1 - Procedimientos almacenados core (medio plazo).

### Cronograma compacto
- Semana 1: CP1 completo (4 vistas + validaciones).
- Semana 2: MP1 parcial (alta de curso + actualizacion de progreso).
- Semana 3: MP1 completo (valoracion + pruebas integradas + ajustes).

### Dependencias y orden recomendado
1. Crear y validar vistas CP1.
2. Crear procedimientos MP1.
3. Ejecutar pruebas integradas manuales.
4. Ajustar documentacion final del video.

### Evidencias esperadas
- Scripts SQL en carpeta codigo del video.
- README del video actualizado.
- Checklist del video con estado de avance.

---

## 6. Cierre del Lanzamiento

El PRD queda formalmente lanzado con alcance reducido, medible y alineado al objetivo pedagogico del curso. La ejecucion de scripts se realiza manualmente por el estudiante.

**Fin del PRD**

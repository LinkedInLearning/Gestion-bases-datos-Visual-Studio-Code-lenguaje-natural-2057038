/*
Objetivo: Validar MP1 con casos exitosos y fallidos.
Ejecucion: Manual por el estudiante.
Nota: Se recomienda ejecutar en base de pruebas.
*/

PRINT 'Tests MP1 - Inicio';

DECLARE @CursoIDNuevo INT;

-- Caso exitoso: alta de curso
EXEC dbo.usp_AgregarCurso
    @PlataformaID = 1,
    @AutorID = 1,
    @Titulo = 'Curso Test MP1',
    @UrlCurso = 'https://ejemplo.com/curso-test-mp1',
    @Nivel = 'Intermedio',
    @DuracionMinutos = 120,
    @FechaPublicacion = '2025-01-10',
    @Activo = 1,
    @CursoIDOut = @CursoIDNuevo OUTPUT;

SELECT @CursoIDNuevo AS CursoIDNuevo;

-- Caso exitoso: progreso al 80%
EXEC dbo.usp_ActualizarProgreso
    @CursoID = @CursoIDNuevo,
    @Estado = 'En progreso',
    @Porcentaje = 80,
    @FechaUltimoAvance = NULL;

-- Caso exitoso: valoracion
EXEC dbo.usp_AgregarValoracion
    @CursoID = @CursoIDNuevo,
    @Puntuacion = 5,
    @Recomendado = 1,
    @Comentario = 'Prueba de integracion MP1';

-- Caso fallido esperado: valoracion duplicada
BEGIN TRY
    EXEC dbo.usp_AgregarValoracion
        @CursoID = @CursoIDNuevo,
        @Puntuacion = 4,
        @Recomendado = 1,
        @Comentario = 'Debe fallar por duplicado';
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

-- Caso fallido esperado: retroceso de progreso
BEGIN TRY
    EXEC dbo.usp_ActualizarProgreso
        @CursoID = @CursoIDNuevo,
        @Estado = 'En progreso',
        @Porcentaje = 60,
        @FechaUltimoAvance = NULL;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

PRINT 'Tests MP1 - Fin';
GO

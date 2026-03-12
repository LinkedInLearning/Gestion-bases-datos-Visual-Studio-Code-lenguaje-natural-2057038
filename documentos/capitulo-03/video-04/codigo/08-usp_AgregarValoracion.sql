/*
Objetivo: Registrar valoracion de curso con reglas de elegibilidad.
Ejecucion: Manual por el estudiante en SQL Server.
*/

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

        IF NOT EXISTS (SELECT 1
  FROM dbo.Cursos
  WHERE CursoID = @CursoID)
            THROW 50021, 'Curso no existe.', 1;

        IF @Puntuacion NOT BETWEEN 1 AND 5
            THROW 50022, 'La puntuacion debe estar entre 1 y 5.', 1;

        IF EXISTS (SELECT 1
  FROM dbo.Valoraciones
  WHERE CursoID = @CursoID)
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

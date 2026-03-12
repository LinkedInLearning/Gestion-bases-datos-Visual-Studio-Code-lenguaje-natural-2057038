/*
Objetivo: Actualizar o crear progreso con reglas de consistencia.
Ejecucion: Manual por el estudiante en SQL Server.
*/

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

        IF NOT EXISTS (SELECT 1
  FROM dbo.Cursos
  WHERE CursoID = @CursoID)
            THROW 50011, 'Curso no existe.', 1;

        IF @Estado NOT IN ('Pendiente', 'En progreso', 'Completado')
            THROW 50012, 'Estado invalido.', 1;

        IF @Porcentaje < 0 OR @Porcentaje > 100
            THROW 50013, 'Porcentaje fuera de rango (0-100).', 1;

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

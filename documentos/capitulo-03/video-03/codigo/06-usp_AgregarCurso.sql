/*
Objetivo: Alta de curso con validaciones de negocio.
Ejecucion: Manual por el estudiante en SQL Server.
*/

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

        IF NOT EXISTS (SELECT 1
  FROM dbo.Plataformas
  WHERE PlataformaID = @PlataformaID)
            THROW 50001, 'Plataforma no existe.', 1;

        IF NOT EXISTS (SELECT 1
  FROM dbo.Autores
  WHERE AutorID = @AutorID)
            THROW 50002, 'Autor no existe.', 1;

        IF @Nivel NOT IN ('Basico', 'Intermedio', 'Avanzado')
            THROW 50003, 'Nivel invalido. Use Basico, Intermedio o Avanzado.', 1;

        IF @DuracionMinutos <= 0
            THROW 50004, 'La duracion debe ser mayor que cero.', 1;

        IF @FechaPublicacion < '2000-01-01'
            THROW 50005, 'La fecha de publicacion debe ser mayor o igual a 2000-01-01.', 1;

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

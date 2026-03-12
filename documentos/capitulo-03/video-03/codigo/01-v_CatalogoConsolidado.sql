/*
Objetivo: Vista consolidada para consumo de reportes del curso.
Ejecucion: Manual por el estudiante en SQL Server.
*/

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

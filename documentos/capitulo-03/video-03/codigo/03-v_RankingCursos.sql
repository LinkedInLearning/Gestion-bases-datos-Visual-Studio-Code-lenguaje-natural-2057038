/*
Objetivo: Ranking de cursos para analisis comparativo.
Ejecucion: Manual por el estudiante en SQL Server.
*/

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

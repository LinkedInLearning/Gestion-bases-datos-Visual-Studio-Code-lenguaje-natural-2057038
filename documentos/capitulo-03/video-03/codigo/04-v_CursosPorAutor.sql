/*
Objetivo: Metricas por autor para evaluar cobertura y desempeno.
Ejecucion: Manual por el estudiante en SQL Server.
*/

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

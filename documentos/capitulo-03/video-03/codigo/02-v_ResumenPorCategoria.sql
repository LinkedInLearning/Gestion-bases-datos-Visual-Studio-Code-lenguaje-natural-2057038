/*
Objetivo: Resumen agregado por categoria para seguimiento del portafolio.
Ejecucion: Manual por el estudiante en SQL Server.
*/

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

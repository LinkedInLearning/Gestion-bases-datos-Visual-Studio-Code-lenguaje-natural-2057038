/*
Objetivo: Pruebas de consistencia para las vistas CP1.
Ejecucion: Manual por el estudiante.
*/

PRINT 'Validacion CP1 - Inicio';

-- 1) Conteo general de catalogo
SELECT COUNT(*) AS TotalCatalogo
FROM dbo.v_CatalogoConsolidado;

-- 2) Coherencia de estados por categoria
SELECT
  Categoria,
  TotalCursos,
  (CompletadosCnt + EnProgresoCnt + PendientesCnt) AS SumaEstados
FROM dbo.v_ResumenPorCategoria
WHERE (CompletadosCnt + EnProgresoCnt + PendientesCnt) > TotalCursos;

-- 3) Ranking sin duplicados
SELECT Ranking, COUNT(*) AS Repeticiones
FROM dbo.v_RankingCursos
GROUP BY Ranking
HAVING COUNT(*) > 1;

-- 4) Completados no mayor a total por autor
SELECT Autor, TotalCursos, CompletadosCnt
FROM dbo.v_CursosPorAutor
WHERE CompletadosCnt > TotalCursos;

PRINT 'Validacion CP1 - Fin';
GO

/*
Objetivo: Generar un informe avanzado de rendimiento por usuario y categoria para los ultimos 12 meses.
Ejecucion: Manual por el estudiante en SQL Server.

Adaptacion al esquema actual de CursosFavoritosLL:
- La base del repositorio es monousuario y registra el progreso por curso en dbo.Progreso.
- Para conservar la salida pedida por usuario y categoria, la consulta modela un unico usuario logico.
- Los rankings y percentiles por usuario dentro de categoria quedan calculados sobre ese unico usuario.
*/

;WITH
  Parametros
  AS
  (
    SELECT
      DATEFROMPARTS(YEAR(DATEADD(MONTH, -11, CAST(GETDATE() AS DATE))), MONTH(DATEADD(MONTH, -11, CAST(GETDATE() AS DATE))), 1) AS MesInicial,
      DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)), 1) AS MesActual,
      DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(CAST(GETDATE() AS DATE)), MONTH(CAST(GETDATE() AS DATE)), 1)) AS MesSiguiente
  ),
  Numeros
  AS
  (
                                                  SELECT 0 AS N
    UNION ALL
      SELECT 1
    UNION ALL
      SELECT 2
    UNION ALL
      SELECT 3
    UNION ALL
      SELECT 4
    UNION ALL
      SELECT 5
    UNION ALL
      SELECT 6
    UNION ALL
      SELECT 7
    UNION ALL
      SELECT 8
    UNION ALL
      SELECT 9
    UNION ALL
      SELECT 10
    UNION ALL
      SELECT 11
  ),
  Meses
  AS
  (
    SELECT DATEADD(MONTH, n.N, p.MesInicial) AS MesReporte
    FROM Parametros p
    CROSS JOIN Numeros n
  ),
  UsuarioContexto
  AS
  (
    SELECT
      1 AS UsuarioID,
      CAST(N'Usuario actual' AS NVARCHAR(150)) AS Usuario
  ),
  BaseActividad
  AS
  (
    SELECT
      uc.UsuarioID,
      uc.Usuario,
      cat.CategoriaID,
      cat.Nombre AS Categoria,
      pgr.CursoID,
      pgr.Estado,
      pgr.Porcentaje,
      pgr.FechaInicio,
      pgr.FechaUltimoAvance,
      pgr.FechaCompletado,
      CASE
      WHEN pgr.FechaInicio >= p.MesInicial AND pgr.FechaInicio < p.MesSiguiente
        THEN DATEFROMPARTS(YEAR(pgr.FechaInicio), MONTH(pgr.FechaInicio), 1)
    END AS MesInicio,
      CASE
      WHEN pgr.FechaCompletado >= p.MesInicial AND pgr.FechaCompletado < p.MesSiguiente
        THEN DATEFROMPARTS(YEAR(pgr.FechaCompletado), MONTH(pgr.FechaCompletado), 1)
    END AS MesCompletado,
      CASE
      WHEN pgr.FechaInicio IS NOT NULL AND pgr.FechaCompletado IS NOT NULL
        THEN DATEDIFF(DAY, pgr.FechaInicio, pgr.FechaCompletado)
    END AS DiasHastaCompletar
    FROM dbo.Progreso pgr
    CROSS JOIN UsuarioContexto uc
      INNER JOIN dbo.Cursos c ON c.CursoID = pgr.CursoID
      INNER JOIN dbo.CursosCategorias cc ON cc.CursoID = c.CursoID
      INNER JOIN dbo.Categorias cat ON cat.CategoriaID = cc.CategoriaID
    CROSS JOIN Parametros p
    WHERE (pgr.FechaInicio >= p.MesInicial AND pgr.FechaInicio < p.MesSiguiente)
      OR (pgr.FechaCompletado >= p.MesInicial AND pgr.FechaCompletado < p.MesSiguiente)
  ),
  UsuarioCategoriaActiva
  AS
  (
    SELECT DISTINCT
      ba.UsuarioID,
      ba.Usuario,
      ba.CategoriaID,
      ba.Categoria
    FROM BaseActividad ba
  ),
  MallaMensual
  AS
  (
    SELECT
      m.MesReporte,
      uca.UsuarioID,
      uca.Usuario,
      uca.CategoriaID,
      uca.Categoria
    FROM Meses m
    CROSS JOIN UsuarioCategoriaActiva uca
  ),
  MetricasMensuales
  AS
  (
    SELECT
      mm.MesReporte,
      mm.UsuarioID,
      mm.Usuario,
      mm.CategoriaID,
      mm.Categoria,
      COALESCE(
      (
        SELECT COUNT(DISTINCT baInicio.CursoID)
        FROM BaseActividad baInicio
        WHERE baInicio.UsuarioID = mm.UsuarioID
          AND baInicio.CategoriaID = mm.CategoriaID
          AND baInicio.MesInicio = mm.MesReporte
      ),
      0
    ) AS CursosIniciados,
      COALESCE(
      (
        SELECT COUNT(DISTINCT baComp.CursoID)
        FROM BaseActividad baComp
        WHERE baComp.UsuarioID = mm.UsuarioID
          AND baComp.CategoriaID = mm.CategoriaID
          AND baComp.MesCompletado = mm.MesReporte
          AND baComp.Estado = N'Completado'
      ),
      0
    ) AS CursosCompletados,
      COALESCE(
      CAST(
        (
          SELECT AVG(CAST(baTiempo.DiasHastaCompletar AS DECIMAL(10,2)))
          FROM BaseActividad baTiempo
          WHERE baTiempo.UsuarioID = mm.UsuarioID
            AND baTiempo.CategoriaID = mm.CategoriaID
            AND baTiempo.MesCompletado = mm.MesReporte
            AND baTiempo.DiasHastaCompletar IS NOT NULL
        ) AS DECIMAL(10,2)
      ),
      0.00
    ) AS TiempoMedioDiasHastaCompletar
    FROM MallaMensual mm
  ),
  MetricasVentana
  AS
  (
    SELECT
      met.MesReporte,
      met.UsuarioID,
      met.Usuario,
      met.CategoriaID,
      met.Categoria,
      met.CursosIniciados,
      met.CursosCompletados,
      met.TiempoMedioDiasHastaCompletar,
      CAST(COALESCE(100.0 * met.CursosCompletados / NULLIF(met.CursosIniciados, 0), 0.0) AS DECIMAL(6,2)) AS TasaFinalizacionPct,
      SUM(met.CursosCompletados) OVER (PARTITION BY met.MesReporte, met.CategoriaID) AS TotalCompletadosMesCategoria,
      SUM(met.CursosCompletados) OVER (PARTITION BY met.MesReporte) AS TotalCompletadosMesGlobal,
      SUM(met.CursosCompletados) OVER () AS TotalCompletadosGlobal12Meses,
      AVG(CAST(met.CursosCompletados AS DECIMAL(10,2))) OVER (PARTITION BY met.MesReporte, met.CategoriaID) AS PromedioCompletadosMesCategoria,
      AVG(NULLIF(met.TiempoMedioDiasHastaCompletar, 0.00)) OVER (PARTITION BY met.MesReporte, met.CategoriaID) AS PromedioDiasHastaCompletarCategoria,
      LAG(met.CursosCompletados, 1, 0) OVER (PARTITION BY met.UsuarioID, met.CategoriaID ORDER BY met.MesReporte) AS CursosCompletadosMesAnterior,
      LEAD(met.CursosCompletados, 1, 0) OVER (PARTITION BY met.UsuarioID, met.CategoriaID ORDER BY met.MesReporte) AS CursosCompletadosMesSiguiente,
      LAG(CAST(COALESCE(100.0 * met.CursosCompletados / NULLIF(met.CursosIniciados, 0), 0.0) AS DECIMAL(6,2)), 1, 0.00)
      OVER (PARTITION BY met.UsuarioID, met.CategoriaID ORDER BY met.MesReporte) AS TasaFinalizacionMesAnteriorPct
    FROM MetricasMensuales met
  ),
  RankingAnualBase
  AS
  (
    SELECT
      met.UsuarioID,
      MAX(met.Usuario) AS Usuario,
      met.CategoriaID,
      MAX(met.Categoria) AS Categoria,
      SUM(met.CursosIniciados) AS CursosIniciados12Meses,
      SUM(met.CursosCompletados) AS CursosCompletados12Meses,
      CAST(COALESCE(100.0 * SUM(met.CursosCompletados) / NULLIF(SUM(met.CursosIniciados), 0), 0.0) AS DECIMAL(6,2)) AS TasaFinalizacion12MesesPct,
      CAST(AVG(NULLIF(met.TiempoMedioDiasHastaCompletar, 0.00)) AS DECIMAL(10,2)) AS TiempoMedio12MesesDias
    FROM MetricasMensuales met
    GROUP BY
    met.UsuarioID,
    met.CategoriaID
  ),
  RankingAnual
  AS
  (
    SELECT
      rab.UsuarioID,
      rab.Usuario,
      rab.CategoriaID,
      rab.Categoria,
      rab.CursosIniciados12Meses,
      rab.CursosCompletados12Meses,
      rab.TasaFinalizacion12MesesPct,
      rab.TiempoMedio12MesesDias,
      DENSE_RANK() OVER
    (
      PARTITION BY rab.CategoriaID
      ORDER BY
        rab.CursosCompletados12Meses DESC,
        rab.TasaFinalizacion12MesesPct DESC,
        CASE WHEN rab.TiempoMedio12MesesDias IS NULL THEN 2147483647 ELSE rab.TiempoMedio12MesesDias END ASC,
        rab.UsuarioID ASC
    ) AS RankingAnualCategoria
    FROM RankingAnualBase rab
  ),
  RankingMensual
  AS
  (
    SELECT
      mv.MesReporte,
      mv.UsuarioID,
      mv.Usuario,
      mv.CategoriaID,
      mv.Categoria,
      mv.CursosIniciados,
      mv.CursosCompletados,
      mv.TiempoMedioDiasHastaCompletar,
      mv.TasaFinalizacionPct,
      mv.TotalCompletadosMesCategoria,
      mv.TotalCompletadosMesGlobal,
      mv.TotalCompletadosGlobal12Meses,
      mv.PromedioCompletadosMesCategoria,
      mv.PromedioDiasHastaCompletarCategoria,
      mv.CursosCompletadosMesAnterior,
      mv.CursosCompletadosMesSiguiente,
      mv.TasaFinalizacionMesAnteriorPct,
      CAST(mv.CursosCompletados - mv.CursosCompletadosMesAnterior AS INT) AS VariacionCompletadosVsMesAnterior,
      CAST(mv.TasaFinalizacionPct - mv.TasaFinalizacionMesAnteriorPct AS DECIMAL(6,2)) AS VariacionTasaVsMesAnteriorPuntos,
      ROW_NUMBER() OVER
    (
      PARTITION BY mv.MesReporte, mv.CategoriaID
      ORDER BY
        mv.CursosCompletados DESC,
        mv.TasaFinalizacionPct DESC,
        CASE WHEN mv.TiempoMedioDiasHastaCompletar = 0 THEN 2147483647 ELSE mv.TiempoMedioDiasHastaCompletar END ASC,
        mv.UsuarioID ASC
    ) AS RankingMensualRowNumber,
      DENSE_RANK() OVER
    (
      PARTITION BY mv.MesReporte, mv.CategoriaID
      ORDER BY
        mv.CursosCompletados DESC,
        mv.TasaFinalizacionPct DESC,
        CASE WHEN mv.TiempoMedioDiasHastaCompletar = 0 THEN 2147483647 ELSE mv.TiempoMedioDiasHastaCompletar END ASC
    ) AS RankingMensualDense,
      CAST(
      (1.0 - PERCENT_RANK() OVER
      (
        PARTITION BY mv.MesReporte, mv.CategoriaID
        ORDER BY
          mv.TasaFinalizacionPct ASC,
          mv.CursosCompletados ASC,
          CASE WHEN mv.TiempoMedioDiasHastaCompletar = 0 THEN 2147483647 ELSE mv.TiempoMedioDiasHastaCompletar END DESC
      )) * 100.0 AS DECIMAL(6,2)
    ) AS PercentilRendimientoCategoriaPct
    FROM MetricasVentana mv
  )
SELECT
  rm.MesReporte,
  rm.UsuarioID,
  rm.Usuario,
  rm.CategoriaID,
  rm.Categoria,
  rm.CursosIniciados,
  rm.CursosCompletados,
  rm.TasaFinalizacionPct,
  rm.TiempoMedioDiasHastaCompletar,
  rm.RankingMensualRowNumber,
  rm.RankingMensualDense,
  ra.RankingAnualCategoria,
  rm.VariacionCompletadosVsMesAnterior,
  rm.VariacionTasaVsMesAnteriorPuntos,
  rm.PercentilRendimientoCategoriaPct,
  CAST(COALESCE(100.0 * rm.CursosCompletados / NULLIF(rm.TotalCompletadosGlobal12Meses, 0), 0.0) AS DECIMAL(8,4)) AS ContribucionPctTotalGlobal,
  rm.CursosCompletadosMesAnterior,
  rm.CursosCompletadosMesSiguiente,
  CAST(COALESCE(rm.PromedioCompletadosMesCategoria, 0.0) AS DECIMAL(10,2)) AS PromedioCompletadosMesCategoria,
  CAST(COALESCE(rm.PromedioDiasHastaCompletarCategoria, 0.0) AS DECIMAL(10,2)) AS PromedioDiasHastaCompletarCategoria,
  rm.TotalCompletadosMesCategoria,
  rm.TotalCompletadosMesGlobal,
  rm.TotalCompletadosGlobal12Meses,
  ra.CursosIniciados12Meses,
  ra.CursosCompletados12Meses,
  ra.TasaFinalizacion12MesesPct,
  ra.TiempoMedio12MesesDias
FROM RankingMensual rm
  INNER JOIN RankingAnual ra
  ON ra.UsuarioID = rm.UsuarioID
    AND ra.CategoriaID = rm.CategoriaID
ORDER BY
  rm.MesReporte DESC,
  rm.Categoria ASC,
  rm.RankingMensualDense ASC,
  rm.Usuario ASC;
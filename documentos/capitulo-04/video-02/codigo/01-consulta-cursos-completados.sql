-- Consulta principal: cursos completados
SELECT
  c.CursoID,
  c.Titulo,
  p.Estado,
  p.Porcentaje,
  p.FechaCompletado
FROM dbo.Cursos AS c
  INNER JOIN dbo.Progreso AS p ON p.CursoID = c.CursoID
WHERE p.Estado = 'Completado'
ORDER BY p.FechaCompletado DESC, c.Titulo ASC;

-- Variante: definición alternativa de completado
SELECT
  c.CursoID,
  c.Titulo,
  p.Estado,
  p.Porcentaje,
  p.FechaCompletado
FROM dbo.Cursos AS c
  INNER JOIN dbo.Progreso AS p ON p.CursoID = c.CursoID
WHERE p.Porcentaje = 100
  AND p.FechaCompletado IS NOT NULL
ORDER BY p.FechaCompletado DESC, c.Titulo ASC;

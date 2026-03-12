| Frase en lenguaje natural | Equivalencia SQL (patrón) |
|---|---|
| Dame, para cada categoría, los 3 cursos con mejor valoración y muestra su posición dentro de la categoría | `ROW_NUMBER() OVER (PARTITION BY Categoria ORDER BY Valoracion DESC)` |
| Muéstrame la evolución del progreso por usuario comparando cada curso con el anterior y el siguiente | `LAG(Progreso) OVER (PARTITION BY Usuario ORDER BY Fecha)`, `LEAD(Progreso) OVER (PARTITION BY Usuario ORDER BY Fecha)` |
| Calcula el porcentaje acumulado de cursos completados por mes para cada usuario | `SUM(...) OVER (PARTITION BY Usuario ORDER BY Mes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` |
| Identifica cursos cuya duración esté por encima del promedio de su categoría | `WHERE Duracion > (SELECT AVG(Duracion) ... WHERE CategoriaId = c.CategoriaId)` |
| Dame el top 10 global de cursos y su percentil en toda la plataforma | `TOP 10`, `PERCENT_RANK() OVER (ORDER BY Valoracion DESC)` |
| Devuélveme cursos empatados en valoración usando ranking denso por categoría | `DENSE_RANK() OVER (PARTITION BY Categoria ORDER BY Valoracion DESC)` |
| Muestra la diferencia entre cada valoración y la media móvil de las últimas 5 valoraciones por curso | `AVG(Valoracion) OVER (PARTITION BY Curso ORDER BY Fecha ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)` |
| Detecta rachas de actividad consecutiva por usuario | `ROW_NUMBER() OVER (PARTITION BY Usuario ORDER BY Fecha)` + agrupación por "islas" |
| Agrupa cursos por cuartiles de duración y devuelve un resumen por cuartil | `NTILE(4) OVER (ORDER BY Duracion)` |
| Encuentra autores cuya mediana de valoración sea superior a la mediana global | `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Valoracion) OVER (PARTITION BY Autor)` |
| Compara la valoración de cada curso con la del curso anterior del mismo autor y marca tendencia | `LAG(Valoracion) OVER (PARTITION BY Autor ORDER BY FechaPublicacion)` |
| Dame usuarios cuyo progreso actual esté en el percentil 90 o superior de su cohorte | `CUME_DIST() OVER (PARTITION BY Cohorte ORDER BY Progreso)` + filtro `>= 0.9` |
| Muestra qué porcentaje aporta cada categoría al total de cursos completados | `SUM(Completados) * 1.0 / SUM(SUM(Completados)) OVER ()` |
| Devuelve solo la última versión de cada curso y excluye versiones obsoletas | `ROW_NUMBER() OVER (PARTITION BY Curso ORDER BY Version DESC)` + filtro `rn = 1` |
| Detecta duplicados lógicos por título normalizado y autor | `GROUP BY TituloNormalizado, Autor HAVING COUNT(*) > 1` |


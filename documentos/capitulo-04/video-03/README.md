# Video 04-03 — Informe avanzado de rendimiento con CTEs y funciones de ventana

## Objetivo de aprendizaje

Construir una consulta SQL avanzada de análisis de rendimiento utilizando CTEs encadenadas, funciones de ventana y subconsultas correlacionadas, aplicada a un esquema real de base de datos monousuario en SQL Server.

## Qué se aprende en este video

- Cómo estructurar una consulta analítica compleja mediante **13 CTEs encadenadas**, cada una con una responsabilidad clara y bien delimitada.
- Uso de **funciones de ventana** con propósitos distintos:
  - `ROW_NUMBER` y `DENSE_RANK` para rankings mensuales y anuales por categoría.
  - `LAG` y `LEAD` para calcular variación frente al mes anterior y siguiente.
  - `SUM OVER` y `AVG OVER` para acumulados y promedios de ventana deslizante.
  - `PERCENT_RANK` para calcular el percentil de rendimiento.
- Cómo generar una **malla mensual completa** con `CROSS JOIN` para evitar huecos en series temporales.
- Técnica de **subconsultas correlacionadas** para métricas que no pueden agregarse directamente con `GROUP BY`.
- Manejo seguro de **nulos y división por cero** con `NULLIF` y `COALESCE`.
- Cómo adaptar una consulta diseñada para múltiples usuarios a un **esquema monousuario real**, usando un usuario lógico mediante CTE de contexto.
- Lectura, comprensión y documentación de SQL complejo bloque a bloque.

## Prompts trabajados

| # | Archivo | Descripción |
|---|---------|-------------|
| 01 | [01-informe-avanzado-rendimiento-usuarios-categorias.md](prompts/01-informe-avanzado-rendimiento-usuarios-categorias.md) | Solicitud inicial del informe avanzado con todas las técnicas requeridas |
| 02 | [02-adaptalo.md](prompts/02-adaptalo.md) | Adaptación al esquema monousuario real |
| 03 | [03-explicacion-profunda-sql-generado.md](prompts/03-explicacion-profunda-sql-generado.md) | Explicación bloque a bloque del SQL generado |
| 04 | [04-documento-explicacion-completa.md](prompts/04-documento-explicacion-completa.md) | Solicitud de documento con la explicación completa |

## Evidencias generadas

| Archivo | Descripción |
|---------|-------------|
| [codigo/01-informe-avanzado-rendimiento-usuarios-categorias.sql](codigo/01-informe-avanzado-rendimiento-usuarios-categorias.sql) | Consulta SQL avanzada (~310 líneas) con 13 CTEs, funciones de ventana y subconsultas correlacionadas, adaptada al esquema monousuario `CursosFavoritosLL` |
| [codigo/02-explicacion-informe-avanzado-rendimiento.md](codigo/02-explicacion-informe-avanzado-rendimiento.md) | Documento didáctico (~520 líneas) con análisis profundo de cada bloque del SQL: qué resuelve, por qué se usó esa técnica y cómo podría simplificarse u optimizarse |

## Resultado esperado para el estudiante

Al finalizar este video, el estudiante es capaz de:

1. Leer y entender una consulta SQL analítica compleja con múltiples CTEs encadenadas.
2. Escribir o adaptar consultas con funciones de ventana para rankings, variaciones temporales y percentiles.
3. Generar series temporales completas con `CROSS JOIN` para evitar huecos en informes mensuales.
4. Documentar y explicar SQL avanzado en lenguaje natural, justificando cada decisión técnica.
5. Usar GitHub Copilot o un asistente de IA para adaptar una consulta compleja a las restricciones reales de un esquema existente.

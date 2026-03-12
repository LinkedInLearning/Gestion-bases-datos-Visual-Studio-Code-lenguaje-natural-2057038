# Video 03-03

## Objetivo de aprendizaje

Lanzar un PRD enfocado en dos iniciativas técnicas para SQL Server: vistas de consolidación (CP1) y procedimientos almacenados core (MP1), con scripts listos para revisión del estudiante y ejecución manual.

## Qué se aprende

- Definir alcance técnico realista y medible en un PRD.
- Diseñar vistas reutilizables para consultas de negocio.
- Implementar procedimientos con validaciones y control transaccional.
- Ejecutar pruebas funcionales manuales en SQL Server.

## Prompt trabajado

- Se reestructuró el PRD para dejar únicamente dos iniciativas: CP1 (vistas) y MP1 (procedimientos).
- Se dejó fuera de alcance auditoría, histórico, multiusuario y optimizaciones avanzadas.
- Se materializaron scripts completos y coherentes para revisión y ejecución manual del estudiante.

## Evidencias generadas

- PRD final de lanzamiento: enfoque CP1 + MP1.
- Scripts CP1:
  - codigo/01-v_CatalogoConsolidado.sql
  - codigo/02-v_ResumenPorCategoria.sql
  - codigo/03-v_RankingCursos.sql
  - codigo/04-v_CursosPorAutor.sql
  - codigo/05-validacion-vistas.sql
- Scripts MP1:
  - codigo/06-usp_AgregarCurso.sql
  - codigo/07-usp_ActualizarProgreso.sql
  - codigo/08-usp_AgregarValoracion.sql
  - codigo/09-tests-procedimientos.sql

## Resultado esperado para el estudiante

Ejecutar manualmente los scripts en el orden recomendado, validar resultados y comprender cómo se implementa una capa SQL robusta con vistas y procedimientos en un entorno de base de datos relacional.

# Desafíos de práctica

## Desafío 1: Filtro y orden básico
Crea una consulta que devuelva solo cursos completados mostrando CursoID, Título, Estado, Porcentaje y FechaCompletado.

## Desafío 2: Dos formas de definir completado
Escribe dos consultas equivalentes: una con Estado = 'Completado' y otra con Porcentaje = 100 y FechaCompletado no nula. Compara resultados.

## Desafío 3: Todos los cursos con LEFT JOIN
Lista todos los cursos, incluso sin progreso, mostrando Título, Estado y Porcentaje.

## Desafío 4: Detector de inconsistencias
Identifica registros con Estado = 'Completado' y Porcentaje < 100, o con FechaCompletado nula.

## Desafío 5: Ranking de avance
Construye un ranking por mayor porcentaje y, en empate, por FechaUltimoAvance más reciente. Devuelve solo los primeros 5.

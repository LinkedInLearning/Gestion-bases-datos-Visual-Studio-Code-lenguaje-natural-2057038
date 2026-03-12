# Explicación del informe avanzado de rendimiento

## Objetivo del documento

Este documento explica en profundidad la consulta del archivo `01-informe-avanzado-rendimiento-usuarios-categorias.sql`. La idea es entender no solo qué hace cada bloque, sino también por qué está escrito así, qué técnica aporta cada parte y cómo podría simplificarse u optimizarse en un escenario real.

## Idea general de la consulta

La consulta transforma datos operativos del seguimiento de cursos en una vista analítica mensual por usuario y categoría para los últimos 12 meses.

En términos conceptuales, el flujo es este:

1. Define la ventana temporal.
2. Genera los 12 meses que se van a analizar.
3. Construye una base de actividad con fechas y medidas derivadas.
4. Genera una malla completa de meses por usuario y categoría para no perder meses sin actividad.
5. Calcula métricas mensuales.
6. Aplica funciones de ventana para comparativas, acumulados y variaciones.
7. Calcula ranking anual y ranking mensual.
8. Entrega una salida final con contexto mensual y anual en la misma fila.

La arquitectura está bien pensada porque separa preparación, agregación y analítica de ventana. Eso hace que la consulta sea mucho más fácil de razonar que si todo estuviera mezclado en un único SELECT.

## Contexto importante del modelo

La versión actual está adaptada al esquema real del repositorio, que es monousuario. La tabla `dbo.Progreso` guarda el avance por curso, no por usuario.

Por eso la consulta modela un único usuario lógico llamado `Usuario actual`. Esta decisión permite mantener una salida con columnas de usuario y categoría sin inventar tablas nuevas.

Consecuencia directa:

- Los rankings por usuario dentro de una categoría son técnicamente correctos.
- Pero al existir un solo usuario lógico, esos rankings tienden a valer 1.
- El percentil de rendimiento también pierde poder comparativo real dentro de la categoría.

Esto no invalida la consulta. Simplemente significa que, en el modelo actual, una parte del valor está en la técnica SQL y no tanto en la riqueza analítica del dato.

## Bloque 1: Parámetros

Este bloque calcula el rango temporal del informe.

Qué resuelve:

- Determina desde qué mes se deben considerar los datos.
- Define el límite superior para incluir información hasta el mes actual.

Por qué se usa esta técnica:

- Centraliza la lógica de fechas en un único lugar.
- Evita repetir expresiones de fecha varias veces en la consulta.
- Reduce errores cuando se ajusta el rango temporal.

Lo importante del diseño:

- `MesInicial` representa el primer día del mes de hace 11 meses.
- `MesSiguiente` representa el primer día del mes siguiente al actual.
- Ese patrón permite filtrar con el esquema `>= inicio` y `< fin`, que suele ser más robusto que trabajar con finales de mes manuales.

Cómo podría simplificarse:

- `MesActual` no se usa en la consulta final, por lo que podría eliminarse.

Cómo podría optimizarse:

- No hay un problema real de rendimiento aquí. Este bloque es ligero y correcto.

## Bloque 2: Números

Este bloque genera manualmente los números del 0 al 11.

Qué resuelve:

- Permite construir los 12 meses de la ventana temporal sin depender de una tabla auxiliar.

Por qué se usa esta técnica:

- Es una forma simple y autocontenida de generar una secuencia corta.
- Es muy útil en demos, ejemplos didácticos o scripts que deben ejecutarse tal cual.

Cómo podría simplificarse:

- Podría reemplazarse por una CTE recursiva.
- Podría reemplazarse por una tabla calendario si el proyecto ya la tuviera.

Cómo podría optimizarse:

- Para 12 filas, el coste es despreciable.
- En escenarios reales, una tabla calendario es la mejor opción porque aporta reutilización, más claridad y mejor integración con reportes recurrentes.

## Bloque 3: Meses

Este bloque convierte la secuencia numérica en una lista real de meses.

Qué resuelve:

- Genera exactamente una fila por cada mes dentro de la ventana de 12 meses.

Por qué se usa esta técnica:

- Permite construir luego una malla mensual completa.
- Garantiza que puedan aparecer meses con cero actividad, algo clave en analítica temporal.

Si este bloque no existiera:

- La consulta solo devolvería meses donde hubiera datos.
- Se perdería continuidad temporal.
- Las comparaciones mes a mes serían menos fiables y menos didácticas.

## Bloque 4: UsuarioContexto

Este bloque crea un usuario lógico fijo.

Qué resuelve:

- Adapta la consulta al esquema actual, que no incluye usuarios en el seguimiento del progreso.

Por qué se usa esta técnica:

- Permite mantener la estructura solicitada por usuario y categoría.
- Evita reescribir toda la consulta con otro diseño.
- Deja la salida preparada para una evolución futura hacia un modelo multiusuario.

Cómo podría simplificarse:

- Si no interesara conservar la dimensión usuario, podría eliminarse y dejar la consulta solo por categoría.

Cómo podría optimizarse:

- No hay optimización relevante aquí. Es una capa de compatibilidad conceptual.

## Bloque 5: BaseActividad

Este es el bloque central de preparación del dato.

Qué resuelve:

- Une `dbo.Progreso`, `dbo.Cursos`, `dbo.CursosCategorias` y `dbo.Categorias`.
- Deriva para cada fila el mes de inicio, el mes de completado y los días hasta completar.
- Filtra la actividad para limitarla a la ventana de 12 meses.

Por qué se usa esta técnica:

- Conviene concentrar la normalización del dato en una sola capa.
- Los cálculos derivados quedan disponibles para todas las CTE posteriores.
- Hace que las capas siguientes trabajen con datos más limpios y expresivos.

Qué aprende el estudiante aquí:

- Una consulta analítica suele necesitar una fase de preparación previa.
- No todo debe calcularse directamente en el SELECT final.
- Derivar campos una sola vez mejora legibilidad y mantenibilidad.

Detalles técnicos importantes:

- `MesInicio` se calcula a partir de `FechaInicio` truncando al primer día del mes.
- `MesCompletado` hace lo mismo con `FechaCompletado`.
- `DiasHastaCompletar` usa `DATEDIFF(DAY, FechaInicio, FechaCompletado)`.

Por qué está bien usar `CASE` aquí:

- Evita fabricar fechas mensuales cuando la fecha real es NULL.
- Conserva la semántica correcta de ausencia de dato.

Cómo podría simplificarse:

- El join con `dbo.Cursos` podría omitirse si solo necesitas `CursoID` para llegar a `dbo.CursosCategorias`.

Cómo podría optimizarse:

- En volumen grande, convendría revisar índices sobre `FechaInicio`, `FechaCompletado` y `CursoID`.
- También podría materializarse esta base en una tabla temporal si el reporte se ejecuta con frecuencia.

## Bloque 6: UsuarioCategoriaActiva

Este bloque obtiene las combinaciones activas de usuario y categoría.

Qué resuelve:

- Evita generar meses para categorías que no tienen ninguna actividad dentro del periodo.

Por qué se usa esta técnica:

- Reduce ruido en la salida.
- Mantiene la malla controlada.
- Conserva solo las combinaciones relevantes para el informe.

Cómo podría simplificarse:

- En este caso, al existir un único usuario lógico, conceptualmente podría leerse como "categorías con actividad".

## Bloque 7: MallaMensual

Este bloque hace un `CROSS JOIN` entre meses y combinaciones activas de usuario-categoría.

Qué resuelve:

- Genera una estructura completa donde cada usuario-categoría tiene una fila por mes, incluso si ese mes no tuvo movimiento.

Por qué se usa esta técnica:

- Es un patrón clásico de reporting temporal.
- Permite que los meses vacíos aparezcan con cero en vez de desaparecer.
- Facilita comparaciones con `LAG`, `LEAD` y rankings mensuales.

Qué se perdería sin esta malla:

- Los meses sin actividad.
- La continuidad del eje temporal.
- Parte de la claridad del análisis.

## Bloque 8: MétricasMensuales

Este bloque calcula las tres métricas principales por mes, usuario y categoría:

- Cursos iniciados.
- Cursos completados.
- Tiempo medio hasta completar.

Qué resuelve:

- Convierte la malla mensual en un nivel agregado listo para analítica avanzada.

Por qué se usaron subconsultas correlacionadas:

- Porque hacen muy visible la idea de "calcular esta métrica para la fila actual".
- Porque el enunciado original pedía explícitamente subconsultas correlacionadas.
- Porque didácticamente son fáciles de leer cuando cada subconsulta representa una medida concreta.

Ventaja didáctica:

- Cada métrica se entiende por separado.
- La relación entre la fila de salida y el subconjunto que se analiza queda muy clara.

Desventaja técnica:

- En rendimiento, las subconsultas correlacionadas suelen escalar peor que una agregación condicional.

Cómo podría simplificarse:

- Reemplazando estas subconsultas por un `GROUP BY` sobre `BaseActividad` con expresiones condicionales.

Cómo podría optimizarse:

- Usar una sola agregación con `SUM(CASE ...)`, `COUNT(CASE ...)` y `AVG(CASE ...)`.
- Evitar `COUNT(DISTINCT ...)` si el modelo garantiza unicidad suficiente para usar `COUNT(*)` o `COUNT(CursoID)`.

Por qué se usa `COALESCE`:

- Para convertir NULL en cero cuando no hay datos para ese mes.
- Esto hace que el reporte sea más cómodo de consumir.

## Bloque 9: MétricasVentana

Este bloque incorpora métricas que dependen de comparar una fila con otras filas dentro de su partición.

Qué resuelve:

- Calcula la tasa de finalización.
- Calcula totales por categoría y por conjunto global.
- Calcula promedios de referencia dentro del mes y la categoría.
- Recupera el valor del mes anterior y del siguiente con `LAG` y `LEAD`.

Por qué se usan funciones de ventana:

- Porque permiten analizar relaciones entre filas sin perder el detalle de cada fila.
- Si se hiciera esto con `GROUP BY`, se colapsaría la granularidad.

Explicación de cada técnica:

- `SUM(...) OVER (PARTITION BY ...)` calcula acumulados o totales por grupo sin agrupar la salida.
- `AVG(...) OVER (PARTITION BY ...)` da contexto comparativo dentro de la categoría.
- `LAG(...)` mira al mes anterior.
- `LEAD(...)` mira al siguiente mes.

Tasa de finalización:

- Se calcula como cursos completados entre cursos iniciados.
- Usa `NULLIF` para evitar dividir entre cero.
- Usa `COALESCE` para devolver 0 en lugar de NULL.

Por qué esta técnica es importante:

- El patrón `valor / NULLIF(denominador, 0)` es una de las defensas más útiles en SQL analítico.
- Evita errores de ejecución y mantiene el flujo del reporte.

Matiz sobre los tiempos medios:

- Se usa `AVG(NULLIF(TiempoMedioDiasHastaCompletar, 0.00))` para no tratar el cero técnico como una observación real.
- Eso funciona, pero conceptualmente sería más limpio mantener NULL hasta el final y aplicar `COALESCE` solo en el SELECT final.

## Bloque 10: RankingAnualBase

Este bloque resume las métricas a nivel de 12 meses por usuario y categoría.

Qué resuelve:

- Prepara la base para el ranking anual.
- Separa el resumen anual de las métricas mensuales.

Por qué se usa esta técnica:

- Evita mezclar agregación anual y ranking mensual en una sola capa.
- Hace la consulta más fácil de depurar y mantener.

Métricas que construye:

- Cursos iniciados en 12 meses.
- Cursos completados en 12 meses.
- Tasa de finalización anual.
- Tiempo medio anual hasta completar.

Cómo podría simplificarse:

- El uso de `MAX(Usuario)` y `MAX(Categoria)` responde a la necesidad de arrastrar etiquetas de columnas agrupadas. Es correcto, aunque conceptualmente ese valor es constante dentro del grupo.

## Bloque 11: RankingAnual

Este bloque aplica `DENSE_RANK()` para producir el ranking anual dentro de cada categoría.

Qué resuelve:

- Ordena a los usuarios según rendimiento anual dentro de cada categoría.

Por qué se usa `DENSE_RANK`:

- Porque mantiene empates sin saltarse posiciones intermedias.
- Si dos filas empatan en la posición 1, la siguiente queda en 2 y no en 3.

Orden de los criterios:

1. Cursos completados descendente.
2. Tasa de finalización descendente.
3. Tiempo medio ascendente.
4. UsuarioID ascendente para desempate final.

Por qué esta combinación tiene sentido:

- Prioriza volumen de logros.
- Luego efectividad relativa.
- Luego eficiencia temporal.
- Finalmente garantiza estabilidad del orden.

Cómo podría simplificarse:

- En un caso de negocio más simple, bastaría con ordenar solo por completados.

Cómo podría optimizarse o mejorarse:

- El uso de `2147483647` para mandar NULL al final funciona, pero es poco expresivo.
- Es más limpio usar una clave previa del tipo `CASE WHEN TiempoMedio12MesesDias IS NULL THEN 1 ELSE 0 END` y luego ordenar por el valor real.

## Bloque 12: RankingMensual

Este es el bloque más rico desde el punto de vista analítico.

Qué resuelve:

- Calcula variación de completados frente al mes anterior.
- Calcula variación de la tasa de finalización.
- Calcula ranking mensual con `ROW_NUMBER`.
- Calcula ranking mensual con `DENSE_RANK`.
- Calcula percentil de rendimiento con `PERCENT_RANK`.

Por qué aparecen dos rankings distintos:

- `ROW_NUMBER` siempre asigna una posición única.
- `DENSE_RANK` permite empates sin huecos.

Qué significa cada uno:

- `ROW_NUMBER` sirve cuando quieres una sola fila en primer lugar, segunda, tercera, etc.
- `DENSE_RANK` sirve cuando quieres reflejar empates reales en el rendimiento.

Por qué se usa también `PERCENT_RANK`:

- Porque no solo interesa saber una posición absoluta.
- También interesa entender la posición relativa dentro de la categoría.

Qué hace el cálculo del percentil en esta consulta:

- Ordena el rendimiento desde peor a mejor.
- Luego invierte el resultado con `1.0 - PERCENT_RANK()` para que un mejor rendimiento implique un percentil más alto.

Por qué esto es didácticamente valioso:

- Muestra que las funciones analíticas no solo sirven para ordenar, sino para situar una fila dentro de una distribución.

Cómo podría simplificarse:

- Si solo se quisiera una clasificación mensual sencilla, bastaría con `DENSE_RANK`.
- Si no aporta valor comparativo, `ROW_NUMBER` podría eliminarse.
- Si no interesa anticipar el comportamiento siguiente, `LEAD` tampoco sería necesario.

## Bloque 13: SELECT final

Este bloque une la parte mensual con la anual y construye la salida definitiva del informe.

Qué resuelve:

- Presenta en una sola fila la información mensual y el contexto anual.
- Entrega columnas operativas y analíticas listas para consumo.

Por qué se usa esta técnica:

- Permite que el consumidor del reporte no tenga que recomponer manualmente ranking anual y mensual.
- Hace la salida más útil para análisis, dashboards o exportación.

Columna importante: contribución porcentual al total global

- Se calcula como los completados de la fila entre el total global de completados de los 12 meses.
- De nuevo usa `NULLIF` y `COALESCE` para evitar divisiones inválidas.

Esto enseña una idea importante:

- Una fila puede tener medidas locales, medidas del grupo y medidas del total global al mismo tiempo.
- Las funciones de ventana hacen posible esa convivencia sin perder granularidad.

## Por qué esta arquitectura está bien resuelta

La consulta está bien diseñada por tres razones:

1. Separa etapas con una lógica clara.
2. Usa cada técnica donde aporta más valor.
3. Mantiene el detalle sin renunciar a métricas agregadas.

En otras palabras:

- Primero prepara.
- Luego agrega.
- Luego compara.
- Luego clasifica.
- Finalmente presenta.

Ese orden mental es muy valioso cuando se aprende SQL analítico avanzado.

## Diferencia clave entre agregados y funciones de ventana

Una de las grandes lecciones de esta consulta es la diferencia entre agrupar y aplicar funciones de ventana.

Con `GROUP BY`:

- Se resume la información.
- Se pierden filas del detalle original.

Con funciones `OVER (...)`:

- Se calculan métricas sobre grupos o secuencias.
- Pero se conserva la fila individual.

Por eso ambas técnicas no compiten. Se complementan.

En esta consulta:

- `MetricasMensuales` y `RankingAnualBase` agregan.
- `MetricasVentana`, `RankingAnual` y `RankingMensual` comparan sin perder el detalle ya agregado.

## Qué simplificaría en una versión más limpia

- Eliminar `MesActual` porque no se usa.
- Reemplazar la CTE `Numeros` por una tabla calendario o una CTE recursiva.
- Reescribir `MetricasMensuales` con agregación condicional en lugar de subconsultas correlacionadas.
- Mantener NULL como ausencia de dato hasta el final del proceso.
- Revisar si el join con `dbo.Cursos` es estrictamente necesario.

## Qué optimizaría en una versión orientada a producción

- Índices sobre `dbo.Progreso(FechaInicio)`, `dbo.Progreso(FechaCompletado)` y `dbo.Progreso(CursoID)`.
- Revisar el acceso a `dbo.CursosCategorias` para asegurar que el join por curso y categoría está bien cubierto.
- Materializar `BaseActividad` en una tabla temporal si el volumen o la frecuencia de ejecución crecen.
- Reducir el uso de subconsultas correlacionadas cuando la prioridad sea rendimiento y no expresividad didáctica.

## Conclusiones de aprendizaje

Este SQL enseña varias ideas potentes al mismo tiempo:

- Cómo estructurar una consulta analítica avanzada por capas.
- Cómo generar un eje temporal completo.
- Cómo combinar agregados y funciones de ventana.
- Cómo calcular variaciones intermensuales.
- Cómo construir rankings absolutos y relativos.
- Cómo proteger una consulta frente a NULL y división por cero.

La idea más importante para interiorizar es esta:

No se empieza un informe complejo por el SELECT final. Se empieza construyendo una buena base, después una buena agregación y solo al final se añaden comparativas y rankings.

Ese enfoque hace que la consulta sea más robusta, más legible y mucho más fácil de evolucionar.
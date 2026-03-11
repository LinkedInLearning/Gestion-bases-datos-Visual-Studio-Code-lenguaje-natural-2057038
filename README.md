# Gestión de bases de datos desde Visual Studio Code con lenguaje natural

Este es el repositorio del curso de LinkedIn Learning `[Gestión de bases de datos desde Visual Studio Code con lenguaje natural]`. El curso completo está disponible en [LinkedIn Learning][lil-course-url].

![Gestión de bases de datos desde Visual Studio Code con lenguaje natural][lil-thumbnail-url] 

Consulta este README en la rama main para obtener la organización actualizada del repositorio y acceder a los materiales de apoyo del curso.

DESCRIPCIÓN DEL CURSO

Aprende a gestionar y optimizar bases de datos directamente desde Visual Studio Code utilizando lenguaje natural y herramientas avanzadas. Descubre cómo conectar con un servidor SQL, crear y administrar bases de datos, y documentarlas de forma clara con el apoyo de GitHub Copilot y la extensión de SQL Server para VSCode. Este curso te muestra cómo complementar tu labor como DBA con flujos de trabajo más ágiles y eficientes, reduciendo tareas repetitivas y mejorando la precisión en la gestión diaria.		

## Instrucciones

Este repositorio se utilizará como material de apoyo del curso para ir almacenando, de forma ordenada, los archivos que se generen en cada vídeo. El objetivo es que el alumnado pueda consultar en cualquier momento los prompts utilizados durante la explicación y el código, consultas, scripts o documentos resultantes, de manera que le resulte sencillo seguir el curso y abrir directamente los materiales trabajados en cada lección.

La organización del contenido se hará por capítulos y, dentro de cada capítulo, por vídeos. Cada vídeo contará con su propio espacio para separar con claridad los prompts empleados y los archivos generados a partir de ellos. Así, el repositorio funcionará como una referencia práctica y estructurada de todo el recorrido del curso.

## Ramas

La rama principal del repositorio será main, que actuará como punto central donde se irán incorporando los materiales del curso. En lugar de trabajar con una rama distinta para cada vídeo, la separación del contenido se realizará mediante carpetas organizadas por capítulo y por vídeo.

Dentro de cada vídeo se mantendrá una estructura común que permitirá al alumnado identificar fácilmente qué se ha hecho en esa lección, qué instrucciones se han utilizado y qué archivos se han generado como resultado. Esta organización facilitará tanto el seguimiento progresivo del curso como la consulta posterior de los materiales.

## Estructura de archivos

La carpeta raíz de los materiales del curso es `documentos/`. Dentro de ella, los contenidos se organizan por capítulo y vídeo.

```text
documentos/
   capitulo-01/
      video-01/
         README.md
         prompts/
            01-prompt-inicial.md
            02-prompt-ajuste.md
         codigo/
            consulta.sql
            script.ps1
```

Reglas de organización:
1. Cada capítulo se guarda en `documentos/capitulo-XX/`.
2. Cada vídeo se guarda en `documentos/capitulo-XX/video-YY/`.
3. Los prompts del vídeo van en `prompts/` y el resultado generado va en `codigo/`.
4. Cada vídeo debe incluir su propio `README.md` con objetivo, resumen, prompts usados y archivos generados.

## Instalación

1. Para utilizar estos archivos de ejercicios, debes tener descargado lo siguiente:
   - vs Code
   - la extensión mssql
   - una cuenta de Github Copilot

2. Clona este repositorio en tu máquina local usando la Terminal (macOS) o CMD (Windows), o una herramienta GUI como SourceTree.
3. Accede a `documentos/capitulo-XX/video-YY/` para consultar los prompts, el código generado y la documentación asociada al vídeo que estés siguiendo.

### Docente

**Juanjo Luna**

Echa un vistazo a mis otros cursos en [LinkedIn Learning](https://www.linkedin.com/learning/instructors/juanjo-luna).

[0]: # (Replace these placeholder URLs with actual course URLs)
[lil-course-url]: https://www.linkedin.com
[lil-thumbnail-url]: https://media.licdn.com/dms/image/v2/D4E0DAQG0eDHsyOSqTA/learning-public-crop_675_1200/B4EZVdqqdwHUAY-/0/1741033220778?e=2147483647&v=beta&t=FxUDo6FA8W8CiFROwqfZKL_mzQhYx9loYLfjN-LNjgA

[1]: # (End of ES-Instruction ###############################################################################################)

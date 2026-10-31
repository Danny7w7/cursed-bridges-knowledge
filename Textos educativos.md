---
tags: [cursed-bridges, educación, nivel-1]
actualizado: 2026-10-30
---

# Textos educativos

Volver a [[00 Cursed Bridges]]. Reglas: [[Mecánica principal acordada]]. Integración: [[Contratos de integración]].

## Decisiones

- Público: universidad inicial; vocabulario de vértices y aristas relacionado con islas y puentes.
- Explicaciones solo antes de Comenzar y al terminar. El intento mantiene únicamente el objetivo.
- Visitas intermedias sin orden impuesto. No mostrar una solución durante la introducción.
- El nivel 1 anuncia «Dos senderos posibles», referido a los que cumplen inicio A, final D y visitas B/C.

La existencia de un sendero y el cumplimiento del objetivo son comprobaciones diferentes. En particular, A → D es un sendero válido, pero no supera el nivel porque omite B y C.

## Presentación

La cinemática muestra el mapa completo, la equivalencia islas/vértices y puentes/aristas, el rótulo de dos senderos y Cerberus. Se retiraron la enumeración de islas y la conclusión automática del teorema de Euler. La introducción no indica un recorrido concreto.

Antes de comenzar se explican la definición de sendero, la posibilidad de repetir vértices, los cruces completos y la repetición de aristas incluso en sentido contrario. Se conservan objetivo, controles, derrumbe y ventaja inicial.

Después del intento se muestran causa, explicación matemática, condiciones cumplidas o pendientes y secuencias reales de vértices y aristas. Se usa el mensaje y paso de la primera infracción del validador. Captura y lava conservan su causa física.

Ejemplo al ganar:

> Construiste un sendero: no repetiste ninguna arista. Volviste a A; repetir vértices está permitido en un sendero.

El menú «Cómo se juega» reúne los cinco conceptos de la especificación y aclara que pedir un sendero no exige, por definición, recorrer todos los puentes.

## Implementación y compatibilidad

- `TextosEducativos`: catálogo y funciones puras de composición; no valida movimientos.
- `MotorPartida`: usa la evaluación existente y el historial para construir el mensaje.
- `InterfazIntento`: conserva Bodoni/Merriweather y los colores actuales. Ventana limitada a 720×560 y al 85 %/75 % de la pantalla; texto desplazable con altura calculada y botones fijos.
- `MenuPrincipal`: panorámica y rótulos sin ruta sugerida; conserva cámara, audio, portada y acciones.
- `CatalogoNiveles`: descripción del nivel 1 sin orden de visita.
- `PruebasTextosEducativos`: comprobaciones matemáticas y editoriales.

No se cambian remotos, firmas del controlador de interfaz ni contrato 1.0.0. El cuerpo del mensaje se encuentra ahora en `ResultadoOPreparacion.Contenido.Explicacion`. Repetir un evento de resultado no duplica el contenido ni reinicia la posición de lectura.

El número de dos soluciones es texto de autoría: las pruebas enumeran las soluciones de la topología actual y fallan si deja de ser correcto. Si se editan conexiones u objetivo, actualizar el rótulo junto con esas pruebas.

El catálogo de niveles 2–5 mantiene entradas heredadas del prototipo; sigue pendiente alinearlas con sus mapas aprobados antes de habilitarlos.

## Validación

- 22 comprobaciones educativas: dos senderos, visitas libres, ausencia de solución inicial, repetición de A permitida, objetivo incompleto, primera infracción y causas físicas.
- 16 comprobaciones de interfaz: carga, tamaño, lectura, desplazamiento de un texto de 7.000 caracteres, botones, ausencia de teoría durante el intento y reinicio.
- 18 comprobaciones matemáticas, 138 de integración y 23 de Cerberus correctas.
- Cinemática real ejecutada por MCP mediante una copia temporal del mismo código con acceso al inicio de nivel; rótulos completos sin recortes, sin secuencia de islas y con el intento en preparación. La copia temporal se retiró.
- Victoria A → B → C → A → D en Play con controles normales, incluido el salto; resultado explica la repetición permitida de A y muestra vértices/aristas.
- A → D en Play termina por ausencia de salida con explicación de sendero válido y visitas B/C pendientes.

No se controló el PC ni se tomaron capturas. Guardar el place desde Studio.

## Respaldo para el compañero

`Desarrollo/Textos-educativos-2026-10-30/` contiene las seis fuentes verificadas contra Studio, huellas SHA-256, resultados, pruebas por MCP y copias anteriores. Esas seis fuentes prevalecen sobre las de entregas previas. El respaldo no incluye mallas ni sustituye guardar el place.

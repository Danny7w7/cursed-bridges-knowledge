---
tags: [cursed-bridges, diseño, especificacion]
actualizado: 2026-10-31
estado: aprobado-implementacion-parcial
---

# Mecánica principal acordada

Volver a [[00 Cursed Bridges]]. Desarrollo: [[Hoja de ruta]]. Reparto: [[Trabajo en paralelo]].

**Fuente de verdad funcional:** decisiones tomadas con el usuario y plan aceptado el 2026-10-30. Esta especificación reemplaza el alcance exclusivamente euleriano de las notas anteriores. El avance real se registra en [[Estado y pendientes]]: el nivel 1 está entregado y los niveles 2–5 siguen pendientes.

## 1. Alcance

| Decisión | Acuerdo |
|---|---|
| Público educativo | Universidad inicial. Estudio de recorridos en grafos; usar las definiciones que figuran abajo. |
| Plataforma inicial | PC, teclado y ratón. |
| Modalidad | Un jugador por partida. |
| Movimiento | Caminata libre y salto normal de Roblox. |
| Dash y obstáculos añadidos | No incluidos: sin embestida, rejillas de fuego, rocas que caen, empujones ni aturdimientos. |
| Detección | Automática, con comprobación del servidor. |
| Contenido | Cinco mapas diferentes, uno por tipo de recorrido. |
| Progresión | Secuencia fija; continuar después de ganar. |
| Persistencia | Solo la sesión. Al volver a entrar, empezar por el nivel 1. |
| Pistas | No incluidas. |
| Pausa | Solo antes de comenzar; durante el intento todo sigue avanzando. |
| Salud y vidas | No incluidas; captura y caída causan derrota inmediata. |

## 2. Definiciones y aceptación matemática

Las conexiones son aristas no dirigidas. Cada puente tiene un identificador único, aunque dos puentes unan las mismas islas.

| Tipo | Restricción |
|---|---|
| Sendero | Camino que no contiene aristas repetidas. Puede repetir vértices. |
| Trayectoria | Sendero que no contiene ningún vértice repetido. |
| Camino cerrado | Comienza y termina en el mismo vértice. Puede repetir vértices y aristas. |
| Circuito | Camino cerrado con al menos una arista y sin aristas repetidas. |
| Circuito simple | Circuito sin vértices repetidos, salvo el primero y el último. |

Para ganar cualquier desafío se debe completar al menos un cruce: aparecer en la isla inicial no es una solución vacía.

- Las categorías se solapan. Aceptar cualquier solución que cumpla el tipo pedido y las condiciones del nivel.
- No exigir utilizar todas las aristas por el hecho de pedir un sendero o circuito.
- Admitir lazos y puentes paralelos. Un lazo completo A → A puede ser circuito simple según estas definiciones; dos puentes distintos A → B → A también.
- Usar el mismo puente AB para ir y volver repite una arista, aunque cambie el sentido.
- Visitar una isla solo es un nuevo vértice del recorrido cuando se ha completado un cruce. Volver atrás dentro de un cruce incompleto no añade otra visita.

### Casos de referencia

| Recorrido | Evaluación |
|---|---|
| A → B → C | Puede ser sendero o trayectoria si las aristas son diferentes. |
| A → B → A usando el mismo AB | Puede ser camino cerrado; no es sendero ni circuito. |
| A → B → A usando AB1 y AB2 | Puede ser sendero, circuito y circuito simple; no es trayectoria. |
| A → A mediante el lazo AA | Puede ser circuito simple si también satisface el objetivo del nivel. |
| A → B → C → A → D → E → A, sin repetir aristas | Es circuito; no es circuito simple. |

## 3. Objetivos por nivel

Combinar únicamente: tipo, inicio, final e islas obligatorias. No exigir orden entre las intermedias. Las condiciones de orden, longitud o puentes específicos quedan fuera de esta versión.

| Nivel | Tipo y topología | Objetivo y ejemplo válido |
|---|---|---|
| 1 | Sendero. AB, BC, CA y AD. Conservar el triángulo actual y añadir D. | A → D visitando B y C. Ejemplo: A → B → C → A → D. |
| 2 | Trayectoria. Ocho islas A–H y once puentes: AC, AG, CF, CH, FB, BE, BG, BD, EG, GD y DH. | La ruta sin retorno: A → H sin repetir islas y sin visitas intermedias obligatorias. No exigir todas las islas ni todos los puentes. Ejemplo válido, sin imponer orden: A → C → F → B → E → G → D → H. Objetivo registrado; balance e integración física pendientes. |
| 3 | Camino cerrado. Cuadrado ABCD, AB1 y AB2 paralelos, BC, CD, DA y lazo CC. | A → A visitando B, C y D. Ejemplo con repeticiones: A → B → C → B → A → D → A. |
| 4 | Circuito. Triángulos AB–BC–CA y AD–DE–EA unidos por A. | A → A visitando B y D. Ejemplo: A → B → C → A → D → E → A. |
| 5 | Circuito simple. AB, BC, CD, DE, EA y conexión adicional AC. | A → A visitando B, C, D y E. Ejemplo: A → B → C → D → E → A. |

Las rutas de ejemplo no son soluciones únicas. El nivel 3 incluye seis puentes: AB1, AB2, BC, CD, DA y CC; en su ejemplo de ida y vuelta se permite reutilizar el mismo AB.

Todos los mapas deben admitir al menos una solución. No introducir niveles imposibles del diseño antiguo.

La especificación visual del nivel 2 reemplaza el diseño anterior de cinco islas. El escenario está construido y su objetivo está registrado en LevelData: [[Nivel 2 - La ruta sin retorno]]. Sigue como borrador independiente sin habilitarse como partida; faltan los pasos 3–6 de [[Plan de integración del nivel 2]].

## 4. Inicio, victoria y derrota

1. Preparar y cargar el mapa; colocar al jugador en A.
2. Mostrar tipo y condiciones. Mantener el intento detenido mientras lee.
3. Al pulsar **Comenzar**, habilitar el recorrido y la ventaja inicial.
4. Activar la persecución al terminar esa ventaja. Los cruces ya realizados forman parte del intento.
5. Comprobar reglas y objetivo en cada cruce completado.
6. Mostrar resultado; **Reintentar** restaura el mismo desafío y **Continuar** pasa al siguiente.

La victoria es automática cuando el recorrido cumple todas las condiciones. Llegar a la meta sin haber visitado las islas obligatorias no basta.

Derrotas:

- Regla incumplida: explicar qué puente o vértice se repitió y por qué contradice el objetivo.
- Captura de Cerberus.
- Caída a la lava.
- Sin salida: estando en una isla, no queda un cruce legal y el objetivo sigue incompleto.

No ejecutar una búsqueda global para revelar anticipadamente que una decisión eliminó todas las soluciones. Seguir permitiendo jugar mientras existan movimientos legales.

Al terminar el quinto nivel, mostrar finalización y permitir reiniciar la secuencia.

## 5. Cruces físicos

- Entrada al puente, avance y llegada deben comprobarse espacialmente en el servidor.
- Un cruce solo se añade al recorrido al alcanzar el extremo de llegada correcto.
- No contar dos veces una llegada por contacto repetido, salto o varios tablones detectados.
- Cada puente paralelo debe distinguirse por su identidad.
- Un lazo exige recorrerlo de un extremo al otro; entrar y volver por donde llegó no completa el lazo.
- Saltar dentro de una ruta válida está permitido. Un salto directo entre islas sin completar un puente no se registra como arista válida ni permite avanzar el estado a otra isla.
- Si regresa a la isla de salida antes de completar el cruce, no añadir vértice ni arista. El puente no se restaura.

## 6. Derrumbe

| Tipo de recorrido | Comportamiento |
|---|---|
| Sendero, trayectoria, circuito y circuito simple | Derrumbe progresivo detrás del jugador durante el cruce. |
| Camino cerrado | Puentes reutilizables, sin derrumbe por cruce. |

La onda de derrumbe continúa aunque el jugador se detenga o regrese. Debe poder alcanzarlo si retrocede o tarda demasiado.

Separar:

- **Recorrida:** arista que ya forma parte de la secuencia matemática.
- **En derrumbe/inutilizable:** puente que deja de ofrecer una ruta física segura.

Un puente abandonado puede quedar inutilizable sin estar recorrido. El servidor controla el soporte físico y la navegación; el efecto visual acompaña ese estado.

## 7. Cerberus

- Sigue los mismos puentes que toma el jugador, en el mismo sentido y orden. Registrar los cruces desde Comenzar, incluida la ventaja inicial; no elegir conexiones alternativas.
- Su velocidad de desplazamiento coincide con la del jugador en los cinco niveles.
- La dificultad aumenta por objetivos más exigentes y menor ventaja inicial, no por hacerlo cada vez más rápido.
- Considerar la posición del jugador durante un cruce incompleto y conservar su regreso si abandona el puente. No convertirlo en una visita a la isla de destino.
- La entrada desde la roca sigue siendo por A. Cuando un puente del rastro ya se derrumbó, saltar su mismo trayecto hasta su extremo de llegada; esperar a que el jugador termine el cruce antes de anunciar ese salto. Conservar el derrumbe actual.
- Fijar el punto de aterrizaje al anunciarlo, dar tiempo para apartarse y no capturar durante el salto ni inmediatamente al aterrizar.
- Mantener locomoción, animación, ubicación visual y detección de captura coherentes.

Cambio solicitado por el usuario el 2026-10-30: seguimiento del recorrido y salto por el mismo puente derrumbado. Detalles y evidencia: [[Cerberus seguidor]].

### Valores iniciales de balance

| Parámetro | Valor inicial del plan |
|---|---|
| Ventaja en niveles 1–5 | 10, 8, 6, 4 y 3 segundos |
| Separación inicial del derrumbe | Aproximadamente 1 segundo |
| Avance del derrumbe | Relacionado con la velocidad normal y distancia real sobre el puente |
| Aviso del salto | 2 segundos |
| Periodo sin captura tras aterrizar | 1 segundo |

Son valores iniciales configurables. Después de probar la implementación, el nivel 1 quedó validado con **12 segundos de ventaja** y el resto de sus valores sin cambios; ver [[Entrega del nivel 1]]. El balance de los niveles 2–5 sigue pendiente de pruebas.

Estado local al integrar Cerberus del nivel 2 el 2026-10-31: el nivel 1 ya tenía **5 segundos** en su atributo y se conservó. El nivel 2 usa **4 segundos** como valor inicial, con velocidad 16 y tiempos de salto 2/1,2/1. Su persecución se probó de forma aislada; el balance de una partida completa se cerrará en el paso 6 de [[Plan de integración del nivel 2]].

## 8. Interfaz y explicación

Antes de Comenzar: explicar la equivalencia islas/vértices y puentes/aristas, la definición del recorrido, el objetivo y los controles. Lenguaje para universidad inicial. La cinemática presenta una panorámica y los conceptos, sin enumerar islas como secuencia ni revelar soluciones.

Durante el intento: mantener únicamente el tipo solicitado y las condiciones concretas. Las visitas intermedias se indican sin imponer orden. No mostrar teoría ni avisos educativos durante la persecución.

El nivel 1 tiene dos senderos que cumplen sus condiciones: el rótulo inicial dice «Dos senderos posibles» y no los enumera. El recuento se comprueba con la topología actual en las pruebas.

Después de ganar o perder: mostrar las secuencias reales de vértices y aristas y explicar por separado la validez matemática y el cumplimiento del objetivo. Repetir A puede estar permitido; A → D puede ser un sendero válido y aun así perder por faltar B y C. No exigir todos los puentes por la definición de sendero.

Para un error, señalar la primera infracción indicada por el validador. Para captura o caída, conservar la causa física sin inventar un error matemático. Los textos largos se desplazan con los botones fijos. Detalles y evidencia: [[Textos educativos]].

## 9. Restauración y escenarios editables

- Conservar mapas en Workspace y las ediciones manuales. No reconstruirlos en cada Play.
- Guardar/restaurar el estado de las piezas para cada reintento.
- Reiniciar recorrido, puentes, personaje y Cerberus.
- Invalidar callbacks, animaciones y acciones pendientes de intentos anteriores.
- Preparar la llegada al siguiente mapa con streaming activo antes de permitir movimiento y persecución.

## 10. Límites

No añadir multijugador, persistencia entre sesiones, salud, vidas, puntuaciones, pistas, pausa activa, nuevos assets externos, modo arquitecto, niveles imposibles ni rediseño artístico.

No controlar el PC del usuario. Usar MCP; solicitarle una captura o comprobación visual solo cuando resulte necesaria.

---
tags: [cursed-bridges, coordinacion, contratos]
actualizado: 2026-10-31
---

# Trabajo en paralelo

Volver a [[00 Cursed Bridges]]. Orden: [[Hoja de ruta]]. Reglas: [[Mecánica principal acordada]].

## Responsabilidades

- **Responsable principal:** integración de sistemas, estado del intento, validación autoritativa, cruces, derrumbes, persecución e integración final.
- **Compañero:** entregas acotadas con entradas/salidas conocidas, textos, presentación, auditoría de mapas y pruebas. Puede tomar un módulo mayor cuando se le asigne expresamente y quede separado del trabajo activo.
- **Usuario:** decisiones de alcance y comprobaciones visuales o de jugabilidad que se le soliciten.

El documento propone límites de trabajo; no lanza agentes ni asigna tareas automáticamente a otro chat.

## Límite de la mecánica

Por decisión explícita del usuario, el juego se centra en construir recorridos sobre el grafo. No incorporar dash, rejillas de fuego, rocas que caen, aturdimientos o empujones. El fuego ambiental de braseros, runas y decoración se conserva. Cualquier ampliación de mecánicas requiere una nueva decisión del usuario.

Los componentes Embestida y PeligrosPuentes se retiraron de Studio; sus copias en Desarrollo son respaldo histórico, no módulos para reinstalar. Véase [[Mecánica centrada en grafos]].

## Tareas disponibles para el compañero

| ID | Entrega concreta | Cuándo empezar | Límites |
|---|---|---|---|
| P01 | Catálogo de textos de objetivos y resultados, más ejemplos válidos e inválidos de los cinco tipos. | Ahora. | Documento propio; no editar validadores ni cambiar definiciones. |
| P02 | Interfaz mínima aislada para preparación, intento y resultado. | Contrato 1.0.0 disponible; coordinar turno sobre la base existente. | Crear un módulo de presentación; no editar `GameController` ni conectar directamente los remotos. |
| P03 | Informe de conexiones y anchuras de los cinco mapas: puertas, extremos, huecos, paralelos y lazos. | Al entregar R02, o sobre una copia acordada durante su preparación. | Lectura del escenario; correcciones geométricas solo por turno y en objetos asignados. |
| P04 | Matriz de pruebas y reproducción de errores con nivel, ruta e identificadores. | Casos matemáticos desde R01; físicos desde R03. | No corregir simultáneamente los controladores mientras el principal integra. |
| P05 | Apoyo de locomoción: poses de caminar/saltar y revisión de correspondencia con el cuerpo. | Tras acordar raíz móvil y contrato de animación en R00/R06. | Módulo o copia aislada; no sustituir el animador activo sin entrega coordinada. |

**P01 integrado para el nivel 1:** catálogo, explicaciones iniciales/finales y pruebas en [[Textos educativos]]. El compañero puede continuar con los textos de los mapas pendientes y revisar contenido, coordinando la escritura de módulos compartidos.

### P01 — Textos y ejemplos

El nivel 1 ya utiliza `TextosEducativos`. Mantener universidad inicial, teoría solo antes/después, resultado con historial real y cinemática sin solución ni orden de visitas. No sobrescribir el módulo o el diseño actual sin releerlo.

Entregar un archivo propio, por ejemplo `Textos educativos.md`, con:

- Instrucción breve de cada uno de los cinco objetivos aprobados.
- Explicación de victoria y ejemplos de primera infracción.
- Mensajes separados para captura, lava y ausencia de salida.
- Casos de lazo, paralelos y repetición en sentido inverso.
- Ejemplos que demuestren que sendero puede repetir vértices y camino cerrado puede repetir aristas.

**Aceptación:** español claro, terminología exacta, sin afirmar que todo circuito es euleriano ni exigir todos los puentes. No añadir pistas o teoría permanente.

### P02 — Interfaz mínima

Existe una implementación base de `InterfazIntento`. El compañero puede mejorar su presentación por turno, conservando [[Contratos de integración]], para que:

- Reciba datos y callbacks; no deduzca el estado del juego.
- Muestre tipo y condiciones durante el intento.
- Muestre Comenzar en preparación y las acciones correspondientes al resultado.
- Presente la explicación detallada al terminar.
- Limpie conexiones y elementos al destruirse.

El responsable principal adapta `UIController` e integra el módulo. El compañero no debe modificar ese mismo controlador por su cuenta.

**Aceptación:** funciona con datos de prueba, sin depender del servidor ni introducir pistas, pausa activa, salud, puntuación o diseños para plataformas fuera de PC.

### P03 — Revisión de mapas

Entregar una tabla por mapa con objetos inspeccionados, problema, evidencia textual y corrección propuesta. Priorizar:

1. Identificadores duplicados o conexiones a islas inexistentes.
2. Extremos que no llegan a los muelles.
3. Paso del personaje y cuerpo de Cerberus.
4. Entradas distinguibles de paralelos y lazos.
5. Tablones sin orden o rutas que se cruzan físicamente sin vértice.

No volver a generar mapas para corregirlos ni modificar plantillas compartidas sin coordinación.

### P04 — Pruebas y reporte

Registrar como mínimo: nivel, estado inicial, secuencia de vértices, identificadores de aristas, acción física, resultado esperado, resultado observado y pasos para reproducir.

Un reporte debe distinguir fallo matemático, detección física, navegación, representación y reinicio. Solicitar capturas al usuario solo cuando la información textual o por MCP no alcance.

### P05 — Animación

Preparar poses y transiciones que reciban una raíz y un estado de locomoción, sin elegir rutas ni decidir capturas. Conservar `JointPos` y la jerarquía del modelo.

**Aceptación:** no devuelve a Cerberus a su plataforma original, no altera su tamaño para ocultar problemas de paso y puede volver a reposo al terminar el intento.

## Contratos fijados en R00

El contrato técnico 1.0.0 está fijado en [[Contratos de integración]]. La base del nivel 1 está validada; ver [[Entrega del nivel 1]]. El compañero puede mejorar textos y presentación sobre esa base, conservando firmas y coordinando turnos de escritura. No sustituir el motor ni el adaptador de remotos.

### Datos compartidos

| Concepto | Contenido mínimo |
|---|---|
| Tipo de recorrido | `sendero`, `trayectoria`, `camino_cerrado`, `circuito`, `circuito_simple` |
| Objetivo | `tipo`, `inicio`, `final`, `islasObligatorias` |
| Historial | Secuencias ordenadas de vértices y aristas, más conjuntos/contadores de visitas. |
| Fase | Preparación, activo, victoria o derrota; ventaja inicial pertenece al intento activo. |
| Cruce en curso | Arista, extremo de entrada, sentido y avance físico; no se añade todavía al historial. |
| Puente | Separar recorrido matemático, derrumbe y transitabilidad física. |
| Resultado | Resultado, causa, explicación y referencias a los identificadores implicados. |
| Identidad del intento | Valor que cambia al reiniciar o avanzar y permite ignorar callbacks antiguos. |

El catálogo de objetivos vive en `LevelData`; la topología y las posiciones reales se obtienen de los modelos del escenario.

### Frontera de presentación

~~~text
crear(contenedor, acciones) -> controladorInterfaz
acciones: alComenzar, alReintentar, alContinuar

controladorInterfaz.actualizar(estadoPresentacion)
controladorInterfaz.mostrarResultado(resultadoPresentacion)
controladorInterfaz.destruir()
~~~

El estado de presentación contiene textos y disponibilidad de acciones. La interfaz no procesa movimientos, no llama al validador y no envía victorias o cruces.

### Fronteras del servidor

- Validador: recibe objetivo e historial; devuelve evaluación sin mover objetos.
- Detector: emite cruces comprobados; no decide la victoria.
- Controlador: aplica reglas y cambios del intento una sola vez.
- Derrumbe: recibe inicio/sentido e identidad del intento; comunica transitabilidad.
- Navegación: recibe grafo transitable y posiciones; devuelve ruta por distancia.
- Cerberus: consume navegación y estado; no modifica el historial del jugador.

No utilizar el algoritmo de pistas de Euler como sustituto de estos contratos.

## Cómo evitar interferencias entre chats

1. Antes de escribir, declarar etapa, entrega y objetos/scripts que se van a tocar.
2. Si ambos usan la misma instancia de Studio, alternar escrituras y pruebas de Play. El otro puede trabajar en documentación, preparar módulos fuera de la instancia o revisar información.
3. Releer la versión actual de cada script al tomar el turno.
4. No sobrescribir cambios ajenos ni sustituir un mapa generado por el otro.
5. Entregar un resumen concreto al terminar y liberar los objetos asignados.
6. Integrar un módulo solo después de comprobar que cumple el contrato fijado en R00.

`GameController`, `UIController`, `BridgeFX`, `CerberusAnimator`, el arranque y los escenarios compartidos requieren un único escritor a la vez. No editar estos objetos en paralelo por el hecho de que las tareas tengan nombres diferentes.

## Registro de entrega

Copiar este bloque al cerrar cada tarea:

~~~text
Fecha:
Responsable:
Etapa o tarea:
Estado: pendiente / en curso / listo para integrar / verificado
Objetos o archivos modificados:
Contrato utilizado y versión:
Qué entrega:
Qué se comprobó y resultado:
Pendientes o limitaciones:
Qué puede hacer el siguiente responsable:
Objetos liberados:
~~~

No marcar un comportamiento como probado si solo se revisó el código. No publicar, enviar mensajes a terceros ni ampliar el alcance como parte de una entrega.

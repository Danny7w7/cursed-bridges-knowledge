---
tags: [cursed-bridges, nivel-1, geometría]
actualizado: 2026-10-30
---

# Uniones de puentes

Volver a [[00 Cursed Bridges]]. Estado: [[Estado y pendientes]].

## Corrección

Los muelles son más estrechos que los tableros. Un encuentro que sostiene al personaje por el centro puede dejar huecos laterales. Se añadieron ocho accesos de piedra, uno por extremo de AB, BC, CA y AD, sin mover ni sustituir las piezas existentes.

Cada acceso cubre el ancho del tablón extremo más un margen de 0,25 studs por lado. Su borde interior entra en el disco de la isla y el exterior se solapa con el primer tablón. La pendiente conecta las alturas reales de las superficies. Material y color se toman de las placas del muelle cercano.

## Objetos y lógica

- Piezas: `Workspace.Niveles.Nivel1.Islands.Island_X.AccesosPuentes.Union_<EdgeId>_<From|To>`.
- Partes visibles, ancladas y con colisión; atributos `UnionGenerada=true`, `Kind=Acceso`, `PuenteId`, `Extremo` y `NodeId`.
- Permanecen con la isla cuando el tramo de madera se derrumba. No cambian los tablones, las aristas ni el historial.
- `EscenarioNivel` incluye los accesos en la detección de isla. `DetectorCruces` permite iniciar el cruce según el ancho real, eliminando el límite lateral fijo de 12 studs.
- `UnionesPuentes` es una herramienta de autoría. `GeneradorNivel` la llama al construir un escenario nuevo. El inicio de la partida no reconstruye piezas.

## Después de modificar el mapa

Mover la isla mediante su modelo completo. Ajustar también los puentes conectados. Con Studio en Edición, recalcular los accesos por MCP o desde la barra de comandos:

~~~lua
require(game.ServerScriptService.UnionesPuentes).crear(workspace.Niveles.Nivel1)
~~~

La herramienta reutiliza sus piezas existentes y rechaza nombres ocupados por piezas manuales. Recalcular sobrescribe las dimensiones, posición y apariencia de los accesos marcados; conservar cualquier ajuste manual por separado si se desea mantenerlo. No recalcula automáticamente al mover modelos y no se ejecuta durante Play.

Está comprobada en los cuatro puentes rectos del nivel 1. Los lazos y paralelos requieren sus propias pruebas físicas cuando se construyan esos mapas.

## Validación

- Antes de la corrección: 20 muestras sin soporte en un barrido de 4.472 puntos de las ocho uniones.
- Después: barrido más denso de 19.720 puntos, sin huecos de colisión, hasta el 98 % del semiancho de cada tablero.
- 24 pruebas con Humanoid en una copia temporal: tres carriles por cada una de las ocho uniones, ida y vuelta, saltos deshabilitados. Sin caídas ni atascos.
- 24 cruces simulados del detector: ambos sentidos y tres carriles, registrados una sola vez.
- Dos ejecuciones del autor mantienen los mismos ocho objetos, sin duplicarlos.
- 18 comprobaciones matemáticas y 138 de integración correctas.
- Victoria real A → B → C → A → D sin saltos, aproximadamente 29 segundos, con derrumbe y Cerberus.
- Studio quedó en Edición. Sin errores nuevos de la mecánica; continúan los avisos previos de Kohl's Admin sobre DataStores.

Todo se comprobó mediante MCP, sin controlar el PC ni tomar capturas. La revisión estética final queda a la observación del usuario.

## Respaldo

`Desarrollo/Uniones-puentes-2026-10-30/` contiene cuatro fuentes leídas de Studio, huellas SHA-256, medidas de los ocho accesos, comprobaciones y pruebas reproducibles. Los cuatro módulos de ese paquete prevalecen sobre sus versiones de la entrega inicial. El respaldo no incluye mallas ni sustituye guardar el place en Studio.

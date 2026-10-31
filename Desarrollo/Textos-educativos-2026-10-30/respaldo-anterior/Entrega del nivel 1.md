---
tags: [cursed-bridges, entrega, nivel-1]
actualizado: 2026-10-30
estado: implementado-y-validado
---

# Entrega del nivel 1

Volver a [[00 Cursed Bridges]]. Interfaces: [[Contratos de integración]]. Avance global: [[Estado y pendientes]].

## Cómo jugar

1. Iniciar Play y esperar la preparación.
2. Leer el objetivo y pulsar **Comenzar**.
3. Caminar con WASD y saltar con Espacio.
4. Salir de A, visitar B y C y llegar a D sin repetir puentes.
5. Tras ganar o perder, usar **Repetir nivel** o **Reintentar**.

Soluciones comprobadas: A → B → C → A → D y A → C → B → A → D. Repetir A está permitido: se pide un sendero, no una trayectoria.

Ir primero por AD no cumple el objetivo: faltan B y C y el derrumbe deja a D sin salida legal.

## Escenario editable

`Workspace.Niveles.Nivel1` contiene A, B, C y D, y los puentes AB, BC, CA y AD. Las piezas del triángulo conservaron sus posiciones.

Mover cada isla mediante su modelo completo; conservar `Superficie` como parte principal y los identificadores. Revisar las uniones de los puentes tras moverla. El arranque no reconstruye el escenario.

## Mecánica

- Cruces comprobados por el servidor y añadidos al alcanzar la otra isla.
- Saltos normales y regreso durante un cruce incompleto.
- Distinción entre arista recorrida y puente inutilizable.
- Derrumbe progresivo, colisiones del servidor y caída animada del cliente.
- Cerberus a la velocidad del jugador, siguiendo sus mismos puentes, sentido y orden.
- Primera entrada por A y salto anunciado por el mismo puente cuando ya se derrumbó.
- Derrota por infracción, captura, lava o ausencia de salida.
- Reintento que restaura escenario, recorrido, personaje y enemigo.
- Objetivo mínimo durante el intento; explicación del recorrido al terminar.

## Corrección de uniones · 2026-10-30

Ocho accesos de piedra visibles y editables unen las islas con el ancho completo de los puentes. Se conserva la geometría existente de islas y tablones. La comprobación actual cubrió 19.720 muestras de suelo sin huecos; 24 pruebas físicas por tres carriles, de ida y vuelta, sin saltos, caídas ni atascos; y una victoria A → B → C → A → D sin saltar. Las 18 comprobaciones matemáticas y 138 de integración siguen pasando.

Detalles de autoría, respaldo y límites: [[Uniones de puentes]].

## Cerberus seguidor · 2026-10-30

La persecución registra los cruces desde Comenzar, incluida la ventaja inicial, y los sigue en orden. Los saltos por derrumbe conservan el trayecto del mismo puente, aviso y gracia. Reintentar limpia la secuencia.

Pasaron 23 comprobaciones específicas, las 138 de integración y las 18 matemáticas. En Play, al elegir A → B → C → A → D siguió AB → BC; al elegir A → C → B → A → D siguió CA → BC. Ambas partidas terminaron en victoria antes de que el enemigo completara el resto del rastro. Al permanecer en A, Cerberus capturó al jugador.

La entrega posterior está en `Desarrollo/Cerberus-seguidor-2026-10-30/`; sus tres módulos prevalecen sobre sus copias anteriores. Véase [[Cerberus seguidor]].

## Configuración validada

| Atributo | Valor |
|---|---|
| VentajaInicial | 12 |
| VelocidadJugador | 16 |
| RetardoDerrumbe | 1 |
| AvisoSalto | 2 |
| DuracionSalto | 1,2 |
| GraciaAterrizaje | 1 |
| UsarConfiguracionPublicada | false |

La ventaja se ajustó después de las pruebas. Para esta entrega no hacen falta claves de ConfigService ni acceso de Studio a DataStores.

## Evidencia

- 18 comprobaciones matemáticas y 138 de integración en copias aisladas.
- Victorias reales en ambos sentidos del triángulo y después de reintentar.
- Última victoria directa con efectos corregidos: aproximadamente 30,5 segundos; ruta inversa: unos 33,9 segundos.
- A → D pierde con explicación de las visitas pendientes.
- Captura al permanecer en A, después de la ventaja, el salto y la gracia.
- Cuerpo de Cerberus sincronizado con la raíz móvil.
- 149 piezas animadas en caída y 176 restauradas al reintentar.
- Sin errores nuevos de la mecánica en la consola final; persisten avisos del sistema externo Kohl's Admin.

Pruebas realizadas por MCP, sin controlar el PC ni tomar capturas. La sensación de juego y revisión visual final quedan abiertas al comentario del usuario.

## Entrega al compañero

`Desarrollo/Nivel1/` contiene las 20 fuentes verificadas en el cierre inicial, configuración del escenario y registro de comprobaciones. La corrección posterior de accesos se entrega en `Desarrollo/Uniones-puentes-2026-10-30/`; sus cuatro módulos prevalecen sobre las copias anteriores. Véase [[Uniones de puentes]]. Es un respaldo de código; no incluye las mallas ni sustituye el place.

El compañero puede pulir textos e `InterfazIntento` conservando sus firmas. Cambios de lógica y escenarios requieren coordinación y un escritor por objeto.

Los niveles 2–5 siguen pendientes. Continuar permanece oculto mientras solo exista el primero.

**Studio quedó en Edición. Guardar el proyecto en Studio para conservar el escenario y sus cambios.**

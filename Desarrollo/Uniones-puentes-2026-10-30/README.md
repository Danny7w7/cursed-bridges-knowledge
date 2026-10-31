# Corrección de uniones · 2026-10-30

PlaceId: 74011338627746. Consultar `Uniones de puentes.md` en la carpeta principal.

Las cuatro fuentes de `ServerScriptService/` corresponden a las leídas de Studio después de la corrección. Sustituyen las copias antiguas de esos módulos; el resto de la entrega inicial conserva su alcance. No es un instalador ni una exportación del place.

`accesos-escenario.json` registra los ocho accesos; `verificacion.json` contiene las comprobaciones; `manifest-fuentes.json` sus huellas. `respaldo-anterior/` conserva fuentes y documentos previos.

Pruebas manuales por MCP:

- `pruebas/uniones_fisicas.luau`: ejecutar en Server durante Play. Mantener la partida en preparación. Crea una copia temporal con colisiones independientes del derrumbe. Probar índices 1–4 y repetir con INICIO=5, FIN=8. Son 24 casos de ida y vuelta en total. Se eliminan la copia y los personajes temporales al terminar.
- `pruebas/recorrido_sin_saltos.luau`: ejecutar en Client durante Play, con el jugador cargado. Reinicia el intento y camina la solución sin activar saltos.

Guardar el proyecto desde Studio para conservar las piezas. El arranque no vuelve a generar el mapa ni los accesos.

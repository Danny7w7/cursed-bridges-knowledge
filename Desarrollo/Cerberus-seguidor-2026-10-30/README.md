# Cerberus seguidor · 2026-10-30

PlaceId: 74011338627746. Consultar `Cerberus seguidor.md` en la carpeta principal.

Las tres fuentes de `ServerScriptService/` corresponden a las leídas de Studio después de la implementación. Sustituyen sus copias anteriores. Se conservó la modificación simultánea del texto de victoria para usar el LevelId real.

- PersecucionCerberus: sigue la cola de cruces y salta el mismo puente derrumbado.
- MotorPartida: registra los eventos del detector también durante la ventaja.
- PruebasCerberusSeguidor: ejecutar manualmente en Edición; emplea copias aisladas.

`manifest-fuentes.json` contiene huellas SHA-256; `verificacion.json`, resultados; `respaldo-anterior/`, fuentes y documentos previos. El respaldo no sustituye guardar el place ni incluye mallas.

Para repetir las comprobaciones específicas por MCP en Edit, clonar el módulo de pruebas con Parent=ServerScriptService, ejecutar `require(copia)()` y destruir esa copia al terminar. Así se evita reutilizar un require almacenado en caché.

`pruebas/recorrido_seguidor.luau` se ejecuta por MCP en Client durante Play. Reinicia el intento y camina A → B → C → A → D sin activar saltos, registrando los saltos y aristas de Cerberus. Para el sentido inverso cambiar la lista de vértices a A,C,B,A,D.

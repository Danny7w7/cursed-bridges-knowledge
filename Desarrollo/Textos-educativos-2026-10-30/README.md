# Textos educativos · 2026-10-30

PlaceId: 74011338627746. Consultar `Textos educativos.md` en la carpeta principal.

Las seis fuentes coinciden con las leídas de Studio tras la entrega. Sustituyen sus copias anteriores; las otras fuentes de entregas previas conservan su alcance.

`manifest-fuentes.json` contiene huellas SHA-256; `verificacion.json`, resultados; `respaldo-anterior/`, código y documentos previos. Guardar el proyecto en Studio: este respaldo no exporta el place ni incluye mallas.

Pruebas por MCP:

- `PruebasTextosEducativos`: en Edit, clonar con Parent=ServerScriptService, ejecutar `require(copia)()` y destruir la copia. El módulo carga una copia fresca del catálogo.
- `prueba_interfaz_final.luau`: en Client durante Play; crea una interfaz temporal, prueba estados y desplazamiento y la destruye al terminar.
- `recorrido_final.luau`: en Client durante Play, después de entrar al nivel; reinicia el intento, camina y permite saltos ante obstáculos. Para el caso de objetivo incompleto cambiar la lista de vértices a A,D.
- `prueba_cinematica.luau`: requiere una copia temporal de MenuPrincipal como ModuleScript llamado `ReplicatedStorage.PruebaTemporalMenuEducativo`. Su fuente es la del menú, seguida de `return {iniciar = iniciarNivel, modoActual = function(): string return modo end}`. Ejecutar la prueba en Client durante Play; después detener Play y eliminar ese módulo en Edit. La prueba desactiva el menú original solo en la sesión de Play para evitar dos controladores de cámara.

El catálogo de niveles 2–5 es heredado y sigue pendiente de alineación. Esta entrega cambia la descripción y presentación del primer nivel.

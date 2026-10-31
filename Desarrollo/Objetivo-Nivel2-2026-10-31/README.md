# Paso 2 del nivel 2 · HECHO

Fecha: 2026-10-31. Place: Cursed bridges, 74011338627746.

## Cambio

Se añadió `LevelData.Levels[2]` a `ReplicatedStorage.LevelData`: La ruta sin retorno, tipo trayectoria, inicio A, destino H y sin visitas intermedias obligatorias. Las ocho islas y las once aristas coinciden con el escenario guardado; las conexiones son no dirigidas. `requiresCircuit=false` y `hint=""`.

Los metadatos de posición usan las coordenadas X/Z del mapa divididas entre 3,5, conservando la convención de autoría existente y la altura base 12. No se ejecutó el generador ni se movió el escenario.

Una trayectoria válida de A a H puede ganar sin visitar las ocho islas ni cruzar todos los puentes. El orden A–C–F–B–E–G–D–H es solo un ejemplo, no una secuencia exigida. No se añadió una solución a los textos del juego.

Solo se editó LevelData. El validador existente ya distingue sendero de trayectoria; se reutilizó sin cambios. El nivel 1 conserva su definición anterior. El mapa permanece como `Nivel2_Escenario`, con `SoloEscenario=true`; la disponibilidad del servidor también exige una carpeta llamada Nivel2. El menú y sus textos corresponden al paso 5.

## Pruebas

`prueba-objetivo.luau` se ejecutó manualmente en Edición, usando copias temporales de los módulos y retirándolas al terminar. No está instalado como script de ejecución.

Pasaron 59 comprobaciones del objetivo y su registro, y las 18 comprobaciones previas de las reglas. Incluyen:

- Identidad, objetivo, nodos, posiciones y aristas contra el escenario real.
- Victoria en trayectorias cortas y largas, incluidos cruces en sentido inverso a From/To.
- Rechazo de vértice repetido mediante cinco aristas distintas, diferenciándolo de un sendero válido.
- Rechazo de arista repetida, conexión inexistente e inicio incorrecto.
- Recorrido vacío y prefijo válido sin victoria; salidas legales y bloqueo físico.
- Enumeración independiente de las diez trayectorias simples A–H, de dos a siete puentes, todas aceptadas por el validador.
- Igualdad profunda de los datos del nivel 1 frente a la fuente anterior y permanencia del nivel 2 sin activar.

La huella geométrica y de acabado de 7.123 BaseParts coincide antes y después. La fuente final coincide exactamente con la edición prevista. No se ejecutó Play ni se comprobaron todavía persecución, derrumbe o transición del nivel 2.

## Respaldo

`LevelData.antes.luau` y `LevelData.luau` conservan las fuentes anterior y final. `verificacion.json` registra resultados y huella de geometría. La documentación anterior está en `documentacion-anterior`. Guardar el place conserva la edición de Studio.

Siguiente bloque: paso 3, integrar Cerberus.

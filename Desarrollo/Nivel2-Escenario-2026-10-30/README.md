# Escenario del nivel 2

PlaceId: 74011338627746. Escena: Workspace.Niveles.Nivel2_Escenario.

Consultar `Nivel 2 - La ruta sin retorno.md` en la carpeta principal. La versión es compacta: ocho islas, once aristas y 19 tramos a escala fija. No está integrada como partida.

El constructor se ejecuta manualmente en Edición por MCP. Para evitar un require antiguo, clonar el ModuleScript con Parent=ServerStorage, invocar el método requerido y destruir esa copia al terminar. Crear primero las ocho islas y después las once conexiones. Finalizar comprueba los identificadores, acabados y referencias protegidas. No iniciar sobre un escenario existente.

Compactar elimina los puentes y accesos del borrador: usarlo solo con conocimiento de las ediciones y después recrear las once aristas y finalizar. Nunca se ejecuta al iniciar Play.

Las pruebas son manuales:

- AuditoriaGeometriaNivel2: ejecutar en Edit; comprueba el suelo y solapes de colisión entre puentes diferentes.
- PruebaFisicaNivel2: ejecutar en Server durante Play. Cambiar INICIO/FIN para recorrer los 38 casos por lotes: 1–6, 7–12, 13–18, 19–24, 25–30, 31–33, 34–36 y 37–38. Cada caso crea y elimina un personaje temporal, sin alterar al jugador.

El manifiesto verifica el código. Escenario.json registra coordenadas y conexiones; verificacion.json contiene los resultados. El respaldo no exporta mallas ni sustituye guardar el place en Studio.

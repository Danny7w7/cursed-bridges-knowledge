# Nivel 2 habilitado en el selector para pruebas

Fecha: 2026-10-31. Solicitud del usuario: probarlo desde la sección inicial de selección de nivel, antes de terminar los pasos 4–6.

## Cambios

Se renombró `Workspace.Niveles.Nivel2_Escenario` a `Nivel2` y se cambió `SoloEscenario` a false. Las 7.811 BaseParts conservan su geometría y acabado; la huella de comprobación normaliza únicamente el cambio de nombre del nivel. No se ejecutó el generador.

Se actualizaron cinco fuentes:

- CatalogoNiveles: La ruta sin retorno, Trayectoria, descripción A–H sin repetir islas y grafo de ocho nodos/once aristas.
- UIController: compara intentos dentro de su nivel, identifica cada preparación por nivel+intento y descarta cargas antiguas al cambiar de mapa.
- MenuPrincipal: espera el nuevo estado por nivel y la carga de la superficie inicial antes de la cinemática.
- GameController: conecta la lava propia de cada sesión, comprobando que sea la activa.
- EscenarioNivel: toma la altura de la lava local, con alternativa global para mapas anteriores.

## Comprobación

En Play, se reinició tres veces el nivel 1 y luego se seleccionó el 2. El intento del nivel 1 era 4 y el nuevo era 2: se aceptó el cambio y la interfaz mostró Trayectoria. El personaje apareció en A=(2720,17,350).

Se comenzó el intento del nivel 2 y se realizó un descenso vertical mediante MCP a su lava, conservando X/Z para no activar la protección contra desplazamientos inválidos. Resultado: derrota con código lava. Reintentar volvió a A en preparación y seleccionar el nivel 1 volvió correctamente al otro mapa. La consola consultada no mostró errores.

Estas comprobaciones usaron los mismos remotos del selector y la interfaz real. No se pulsaron botones con automatización de PC ni se tomaron capturas. La navegación visual de la tarjeta queda para la prueba del usuario.

Los pasos 4–6 no se marcan como completos: aún faltan la matriz de derrumbe/restauración, la revisión educativa y la transición desde una victoria del nivel 1. La selección directa ya está disponible.

## Respaldo

Fuentes anteriores/actuales y verificacion.json en esta carpeta. La documentación anterior está en documentacion-anterior. La escena no se modificó salvo nombre del contenedor y atributo SoloEscenario; para volver al estado previo, restaurar Nivel2_Escenario y SoloEscenario=true, además de las fuentes anteriores si corresponde.

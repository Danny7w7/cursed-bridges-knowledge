# Cursed Bridges — Continuar en casa

Actualizado: 2026-10-31. **Trabajo interrumpido por el usuario durante el paso 4.**

## Antes de cambiar de PC

Guardar el proyecto en Roblox Studio. Llevar el place guardado (`.rbxl`/`.rbxlx`, o abrir su versión guardada en Roblox) y toda esta carpeta de documentación. Los `.md` y las fuentes de respaldo no contienen las mallas ni sustituyen guardar el place. Abrir el proyecto en Studio y conectar su MCP en el PC de casa.

## Instrucción para el nuevo chat

Lee este archivo, `Plan de integración del nivel 2.md`, `Estado y pendientes.md` y `Desarrollo/Derrumbe-Nivel2-2026-10-31/README.md`. Conéctate por MCP a Cursed bridges, placeId **74011338627746**, y comprueba las fuentes reales antes de editar. **Continúa validando el paso 4; hay tres parches aplicados que todavía no se han probado.** No rehagas el escenario ni marques ese paso como terminado sin comprobarlo.

El usuario prohíbe controlar su PC o tomar capturas automáticamente. Usar MCP; pedirle una captura solo cuando haga falta. Mantener el trabajo por pasos, actualizar los `.md` y devolver la lista con los pasos completados tachados. No añadir dash, fuego como obstáculo, rocas que caen, empujones ni mecánicas ajenas al grafo. Conservar el trabajo de presentación Hades del compañero.

## Estado jugable

- Nivel 1: `Workspace.Niveles.Nivel1`, sendero A → D visitando B y C, sin repetir puentes. Se puede repetir A.
- Nivel 2: **`Workspace.Niveles.Nivel2`**, antes Nivel2_Escenario. Ya está habilitado en NIVELES → II por petición del usuario; `SoloEscenario=false`.
- Nombre: La ruta sin retorno. **Trayectoria A → H sin repetir islas. No exige visitar todas las islas ni usar todos los puentes.**
- Ocho vértices A–H. Once aristas exactas: AC, AG, CF, CH, FB, BE, BG, BD, EG, GD, DH.
- Diez trayectorias simples A–H válidas, de dos a siete puentes. A–C–H es válida; no imponer la ruta larga de ocho islas ni revelar soluciones en la cinemática.
- Escenario del nivel 2: 605 tablones en 19 tramos, 884 BaseParts de puentes y 22 accesos. Se retiraron los diez muelles sin puente; quedan 22 caminos reales. El total del escenario en Edición es 4.493 BaseParts, incluido el guardián.
- Cerberus sigue los mismos puentes del jugador, en orden y sentido; salta por el mismo puente derrumbado. Posición inicial del nivel 2: (2870,12,350), mirando a A=(2720,12,350). Roca sin muelles decorativos.
- Configuración actual: nivel 1 tiene ventaja **5 s**; nivel 2 **4 s**. Ambos a velocidad 16. Aviso de salto 2 s, vuelo 1,2 s, gracia 1 s, retardo de derrumbe 1 s. Algunas notas históricas dicen 12 s para nivel 1: prevalecen los atributos actuales, que no se cambiaron.

## Lista de trabajo

1. HECHO: despejar entradas y caminos del nivel 2.
2. HECHO: registrar objetivo y topología en LevelData.
3. HECHO: colocar e integrar Cerberus; 146 comprobaciones aisladas y prueba de animación en Play.
4. **EN CURSO: derrumbe y reinicio. Tres parches aplicados; falta validarlos.**
5. PENDIENTE: revisión educativa completa de textos, cinemática, minimapa y resultados. El selector ya tiene nombre, concepto y grafo correctos.
6. PENDIENTE: matriz completa y Continuar desde una victoria del nivel 1. La selección directa, aparición en A, lava, reintento básico y regreso al nivel 1 ya se probaron.

## Punto exacto de interrupción del paso 4

Al iniciar esta sesión, el Play del usuario mostraba **victoria A → C → H**, dos puentes iniciados y 162 piezas caídas, sin errores en consola. Se detuvo Play para inspeccionar y corregir los casos restantes.

Se reprodujo un fallo real en una copia aislada de AG: al iniciar el derrumbe en sentido inverso, **las 64 piezas de estructura/adornos caían al primer instante**, antes de terminar los tablones.

Se aplicaron estos cambios en Studio:

1. **ServerScriptService.DerrumbePuentes**: invertir el avance únicamente de piezas `Kind=Tablon`. La estructura conserva su umbral `longitud+2` en ambos sentidos, para caer al final.
2. **StarterPlayer.StarterPlayerScripts.ClientePuentes**: identificar el modelo raíz `Bridge_*` directamente bajo Bridges, en vez del Model más cercano `Tramo_*`. Así la bisagra, la caché de reposo y la restauración corresponden al puente completo, incluidas juntas y tramos.
3. **ReplicatedStorage.BridgeFX**: limitar el intervalo de reconstrucción a `min(0.035, 1/max(1,#orden))`, evitando reconstrucciones excesivamente largas en AG y otros puentes con muchos tablones.

**No se ejecutaron pruebas después de estos parches.** Al parar, Studio estaba en Edición. No hay una matriz nueva terminada ni una prueba de Play del parche. Las fuentes leídas al cierre coinciden con las ediciones previstas.

## Cómo continuar el paso 4

1. Confirmar que los tres scripts reales contienen estos parches. Las fuentes anteriores y actuales están en `Desarrollo/Derrumbe-Nivel2-2026-10-31/`.
2. En copias aisladas, probar los once puentes en ambos sentidos, incluyendo los tablones de Juntas. Antes del retardo no cae nada; después caen los tablones desde el extremo correcto; la estructura cae después del último tablón en ambos sentidos.
3. Repetir caída/restauración varias veces y comprobar CFrame, Color, Transparency, CanCollide y limpieza de CaidaDesde/IntentoCaida, ondas y bloqueos. Confirmar que actualizar un intento anterior no vuelva a derrumbar piezas del nuevo.
4. Comprobar en Play la animación y reconstrucción de un puente de varios tramos: todas las piezas vuelven al lugar y color correctos; no quedan animaciones del intento anterior. Revisar especialmente cruces inversos y reiniciar antes de que termine una caída/reconstrucción.
5. Probar detección física, cruce completo y regreso incompleto, lava local y reintento con recorrido limpio. Hacer una regresión del nivel 1, porque los tres scripts son compartidos.
6. Actualizar evidencia, marcar el paso 4 solo si pasa y devolver la lista actualizada al usuario.

## Arquitectura y respaldos útiles

El servidor usa GameController → MotorPartida → DetectorCruces, DerrumbePuentes y PersecucionCerberus. EscenarioNivel lee el mapa guardado. ReglasRecorrido valida los cinco tipos. La caída visual se ejecuta en ClientePuentes/BridgeFX.

Cambios ya probados para habilitar el selector: UIController identifica intentos por nivel+intento; MenuPrincipal espera estado/carga del mapa; GameController conecta la lava por sesión; EscenarioNivel usa primero la lava local. No deshacerlos.

Respaldos principales dentro de Desarrollo: Objetivo-Nivel2-2026-10-31, Cerberus-Nivel2-2026-10-31, Selector-Nivel2-2026-10-31 y **Derrumbe-Nivel2-2026-10-31**. Los JSON registran comprobaciones; las fuentes históricas pueden usar el nombre anterior Nivel2_Escenario.

La herramienta manual ServerStorage.ConstructorEscenarioNivel2 corresponde al borrador anterior. No se ejecuta al iniciar; no reconstruir ni compactar sobre las ediciones actuales. Sus firmas históricas no se renovaron para ocultar cambios posteriores autorizados.

Las correcciones de parpadeo de suelo ya están aplicadas en las doce islas y la plantilla, mediante pequeñas separaciones verticales. Mantenerlas. Las piezas retiradas de los accesos están respaldadas en ServerStorage.RespaldoAccesosNivel2_20261031 y carpetas históricas del nivel 1.

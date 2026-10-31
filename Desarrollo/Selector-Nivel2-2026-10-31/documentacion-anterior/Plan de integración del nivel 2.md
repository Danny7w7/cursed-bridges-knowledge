---
tags: [cursed-bridges, nivel-2, plan]
actualizado: 2026-10-31
estado: pasos-1-2-y-3-hechos
---

# Plan de integración del nivel 2

Volver a [[00 Cursed Bridges]]. Escenario: [[Nivel 2 - La ruta sin retorno]]. Estado general: [[Estado y pendientes]].

Regla registrada: **trayectoria**, un sendero sin vértices repetidos. Inicio A, destino H, sin visitas intermedias obligatorias; no exigir todos los puentes ni todas las islas. Mantener las once conexiones exactas y los modelos editables.

- [x] **1. ~~Despejar las entradas y revisar los caminos~~ — HECHO.** Los 22 accesos están despejados. Se retiraron los diez muelles sin puente por elección del usuario: quedan 22 caminos reales, con cinco placas cada uno. Las columnas, cadenas, coronas, rocas y conjuntos de altar que invadían los pasos están respaldados en ServerStorage. Pasaron 154 barridos de colisión y 4.440 muestras de suelo, sin bloqueos ni huecos detectados. Se comprobaron alineación y solape de los caminos con sus accesos. Pruebas geométricas en Edición.
- [x] **2. ~~Registrar el objetivo jugable~~ — HECHO.** `LevelData.Levels[2]` registra La ruta sin retorno como trayectoria A → H, sin visitas intermedias obligatorias. Sus ocho islas y once aristas coinciden con el escenario guardado. Se reutiliza el validador existente: 59 comprobaciones del objetivo y 18 comprobaciones previas de reglas correctas; acepta las diez trayectorias simples A–H y rechaza vértices repetidos. Datos del nivel 1 conservados.
- [x] **3. ~~Integrar Cerberus~~ — HECHO.** Cerberus, su roca y su resplandor están colocados frente a A. El perseguidor y el motor existentes leen las rutas del nivel 2. Pasaron 146 comprobaciones aisladas: diez trayectorias con puentes intactos y derrumbados, mismo orden/sentido, saltos por el mismo puente, captura y reinicio. Se comprobó la animación en Play con una cola virtual AC–CH. Reacciones del cliente separadas por nivel. Ventaja inicial 4 s, velocidad 16; balance de una partida completa pendiente del paso 6.
- [ ] **4. Conectar derrumbe y reinicio.** Comprobar puentes de varios tramos, detección de cruces, lava propia y restauración completa al reintentar.
- [ ] **5. Actualizar la presentación.** Corregir el antiguo concepto de circuito euleriano del menú: nombre, explicación de trayectoria, cinemática y resultados, sin revelar una solución. Verificar minimapa e interfaz.
- [ ] **6. Activar y probar la transición.** Continuar desde el nivel 1, esperar la carga del mapa y comprobar victoria, vértice repetido, captura, caída y reintento. Revisar que el nivel 1 conserve su funcionamiento.

El nivel sigue en `Workspace.Niveles.Nivel2_Escenario`, con `SoloEscenario=true`: los pasos 1–3 no activan su jugabilidad ni adelantan los siguientes bloques. El catálogo del menú y sus textos se corregirán en el paso 5.

Evidencia del paso 1: `Desarrollo/Accesos-Nivel2-2026-10-31/README.md` y `verificacion.json`.

Evidencia del paso 2: `Desarrollo/Objetivo-Nivel2-2026-10-31/README.md`, fuentes anterior/actual y `verificacion.json`.

Evidencia del paso 3: `Desarrollo/Cerberus-Nivel2-2026-10-31/README.md`, cliente anterior/actual, módulos de referencia, prueba y `verificacion.json`. Sigue el paso 4: derrumbe, lava y reinicio del intento completo.

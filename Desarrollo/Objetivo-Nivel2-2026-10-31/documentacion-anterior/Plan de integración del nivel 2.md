---
tags: [cursed-bridges, nivel-2, plan]
actualizado: 2026-10-31
estado: paso-1-hecho
---

# Plan de integración del nivel 2

Volver a [[00 Cursed Bridges]]. Escenario: [[Nivel 2 - La ruta sin retorno]]. Estado general: [[Estado y pendientes]].

Regla del nivel: **trayectoria**, un sendero sin vértices repetidos. Inicio A, destino H; no exigir todos los puentes. Las visitas adicionales no están configuradas. Mantener las once conexiones exactas y los modelos editables.

- [x] **1. ~~Despejar las entradas y revisar los caminos~~ — HECHO.** Los 22 accesos están despejados. Se retiraron los diez muelles sin puente por elección del usuario: quedan 22 caminos reales, con cinco placas cada uno. Las columnas, cadenas, coronas, rocas y conjuntos de altar que invadían los pasos están respaldados en ServerStorage. Pasaron 154 barridos de colisión y 4.440 muestras de suelo, sin bloqueos ni huecos detectados. Se comprobaron alineación y solape de los caminos con sus accesos. Pruebas geométricas en Edición.
- [ ] **2. Registrar el objetivo jugable.** Incorporar La ruta sin retorno como trayectoria A → H y actualizar LevelData. Reutilizar el validador de vértices repetidos.
- [ ] **3. Integrar Cerberus.** Colocarlo en este mapa y conectar seguimiento del recorrido, saltos por el mismo puente derrumbado y captura. Ajustar la ventaja inicial mediante pruebas.
- [ ] **4. Conectar derrumbe y reinicio.** Comprobar puentes de varios tramos, detección de cruces, lava propia y restauración completa al reintentar.
- [ ] **5. Actualizar la presentación.** Corregir el antiguo concepto de circuito euleriano del menú: nombre, explicación de trayectoria, cinemática y resultados, sin revelar una solución. Verificar minimapa e interfaz.
- [ ] **6. Activar y probar la transición.** Continuar desde el nivel 1, esperar la carga del mapa y comprobar victoria, vértice repetido, captura, caída y reintento. Revisar que el nivel 1 conserve su funcionamiento.

El nivel sigue en `Workspace.Niveles.Nivel2_Escenario`, con `SoloEscenario=true`: el paso 1 no activa su jugabilidad ni adelanta los siguientes bloques.

Evidencia del paso 1: `Desarrollo/Accesos-Nivel2-2026-10-31/README.md` y `verificacion.json`.

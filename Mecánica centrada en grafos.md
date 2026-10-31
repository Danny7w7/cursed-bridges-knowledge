---
tags: [cursed-bridges, mecanica, controles]
actualizado: 2026-10-31
---

# Mecánica centrada en grafos

Volver a [[00 Cursed Bridges]]. Reglas: [[Mecánica principal acordada]].

El usuario pidió retirar el dash y los obstáculos añadidos para mantener el foco educativo en construir recorridos sobre grafos.

## Retirado

- LocalScript Embestida: entrada por Shift/mando, aceleración, siluetas e indicador de recarga.
- Script PeligrosPuentes: rejillas de fuego periódicas, rocas que caen, avisos, empujones, inmunidad por dash y aturdimiento.
- RemoteEvents Embestida y GolpeJugador.
- Texto sobre Shift y obstáculos en la preparación.

Los peligros se generaban durante Play; el generador ya no existe y no se recrearon durante el recorrido de comprobación.

## Conservado

Caminata normal y salto, islas/vértices, puentes/aristas, validación matemática, objetivos, explicaciones educativas, derrumbe y persecución de Cerberus. El fuego de braseros y decoración se conserva. El diseño actual de la interfaz se mantiene.

## Validación

- 18 comprobaciones matemáticas, 138 de integración, 23 de Cerberus y 22 de textos: 201 correctas.
- Sesión nueva sin PlayerScripts.Embestida, HUDEmbestida, GolpeFX ni instrucciones obsoletas.
- Victoria real A → B → C → A → D en aproximadamente 29 segundos, con velocidad normal 16 y sin carpetas Peligros durante el recorrido.
- Studio se desconectó después de la prueba; no se obtuvo la lectura final del escenario tras detener Play.

## Respaldo

Desarrollo/Retiro-dash-obstaculos-2026-10-30 contiene el código anterior, la interfaz corregida y resultados. El retiro comenzó el 30 y se documentó al cierre del 31. Las copias anteriores son históricas y no se ejecutan desde esa carpeta.

Guardar el place en Studio para conservar los cambios.

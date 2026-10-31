---
tags: [cursed-bridges, estetica, tecnico]
---

# Clima e iluminación

Volver a [[00 Cursed Bridges]].

Objetivo: inframundo estilo Hades que **se lea bien** (siluetas claras, acentos de fuego), no una pantalla negra ni todo rojo.

## Decisiones
- **Sin `Atmosphere`**: en Roblox dibuja un cielo diurno azul encima del skybox. Se usa niebla clásica.
- **Cielo propio** (6 caras generadas y subidas): vacío negro-carmesí arriba, resplandor de brasas en el horizonte, chispas tenues. Sol y luna ocultos (`CelestialBodiesShown = false`); la luz del sol sigue activa.
- **Mar de lava**: el antiguo baseplate (`MarDeLava`, Y = -60, material CrackedLava oscuro) con una `SurfaceLight` hacia arriba que ilumina en naranja la panza de las islas.
- **Clima (cliente)**: script `Clima` con ceniza que cae y brasas que suben alrededor de la cámara.

## Valores de Lighting
| Propiedad | Valor |
|---|---|
| ClockTime | 17.4 (sol bajo y cálido) |
| Brightness | 2 |
| ExposureCompensation | 0.6 |
| Ambient / OutdoorAmbient | (100,88,98) / (140,122,132) |
| Fog | color (38,12,16), 150 → 900 |
| ColorCorrection | contraste 0.15, saturación 0, tinte (255,246,242) |
| Bloom | intensidad 0.7, umbral 1.3 |

Lección: el rojo saturado en cielo, niebla y suelo a la vez aplana todo; el contraste viene de mantener el cielo y la lava oscuros y dejar el color fuerte a los acentos (runas, fuego, sellos).

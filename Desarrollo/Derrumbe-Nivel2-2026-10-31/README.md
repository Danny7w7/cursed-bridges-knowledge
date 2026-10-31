# Paso 4 — Interrumpido, validación pendiente

Fecha: 2026-10-31. El usuario pidió detener el trabajo y preparar continuación en otro PC.

Estado: **tres parches aplicados en Studio, sin pruebas posteriores todavía**. No marcar el paso 4 como terminado.

- DerrumbePuentes: corregir la inversión del avance para que solo afecte tablones; estructura y adornos deben caer al final en ambos sentidos.
- ClientePuentes: usar el modelo raíz de cada puente bajo Bridges, compartiendo caché y bisagra entre todos sus tramos y juntas.
- BridgeFX: acotar la duración de la reconstrucción de puentes largos mediante un intervalo máximo de 1/#orden entre piezas.

Antes del parche se reprodujo el fallo en una copia de AG: sus 64 piezas distintas de tablones caían al primer instante en sentido inverso.

Esta carpeta guarda `*.antes.luau`, fuentes actuales `*.luau` y `estado-interrumpido.json`. Las fuentes actuales se volvieron a leer de Studio al cierre y coinciden con los parches previstos. No hay un resultado de pruebas posteriores ni una partida con el parche.

Continuación y matriz propuesta: `../../CONTINUAR EN CASA.md`. Revisar once puentes en ambos sentidos, varios reinicios, reconstrucción visual/CFrame/color/colisión, cancelación de efectos antiguos y regresión del nivel 1. Usar copias aisladas y MCP; no controlar el PC.

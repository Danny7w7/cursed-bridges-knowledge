---
tags: [cursed-bridges, diseño, tecnico]
actualizado: 2026-10-28
---

# Escala y medidas

Volver a [[00 Cursed Bridges]].

| Elemento | Medida |
|---|---|
| Cerberus en juego | escala 2.2 → ~24.5 ancho (con cabezas), ~37 largo, ~38 alto; cuerpo ~12 de ancho |
| Isla (escala 1.8) | suelo radio ~45, puerta del muelle ~15 de ancho, punta del muelle a ~47 |
| Losa del puente (nativa) | 21.9 tras ensanchar (+5.5 por lado) |
| Puentes en el nivel 1 | ~54 de largo, ~31 de ancho, escala ~1.07 |
| Separación de islas (nivel 1) | ~141 entre centros |
| `LAYOUT_SCALE` | 3.5 (LevelData × 3.5) |
| Superficie de las islas | Y = 12 |

Regla: el cuerpo del Cerberus debe pasar por la puerta del muelle y entre los barandales; las cabezas laterales van por encima (~26 de altura). Las plantillas se escalan de forma **uniforme** para no deformar nada.


## Nivel 2: escenario compacto

- Superficie de islas a Y=12; visual a escala 1,8 y radio de suelo 44,82.
- Origen del escenario: (2500, 12, 0). Distribución final y medidas en [[Nivel 2 - La ruta sin retorno]].
- Secciones copiadas de AB: escala de modelo aproximada 1,2863; tablón de unos 30,61 de ancho. Las dimensiones de cada pieza se conservan.
- 19 tramos forman las once aristas; hay 605 tablones ordenados.
- Separación entre primeros tablones de módulos consecutivos: 58,596 studs. Entre el último tablón de un módulo y el primero del siguiente: 5,239, cubiertos por tablones de junta.
- Conexión más larga entre centros: unos 347,85 studs, reducida desde 970,82.
- Distancia mínima entre centros de islas: 155,08; radio máximo de sus cajas visuales proyectadas: 68,24. No se superponen las islas.
- Lava independiente de 2048×16×2048, centro (2500, -60, 0); no se modifica la del nivel 1.

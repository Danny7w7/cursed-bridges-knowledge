---
tags: [cursed-bridges, assets, correcciones]
actualizado: 2026-10-31
---

# Superficies y texturas

Volver a [[00 Cursed Bridges]]. Modelo: [[Islas (vértices)]].

## Problema confirmado

Las capturas de B muestran los dibujos del camino y de las losas cambiando al girar la cámara. La medición confirmó losas `03_Losa_suelo_*` con caras superiores a la misma altura que otras losas superpuestas. También las placas `04_Muelle_*_placa_*` se superponían entre sí con caras superiores coplanares. Esto produce z-fighting: la superficie visible alterna al variar la cámara.

En B, las caras de las losas estaban aproximadamente en Y=12 y las del camino en Y=12,351. El conflicto se daba entre piezas del mismo grupo, no entre esas dos alturas.

## Corrección aplicada

Se asignaron alturas distintas a las piezas cuyas huellas se cruzan. La separación entre capas es de 0,06 studs a escala 1,8: el ajuste máximo es de 0,18 en losas y 0,12 en caminos. La plantilla a escala 1 usa separaciones proporcionales para conservar el resultado al clonarla y escalarla.

Se ajustaron 384 MeshParts de las cuatro islas del nivel 1, las ocho del escenario del nivel 2 y `ServerStorage.Isla`. Solo cambió su posición vertical. Se conservaron sus posiciones horizontales, orientación, tamaño, materiales, texturas, transparencia y propiedades de colisión. No se añadió ningún script de ejecución.

## Validación y límites

La comprobación conservadora de huellas orientadas pasó de 646 pares superpuestos con caras superiores a igual altura a cero. La huella de propiedades de 9.513 piezas coincide antes y después al excluir únicamente la coordenada Y de las 384 piezas previstas. Las alturas finales coinciden con el plan, con error menor de 0,000001 studs.

La comprobación se hizo en Edición mediante MCP. No se controló el PC, no se tomaron capturas nuevas y no se comprobó visualmente el movimiento de cámara después del ajuste. La confirmación visual queda a cargo del usuario.

## Respaldo y futuras importaciones

Plan con alturas anteriores y desplazamientos: `Desarrollo/Superficies-islas-2026-10-31/antes.json`. Resultados: `verificacion.json` y `README.md` en esa carpeta. La edición está registrada en el historial de Studio y debe guardarse con el place.

La corrección está incorporada en la plantilla de Studio; una importación nueva del GLB original puede volver a introducir las superficies coplanares. Conservar estas separaciones al sustituir la plantilla. Las firmas históricas del constructor del nivel 2 siguen registrando su estado original; no se renovaron para ocultar las ediciones posteriores autorizadas del nivel 1 y la plantilla.

# Corrección de superficies coplanares

Fecha: 2026-10-31. Place: Cursed bridges, 74011338627746.

Las capturas del usuario mostraban parpadeo y texturas alternando en los caminos y losas de B. La inspección encontró superposición entre las caras superiores de distintas MeshParts con igual altura.

Se construyó un grafo de intersecciones de las huellas orientadas de `03_Losa_suelo_*` y `04_Muelle_*_placa_*`. Las piezas adyacentes recibieron niveles verticales distintos, con separaciones de 0,06 studs a escala 1,8. No se cambió el tamaño, orientación ni acabado de los modelos. Se usaron las cajas orientadas como comprobación conservadora; no se descargaron ni alteraron los meshes.

## Alcance

- Nivel 1: 96 piezas ajustadas en A, B, C y D.
- Nivel 2, escenario: 256 piezas en A–H.
- Plantilla `ServerStorage.Isla`: 32 piezas, con desplazamiento proporcional a su escala 1.
- Total: 384 piezas; hasta 0,18 studs en losas y 0,12 en caminos de los escenarios.

`antes.json` conserva cada ruta, su altura original y el desplazamiento aplicado. Permite restaurar Y sin cambiar X/Z ni orientación. La modificación también quedó en el historial de Studio.

## Resultados

`verificacion.json` registra 646 pares coplanares superpuestos antes y cero después. Una segunda planificación no propone más cambios. Los 384 destinos coinciden con sus alturas previstas, con error máximo menor de 0,000001 studs.

La firma de 9.513 BaseParts, excluyendo únicamente Y de las piezas previstas, coincide antes y después. Incluye otras coordenadas y orientaciones, dimensiones, materiales, colores, identificadores de mesh/textura, SurfaceAppearance y propiedades de colisión/renderizado. Esto verifica que los cambios se limitaron a las alturas planificadas.

Pruebas geométricas en Edición. No hubo una nueva prueba física en Play ni inspección visual posterior del movimiento de cámara. No se controló el PC. El usuario debe guardar el place para conservar el cambio.

La plantilla corregida sirve para futuras construcciones en Studio. El GLB fuente permanece como estaba. No se cambiaron las firmas históricas de protección del constructor del nivel 2.

---
tags: [cursed-bridges, nivel-2, escenario]
actualizado: 2026-10-30
estado: escenario-construido-mecanica-pendiente
---

# Nivel 2: La ruta sin retorno

Volver a [[00 Cursed Bridges]]. Estado: [[Estado y pendientes]].

## Entrega

Escenario tridimensional construido y editable en `Workspace.Niveles.Nivel2_Escenario`. Contiene exactamente ocho islas y once puentes, sin habilitar la partida del nivel 2.

La especificación reemplaza el diseño anterior de cinco islas. Tras observar el primer montaje, el usuario pidió compactar las distancias y juntar mejor los tramos; la versión entregada incorpora ambos ajustes.

## Grafo y distribución

Aristas no dirigidas: **AC, AG, CF, CH, FB, BE, BG, BD, EG, GD y DH**.

Grados: A=2, B=4, C=3, D=3, E=2, F=2, G=4, H=2. Cada conexión dispone de un muelle propio, con portón, cadenas y braseros orientados como conjunto. Los muelles sin conexión se conservan como decoración.

Origen de superficie: **(2500, 12, 0)**. Coordenadas X/Z relativas:

| Isla | X | Z |
|---|---:|---:|
| A | 220 | 350 |
| B | -100 | 40 |
| C | -20 | 520 |
| D | 20 | 210 |
| E | 0 | -140 |
| F | -190 | 330 |
| G | 110 | 20 |
| H | 25 | 365 |

Todos los suelos permanecen a Y=12. Las letras son visibles; A indica INICIO y H DESTINO. Ningún puente tiene un tratamiento que identifique la solución. Las conexiones no se cruzan y la disposición es irregular.

La mayor distancia entre islas conectadas se redujo de unos 971 a 348 studs. La envolvente de centros pasó de 900×1160 a 410×660. La distancia mínima entre islas es de 155,08 studs y cada visual queda contenido en un radio de 68,24, por lo que sus geometrías no se superponen.

## Modelos y uniones

Las islas reutilizan la plantilla existente a escala 1,8. Los puentes reutilizan AB como patrón: mismo tamaño de piezas, materiales, colores y mallas. Las once aristas se componen de 19 tramos y 605 tablones en total.

Las juntas entre módulos, que inicialmente tenían unos 17,46 studs entre tablones extremos, se acercaron a 5,24. Ese intervalo está cubierto por dos tablones adicionales del mismo modelo. Las barandas quedan próximas y usan eslabones existentes como enlace. Los tramos comparten la zona de acople; un desfase de posición de 0,03 studs evita planos coincidentes, sin cambiar escalas.

Los 22 accesos de piedra conectan todo el ancho del tablero con el suelo de las islas. Se conserva el acabado Cobblestone y el color de los muelles. Permanecen dentro de AccesosPuentes en cada isla.

La lava es una copia independiente del modelo global, con sus mismas dimensiones y apariencia. No se añadieron assets externos ni se modificó iluminación o clima.

## Construcción e integración posterior

`ServerStorage.ConstructorEscenarioNivel2` contiene herramientas manuales: iniciar, crearIsla, crearPuente, verificar, finalizar y compactar. Solo se ejecutan en Edición. Iniciar rechaza un escenario existente. Compactar elimina los puentes y accesos de este borrador para reconstruirlos; no usarlo después de ediciones manuales sin conservarlas.

La herramienta escribe exclusivamente el escenario nuevo. El nivel 1 y las plantillas se usan como referencias de lectura. Durante la sesión se reconectó Studio y se conservó la firma inicial junto con una referencia renovada; la comparación final verifica que esa referencia y las plantillas permanecen iguales.

Para integrar la mecánica después: acordar objetivo y visitas, configurar la trayectoria, actualizar catálogos y presentación, incorporar Cerberus y probar transición y reinicio. Solo entonces renombrar a Nivel2. La referencia A → C → F → B → E → G → D → H no se muestra en el escenario ni constituye todavía un objetivo configurado.

## Verificación

- Ocho islas, once conexiones exactas y 22 accesos.
- Tamaños, materiales y texturas de los visuales y tramos coinciden con sus referencias.
- 35.982 muestras de suelo distribuidas por centro y laterales: sin huecos.
- Ninguna intersección de colisión entre estructuras de puentes distintos.
- 38 casos físicos de ida y vuelta con Humanoid y saltos deshabilitados: 22 encuentros con islas, ocho juntas entre módulos y ocho accesos completos de B/G. Sin caídas ni atascos.
- 6.195 piezas de escenario. Todas las pruebas temporales quedaron retiradas.
- No se activó el nivel en menús ni se añadieron objetivos o cambios a los controladores.

Trabajo realizado por MCP, sin controlar el PC ni tomar capturas. Guardar el place desde Studio.

## Respaldo

`Desarrollo/Nivel2-Escenario-2026-10-30/` contiene constructor, medidas, conexiones, comprobaciones, pruebas manuales y huellas SHA-256. No contiene las mallas ni sustituye guardar el proyecto en Studio.

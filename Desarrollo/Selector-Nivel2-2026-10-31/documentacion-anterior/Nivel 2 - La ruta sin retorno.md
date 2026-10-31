---
tags: [cursed-bridges, nivel-2, escenario]
actualizado: 2026-10-31
estado: escenario-construido-mecanica-pendiente
---

# Nivel 2: La ruta sin retorno

Volver a [[00 Cursed Bridges]]. Estado: [[Estado y pendientes]]. Lista de trabajo: [[Plan de integración del nivel 2]].

## Entrega

Escenario tridimensional construido y editable en `Workspace.Niveles.Nivel2_Escenario`. Contiene exactamente ocho islas y once puentes, sin habilitar la partida del nivel 2.

La especificación reemplaza el diseño anterior de cinco islas. Tras observar el primer montaje, el usuario pidió compactar las distancias y juntar mejor los tramos; la versión entregada incorpora ambos ajustes.

## Grafo y distribución

Aristas no dirigidas: **AC, AG, CF, CH, FB, BE, BG, BD, EG, GD y DH**.

Grados: A=2, B=4, C=3, D=3, E=2, F=2, G=4, H=2. Cada conexión dispone de un camino y acceso propio. El paso 1 de integración retiró las columnas y adornos que invadían sus entradas; por elección del usuario también se retiraron los diez muelles decorativos sin conexión. Quedan 22 caminos, uno por extremo de puente.

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

## Paso 1 de integración · HECHO

Se despejaron los 22 accesos: portales con sus adornos, 72 agujas/rocas y doce conjuntos de altar que sobresalían hacia los pasos. Después se retiraron completos los diez muelles sin puente, incluidos sus caminos y adornos, según la elección del usuario al revisar F.

Los 22 caminos reales conservan sus cinco placas, la corrección de superficies coplanares y su alineación. Se solapan aproximadamente 7,01 studs con sus accesos de piedra. Se conservaron las ocho islas, las once conexiones, los 605 tablones y los 22 accesos; el escenario contiene ahora 3.805 BaseParts.

Pasaron 154 barridos de colisión y 4.440 muestras de suelo, sin obstáculos ni huecos detectados. No queda decoración alta invadiendo la zona de entrada. El mayor cambio de altura medido entre muestras consecutivas fue de 0,552 studs. La comprobación se hizo en Edición; no se realizó un nuevo recorrido en Play.

Respaldo de las 2.390 BaseParts retiradas: `ServerStorage.RespaldoAccesosNivel2_20261031`. Las rutas y padres originales están registrados como atributos. Evidencia y documentación anterior: `Desarrollo/Accesos-Nivel2-2026-10-31/`.

La huella de las piezas conservadas coincide antes y después de cada retiro; incluye las posiciones, dimensiones y materiales del nivel 1, la plantilla y los puentes del nivel 2. No se modificaron controladores ni se activó el nivel. Ver [[Plan de integración del nivel 2]].

## Paso 2 de integración · HECHO

`ReplicatedStorage.LevelData.Levels[2]` registra **La ruta sin retorno** con `objetivo = {tipo = "trayectoria", inicio = "A", final = "H", islasObligatorias = {}}`. Se gana al llegar de A a H sin repetir vértices, con al menos un cruce; no exige visitar todas las islas ni utilizar todos los puentes.

El catálogo contiene las ocho islas y las once conexiones exactas del escenario. Sus coordenadas de autoría reproducen los centros guardados con la convención de escala 3,5 y altura 12; el juego sigue leyendo la geometría real del mapa.

Pasaron 59 comprobaciones del registro y su objetivo, además de las 18 pruebas previas de las reglas. El validador acepta las diez trayectorias simples A–H del grafo, de dos a siete puentes, y rechaza repetir un vértice incluso por aristas distintas. Los datos del nivel 1 coinciden con su versión anterior y las 7.123 piezas conservadas mantienen su huella geométrica y de acabado.

En el paso 2 solo se modificó `LevelData`. El menú conserva su presentación anterior hasta el paso 5; no se habilitó la partida. Evidencia: `Desarrollo/Objetivo-Nivel2-2026-10-31/`.

## Paso 3 de integración · HECHO

El escenario contiene `Cerberus`, `GuardianRock` y `GuardianGlow`. El guardián está en **(2870, 12, 350)**, a 150 studs de A y mirando hacia ella. Se reutilizaron Cerberus a escala 1,2, la plantilla corregida de isla a escala 2 y el resplandor existente. La roca no tiene caminos ni portales sin puente y queda fuera del archipiélago, con más de 50 studs de separación entre sus cajas en X.

`EscenarioNivel`, `MotorPartida` y `PersecucionCerberus` ya admiten las rutas de este mapa; no se reescribieron. El controlador de movimiento y el aviso se crean en ejecución, evitando dejar una raíz duplicada en Edición. `CerberusClient` limita las reacciones de resultado y rugido al nivel activo y dirige la mirada al jugador solo en ese nivel.

Configuración inicial: ventaja 4 s, velocidad 16, aviso 2 s, vuelo 1,2 s, gracia 1 s y retardo de derrumbe 1 s. El atributo actual de ventaja del nivel 1 es 5 s y se conservó. El balance de una partida completa del nivel 2 se comprobará en el paso 6.

Pasaron 146 comprobaciones aisladas sobre geometría real: veinte escenarios de seguimiento, que cubren las diez trayectorias A–H con puentes intactos y marcados como derrumbados. Se comprobó orden/sentido, avance a velocidad normal, 348 muestras de salto por el mismo puente, espera de cruces incompletos, regreso, captura y restauración. En Play, una cola virtual AC–CH terminó en H y el cuerpo animado acompañó la raíz; se verificó también el retorno de la animación a la roca. No fue una partida completa ni una prueba del derrumbe físico del paso 4.

Se añadieron 688 BaseParts: 323 del guardián, 364 de la roca y una del resplandor. El escenario contiene ahora 4.493 BaseParts. Las 7.123 piezas preexistentes conservan su huella de geometría y acabado. Studio quedó en Edición, sin pruebas temporales, raíces ni avisos de salto persistentes. Evidencia: `Desarrollo/Cerberus-Nivel2-2026-10-31/`.

## Construcción e integración posterior

`ServerStorage.ConstructorEscenarioNivel2` contiene herramientas manuales: iniciar, crearIsla, crearPuente, verificar, finalizar y compactar. Solo se ejecutan en Edición. Iniciar rechaza un escenario existente. Compactar elimina los puentes y accesos de este borrador para reconstruirlos; no usarlo después de ediciones manuales sin conservarlas.

La herramienta escribe exclusivamente el escenario nuevo. El nivel 1 y las plantillas se usan como referencias de lectura. Durante la sesión se reconectó Studio y se conservó la firma inicial junto con una referencia renovada; la comparación final verifica que esa referencia y las plantillas permanecen iguales.

Para terminar la integración faltan derrumbe/reinicio del intento completo, presentación y transición. Solo al activar el nivel se renombrará a Nivel2. La referencia A → C → F → B → E → G → D → H sigue siendo un ejemplo válido; no es un orden obligatorio ni se muestra como solución en el juego.

## Verificación

- Ocho islas, once conexiones exactas y 22 accesos.
- Tamaños, materiales y texturas de los visuales y tramos coinciden con sus referencias.
- 35.982 muestras de suelo distribuidas por centro y laterales: sin huecos.
- Ninguna intersección de colisión entre estructuras de puentes distintos.
- 38 casos físicos de ida y vuelta con Humanoid y saltos deshabilitados: 22 encuentros con islas, ocho juntas entre módulos y ocho accesos completos de B/G. Sin caídas ni atascos.
- Montaje original: 6.195 piezas. Tras despejar los accesos y retirar muelles sin puente: 3.805 BaseParts. Todas las pruebas temporales quedaron retiradas.
- No se activó el nivel en menús. El paso 2 añadió su objetivo a LevelData; los controladores se conservan.

Trabajo realizado por MCP, sin controlar el PC ni tomar capturas. Guardar el place desde Studio.

## Respaldo

`Desarrollo/Nivel2-Escenario-2026-10-30/` contiene constructor, medidas, conexiones, comprobaciones, pruebas manuales y huellas SHA-256. No contiene las mallas ni sustituye guardar el proyecto en Studio.

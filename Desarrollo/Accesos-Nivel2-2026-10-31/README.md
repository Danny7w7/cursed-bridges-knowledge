# Paso 1 del nivel 2 · HECHO

Fecha: 2026-10-31. Place: Cursed bridges, 74011338627746. Escenario: `Workspace.Niveles.Nivel2_Escenario`.

## Retiro de obstáculos

Se despejaron las 22 entradas activas:

- 22 portales: 1.518 BaseParts, incluidas bases, obeliscos, coronas, collares, púas, cadenas y llamas asociadas.
- 72 agujas/rocas que invadían el ancho de los accesos.
- Doce conjuntos completos de altar/brasero: 60 BaseParts.

Primer retiro: 1.650 BaseParts y 56 instancias Fire. Se mantuvieron las cinco placas de cada camino activo, las superficies de las islas y los accesos de piedra.

Al revisar la captura de F, el usuario eligió retirar los caminos y adornos de muelles sin puente en todo el nivel 2. Se archivaron los diez modelos completos: 740 BaseParts y veinte instancias Fire adicionales. Quedan 22 caminos reales, con 110 placas en total.

## Respaldo

Las 2.390 BaseParts y 76 instancias Fire se conservan en `ServerStorage.RespaldoAccesosNivel2_20261031`, agrupadas por isla y grupo de origen. `RutaAntesDelRetiro` y `PadreAntesDelRetiro` identifican su ubicación original. Algunos eslabones tienen nombres repetidos; se conservaron como instancias separadas con sus transformaciones originales.

`antes.json` registra el primer inventario; `muelles-sin-puente-antes.json` registra el retiro posterior. La documentación anterior está en `documentacion-anterior`. Guardar el place conserva la escena y los respaldos de instancias; los JSON no contienen las mallas.

## Verificación

- Ocho islas, once conexiones exactas, 22 accesos, 605 tablones y 3.805 BaseParts activas.
- Cero muelles sin conexión y cero objetivos de retiro pendientes.
- 154 barridos `Blockcast`, siete franjas por acceso, sin bloqueos detectados.
- Revisión de toda la decoración visible alta en la zona de entrada, incluyendo piezas sin colisión: ningún obstáculo restante.
- 4.440 rayos de suelo por centro y laterales de los caminos, desde la isla hasta el primer tramo del puente: sin huecos detectados. Mayor diferencia entre alturas consecutivas: 0,552 studs.
- Los caminos se alinean con la isla vecina, con desviación lateral inferior a 0,001 studs, y se solapan aproximadamente 7,01 studs con sus accesos de piedra.
- Coincidencia de huellas antes/después para todas las piezas conservadas. Protege geometría y acabado del nivel 1, la plantilla, los puentes y accesos del nivel 2, además del resto de decoración conservada.

La comprobación fue geométrica en Edición mediante MCP; no se realizó otra prueba física en Play. No se controló el PC ni se tomaron capturas. No se activó el nivel ni se adelantaron los pasos 2–6.

`verificacion.json` contiene los resultados. `inspeccion.luau` conserva las funciones usadas para identificar los obstáculos; no está instalado como script de ejecución en Studio.

Las firmas históricas del constructor corresponden a su montaje original. No se renovaron para ocultar estas ediciones autorizadas. No reconstruir ni compactar este escenario sobre las ediciones manuales sin conservarlas.

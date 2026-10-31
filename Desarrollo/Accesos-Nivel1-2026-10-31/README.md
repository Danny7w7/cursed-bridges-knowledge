# Limpieza de los ocho accesos del nivel 1

Fecha: 2026-10-31. Place: Cursed bridges, 74011338627746.

El usuario señaló los mismos obstáculos de entrada en B y C y un pincho restante en A. Se revisaron los dos extremos de los cuatro puentes y se extendió la corrección a la entrada de D.

## Cambios

- A: cinco agujas/rocas, incluida `06_Aguja_obsidiana_18`, en el centro de la entrada CA.
- B: portales de los muelles 3 y 4 y cinco agujas/rocas.
- C: portales de los muelles 1 y 2 y cinco agujas/rocas.
- D: portal del muelle 1 y dos agujas/rocas.

Se retiraron completos los portales y sus cadenas, collares, púas y fuegos asociados. Se conservan los pisos y las piezas `04_Muelle_*`, las superficies de las islas y los accesos de piedra. La decoración fuera de los pasos permanece en el escenario.

Son 152 raíces, 362 BaseParts y diez instancias Fire trasladadas a `ServerStorage.RespaldoAccesosNivel1_20261031`, con subcarpetas por isla y grupo original. El atributo `RutaAntesDelRetiro` permite ubicar cada raíz. Esto se suma al retiro anterior de A, conservado en su carpeta de respaldo propia.

## Comprobación

`antes.json` registra el plan y los objetos protegidos. `verificacion.json` contiene los resultados:

- Cero objetivos pendientes y cero rocas/portales dentro del ancho de los ocho accesos.
- 56 barridos `Blockcast`, siete franjas por entrada, sin colisiones detectadas.
- Revisión adicional del volumen visible sobre 15 studs en la zona de entrada (desde 30 studs del centro de la isla hasta seis studs después del primer tablón), con el ancho completo del tablero: sin piezas altas invadiendo el paso.
- Firmas iguales de posición, tamaño y colisión de los cuatro puentes, superficies, placas de muelle y accesos de piedra. Firma del escenario del nivel 2 también igual.
- Validación en Edición, sin un nuevo recorrido en Play ni inspección visual de una captura nueva.

La revisión anterior solo comprobaba colisiones y dejó pasar el pincho decorativo de A, que tenía `CanCollide=false`. Esta revisión también analiza la geometría visible de esas piezas.

## Referencia del constructor

Al retirar los portales activos, no quedan eslabones utilizables en las islas del nivel 1. Se conservó una copia exacta de un eslabón retirado como `ServerStorage.EslabonReferenciaNivel2`, con su escala y acabado originales. `ConstructorEscenarioNivel2.eslabonReferencia` usa ahora esa plantilla y conserva la búsqueda anterior como alternativa. El módulo carga correctamente. No se ejecutó construcción ni compactación del nivel 2.

La firma histórica de protección del nivel 1 dentro del escenario del nivel 2 no se renovó: registra el estado previo a estas retiradas autorizadas. El módulo y la documentación anteriores acompañan este registro. Guardar el place conserva la escena editada y los respaldos de instancias dentro de ServerStorage.

---
tags: [cursed-bridges, assets, diseño]
actualizado: 2026-10-31
---

# Islas (vértices)

Volver a [[00 Cursed Bridges]].

## Modelo del usuario

- Fuente registrada: `Documents/Cursed bridges/Islas/isla_infernal_embellecida.glb`; plantilla actual `ServerStorage.Isla`.
- Referencia del modelo: 660 piezas y 16 materiales, con basaltos, obsidiana, magma, runas, bronce y fuego.
- Núcleo flotante, suelo, cuatro muelles, obeliscos, braseros, cadenas, plataforma central, runa y decoración volcánica.
- Medidas nativas documentadas: suelo de radio 24,9; punta del muelle a 26,1; puerta a 21,7, con abertura aproximada de 8,8.
- Atributos de plantilla: `FloorRadius`, `PierTipRadius`, `GateRadius` y `Pier1..4`. Las piezas de la runa central llevan `Sello`.
- Los materiales se recuperaron del modelo fuente y se aplicaron por nombre.

## Estructura editable actual

~~~text
Workspace
  Niveles
    Nivel1
      Islands
        Island_A (Model, atributo NodeId = A)
          AccesosPuentes (Folder, accesos físicos de piedra)
          Superficie (Part, PrimaryPart, atributo NodeId = A)
            Visual (Model)
            SelloLuz
            GradeLabel
            ClickDetector
~~~

A, B, C y la nueva D tienen esta estructura. Mover o rotar el modelo `Island_A` completo permite trasladar superficie y elementos visuales juntos.

No mover únicamente `Visual` si se pretende cambiar de sitio la isla completa: dejaría separada su superficie caminable. Conservar los identificadores y comprobar los extremos de sus puentes después de una modificación espacial.

## Construcción y escala

- Escala de isla: 1,8; suelo de radio aproximado 45 y puerta de unos 15 studs.
- La superficie invisible es un cilindro que se conserva dentro del modelo como `Superficie`.
- `GeneradorNivel` contiene la construcción reutilizable. Su planificación original asigna muelles y orientaciones; el arranque no vuelve a aplicar esa planificación a un escenario existente.
- El generador conserva una separación artística de 3 studs entre punta de muelle y pivote del puente. Los accesos de piedra de `UnionesPuentes` cubren el encuentro utilizando las medidas reales del tablero.
- El guardián tiene una plataforma creada con la misma plantilla a escala 2.

Los colores de paridad y el clic pertenecen al prototipo anterior. La nueva mecánica utiliza detección física y letreros de inicio, visita obligatoria y meta.

## Uniones caminables

Las ocho uniones de AB, BC, CA y AD tienen una pieza visible y sólida en `Island_X.AccesosPuentes`. Cubren todo el ancho del tablero y se solapan con el suelo de la isla y los primeros tablones. No hace falta saltar para salvar la unión.

Son parte de la isla y permanecen al derrumbarse el puente. No llevan `Kind=Tablon` ni añaden aristas al grafo. `EscenarioNivel` reconoce su superficie como isla y `DetectorCruces` usa el ancho real del tablero.

Después de mover islas o puentes, recalcular en Edición siguiendo [[Uniones de puentes]]. El arranque no vuelve a generar los accesos.

## Accesos despejados del nivel 1 · 2026-10-31

Se retiraron los portales decorativos que estrechaban las ocho entradas de los cuatro puentes: muelles 2/3/4 de A, 3/4 de B, 1/2 de C y 1 de D. Incluyen bases, obeliscos, coronas, collares, púas, cadenas y fuegos asociados. También se retiraron las rocas y agujas que invadían el ancho de esos pasos, incluido el pincho de A `06_Aguja_obsidiana_18` que quedaba tras la primera revisión.

Se conservan el suelo de los muelles, `Superficie`, `AccesosPuentes` y los cuatro puentes. Las piezas de la primera revisión están en `ServerStorage.RespaldoAccesosIslaA_20261031`; las retiradas en la revisión completa están en `ServerStorage.RespaldoAccesosNivel1_20261031`. Cada raíz conserva su ruta original en el atributo `RutaAntesDelRetiro`. La decoración fuera de los pasos y el escenario del nivel 2 se conservan.

Pasaron 56 comprobaciones con `Blockcast`: siete franjas (−12, −9, −4, 0, 4, 9 y 12 studs) en cada una de las ocho entradas. También se comprobó el volumen visible de los accesos, incluyendo piezas sin colisión: no quedan rocas, pinchos ni portales en esos pasos. Las firmas de posición, tamaño y colisión de los suelos, uniones y cuatro puentes, además del escenario del nivel 2, coinciden antes y después de esta revisión. No se realizó un nuevo recorrido en Play. Registro: `Desarrollo/Accesos-Nivel1-2026-10-31/README.md`.

## Caminos y accesos del nivel 2

El paso 1 de integración despejó los 22 accesos del nivel 2. Se retiraron los portales, rocas y altares que invadían esas entradas. Por elección del usuario, también se retiraron los diez muelles decorativos sin puente y sus caminos: quedan 22 caminos con conexión real, cada uno con cinco placas. Los caminos conservados están alineados y se solapan unos 7,01 studs con sus accesos de piedra. Pruebas, respaldo y tareas siguientes: [[Plan de integración del nivel 2]] y [[Nivel 2 - La ruta sin retorno]].

## Superficies del suelo

Los caminos y las losas tenían caras coplanares superpuestas que parpadeaban al mover la cámara. Se separaron ligeramente en altura en las doce islas de los escenarios y en `ServerStorage.Isla`, conservando materiales, dimensiones y posiciones horizontales. La comprobación geométrica quedó sin pares coplanares superpuestos. Detalles, medidas y respaldo: [[Superficies y texturas]]. La confirmación visual posterior sigue pendiente del usuario.

## Adaptación prevista

- El nivel 1 se organizó bajo `Workspace.Niveles` conservando las piezas manuales de A, B y C. Los mapas 2–5 siguen pendientes.
- Mantener `NodeId` estable y leer la posición real del modelo.
- Preparar entradas y salidas de puentes distinguibles, también para lazos y paralelos.
- Validar que el personaje y el cuerpo de Cerberus atraviesen los muelles.
- Revisar especialmente la unión de los puentes paralelos con la puerta del muelle; la incompatibilidad de anchura ya figuraba en las notas anteriores.

La cadena animada de las puertas queda como idea futura, fuera de la mecánica acordada.

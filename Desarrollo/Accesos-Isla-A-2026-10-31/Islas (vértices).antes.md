---
tags: [cursed-bridges, assets, diseño]
actualizado: 2026-10-30
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

## Adaptación prevista

- El nivel 1 se organizó bajo `Workspace.Niveles` conservando las piezas manuales de A, B y C. Los mapas 2–5 siguen pendientes.
- Mantener `NodeId` estable y leer la posición real del modelo.
- Preparar entradas y salidas de puentes distinguibles, también para lazos y paralelos.
- Validar que el personaje y el cuerpo de Cerberus atraviesen los muelles.
- Revisar especialmente la unión de los puentes paralelos con la puerta del muelle; la incompatibilidad de anchura ya figuraba en las notas anteriores.

La cadena animada de las puertas queda como idea futura, fuera de la mecánica acordada.

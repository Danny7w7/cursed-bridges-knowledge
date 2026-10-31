# Accesos despejados de la isla A

Fecha: 2026-10-31. Place: Cursed bridges, 74011338627746.

Se retiró la decoración señalada por el usuario de `Workspace.Niveles.Nivel1.Islands.Island_A`:

- `Visual.world.05_Muelle_[234]_*_Node`: bases, obeliscos y coronas.
- `Visual.Embellecido.Muelle_[234]_*`: collares, púas, cadenas y fuegos asociados.
- `Visual.world.06_Aguja_obsidiana_14_Node`: roca situada en medio de la entrada AB.

Son 82 raíces, 208 BaseParts y seis instancias Fire. Están archivadas en `ServerStorage.RespaldoAccesosIslaA_20261031`, agrupadas en `world` y `Embellecido`; cada raíz conserva su ruta en `RutaAntesDelRetiro`. No se modificaron las placas `04_Muelle_*`, la superficie de la isla, los accesos de piedra, los puentes ni las otras islas.

## Validación

`verificacion.json` registra cero objetivos restantes y las firmas iguales antes/después de las 15 placas y los cuatro puentes. Los 15 barridos con `Blockcast` (tres entradas por cinco carriles: −12, −9, 0, 9 y 12 studs) no encontraron obstáculos sólidos en la decoración de A. Pruebas hechas en Edición; no se realizó otro recorrido en Play.

## Compatibilidad del constructor

`ServerStorage.ConstructorEscenarioNivel2` buscaba un eslabón de referencia exclusivamente en A. Ahora lo busca entre las islas del nivel 1, que aún conservan el mismo modelo. Es un cambio de una línea y el módulo carga correctamente. No se ejecutaron sus funciones de construcción ni se modificó el escenario del nivel 2.

Su comprobación histórica `ProteccionesOrigen` continúa registrando el nivel 1 anterior: la retirada autorizada de esta decoración cambia esa firma. No se renovó silenciosamente esa referencia ni se reconstruyó el nivel 2 para hacerla coincidir.

## Respaldo

`antes.json` contiene el inventario anterior. Las fuentes anterior/actual del constructor y los dos documentos anteriores acompañan este registro. El respaldo completo de los objetos está dentro de Studio en la carpeta de ServerStorage indicada arriba; guardar el place conserva tanto la edición como ese respaldo.

---
tags: [cursed-bridges, assets, pipeline]
actualizado: 2026-10-30
---

# Assets y pipeline de modelos

Volver a [[00 Cursed Bridges]].

## Alcance actual

Reutilizar `Isla`, `Cerberus`, `PuenteRecto`, `PuenteParalelas` y `PuenteLazo` existentes en Studio. La mecánica principal no requiere nuevos assets externos ni reimportar los modelos.

## Lecciones registradas de importación

- En las importaciones realizadas, OBJ fusionó piezas que necesitaban mantenerse separadas. Se adoptó GLB para conservar nodos como MeshParts.
- Los colores se hornearon en una textura-paleta porque se perdían materiales durante la importación.
- El conversor divide las mallas que superan el límite utilizado por el pipeline, aproximadamente 20.000 triángulos.
- Se observó un giro de 180° en Y al importar glTF.
- Algunos exports incluyeron objetos ajenos como `Baseplate1/2` y `Spawnlocation1/2`. Revisar su procedencia antes de retirarlos.
- Importar y editar fuera de Play para conservar los cambios en el escenario de Edición.

Estas notas describen el pipeline utilizado; no son una nueva auditoría de las versiones actuales del importador.

## Herramientas registradas

Ubicación documentada: `Documents/Cursed bridges/Herramientas`.

- `convert_bridges.js`: procesa OBJ y MTL, ensancha la losa, agrupa piezas animables y hornea la paleta.
- `obj_to_glb.js`: convierte el resultado a GLB, con nodos separados y paleta incrustada.
- `render_top.js`: produce una vista cenital para revisión.

Flujo documentado:

~~~bash
node convert_bridges.js && node obj_to_glb.js
~~~

No es necesario ejecutar este pipeline para comenzar la hoja de ruta.

## Fuentes

- `Cerberus/cerberus.glb`: fuente válida según el registro anterior. El OBJ fue sobrescrito por un export defectuoso el 2026-10-27.
- `Islas/isla_infernal_embellecida.glb`: fuente de la isla modelada; existe su plantilla en Studio. La antigua nota que afirmaba que no había isla modelada estaba desactualizada.
- `Islas/isla_infernal_embellecida.obj`: registrado como export defectuoso; no usarlo como referencia de la isla actual.
- `Puentes/*.obj`: fuentes originales documentadas de los tres tipos.

Las rutas fuente se conservan como referencia del trabajo previo; esta actualización no vuelve a auditar esos archivos.

## Datos que deben preservarse

- Puentes: `Kind`, `Edge` y `Order`, pivotes y medidas `Span`/`Reach`.
- Islas: atributos de radios, muelles y sello.
- Cerberus: articulaciones `JointPos`, jerarquía, materiales y etiqueta `Cerberus`.
- Aristas colocadas: `EdgeId`, `From` y `To`; vértices: `NodeId`.

La inspección por MCP confirmó orden numérico en los tablones: 31 en el recto, 33 por arista en paralelas y 71 en el lazo. Esto permite preparar recorridos físicos sin inferir el orden mediante distancia recta.

Los cambios del compañero en geometría deben seguir los límites de [[Trabajo en paralelo]] y no sustituir plantillas mientras otro responsable integra la mecánica.

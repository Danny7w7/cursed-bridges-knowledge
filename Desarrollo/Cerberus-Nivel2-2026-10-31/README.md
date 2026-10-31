# Paso 3 del nivel 2 · HECHO

Fecha: 2026-10-31. Place: Cursed bridges, 74011338627746.

## Instalación

Se añadieron a `Workspace.Niveles.Nivel2_Escenario`:

- `Cerberus`: copia del modelo existente, escala 1,2, 323 BaseParts ancladas y sin colisión, etiqueta Cerberus y modo de streaming Persistent.
- `GuardianRock`: copia de la plantilla corregida `ServerStorage.Isla`, a escala 2, retirando sus cuatro muelles y sus adornos para evitar nuevos caminos sin conexión. Conserva 364 BaseParts.
- `GuardianGlow`: resplandor existente, una BasePart.

Pivote del guardián y su roca: (2870, 12, 350), orientado hacia A=(2720, 12, 350). Separación mínima en X entre las cajas de la roca y todo el archipiélago: más de 50 studs. No se añadieron vértices ni puentes.

Configuración inicial: ventaja 4 s, velocidad 16, retardo de derrumbe 1 s, aviso 2 s, vuelo 1,2 s, gracia 1 s, configuración publicada desactivada. El nivel 1 conserva sus atributos actuales, incluida ventaja 5 s.

## Código

Se reutilizaron sin cambios PersecucionCerberus, MotorPartida, EscenarioNivel y CerberusAnimator. El motor ya registra los cruces durante la ventaja y el perseguidor usa su identidad, sentido y orden. La raíz y el aviso se crean al ejecutar; no se guardaron en la escena de Edición.

Solo se editó `StarterPlayer.StarterPlayerScripts.CerberusClient`: resultados y rugidos afectan al guardián del nivel activo; la mirada al jugador también se limita a ese nivel. La identificación usa el atributo LevelId de sus ancestros, por lo que admite el nombre provisional del escenario.

## Pruebas

`prueba-seguimiento.luau` se ejecutó manualmente en Edición usando una copia del enemigo y de los módulos bajo ServerStorage; la geometría del mapa se leyó sin modificarla. Las copias se retiraron al terminar.

Pasaron 146 comprobaciones: las diez trayectorias simples A–H con puentes intactos y con bloqueos simulados, veinte escenarios en total. Se comprobaron cola durante la ventaja, ingreso por A, duplicados, orden/sentido, velocidad aproximada 16, 348 muestras de salto por el mismo puente, espera de llegada, destino anunciado fijo, regreso, captura, parada y reinicio. Captura virtual a los 10 s, incluida la ventaja inicial de 4 s.

En Play se alimentó una cola virtual AC–CH al controlador del nivel 2, sin activar una partida del mapa. Terminó en H y el cliente mostró el cuerpo desplazado con la raíz: más de 343 studs de movimiento y menos de 1,36 studs de separación horizontal estable del pecho respecto a la raíz. El muestreo cliente se hizo con el enemigo ya detenido. Se comprobó también que la animación volviera a la roca al reiniciar la raíz replicada. El reinicio lógico de PersecucionCerberus se comprobó en las copias aisladas. La consola consultada no contenía errores.

No fue una partida completa del nivel 2 ni una prueba del derrumbe físico. La captura contra un personaje real y el balance final se comprobarán en la integración de los pasos siguientes.

## Cierre y respaldo

El escenario tiene 4.493 BaseParts después de añadir 688. La huella de las 7.123 piezas preexistentes coincide con el inicio de esta entrega. No quedan objetos de prueba, raíces ni avisos de salto en Edición. El mapa sigue llamado Nivel2_Escenario, con SoloEscenario=true.

Esta carpeta conserva el cliente anterior/actual, módulos de referencia sin cambios, prueba y verificacion.json. `documentacion-anterior` conserva las notas anteriores. La instalación de objetos y configuración queda descrita en verificacion.json; guardar el place conserva las nuevas instancias y el código de Studio.

Siguiente bloque: paso 4, derrumbe, lava y reinicio del intento completo.

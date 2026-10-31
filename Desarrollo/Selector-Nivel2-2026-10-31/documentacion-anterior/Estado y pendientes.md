---
tags: [cursed-bridges, estado]
actualizado: 2026-10-31
---

# Estado y pendientes

Volver a [[00 Cursed Bridges]]. Plan: [[Hoja de ruta]]. Entrega: [[Entrega del nivel 1]].

## Nivel 1 cerrado

**Nivel 1 implementado y validado por MCP.** Salir de A, visitar B y C y terminar en D sin repetir puentes. Caminata y salto, derrumbe, persecución, resultados y reintento.

Studio quedó en Edición. El guardado manual del place sigue a cargo del usuario; la copia de fuentes no sustituye guardar el escenario.

## Nivel 2: escenario construido

**La ruta sin retorno** está en `Workspace.Niveles.Nivel2_Escenario`: ocho islas, once puentes y 22 accesos. Tras la revisión del usuario se compactó la distribución y se acercaron los tramos. Pasaron 35.982 muestras de suelo y 38 recorridos físicos de ida y vuelta sin saltos, caídas ni atascos, incluidos los ocho accesos de B/G.

**Paso 1 de integración hecho:** 22 accesos despejados y diez muelles sin puente retirados. Quedan únicamente 22 caminos con conexión real. Pasaron 154 barridos y 4.440 muestras de suelo, sin bloqueos ni huecos detectados; se verificó la alineación de los caminos y sus uniones.

**Paso 2 de integración hecho:** objetivo registrado en LevelData como trayectoria A → H, sin repetir islas ni exigir todas las islas o puentes. Ocho islas y once conexiones contrastadas con el escenario; 59 comprobaciones del objetivo y 18 previas de reglas correctas. Datos del nivel 1 y geometría conservados.

**Paso 3 de integración hecho:** Cerberus, roca y resplandor colocados; perseguidor existente conectado a la geometría. Pasaron 146 comprobaciones aisladas de seguimiento, saltos, captura y reinicio y una comprobación de animación en Play. Ventaja inicial 4 s y velocidad 16; las reacciones del cliente se separan por nivel.

El mapa sigue sin habilitarse como nivel jugable. Sigue el paso 4, derrumbe, lava y reinicio del intento completo. Lista con el estado de los seis pasos: [[Plan de integración del nivel 2]]. Detalles y respaldo: [[Nivel 2 - La ruta sin retorno]].

## Mecánica centrada en grafos

Se retiraron el dash y los obstáculos añadidos de rejillas de fuego y rocas que caen. También se eliminaron sus eventos, indicador, efectos de golpe y explicación de Shift. Se conservan el fuego decorativo, los escenarios, el recorrido por islas/puentes, el derrumbe y Cerberus.

Pasaron 201 comprobaciones existentes y una victoria real A → B → C → A → D, sin dash, con velocidad 16 y sin regeneración de peligros durante el recorrido. Detalles: [[Mecánica centrada en grafos]].

## Accesos del nivel 1

Se despejaron las ocho entradas activas de A, B, C y D: columnas, coronas, cadenas y adornos asociados, además de las rocas y pinchos que invadían los pasos. La segunda revisión incluye 17 rocas o agujas, entre ellas el pincho restante de A. Pasaron 56 comprobaciones de colisión y la revisión de geometría visible sin colisión. Los suelos, uniones, cuatro puentes y escenario del nivel 2 mantienen sus firmas de geometría. Pruebas en Edición, sin repetir el recorrido en Play. Respaldo adicional: `ServerStorage.RespaldoAccesosNivel1_20261031`. Detalles: [[Islas (vértices)]] y `Desarrollo/Accesos-Nivel1-2026-10-31/README.md`.

## Superficies del suelo

Se corrigieron los solapamientos coplanares de losas y caminos en los niveles 1/2 y en la plantilla: 384 ajustes verticales pequeños, con materiales y dimensiones conservados. La revisión geométrica pasó de 646 pares superpuestos a igual altura a cero. La confirmación al girar la cámara sigue pendiente del usuario. Detalles: [[Superficies y texturas]].

## Implementado

- [x] Cuatro islas y cuatro puentes bajo `Workspace.Niveles.Nivel1`.
- [x] Ocho uniones con accesos de piedra; pruebas por centro y laterales sin saltar. Véase [[Uniones de puentes]].
- [x] D y AD añadidos sin mover ni sustituir A, B y C.
- [x] Arranque que conserva el escenario editado.
- [x] Contratos 1.0.0 y validador para los cinco tipos de recorrido.
- [x] Inicio, cruces físicos, victoria, derrotas y reintento.
- [x] Derrumbe del servidor y animación del cliente.
- [x] Raíz móvil, locomoción, captura y salto anunciado de Cerberus.
- [x] Primer ingreso por A y seguimiento de los mismos puentes del jugador; salto por el mismo puente derrumbado. Véase [[Cerberus seguidor]].
- [x] Interfaz de objetivo y acciones; explicaciones educativas de universidad inicial solo antes y después del intento. Véase [[Textos educativos]].
- [x] Cinemática sin secuencia sugerida de islas y rótulo «Dos senderos posibles».
- [x] Configuración local; consulta remota opcional desactivada por defecto.
- [x] Copia de las 20 fuentes verificadas y contrato para el compañero.

## Verificación

| Comprobación | Resultado |
|---|---|
| Reglas matemáticas | 18 comprobaciones correctas |
| Integración en copias aisladas | 138 comprobaciones correctas |
| Coincidencia inicial entre Studio y copia de fuentes | 20 iguales al cierre inicial; parche de cuatro módulos en [[Uniones de puentes]] |
| Accesos de islas y puentes | 19.720 muestras sin huecos; 24 idas y vueltas físicas sin saltos ni caídas |
| A → B → C → A → D | Victoria en Play con enemigo y derrumbe |
| A → C → B → A → D | Victoria después de reintentar |
| A → D sin visitar B y C | Derrota por objetivo incompleto y ausencia de salida |
| Captura y lava | Derrotas comprobadas |
| Reintento tras ganar | 176 piezas restauradas, historial limpio y enemigo en reposo |
| Animación de caída | 149 piezas desplazadas durante la prueba |
| Cerberus | Cuerpo sigue su raíz; 23 comprobaciones de seguimiento, orden y reinicio; dos victorias en Play y captura al detenerse |
| CrossBridge antiguo | No modifica el recorrido |
| Interfaz | 16 comprobaciones de lectura, desplazamiento, carga, estados y reintento; tipografías conservadas |
| Textos educativos | 22 comprobaciones; dos soluciones verificadas; victoria y A → D con explicación correcta |
| Cinemática | Rótulos sin orden de visitas, lectura detenida y retorno a preparación comprobados en Play |
| Consola final de la mecánica | Sin errores nuevos |

Las pruebas incluyeron movimiento real con Humanoid en Play, además de comprobaciones de posiciones y copias. No se controló el PC ni se tomaron capturas.

## Balance vigente

- Ventaja inicial actual del nivel 1: **5 segundos**, según su atributo local. La entrega original se probó con 12; esta integración conserva los 5 existentes.
- Ventaja inicial del nivel 2: **4 segundos**, validada como configuración inicial del perseguidor; balance de partida completa pendiente del paso 6.
- Jugador y Cerberus: 16 studs/s.
- Retardo de derrumbe: 1 segundo.
- Aviso de salto: 2 segundos; duración: 1,2; gracia al aterrizar: 1.
- `UsarConfiguracionPublicada = false`: no necesita claves publicadas.

Kohl's Admin conserva sus avisos previos de acceso a DataStore en Studio. No se habilitaron APIs ni se modificó ese sistema.

## Hoja de ruta general

| Etapa | Estado |
|---|---|
| R00 · Contratos | Completada para la base del nivel 1 |
| R01 · Reglas | Implementadas para los cinco tipos y probadas |
| R02 · Mapas | Nivel 1 listo; escenario visual del nivel 2 construido y comprobado; mapas 3–5 pendientes |
| R03 · Cruces | Nivel 1 validado; lazos/paralelos físicos pendientes con sus mapas |
| R04 · Intento | Nivel 1 completo; continuación a otro mapa pendiente |
| R05 · Derrumbe | Nivel 1 validado |
| R06 · Cerberus | Nivel 1 validado |
| R07 · Cinco niveles | Primer nivel integrado; secuencia completa pendiente |
| R08 · Cierre | Nivel 1 validado por MCP; valoración visual del usuario y cierre de cinco niveles pendientes |

El catálogo de los niveles 2–5 todavía conserva nombres y grafos del prototipo euleriano. Alinear esas entradas con la especificación antes de habilitar los mapas correspondientes. Esta entrega modifica solo la descripción del nivel 1.

## Próximo trabajo

Integrar la mecánica del nivel 2 cuando el usuario lo indique, partiendo del nuevo escenario de ocho islas. Antes de activarlo, acordar las visitas obligatorias y el balance y actualizar los catálogos heredados. El compañero puede revisar decoración y textos sin alterar las once conexiones ni las escalas.

Siguen fuera de alcance: multijugador, móvil/consola, pistas, pausa activa, persistencia, vidas, puntuaciones, modo arquitecto y nuevos assets.

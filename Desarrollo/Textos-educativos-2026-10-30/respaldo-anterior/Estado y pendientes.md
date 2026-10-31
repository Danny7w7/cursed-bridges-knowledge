---
tags: [cursed-bridges, estado]
actualizado: 2026-10-30
---

# Estado y pendientes

Volver a [[00 Cursed Bridges]]. Plan: [[Hoja de ruta]]. Entrega: [[Entrega del nivel 1]].

## Nivel 1 cerrado

**Nivel 1 implementado y validado por MCP.** Salir de A, visitar B y C y terminar en D sin repetir puentes. Caminata y salto, derrumbe, persecución, resultados y reintento.

Studio quedó en Edición. El guardado manual del place sigue a cargo del usuario; la copia de fuentes no sustituye guardar el escenario.

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
- [x] Interfaz mínima de objetivo y acciones.
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
| Interfaz | Una instancia; Reintentar visible y Continuar oculto |
| Consola final de la mecánica | Sin errores nuevos |

Las pruebas incluyeron movimiento real con Humanoid en Play, además de comprobaciones de posiciones y copias. No se controló el PC ni se tomaron capturas.

## Balance vigente

- Ventaja inicial del nivel 1: **12 segundos**. Se conserva al cambiar Cerberus a seguimiento del recorrido.
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
| R02 · Mapas | Nivel 1 listo; mapas 2–5 pendientes |
| R03 · Cruces | Nivel 1 validado; lazos/paralelos físicos pendientes con sus mapas |
| R04 · Intento | Nivel 1 completo; continuación a otro mapa pendiente |
| R05 · Derrumbe | Nivel 1 validado |
| R06 · Cerberus | Nivel 1 validado |
| R07 · Cinco niveles | Primer nivel integrado; secuencia completa pendiente |
| R08 · Cierre | Nivel 1 validado por MCP; valoración visual del usuario y cierre de cinco niveles pendientes |

## Próximo trabajo

Nivel 2 cuando el usuario lo indique. El compañero puede trabajar en P01 y mejoras visuales de P02 usando [[Contratos de integración]], sin cambiar por su cuenta reglas o controladores.

Siguen fuera de alcance: multijugador, móvil/consola, pistas, pausa activa, persistencia, vidas, puntuaciones, modo arquitecto y nuevos assets.

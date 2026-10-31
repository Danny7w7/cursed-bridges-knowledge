---
tags: [cursed-bridges, tecnico]
actualizado: 2026-10-30
---

# Arquitectura en Studio

Volver a [[00 Cursed Bridges]]. Reglas: [[Mecánica principal acordada]]. Interfaces: [[Contratos de integración]].

Arquitectura del nivel 1 implementado y validado por MCP. Consultar [[Entrega del nivel 1]] para pruebas y balance, y [[Estado y pendientes]] para los otros mapas.

## Escenario

`Workspace.Niveles.Nivel1` contiene:

- `Islands`: modelos `Island_A`, `Island_B`, `Island_C` e `Island_D`, con `NodeId` y `Superficie` como parte principal.
- `Bridges`: AB, BC, CA y AD, identificados por `EdgeId`, `From` y `To`.
- Cerberus, su plataforma y el resplandor del escenario existente.

La migración conserva las piezas y posiciones de A, B y C. D y AD se añadieron usando un muelle libre de A. El arranque no genera un escenario nuevo.

Streaming permanece habilitado. La lava base mide `2048 × 16 × 2048` y su centro está en `(0, -60, 0)`.

## ReplicatedStorage

| Módulo | Responsabilidad |
|---|---|
| ContratosJuego | Tipos compartidos y versión 1.0.0 |
| LevelData | Catálogo y objetivo del nivel; tipos anteriores conservados |
| ReglasRecorrido | Validación pura de cinco recorridos y salidas legales |
| InterfazIntento | Presentación mínima y callbacks de acciones |
| BridgeFX | Representación visual de las caídas notificadas por el servidor |
| CerberusAnimator | Animación procedural que sigue la raíz móvil |
| GraphLogic / EulerAlgorithms | Utilidades anteriores, conservadas; no imponen la victoria general |

`RemoteEvents` conserva los eventos útiles anteriores y añade `ComenzarIntento` y `ContinuarNivel`. Continuar está reservado mientras solo exista el primer nivel.

## ServerScriptService

| Objeto | Responsabilidad |
|---|---|
| GameController | Jugador, personaje, remotos y actualización del intento |
| MotorPartida | Preparación, actividad, resultado, objetivo y reinicio |
| EscenarioNivel | Lectura y validación de islas, puentes y rutas físicas |
| DetectorCruces | Entrada, avance, retorno y llegada desde posiciones comprobadas |
| DerrumbePuentes | Transitabilidad, soporte físico y restauración |
| NavegacionGrafo | Ruta más corta por distancia real |
| PersecucionCerberus | Locomoción, captura y salto con aviso |
| ConfiguracionJuego | Valores por intento; atributos locales por defecto y configuración publicada con activación explícita |
| BridgeBuilder | Comprobación del escenario guardado; sin regeneración automática |
| GeneradorNivel | Herramienta de construcción para Edición |
| PruebasReglasRecorrido | Comprobaciones matemáticas, ejecutadas manualmente |

`PruebasNivel1` está instalado: superó 138 comprobaciones sobre copias aisladas. `PruebasReglasRecorrido` superó 18 comprobaciones. Las partidas completas y el reintento también se probaron en Play.

## Cliente

- `UIController` recibe estado, conecta acciones y espera la superficie inicial antes de habilitar Comenzar.
- `ClientePuentes` observa atributos de caída e identidad del intento y reutiliza BridgeFX.
- `CerberusClient` conserva reacciones de resultado y anima al enemigo.
- `Clima` conserva ceniza y brasas.

El cliente no declara cruces, victoria ni captura. Las acciones antiguas de clic no alteran el historial.

## Fuentes físicas

Los puentes preservan `Kind`, `Edge` y `Order`:

| Plantilla | Tablones ordenados |
|---|---|
| PuenteRecto | 31 |
| PuenteParalelas | 33 por arista |
| PuenteLazo | 71 |

Las posiciones se toman del escenario, con rutas ordenadas por tablón. El servidor separa arista recorrida de puente inutilizable. El cliente anima las piezas después de retirarse el soporte.

La raíz `Cerberus.RaizMovimiento` lleva posición y estado; el animador no la incluye entre las piezas que mueve por cinemática.

## Trabajo posterior

El nivel 1 está cerrado para esta entrega. Los mapas 2–5, pruebas físicas de lazos/paralelos y cambios de nivel siguen en [[Hoja de ruta]].

No habilitar DataStores, modificar iluminación ni importar modelos para resolver fallos del controlador. Las plantillas existentes siguen siendo la base.

---
tags: [cursed-bridges, tecnico, contratos]
actualizado: 2026-10-31
version: 1.0.0
---

# Contratos de integración

Volver a [[00 Cursed Bridges]]. Reglas funcionales: [[Mecánica principal acordada]]. Reparto: [[Trabajo en paralelo]].

Contrato fijado para el código del nivel 1. La comprobación del guardado y el estado final de la entrega se registran en [[Estado y pendientes]]; este documento no certifica por sí mismo una prueba completa de jugabilidad.

## Escenario y datos

- Escenario: `Workspace.Niveles.Nivel1`.
- Islas: `Islands.Island_<id>`, modelos con `NodeId` y `PrimaryPart = Superficie`.
- Puentes: `Bridges.Bridge_<id>`, modelos con `EdgeId`, `From` y `To`.
- Tablones: `Kind = Tablon` y `Order` numérico único dentro del puente.
- Catálogo: `ReplicatedStorage.LevelData`; el nivel 1 tiene `objetivo = {tipo = "sendero", inicio = "A", final = "D", islasObligatorias = {"B", "C"}}`.
- El nivel 2 tiene `objetivo = {tipo = "trayectoria", inicio = "A", final = "H", islasObligatorias = {}}`, con ocho islas y once aristas. Está habilitado para pruebas del usuario como `Nivel2`, con `SoloEscenario=false`; la revisión completa de integración sigue pendiente.
- La topología y las coordenadas jugables se leen del escenario guardado. Las coordenadas del catálogo solo apoyan la autoría.

El nivel 1 tiene AB, BC, CA y AD. Se conservaron las posiciones de A, B y C; D se añadió a partir de un muelle libre de A.

## Tipos compartidos

`ReplicatedStorage.ContratosJuego` exporta los tipos; su tabla de retorno identifica la versión `1.0.0`.

~~~lua
TipoRecorrido = "sendero" | "trayectoria" | "camino_cerrado" | "circuito" | "circuito_simple"
Fase = "preparacion" | "activo" | "victoria" | "derrota"

Objetivo = {
    tipo: TipoRecorrido,
    inicio: string,
    final: string,
    islasObligatorias: {string},
}
Arista = {id: string, from: string, to: string}
Historial = {vertices: {string}, aristas: {string}}
~~~

`from` y `to` se conservan para compatibilidad con los datos anteriores. Las secuencias del historial contienen un vértice más que aristas.

## Validación matemática

`ReplicatedStorage.ReglasRecorrido`:

~~~text
evaluar(objetivo, aristas, historial) -> Evaluacion
agregar(historial, aristaId, llegada) -> nuevoHistorial
salidasLegales(objetivo, aristas, historial, bloqueadas) -> aristas
~~~

- `Evaluacion`: `valido`, `victoria`, `faltantes` y, cuando corresponda, `codigo`, `mensaje` y `paso`.
- `agregar` no modifica el historial recibido.
- `bloqueadas` es un diccionario por identificador de puente y describe transitabilidad física. No equivale al conjunto de aristas recorridas.
- No realizar búsquedas globales de una solución futura para decidir una derrota anticipada.

## Detección y navegación

`ServerScriptService.EscenarioNivel` carga y valida geometría, proyecta posiciones sobre rutas y localiza la isla actual.

`DetectorCruces` recibe escenario, estado del detector, posición, tiempo transcurrido y velocidad. Emite `entrada`, `llegada`, `regreso` o `atajo`.

Un cruce en curso contiene ruta, salida, llegada, sentido y avance; todavía no pertenece al historial. El servidor lo incorpora únicamente en `llegada`.

`NavegacionGrafo.buscar(escenario, desde, hasta, bloqueadas)` devuelve la secuencia de aristas y su distancia, o `nil` si no hay ruta. Usa pesos de longitud real, incluyendo los accesos desde los centros de las islas.

## Control del intento

`ServerScriptService.MotorPartida` compone reglas, detector, derrumbe y enemigo. El adaptador `GameController` gestiona jugador, personaje y remotos.

~~~text
MotorPartida.crear(escenario, objetivo, configuracion, acciones) -> partida
acciones: alEstado(estado), alResultado(resultado)

partida.estado()
partida.historial()
partida.reiniciar(configuracion)
partida.comenzar(intentoId, ahora)
partida.actualizar(ahora, dt, posicion)
partida.derrotar(codigo, mensaje)
~~~

Cada reinicio incrementa `intentoId`. Las acciones atrasadas se rechazan. Una victoria o derrota ya emitida no puede ser sustituida por otro resultado del mismo intento.

### Remotos

| Evento | Dirección | Contenido |
|---|---|---|
| ComenzarIntento | Cliente → servidor | `intentoId` |
| RestartLevel | Cliente → servidor | `intentoId` |
| RequestState | Cliente → servidor | Sin argumentos |
| StateUpdated | Servidor → cliente | `EstadoPresentacion` |
| LevelResult | Servidor → cliente | `Resultado` |
| ContinuarNivel | Reservado | No habilitado mientras solo esté disponible el nivel 1 |

Los antiguos `CrossBridge`, `SelectStart` y `RequestHint` no alteran el recorrido. El cliente nunca declara que cruzó o ganó.

### Estado de presentación

`intentoId`, `levelId`, `fase`, `titulo`, `instruccion`, `definicion`, `peligroDesde`, `puedeContinuar` y `resultado` opcional.

`mapaListo` es opcional y lo utiliza el adaptador del cliente para deshabilitar Comenzar mientras carga la superficie inicial.

### Resultado

`outcome` conserva `victory`/`defeat` para las reacciones del cliente existente. También incluye `message`, `codigo`, `intentoId` y las secuencias `vertices`/`aristas`.

Los errores físicos de captura o lava no se presentan como infracciones matemáticas.

## Interfaz del compañero

`ReplicatedStorage.InterfazIntento` ya tiene una implementación base. El compañero puede mejorar su presentación por turno, conservando:

~~~text
crear(contenedor, acciones) -> controladorInterfaz
acciones: alComenzar(), alReintentar(), alContinuar()

controladorInterfaz.actualizar(estadoPresentacion)
controladorInterfaz.mostrarResultado(resultado)
controladorInterfaz.destruir()
~~~

El adaptador `UIController` conecta remotos y carga del mapa. El módulo de presentación no valida movimientos ni envía eventos por su cuenta.

### Textos educativos

`ReplicatedStorage.TextosEducativos` centraliza fundamentos, definiciones y formato de preparación y resultado. `MotorPartida` construye el resultado usando `ReglasRecorrido.evaluar`, objetivo e historial. Se conserva el contrato 1.0.0: `EstadoPresentacion.definicion`, `instruccion` y `Resultado.message`, sin remotos nuevos.

La interfaz presenta fundamentos y definición solo en preparación. En resultado separa causa, validez, objetivo e historial. El cuerpo está en `PuentesMalditosUI.ResultadoOPreparacion.Contenido.Explicacion`; los botones siguen directamente bajo `ResultadoOPreparacion`. Las pruebas que leían el antiguo label directo deben usar esta ruta o buscarlo por nombre recursivamente.

`MenuPrincipal` conserva el diseño visual y la cámara existente; la cinemática del nivel 1 usa panorámicas y textos de sendero sin orden de islas. El rótulo de dos soluciones es un dato de autoría comprobado contra la topología actual. Véase [[Textos educativos]].

La interfaz activa muestra tipo y condiciones, sin pistas, panel de grados ni ruta permanente. Al terminar presenta causa y recorrido real. Al no existir todavía el nivel 2, ofrece repetir el nivel 1.

## Derrumbe y representación

- `DerrumbePuentes` decide el soporte físico desde el servidor y conserva el reposo de cada pieza.
- Atributos: `MarcoReposo`, `TransparenciaReposo`, `ColisionReposo`, `CaidaDesde` e `IntentoCaida`.
- `ClientePuentes` observa los atributos y llama a `BridgeFX.representarCaida`.
- `IntentoId` en el escenario permite restaurar los efectos al reintentar.
- El cliente anima la caída; no determina cuándo deja de sostener al personaje.

## Cerberus

El nivel 2 ya tiene su propio modelo, roca y resplandor. Usa los mismos contratos de seguimiento; no cambia la versión 1.0.0. `CerberusClient` obtiene el nivel del modelo mediante el `LevelId` de sus ancestros para separar las reacciones. La raíz y la advertencia siguen siendo objetos de ejecución. Configuración inicial del nivel 2: ventaja 4 s, velocidad 16 y tiempos de salto 2/1,2/1 s. La activación jugable sigue pendiente en [[Plan de integración del nivel 2]].

- `PersecucionCerberus` recibe el escenario y la isla inicial.
- `Cerberus.RaizMovimiento` replica marco, `EstadoMovimiento`, `VelocidadActual` y `Reinicio`.
- El animador excluye esa raíz de sus piezas animadas y la usa para ubicar el modelo.
- La zona de captura se calcula con el cuerpo, sin extenderla a llamas o cola.
- Su primera entrada se hace por la isla inicial. Después consume los mismos cruces del jugador, por identidad de arista, sentido y orden.
- `MotorPartida` llama a `cerberus.registrar(evento)` para entrada, llegada y regreso desde que comienza el intento, también durante la ventaja inicial.
- Los puentes derrumbados del rastro se saltan siguiendo sus puntos ordenados. El destino queda fijado al avisar; no hay captura durante salto ni gracia y no se elige otra conexión.
- La raíz añade `RutaEnUso`, `AristasSeguidas` e `IslaActual` para inspección. No sustituyen el historial matemático del jugador.
- Reintentar limpia registros pendientes, seguimiento y salto. `NavegacionGrafo` deja de decidir la persecución. Véase [[Cerberus seguidor]].

## Configuración

Los valores se fijan para el intento; las actualizaciones se aplican al preparar el siguiente.

| Atributo del mapa | Clave opcional de Experience Configs |
|---|---|
| VentajaInicial | `nivel1_VentajaInicial` |
| RetardoDerrumbe | `nivel1_RetardoDerrumbe` |
| AvisoSalto | `nivel1_AvisoSalto` |
| DuracionSalto | `nivel1_DuracionSalto` |
| GraciaAterrizaje | `nivel1_GraciaAterrizaje` |
| VelocidadJugador | `nivel1_VelocidadJugador` |

Por defecto, `UsarConfiguracionPublicada = false`: `ConfiguracionJuego` no consulta ConfigService y utiliza los atributos del mapa. Para usar valores publicados, crear las claves y habilitar ese atributo antes de Play; la lectura se realiza solo en el servidor. No requiere DataStores. El balance validado del nivel 1 usa 12 segundos de ventaja; ver [[Entrega del nivel 1]].

## Propiedad y pruebas

El responsable principal integra `GameController`, `UIController`, detector, motor, derrumbe y enemigo. La presentación y los textos pueden repartirse con las firmas anteriores. Un solo escritor por objeto y pruebas de Play por turnos.

`PruebasReglasRecorrido` comprueba las reglas puras. `PruebasNivel1` prepara copias aisladas para validar transiciones, restauración y captura sin alterar el mapa de Edición. No confundir estos resultados con una partida completa de un jugador real.

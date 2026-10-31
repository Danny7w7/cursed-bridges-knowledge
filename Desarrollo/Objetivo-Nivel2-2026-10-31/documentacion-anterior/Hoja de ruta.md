---
tags: [cursed-bridges, plan, desarrollo]
actualizado: 2026-10-31
estado: nivel-1-validado
---

# Hoja de ruta

Volver a [[00 Cursed Bridges]]. Reglas obligatorias: [[Mecánica principal acordada]]. Reparto: [[Trabajo en paralelo]].

**Objetivo:** entregar la mecánica por bloques comprobables, sin mezclar todos los sistemas en una sola intervención. La publicación de esta hoja de ruta no significa que sus etapas estén implementadas.

## Prioridad actual: integración del nivel 2

El nivel 1 conserva su entrega jugable. La ruta sin retorno tiene ocho islas y once conexiones exactas, con distribución y juntas compactadas. El paso 1 de integración está hecho: 22 entradas despejadas y diez muelles sin puente retirados, conservando solo los caminos reales. Sigue registrar el objetivo de trayectoria. Lista de los seis pasos: [[Plan de integración del nivel 2]]. La activación jugable permanece pendiente. Ver [[Nivel 2 - La ruta sin retorno]], [[Contratos de integración]] y [[Estado y pendientes]].

## Dependencias y focos

~~~text
R00 Contratos
 ├─ R01 Validación matemática
 ├─ R02 Mapas y rutas físicas
 └─ P01 Textos / P02 Interfaz aislada

R01 + R02 → R03 Cruces → R04 Intento completo
R04 → R05 Derrumbes
R02 + R04 → R06 Cerberus
R05 + R06 → R07 Integración de los cinco niveles → R08 Validación final
~~~

Un solo foco principal activo. R01/R02 y R05/R06 permiten trabajo de módulos en paralelo, pero sus pruebas o escrituras en el mismo Studio se realizan por turnos.

## R00 — Contratos y punto de partida

**Depende de:** documentación vigente. **Responsable:** integración principal, con entrega al compañero.

Trabajo:

- Releer el estado actual por MCP y registrar los objetos/scripts que se van a tocar.
- Definir tipos compartidos del objetivo, historial, fase del intento, cruce físico y transitabilidad.
- Fijar nombres y firmas de las acciones Comenzar/Reintentar/Continuar y de los módulos que se repartirán.
- Usar el contrato propuesto en [[Trabajo en paralelo]] como punto de partida; ratificarlo técnicamente antes de integrar módulos.
- Establecer identificador de intento y mecanismo de limpieza para eventos pendientes.

**Cierre:** contratos publicados, responsables asignados y un registro de entrega que permita al compañero trabajar sin editar controladores compartidos.

**Todavía no:** perseguir, derrumbar, construir todos los sistemas o modificar el comportamiento existente.

## R01 — Motor de validación matemática

**Depende de:** R00. **Foco:** reglas puras, sin personaje ni efectos.

Trabajo:

- Representar historial de vértices y aristas con identidad propia.
- Validar los cinco tipos y el objetivo de inicio, final e islas obligatorias.
- Evaluar avance, infracción y victoria sin imponer condiciones eulerianas generales.
- Definir qué continuación es legal y cuándo no quedan salidas; no detectar anticipadamente toda imposibilidad futura.
- Separar historial matemático de puentes físicamente inutilizables.

**Cierre:** pasan casos positivos y negativos de los cinco tipos, incluidos lazos, paralelos, retorno al inicio, objetivo incompleto y recorrido vacío.

**Entrega al compañero:** tipos estables y ejemplos de entrada/salida para textos e interfaz.

## R02 — Cinco mapas y rutas físicas

**Depende de:** R00. **Foco:** escenarios editables y datos de navegación.

Trabajo:

- Organizar mapas en `Workspace.Niveles` y mantener las piezas del triángulo actual; añadir D y AD al primer mapa.
- Preparar los otros cuatro mapas según la especificación, reutilizando las plantillas existentes.
- Mantener separación aproximada de 1.500 studs y lava bajo cada escenario; conservar la estética.
- Leer topología de `NodeId`, `EdgeId`, `From` y `To`.
- Preparar extremos y rutas ordenadas de cada puente a partir de `Order`; distinguir los extremos de un lazo.
- Validar conexiones físicas, huecos, anchura de puertas y paso de personaje/Cerberus, especialmente en paralelos.
- Mantener el generador como herramienta de Edición, sin sustituir mapas al iniciar.

**Cierre:** cinco mapas editables, identificadores únicos por mapa, una solución matemática de referencia por objetivo y rutas físicas continuas.

**Entrega al compañero:** inventario y geometría congelados para revisar conexiones y preparar recorridos de prueba.

## R03 — Detectar cruces al caminar

**Depende de:** R01 y R02. **Foco:** transformar movimiento físico en eventos válidos.

Trabajo:

- Detectar isla de salida, entrada al puente, sentido, avance, retorno y llegada.
- Confirmar cruces desde el servidor; no confiar en `CrossBridge` ni en clics del cliente.
- Admitir saltos normales sin duplicar eventos.
- Diferenciar un lazo completo de una entrada parcial y los dos puentes de una conexión paralela.
- No añadir arista ni vértice cuando vuelve a la salida antes de completar el cruce.
- Impedir que aterrizar en otra isla mediante un atajo avance el estado del recorrido.

**Cierre:** recorrido físico e historial coinciden en ambas direcciones, con salto, retorno, lazo y paralelos.

**Todavía no:** derrumbe ni persecución durante estas pruebas aisladas.

## R04 — Un intento completo y presentación mínima

**Depende de:** R03; recibir P01/P02 cuando estén listos. **Foco:** poder jugar un desafío de principio a fin sin enemigo ni derrumbe todavía.

Trabajo:

- Preparación → Comenzar → intento activo → victoria/derrota.
- Conectar detección con objetivos y explicación del resultado.
- Implementar derrota por regla, lava y ausencia de salida legal.
- Reintentar desde cero y continuar al siguiente objetivo después de ganar.
- Mostrar solo tipo y condiciones durante el intento; explicación al terminar.
- Retirar de la experiencia activa los clics de cruce, pistas y panel teórico del prototipo.
- Congelar el intento antes de comenzar y después del resultado; no añadir pausa durante la partida.

**Cierre:** un nivel puede ganarse, perderse y reiniciarse sin residuos; la secuencia y carga de los mapas funcionan. El estado se conserva solo en la sesión.

**Entrega:** ciclo del intento estable para que derrumbe y Cerberus consuman sus eventos.

## R05 — Derrumbe progresivo real

**Depende de:** R04. **Foco:** soporte físico y representación sincronizados.

Trabajo:

- Activar derrumbe al entrar a un puente en los cuatro tipos que prohíben repetir aristas.
- Mantener reutilizables los puentes de camino cerrado.
- Hacer avanzar la onda detrás del jugador con velocidad vinculada a la longitud de la ruta.
- Continuar la onda si se detiene, retrocede o abandona el cruce.
- Autoridad del servidor para colisiones y transitabilidad; reutilizar efectos de cliente.
- Restaurar piezas y cancelar tareas antiguas al reiniciar.

**Cierre:** avanzar permite completar un cruce, detenerse/retroceder puede causar caída y un cruce abandonado no suma aristas. Reiniciar restaura todo.

## R06 — Locomoción y persecución de Cerberus

**Depende de:** R02 y R04. **Foco:** enemigo funcional con puentes inicialmente intactos.

Trabajo:

- Adaptar la raíz de la animación existente para mover el modelo sin devolverlo a su posición original.
- Recorrer islas y curvas de puentes a la misma velocidad que el jugador.
- Registrar los cruces del jugador desde el inicio y seguir sus mismos puentes, sentido y orden, incluida la ventaja inicial.
- Detectar captura con una zona coherente con el cuerpo, sin usar adornos como alcance arbitrario.
- Implementar ventaja inicial, inicio y parada de persecución.
- Preparar un salto anunciado por el mismo puente del rastro cuando esté derrumbado; fijar el destino y conservar la gracia al aterrizar. No saltar hacia una conexión alternativa.

**Cierre:** sigue la secuencia real del jugador, recorre las curvas del puente incluso al saltar, captura correctamente y limpia el rastro al reintentar. Implementado en el nivel 1: [[Cerberus seguidor]].

El compañero puede preparar locomoción o pruebas en un módulo aislado, según la asignación de R00. No editar simultáneamente `CerberusAnimator`.

## R07 — Integración de los cinco niveles

**Depende de:** R05 y R06. **Foco:** comprobar que los sistemas conviven.

Trabajo:

- Incorporar derrumbes a la transitabilidad usada por Cerberus.
- Gestionar falta de ruta y soporte mientras el enemigo está sobre un puente.
- Aplicar 12 segundos de ventaja en el nivel 1 tras el balance comprobado. Para los niveles 2–5, conservar 8, 6, 4 y 3 como propuestas pendientes de probar; velocidad igual a la del jugador.
- Integrar los cinco objetivos, resultados, continuación y pantalla de finalización.
- Esperar streaming al cambiar de mapa; habilitar controles solo cuando sea seguro comenzar.
- Resolver simultaneidad de resultado, captura, caída y eventos pendientes sin dobles victorias/derrotas.

**Cierre:** los cinco niveles se pueden completar en secuencia y reiniciar; no se capturan jugadores durante el aterrizaje ni se reutilizan eventos de intentos anteriores.

## R08 — Pruebas, balance y cierre

**Depende de:** R07. **Foco:** estabilizar, sin añadir características.

Trabajo:

- Ejecutar la matriz matemática y física.
- Probar victoria, infracción, captura, lava, bloqueo, reintento y cambio de nivel.
- Revisar saltos, lazos, paralelos, curvas y carga por streaming.
- Medir el balance real del derrumbe, ventaja y salto; ajustar valores configurables.
- Revisar conexiones/eventos y comportamiento de piezas tras varios reinicios.
- Actualizar [[Estado y pendientes]] con pruebas realizadas, resultados y limitaciones.

**Cierre:** recorrido y representación coinciden, no hay errores nuevos del juego en consola, cada objetivo conserva una solución y no se sobrescriben mapas editados.

Usar MCP sin controlar el PC. Si hace falta comprobar sensación de juego o una imagen concreta, pedírselo al usuario; no tomar capturas automáticamente.

## Regla de cierre de cada etapa

Registrar: entrega concreta, objetos modificados, contrato utilizado, comprobación ejecutada, resultado, pendientes y siguiente etapa desbloqueada.

Si cambia un contrato compartido, actualizar primero el acuerdo técnico y avisar al compañero antes de integrar su trabajo. No dar por terminado un bloque únicamente porque compile.

## Qué continuar ahora

1. Nivel 1 entregado: consultar [[Entrega del nivel 1]] y guardar el proyecto en Studio.
2. Compañero: P01 y mejoras acotadas de P02 sobre la base existente y el contrato 1.0.0.
3. Preparar el nivel 2 cuando el usuario lo indique; no dar por completados los cinco mapas.

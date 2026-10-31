<div align="center">

# 🌋 Cursed Bridges

**Un archipiélago infernal para aprender teoría de grafos jugando.**

Roblox Studio · Luau · Juego educativo

</div>

[Diseño del juego](Dise%C3%B1o%20del%20juego.md) · [Mecánicas](Mec%C3%A1nica%20principal%20acordada.md) · [Arquitectura](Arquitectura%20en%20Studio.md) · [Estado del proyecto](Estado%20y%20pendientes.md)

---

## El proyecto

**Cursed Bridges — Puentes Malditos** es un videojuego educativo desarrollado en Roblox. El jugador explora islas flotantes conectadas por puentes antiguos, dentro de un escenario volcánico con una estética inspirada en Hades.

Cada **isla representa un vértice** y cada **puente representa una arista**. Para superar un nivel hay que construir un recorrido que cumpla sus reglas y su objetivo, mientras Cerberus sigue los pasos del jugador.

El propósito es aprender a reconocer y construir distintos recorridos en grafos mediante decisiones dentro del propio escenario.

## Aprender jugando

El diseño contempla cinco niveles, cada uno dedicado a un concepto:

| Nivel | Recorrido | Regla principal |
| :---: | --- | --- |
| 1 | **Sendero** | No repetir puentes. Se pueden repetir islas. |
| 2 | **Trayectoria** | No repetir ninguna isla y, por tanto, tampoco puentes. |
| 3 | **Camino cerrado** | Terminar en la isla inicial; se permiten repeticiones. |
| 4 | **Circuito** | Regresar al inicio utilizando al menos un puente, sin repetir puentes. |
| 5 | **Circuito simple** | Regresar al inicio sin repetir puentes ni otras islas. |

> El tipo de recorrido y el objetivo del nivel se comprueban por separado. No existe una obligación general de utilizar todos los puentes ni de visitar todas las islas.

## Cómo se juega

1. Seleccionar un nivel y leer el recorrido solicitado y sus condiciones.
2. Pulsar **Comenzar** y desplazarse con **WASD**; **Espacio** permite saltar.
3. Elegir las conexiones del grafo y completar los cruces sin incumplir las reglas.
4. Evitar que Cerberus alcance al personaje y que este caiga a la lava.
5. Consultar el resultado y el recorrido realizado; reintentar permite buscar otra estrategia.

La presentación educativa acompaña la preparación y el resultado. Durante la persecución se mantienen visibles el tipo de recorrido y las condiciones del desafío.

## Mecánicas principales

- **Cruces detectados automáticamente:** el servidor registra el recorrido al caminar entre islas.
- **Derrumbe progresivo:** en los desafíos que prohíben repetir aristas, los puentes caen detrás del jugador. En camino cerrado se mantienen reutilizables.
- **Cerberus sigue el recorrido:** utiliza los mismos puentes, en el mismo sentido y orden; cuando están derrumbados, anuncia un salto por ese mismo trayecto.
- **Victoria y derrota con explicación:** se distingue el cumplimiento matemático de las causas físicas, como captura o caída.
- **Reintentos del mismo desafío:** restauración del escenario y reinicio del historial y del guardián.
- **Escenarios editables:** las islas y los puentes permanecen en Workspace para trabajar sobre ellos desde Roblox Studio.

## Estado del desarrollo

| Contenido | Estado actual |
| --- | --- |
| **Nivel 1 · El primer sendero** | Implementado y probado. |
| **Nivel 2 · La ruta sin retorno** | Habilitado para pruebas desde el selector; validación del derrumbe y la restauración en curso. |
| **Niveles 3–5** | Definidos en el diseño; implementación pendiente. |

En el nivel 2 se parte de **A** y se termina en **H**, sin repetir islas. Su escenario contiene **ocho islas y once puentes**.

**Trabajo activo:** cerrar el paso 4 del nivel 2. Hay tres parches de derrumbe y reconstrucción aplicados, todavía pendientes de validación. Después siguen la revisión de presentación educativa y las pruebas completas de transición entre niveles.

El detalle actualizado está en [Estado y pendientes](Estado%20y%20pendientes.md) y en el [Plan de integración del nivel 2](Plan%20de%20integraci%C3%B3n%20del%20nivel%202.md).

## Qué contiene este repositorio

Este repositorio es la **base de conocimiento de Cursed Bridges**. Reúne decisiones de diseño, reglas educativas, arquitectura, contratos de integración, planes de trabajo y respaldos de fuentes Luau con sus registros de comprobación.

| Documento | Para qué consultarlo |
| --- | --- |
| [Diseño del juego](Dise%C3%B1o%20del%20juego.md) | Visión del proyecto y experiencia educativa. |
| [Mecánica principal acordada](Mec%C3%A1nica%20principal%20acordada.md) | Definiciones, objetivos y alcance funcional. |
| [Arquitectura en Studio](Arquitectura%20en%20Studio.md) | Organización del escenario y responsabilidades de los módulos. |
| [Contratos de integración](Contratos%20de%20integraci%C3%B3n.md) | Tipos, eventos e interfaces compartidas. |
| [Hoja de ruta](Hoja%20de%20ruta.md) | Etapas de desarrollo y criterios de cierre. |
| [Estado y pendientes](Estado%20y%20pendientes.md) | Avance real y comprobaciones realizadas. |
| [Trabajo en paralelo](Trabajo%20en%20paralelo.md) | Coordinación entre colaboradores. |
| [Desarrollo](Desarrollo/) | Respaldos, fuentes y evidencias organizados por entrega. |

Las carpetas de **Desarrollo/** incluyen versiones históricas: para conocer el estado vigente, consultar primero los documentos actuales y contrastarlos con el proyecto abierto en Studio.

## Abrir el proyecto y colaborar

1. Abrir el place **Cursed bridges** en Roblox Studio. Su identificador es `74011338627746`.
2. Consultar las reglas acordadas y el estado del trabajo antes de modificar el proyecto.
3. Para probar los niveles disponibles, iniciar **Play** y entrar a **NIVELES** desde el menú inicial.
4. Para desarrollar mediante MCP, conectar el servidor de Studio y comprobar que el place correcto esté abierto.
5. Trabajar una etapa a la vez, comprobar los cambios y actualizar la documentación y los respaldos correspondientes.

El place y sus recursos se gestionan en Roblox Studio. Los documentos y respaldos de scripts de este repositorio **no sustituyen guardar el proyecto y conservar sus mallas**.

La colaboración se realiza por turnos cuando se modifica el mismo Studio. Se conserva la estética existente y el foco educativo del grafo, sin añadir dash ni obstáculos ajenos a esa mecánica.

## Retomar una sesión de desarrollo

[CONTINUAR EN CASA.md](CONTINUAR%20EN%20CASA.md) contiene el punto exacto de interrupción, los últimos cambios y las comprobaciones que debe realizar el siguiente colaborador o chat.

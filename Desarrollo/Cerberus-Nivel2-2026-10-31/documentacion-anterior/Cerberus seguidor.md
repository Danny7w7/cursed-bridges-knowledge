---
tags: [cursed-bridges, nivel-1, cerberus]
actualizado: 2026-10-30
---

# Cerberus seguidor

Volver a [[00 Cursed Bridges]]. Reglas vigentes: [[Mecánica principal acordada]].

## Decisión del usuario

Cerberus sigue el mismo recorrido que hace el jugador: los mismos puentes, en el mismo sentido y orden. El usuario eligió conservar el derrumbe y que Cerberus salte el hueco del mismo puente.

La ventaja inicial y la velocidad de caminata permanecen en 12 segundos y 16 studs/s en el nivel 1. La entrada desde la roca siempre se anuncia hacia A.

## Comportamiento

`MotorPartida` comunica entrada, llegada y regreso a `PersecucionCerberus.registrar(evento)`. Los registros comienzan desde Comenzar, antes de activar la persecución, por lo que Cerberus recuerda los puentes cruzados durante la ventaja.

Cerberus consume esa cola en orden. Dentro de las islas se dirige al acceso del siguiente puente. En puentes intactos sigue sus puntos ordenados y limita el avance al tramo alcanzado por el jugador. En puentes derrumbados espera una llegada real y anuncia un salto por la misma curva del puente, con destino fijado. No busca rutas alternativas ni elige una isla para interceptar.

Si el jugador abandona un cruce y regresa, el registro conserva esa excursión y termina en la isla de salida: no añade una visita al otro extremo. Los puentes reutilizados, paralelos y lazos mantienen su identidad y sentido.

Se conservan aviso de 2 segundos, vuelo de 1,2 segundos y gracia de 1 segundo. La captura sigue desactivada durante aviso, salto y aterrizaje. Reintentar limpia la cola, el salto y los indicadores; ganar o perder detiene al enemigo.

## Código e inspección

- `PersecucionCerberus`: registro, consumo de cruces, trayectos, saltos y captura.
- `MotorPartida`: comunica los eventos del detector desde el inicio del intento.
- `PruebasCerberusSeguidor`: pruebas manuales en copias aisladas, solo en Edición.
- Atributos de `Cerberus.RaizMovimiento`: `RutaEnUso`, `AristasSeguidas` e `IslaActual`, además de los atributos previos de animación. Sirven para inspección; el historial del jugador sigue perteneciendo al motor.
- `NavegacionGrafo` se conserva como utilidad, pero no elige las rutas de persecución.

## Verificación

- 23 comprobaciones específicas: orden durante la ventaja, ingreso inicial por A, salto al siguiente extremo, recorrido inverso, repetición del mismo puente, cruces abiertos y abandonados, reinicio, paralelos, curva de lazo y parada.
- 138 comprobaciones de integración y 18 matemáticas correctas.
- Play: victoria por A → B → C → A → D; Cerberus saltó A → B → C mediante AB y BC, y comenzó a seguir CA antes de terminar la partida.
- Play tras reiniciar: victoria por A → C → B → A → D; Cerberus saltó A → C → B mediante CA y BC, y comenzó a seguir AB.
- Captura real al quedarse en A, aproximadamente 18 segundos después de Comenzar.
- Sin errores nuevos de la mecánica en consola. Persisten los avisos previos de Kohl's Admin.

Las partidas terminaron antes de que Cerberus completara todo el rastro. El seguimiento de secuencias completas, regresos, lazos y paralelos se comprobó mediante simulación; esos casos no equivalen a disponer ya de los mapas físicos 2–5.

Trabajo realizado mediante MCP, sin controlar el PC ni tomar capturas. Guardar el place en Studio para conservar el código.

## Entrega al compañero

`Desarrollo/Cerberus-seguidor-2026-10-30/` contiene las tres fuentes verificadas, huellas SHA-256, resultados, prueba de Play y respaldo previo. Estas fuentes prevalecen sobre sus copias antiguas. Los demás archivos del parche de uniones y la entrega inicial conservan su alcance.

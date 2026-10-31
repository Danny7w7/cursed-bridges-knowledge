---
tags: [cursed-bridges, diseño]
actualizado: 2026-10-30
---

# Diseño del juego

Volver a [[00 Cursed Bridges]].

La especificación completa y vigente está en [[Mecánica principal acordada]]. Este documento resume el propósito educativo.

## Grafo y juego

| Juego | Grafo |
|---|---|
| Isla | Vértice |
| Puente identificado individualmente | Arista no dirigida |
| Cruce completado | Arista añadida al recorrido |
| Secuencia de islas visitadas | Secuencia de vértices del recorrido |
| Puentes que inciden en una isla | Grado del vértice |
| Puente derrumbado | Arista físicamente inutilizable, aunque el jugador no haya terminado de recorrerla |

**Arista recorrida y arista inutilizable son estados distintos.** Si el jugador abandona un cruce, ese puente puede derrumbarse sin formar parte de su recorrido matemático.

## Objetivo educativo

Comprender las restricciones de cinco tipos de recorrido y aplicarlas en un escenario físico:

1. Sendero: sin aristas repetidas.
2. Trayectoria: sin vértices repetidos.
3. Camino cerrado: mismo vértice inicial y final; admite repeticiones.
4. Circuito: cerrado, no vacío y sin aristas repetidas.
5. Circuito simple: circuito sin vértices intermedios repetidos.

Las categorías pueden solaparse. Una solución no se rechaza por cumplir también otra definición.

Cada nivel combina el tipo con una isla inicial, una meta e islas obligatorias. No se exige orden entre las intermedias ni usar todas las aristas del mapa.

## Bucle de juego acordado

Leer el objetivo → Comenzar → caminar y decidir una ruta mientras Cerberus persigue → ganar o perder con explicación → Continuar o Reintentar.

La primera versión será individual, para PC, con cinco mapas en secuencia y progreso limitado a la sesión. No tendrá pistas ni pausa durante el intento.

## Antecedente euleriano

El prototipo original exigía usar todos los puentes una sola vez. Sus utilidades de grados, conexidad, Hierholzer y Fleury siguen siendo reutilizables cuando corresponda, pero **no definen la victoria de los cinco tipos actuales**.

El criterio de cero o dos vértices impares solo describe los recorridos eulerianos bajo sus condiciones; no debe aplicarse como clasificador general de estos desafíos.

La antigua lista de niveles de casita euleriana, K₄ imposible, Königsberg y modo arquitecto queda como referencia para futuras ampliaciones, fuera de esta primera versión.

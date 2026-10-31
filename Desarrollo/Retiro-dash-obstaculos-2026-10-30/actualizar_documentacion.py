import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
RAIZ = BASE.parent.parent
archivos = {}

for nombre in ["Mecánica principal acordada.md", "Estado y pendientes.md", "Trabajo en paralelo.md"]:
    ruta = RAIZ / nombre
    datos = ruta.read_bytes()
    archivos[nombre] = {"sha": hashlib.sha256(datos).hexdigest(), "texto": datos.decode("utf-8").replace("\r\n", "\n"), "original": datos}


def reemplazar(nombre, antes, despues):
    assert archivos[nombre]["texto"].count(antes) == 1, f"Bloque cambiado en {nombre}"
    archivos[nombre]["texto"] = archivos[nombre]["texto"].replace(antes, despues)


reemplazar("Mecánica principal acordada.md", "| Movimiento | Caminata libre y salto normal de Roblox. |",
           "| Movimiento | Caminata libre y salto normal de Roblox. |\n| Dash y obstáculos añadidos | No incluidos: sin embestida, rejillas de fuego, rocas que caen, empujones ni aturdimientos. |")
reemplazar("Estado y pendientes.md", "## Implementado", """## Mecánica centrada en grafos

Se retiraron el dash y los obstáculos añadidos de rejillas de fuego y rocas que caen. También se eliminaron sus eventos, indicador, efectos de golpe y explicación de Shift. Se conservan el fuego decorativo, los escenarios, el recorrido por islas/puentes, el derrumbe y Cerberus.

Pasaron 201 comprobaciones existentes y una victoria real A → B → C → A → D, sin dash, con velocidad 16 y sin regeneración de peligros durante el recorrido. Detalles: [[Mecánica centrada en grafos]].

## Implementado""")
reemplazar("Trabajo en paralelo.md", "## Tareas disponibles para el compañero", """## Límite de la mecánica

Por decisión explícita del usuario, el juego se centra en construir recorridos sobre el grafo. No incorporar dash, rejillas de fuego, rocas que caen, aturdimientos o empujones. El fuego ambiental de braseros, runas y decoración se conserva. Cualquier ampliación de mecánicas requiere una nueva decisión del usuario.

Los componentes Embestida y PeligrosPuentes se retiraron de Studio; sus copias en Desarrollo son respaldo histórico, no módulos para reinstalar. Véase [[Mecánica centrada en grafos]].

## Tareas disponibles para el compañero""")
for cambio in archivos.values():
    cambio["texto"] = cambio["texto"].replace("actualizado: 2026-10-30", "actualizado: 2026-10-31", 1)

nuevo = RAIZ / "Mecánica centrada en grafos.md"
assert not nuevo.exists(), "Ya existe la nota nueva."
nota = """---
tags: [cursed-bridges, mecanica, controles]
actualizado: 2026-10-31
---

# Mecánica centrada en grafos

Volver a [[00 Cursed Bridges]]. Reglas: [[Mecánica principal acordada]].

El usuario pidió retirar el dash y los obstáculos añadidos para mantener el foco educativo en construir recorridos sobre grafos.

## Retirado

- LocalScript Embestida: entrada por Shift/mando, aceleración, siluetas e indicador de recarga.
- Script PeligrosPuentes: rejillas de fuego periódicas, rocas que caen, avisos, empujones, inmunidad por dash y aturdimiento.
- RemoteEvents Embestida y GolpeJugador.
- Texto sobre Shift y obstáculos en la preparación.

Los peligros se generaban durante Play; el generador ya no existe y no se recrearon durante el recorrido de comprobación.

## Conservado

Caminata normal y salto, islas/vértices, puentes/aristas, validación matemática, objetivos, explicaciones educativas, derrumbe y persecución de Cerberus. El fuego de braseros y decoración se conserva. El diseño actual de la interfaz se mantiene.

## Validación

- 18 comprobaciones matemáticas, 138 de integración, 23 de Cerberus y 22 de textos: 201 correctas.
- Sesión nueva sin PlayerScripts.Embestida, HUDEmbestida, GolpeFX ni instrucciones obsoletas.
- Victoria real A → B → C → A → D en aproximadamente 29 segundos, con velocidad normal 16 y sin carpetas Peligros durante el recorrido.
- Studio se desconectó después de la prueba; no se obtuvo la lectura final del escenario tras detener Play.

## Respaldo

Desarrollo/Retiro-dash-obstaculos-2026-10-30 contiene el código anterior, la interfaz corregida y resultados. El retiro comenzó el 30 y se documentó al cierre del 31. Las copias anteriores son históricas y no se ejecutan desde esa carpeta.

Guardar el place en Studio para conservar los cambios.
"""

for nombre, cambio in archivos.items():
    assert hashlib.sha256((RAIZ / nombre).read_bytes()).hexdigest() == cambio["sha"], f"Cambio simultáneo en {nombre}"
for nombre, cambio in archivos.items():
    respaldo = BASE / "respaldo-anterior" / "documentacion" / nombre
    assert not respaldo.exists(), f"Respaldo ocupado: {nombre}"
for nombre, cambio in archivos.items():
    respaldo = BASE / "respaldo-anterior" / "documentacion" / nombre
    respaldo.parent.mkdir(parents=True, exist_ok=True)
    respaldo.write_bytes(cambio["original"])
    (RAIZ / nombre).write_text(cambio["texto"], encoding="utf-8", newline="\n")
nuevo.write_text(nota, encoding="utf-8", newline="\n")

fuentes = {}
for ruta in BASE.rglob("*.luau"):
    fuentes[ruta.relative_to(BASE).as_posix()] = hashlib.sha256(ruta.read_bytes()).hexdigest()
(BASE / "manifest-fuentes.json").write_text(json.dumps({"algoritmo": "SHA-256", "fuentes": fuentes}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("Actualizados cuatro documentos y creado el manifiesto del respaldo.")

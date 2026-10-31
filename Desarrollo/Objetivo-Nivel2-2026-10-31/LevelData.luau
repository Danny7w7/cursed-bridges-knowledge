--!strict
-- El catálogo define objetivos. La topología y posiciones jugables se leen del escenario guardado.
local Contratos = require(script.Parent.ContratosJuego)
export type NodeDef = {id: string, name: string, position: Vector3}
export type EdgeDef = {id: string, from: string, to: string}
export type LevelDef = {
	id: number, name: string, requiresCircuit: boolean, allowedStarts: {string}?,
	nodes: {NodeDef}, edges: {EdgeDef}, solvable: boolean, hint: string,
	objetivo: Contratos.Objetivo?,
}
local LevelData = {}
LevelData.Levels = {} :: {LevelDef}
LevelData.Levels[1] = {
	id = 1, name = "El primer sendero", requiresCircuit = false, allowedStarts = {"A"},
	objetivo = {tipo = "sendero", inicio = "A", final = "D", islasObligatorias = {"B", "C"}},
	-- Coordenadas de diseño para la herramienta de autoría, nunca para recolocar mapas al iniciar.
	nodes = {
		{id = "A", name = "A", position = Vector3.new(0, 0, 20)},
		{id = "B", name = "B", position = Vector3.new(-20, 0, -15)},
		{id = "C", name = "C", position = Vector3.new(20, 0, -15)},
		{id = "D", name = "D", position = Vector3.new(30.3045785, 0, 50.3045785)},
	},
	edges = {
		{id = "AB", from = "A", to = "B"}, {id = "BC", from = "B", to = "C"},
		{id = "CA", from = "C", to = "A"}, {id = "AD", from = "A", to = "D"},
	},
	solvable = true, hint = "",
}
LevelData.Levels[2] = {
	id = 2, name = "La ruta sin retorno", requiresCircuit = false, allowedStarts = {"A"},
	objetivo = {tipo = "trayectoria", inicio = "A", final = "H", islasObligatorias = {}},
	-- Metadatos de autoría del escenario guardado: X/Z en unidades de diseño (escala 3.5).
	-- La geometría jugable se lee de Workspace; este catálogo no reconstruye ni recoloca el mapa.
	nodes = {
		{id = "A", name = "A", position = Vector3.new(2720, 0, 350) / 3.5},
		{id = "B", name = "B", position = Vector3.new(2400, 0, 40) / 3.5},
		{id = "C", name = "C", position = Vector3.new(2480, 0, 520) / 3.5},
		{id = "D", name = "D", position = Vector3.new(2520, 0, 210) / 3.5},
		{id = "E", name = "E", position = Vector3.new(2500, 0, -140) / 3.5},
		{id = "F", name = "F", position = Vector3.new(2310, 0, 330) / 3.5},
		{id = "G", name = "G", position = Vector3.new(2610, 0, 20) / 3.5},
		{id = "H", name = "H", position = Vector3.new(2525, 0, 365) / 3.5},
	},
	edges = {
		{id = "AC", from = "A", to = "C"},
		{id = "AG", from = "A", to = "G"},
		{id = "CF", from = "C", to = "F"},
		{id = "CH", from = "C", to = "H"},
		{id = "FB", from = "F", to = "B"},
		{id = "BE", from = "B", to = "E"},
		{id = "BG", from = "B", to = "G"},
		{id = "BD", from = "B", to = "D"},
		{id = "EG", from = "E", to = "G"},
		{id = "GD", from = "G", to = "D"},
		{id = "DH", from = "D", to = "H"},
	},
	solvable = true, hint = "",
}
return LevelData


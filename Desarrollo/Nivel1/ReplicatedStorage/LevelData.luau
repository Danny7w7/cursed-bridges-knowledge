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
return LevelData

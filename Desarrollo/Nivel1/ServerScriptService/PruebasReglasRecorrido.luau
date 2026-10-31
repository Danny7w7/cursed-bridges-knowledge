--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reglas = require(ReplicatedStorage.ReglasRecorrido)
local Contratos = require(ReplicatedStorage.ContratosJuego)
type Arista = Contratos.Arista
type Objetivo = Contratos.Objetivo

return function()
	local total = 0
	local function comprobar(nombre: string, condicion: boolean)
		assert(condicion, "Falló: " .. nombre)
		total += 1
	end
	local aristas: {Arista} = {
		{id = "AB", from = "A", to = "B"}, {id = "BC", from = "B", to = "C"},
		{id = "CA", from = "C", to = "A"}, {id = "AD", from = "A", to = "D"},
		{id = "DE", from = "D", to = "E"}, {id = "EA", from = "E", to = "A"},
		{id = "AB2", from = "A", to = "B"}, {id = "AA", from = "A", to = "A"},
	}
	local objetivo: Objetivo = {tipo = "sendero", inicio = "A", final = "D", islasObligatorias = {"B", "C"}}
	local valida = {vertices = {"A", "B", "C", "A", "D"}, aristas = {"AB", "BC", "CA", "AD"}}
	comprobar("sendero admite repetir A y gana nivel 1", Reglas.evaluar(objetivo, aristas, valida).victoria)
	comprobar("llegar a D sin B y C no gana", not Reglas.evaluar(objetivo, aristas, {vertices = {"A", "D"}, aristas = {"AD"}}).victoria)
	comprobar("prefijo válido no gana", Reglas.evaluar(objetivo, aristas, {vertices = {"A", "B"}, aristas = {"AB"}}).valido)
	comprobar("misma arista en sentido inverso falla", not Reglas.evaluar(objetivo, aristas, {vertices = {"A", "B", "A"}, aristas = {"AB", "AB"}}).valido)
	comprobar("no confundir paralelos", Reglas.evaluar(objetivo, aristas, {vertices = {"A", "B", "A"}, aristas = {"AB", "AB2"}}).valido)
	local trayectoria: Objetivo = {tipo = "trayectoria", inicio = "A", final = "C", islasObligatorias = {"B"}}
	comprobar("trayectoria válida", Reglas.evaluar(trayectoria, aristas, {vertices = {"A", "B", "C"}, aristas = {"AB", "BC"}}).victoria)
	comprobar("trayectoria rechaza repetir vértice por paralelo", not Reglas.evaluar(trayectoria, aristas, {vertices = {"A", "B", "A"}, aristas = {"AB", "AB2"}}).valido)
	local cerrado: Objetivo = {tipo = "camino_cerrado", inicio = "A", final = "A", islasObligatorias = {"B"}}
	comprobar("camino cerrado permite repetir AB", Reglas.evaluar(cerrado, aristas, {vertices = {"A", "B", "A"}, aristas = {"AB", "AB"}}).victoria)
	comprobar("recorrido vacío no gana", not Reglas.evaluar(cerrado, aristas, {vertices = {"A"}, aristas = {}}).victoria)
	local circuito: Objetivo = {tipo = "circuito", inicio = "A", final = "A", islasObligatorias = {"B", "D"}}
	local ocho = {vertices = {"A", "B", "C", "A", "D", "E", "A"}, aristas = {"AB", "BC", "CA", "AD", "DE", "EA"}}
	comprobar("circuito permite repetir vértice interno", Reglas.evaluar(circuito, aristas, ocho).victoria)
	comprobar("circuito rechaza misma arista", not Reglas.evaluar(circuito, aristas, {vertices = {"A", "B", "A"}, aristas = {"AB", "AB"}}).valido)
	local simple: Objetivo = {tipo = "circuito_simple", inicio = "A", final = "A", islasObligatorias = {}}
	comprobar("circuito simple rechaza el ocho", not Reglas.evaluar(simple, aristas, ocho).valido)
	comprobar("circuito simple de dos paralelos", Reglas.evaluar(simple, aristas, {vertices = {"A", "B", "A"}, aristas = {"AB", "AB2"}}).victoria)
	comprobar("circuito simple de un lazo", Reglas.evaluar(simple, aristas, {vertices = {"A", "A"}, aristas = {"AA"}}).victoria)
	comprobar("salto sin conexión falla", not Reglas.evaluar(objetivo, aristas, {vertices = {"A", "E"}, aristas = {"AB"}}).valido)
	comprobar("historial incompleto falla", not Reglas.evaluar(objetivo, aristas, {vertices = {"A", "B"}, aristas = {}}).valido)
	local antes = {vertices = {"A"}, aristas = {}}
	Reglas.agregar(antes, "AB", "B")
	comprobar("agregar no modifica el historial original", #antes.vertices == 1 and #antes.aristas == 0)
	local salidas = Reglas.salidasLegales(objetivo, aristas, {vertices = {"A"}, aristas = {}}, {AB = true, AB2 = true, AA = true, EA = true, CA = true, AD = true})
	comprobar("bloqueo físico distinto de arista recorrida", #salidas == 0)
	return {correctas = total}
end

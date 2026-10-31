--!strict
local Escenario = require(script.Parent.EscenarioNivel)
type Datos = Escenario.Datos
local Navegacion = {}
export type Camino = {aristas: {string}, longitud: number}

function Navegacion.buscar(datos: Datos, desde: string, hasta: string, bloqueadas: {[string]: boolean}): Camino?
	if desde == hasta then return {aristas = {}, longitud = 0} end
	local distancias: {[string]: number} = {[desde] = 0}
	local cerrados: {[string]: boolean} = {}
	local previos: {[string]: {nodo: string, arista: string}} = {}
	while true do
		local actual: string? = nil
		local menor = math.huge
		for id, valor in distancias do
			if not cerrados[id] and valor < menor then actual, menor = id, valor end
		end
		if not actual then return nil end
		if actual == hasta then break end
		cerrados[actual] = true
		for _, arista in datos.aristas do
			if bloqueadas[arista.id] or arista.from == arista.to then continue end
			if arista.from == actual or arista.to == actual then
				local vecino = if arista.from == actual then arista.to else arista.from
				local ruta = datos.rutas[arista.id]
				local longitud = ruta.longitud
					+ Escenario.distanciaPlana(datos.islas[ruta.from].centro, ruta.puntos[1])
					+ Escenario.distanciaPlana(datos.islas[ruta.to].centro, ruta.puntos[#ruta.puntos])
				local nueva = menor + longitud
				if nueva < (distancias[vecino] or math.huge) then
					distancias[vecino] = nueva
					previos[vecino] = {nodo = actual, arista = arista.id}
				end
			end
		end
	end
	local ids: {string} = {}
	local actual = hasta
	while actual ~= desde do
		local previo = previos[actual]
		if not previo then return nil end
		table.insert(ids, 1, previo.arista)
		actual = previo.nodo
	end
	return {aristas = ids, longitud = distancias[hasta]}
end

return Navegacion

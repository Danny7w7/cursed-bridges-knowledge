--!strict
local Contratos = require(script.Parent.ContratosJuego)
type Objetivo = Contratos.Objetivo
type Arista = Contratos.Arista
type Historial = Contratos.Historial
type Evaluacion = Contratos.Evaluacion

local Reglas = {}
local TIPOS = {
	sendero = true, trayectoria = true, camino_cerrado = true,
	circuito = true, circuito_simple = true,
}

local function errorRecorrido(codigo: string, mensaje: string, paso: number?): Evaluacion
	return {valido = false, victoria = false, faltantes = {}, codigo = codigo, mensaje = mensaje, paso = paso}
end

function Reglas.evaluar(objetivo: Objetivo, aristas: {Arista}, historial: Historial): Evaluacion
	if not TIPOS[objetivo.tipo] then
		return errorRecorrido("objetivo_invalido", "El tipo de recorrido no está configurado.", nil)
	end
	local cerrado = objetivo.tipo == "camino_cerrado" or objetivo.tipo == "circuito" or objetivo.tipo == "circuito_simple"
	if cerrado and objetivo.final ~= objetivo.inicio then
		return errorRecorrido("objetivo_invalido", "Un recorrido cerrado debe terminar en la isla inicial.", nil)
	end
	if #historial.vertices ~= #historial.aristas + 1 or historial.vertices[1] ~= objetivo.inicio then
		return errorRecorrido("historial_invalido", "El recorrido no comienza en la isla indicada o está incompleto.", nil)
	end
	local indice: {[string]: Arista} = {}
	for _, arista in aristas do
		if indice[arista.id] then
			return errorRecorrido("mapa_invalido", "Hay puentes con el mismo identificador: " .. arista.id .. ".", nil)
		end
		indice[arista.id] = arista
	end
	local usadas: {[string]: boolean} = {}
	local visitas: {[string]: number} = {[objetivo.inicio] = 1}
	for paso, id in historial.aristas do
		local arista = indice[id]
		local desde, hasta = historial.vertices[paso], historial.vertices[paso + 1]
		if not arista or not ((arista.from == desde and arista.to == hasta) or (arista.to == desde and arista.from == hasta)) then
			return errorRecorrido("conexion_invalida", "El puente " .. id .. " no conecta las islas de este cruce.", paso)
		end
		if usadas[id] and objetivo.tipo ~= "camino_cerrado" then
			return errorRecorrido("arista_repetida", "Repetiste el puente " .. id .. ". Este recorrido no permite repetir aristas, tampoco en sentido contrario.", paso)
		end
		usadas[id] = true
		visitas[hasta] = (visitas[hasta] or 0) + 1
		if objetivo.tipo == "trayectoria" and visitas[hasta] > 1 then
			return errorRecorrido("vertice_repetido", "Volviste a la isla " .. hasta .. ". Una trayectoria no permite repetir vértices.", paso)
		end
		if objetivo.tipo == "circuito_simple" and visitas[hasta] > 1 then
			local ultimo = paso == #historial.aristas
			if not (ultimo and hasta == objetivo.inicio and visitas[hasta] == 2) then
				return errorRecorrido("vertice_repetido", "Repetiste la isla " .. hasta .. ". Un circuito simple solo repite el inicio al terminar.", paso)
			end
		end
	end
	local faltantes: {string} = {}
	for _, id in objetivo.islasObligatorias do
		if not visitas[id] then table.insert(faltantes, id) end
	end
	local victoria = #historial.aristas > 0 and historial.vertices[#historial.vertices] == objetivo.final and #faltantes == 0
	return {valido = true, victoria = victoria, faltantes = faltantes}
end

function Reglas.agregar(historial: Historial, aristaId: string, llegada: string): Historial
	local siguiente = {vertices = table.clone(historial.vertices), aristas = table.clone(historial.aristas)}
	table.insert(siguiente.vertices, llegada)
	table.insert(siguiente.aristas, aristaId)
	return siguiente
end

function Reglas.salidasLegales(objetivo: Objetivo, aristas: {Arista}, historial: Historial, bloqueadas: {[string]: boolean}): {Arista}
	local salidas: {Arista} = {}
	local actual = historial.vertices[#historial.vertices]
	for _, arista in aristas do
		if not bloqueadas[arista.id] and (arista.from == actual or arista.to == actual) then
			local llegada = if arista.from == actual then arista.to else arista.from
			if Reglas.evaluar(objetivo, aristas, Reglas.agregar(historial, arista.id, llegada)).valido then
				table.insert(salidas, arista)
			end
		end
	end
	return salidas
end

return table.freeze(Reglas)

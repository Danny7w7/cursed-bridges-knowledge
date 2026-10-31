--!strict
local Contratos = require(script.Parent.ContratosJuego)
type Objetivo = Contratos.Objetivo
type Historial = Contratos.Historial
type Evaluacion = Contratos.Evaluacion
local Textos = {}

Textos.fundamentos = "El mapa representa un grafo: las islas son vértices y los puentes son aristas."
Textos.definiciones = table.freeze({
	sendero = "Un sendero es un recorrido sin aristas repetidas. Puede repetir vértices: puedes volver a una isla por un puente que aún no hayas recorrido.",
	trayectoria = "Una trayectoria es un sendero sin vértices repetidos. No puedes repetir islas ni puentes.",
	camino_cerrado = "Un camino cerrado comienza y termina en el mismo vértice. Puede repetir vértices y aristas.",
	circuito = "Un circuito es un camino cerrado con al menos una arista y sin aristas repetidas. Puede repetir otros vértices.",
	circuito_simple = "Un circuito es simple cuando no repite ningún vértice, excepto el primero al terminar. Tampoco repite aristas.",
})
Textos.registro = "Solo se registran cruces completos. Volver a cruzar un puente ya recorrido, incluso en sentido contrario, repite su arista."
Textos.definicionSenderoBreve = "Un sendero no repite aristas; sí puede repetir vértices."
Textos.presentacionSendero = "Construye un sendero sin repetir puentes. Elige tu propio recorrido."
-- Recuento de autoría comprobado con AB, BC, CA y AD, inicio A, visitas B/C y final D.
Textos.tituloNivel1 = "Dos senderos posibles"
Textos.detalleNivel1 = "Hay dos senderos que cumplen el objetivo de este nivel. Elige tu recorrido sin repetir puentes."

function Textos.preparacion(instruccion: string, definicion: string, nivelId: number): string
	local derrumbe = if nivelId == 1 then "Los puentes caerán detrás de ti. " else ""
	return table.concat({
		Textos.fundamentos, definicion, Textos.registro,
		"OBJETIVO\n" .. instruccion,
		"CONTROLES\nMuévete con WASD y salta con Espacio. " .. derrumbe .. "Cerberus comenzará a seguir tu recorrido después de la ventaja inicial.",
	}, "\n\n")
end

function Textos.instruccion(objetivo: Objetivo): string
	local texto = "Sal de " .. objetivo.inicio .. " y termina en " .. objetivo.final .. "."
	if #objetivo.islasObligatorias > 0 then
		texto ..= " Visita " .. table.concat(objetivo.islasObligatorias, " y ") .. " en cualquier orden."
	end
	if objetivo.tipo ~= "camino_cerrado" then texto ..= " No repitas puentes." end
	return texto
end

function Textos.explicarResultado(objetivo: Objetivo, historial: Historial, evaluacion: Evaluacion, codigo: string, mensaje: string): string
	local bloques = {mensaje}
	local repeticiones: {string} = {}
	local vistas: {[string]: boolean} = {}
	local informadas: {[string]: boolean} = {}
	for _, vertice in historial.vertices do
		if vistas[vertice] and not informadas[vertice] then
			table.insert(repeticiones, vertice)
			informadas[vertice] = true
		end
		vistas[vertice] = true
	end
	if not evaluacion.valido then
		if evaluacion.paso then table.insert(bloques, "Primera infracción: cruce " .. evaluacion.paso .. ".") end
		-- El mensaje del validador es la explicación autoritativa de la infracción.
		if evaluacion.mensaje and evaluacion.mensaje ~= mensaje then table.insert(bloques, evaluacion.mensaje) end
	elseif objetivo.tipo == "sendero" and #historial.aristas > 0 then
		local detalle = if codigo == "objetivo_completo" then "Construiste un sendero: no repetiste ninguna arista." else "Los cruces registrados forman un sendero: no repetiste ninguna arista."
		if #repeticiones > 0 then
			detalle ..= " Volviste a " .. table.concat(repeticiones, " y ") .. "; repetir vértices está permitido en un sendero."
		end
		table.insert(bloques, detalle)
	else
		table.insert(bloques, Textos.definiciones[objetivo.tipo])
	end
	if codigo == "objetivo_completo" then
		local visitas = if #objetivo.islasObligatorias > 0 then "Visitaste " .. table.concat(objetivo.islasObligatorias, " y ") .. " y terminaste en " .. objetivo.final .. "." else "Terminaste en " .. objetivo.final .. "."
		table.insert(bloques, "OBJETIVO CUMPLIDO\n" .. visitas)
	elseif evaluacion.valido then
		local pendientes: {string} = {}
		if #evaluacion.faltantes > 0 then table.insert(pendientes, "Faltó visitar " .. table.concat(evaluacion.faltantes, " y ") .. ".") end
		if historial.vertices[#historial.vertices] ~= objetivo.final then table.insert(pendientes, "El final solicitado es " .. objetivo.final .. ".") end
		if #pendientes > 0 then table.insert(bloques, "OBJETIVO PENDIENTE\n" .. table.concat(pendientes, " ")) end
	end
	local vertices = table.concat(historial.vertices, " → ")
	local aristas = if #historial.aristas > 0 then table.concat(historial.aristas, " → ") else "Ninguna; todavía no completaste un cruce"
		table.insert(bloques, "RECORRIDO REGISTRADO\nVértices: " .. vertices .. ".\nAristas: " .. aristas .. ".")
	return table.concat(bloques, "\n\n")
end

Textos.teoria = table.concat({
	"EL MAPA ES UN GRAFO\n" .. Textos.fundamentos,
	"SENDERO\n" .. Textos.definiciones.sendero,
	"TRAYECTORIA\n" .. Textos.definiciones.trayectoria,
	"CAMINO CERRADO\n" .. Textos.definiciones.camino_cerrado,
	"CIRCUITO\n" .. Textos.definiciones.circuito,
	"CIRCUITO SIMPLE\n" .. Textos.definiciones.circuito_simple,
	"REGLA Y OBJETIVO\nLa validez del recorrido y el objetivo del nivel se comprueban por separado. También debes cumplir el inicio, el final y las visitas indicadas. Pedir un sendero no exige, por definición, utilizar todos los puentes.",
	"CRUCES\n" .. Textos.registro,
	"CÓMO JUGAR\nMuévete con WASD y salta con Espacio. En el nivel 1 los puentes caen detrás de ti. Cerberus seguirá tu mismo recorrido después de la ventaja inicial y saltará por los puentes que ya se derrumbaron.",
}, "\n\n")

return table.freeze(Textos)

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Contratos = require(ReplicatedStorage.ContratosJuego)
local Reglas = require(ReplicatedStorage.ReglasRecorrido)
local Textos = require(ReplicatedStorage.TextosEducativos)
local Escenario = require(script.Parent.EscenarioNivel)
local Detector = require(script.Parent.DetectorCruces)
local Derrumbe = require(script.Parent.DerrumbePuentes)
local Persecucion = require(script.Parent.PersecucionCerberus)
type Datos = Escenario.Datos
type Objetivo = Contratos.Objetivo
type Historial = Contratos.Historial
type Fase = Contratos.Fase
type Configuracion = Contratos.Configuracion
type EstadoPresentacion = Contratos.EstadoPresentacion
type Resultado = Contratos.Resultado
export type Acciones = {alEstado: (EstadoPresentacion) -> (), alResultado: (Resultado) -> ()}
local Motor = {}

function Motor.crear(datos: Datos, objetivo: Objetivo, configuracion: Configuracion, acciones: Acciones)
	assert(datos.islas[objetivo.inicio] and datos.islas[objetivo.final], "El objetivo referencia islas inexistentes.")
	for _, id in objetivo.islasObligatorias do assert(datos.islas[id], "Falta la isla obligatoria " .. id) end
	local config = configuracion
	local intentoId = 0
	local fase: Fase = "preparacion"
	local historial: Historial = {vertices = {objetivo.inicio}, aristas = {}}
	local detector = Detector.nuevo(objetivo.inicio)
	local derrumbe = Derrumbe.crear(datos)
	local cerberus = Persecucion.crear(datos, objetivo.inicio)
	local resultado: Resultado? = nil
	local peligroDesde: number? = nil
	local nombres = {
		sendero = "Sendero", trayectoria = "Trayectoria", camino_cerrado = "Camino cerrado",
		circuito = "Circuito", circuito_simple = "Circuito simple",
	}
	local definiciones = Textos.definiciones
	local instruccion = Textos.instruccion(objetivo)

	local function estado(): EstadoPresentacion
		return {
			intentoId = intentoId, levelId = datos.modelo:GetAttribute("LevelId") :: number,
			fase = fase, titulo = nombres[objetivo.tipo], instruccion = instruccion,
			definicion = definiciones[objetivo.tipo], peligroDesde = peligroDesde,
			puedeContinuar = false, resultado = resultado,
		}
	end
	local function publicar()
		datos.modelo:SetAttribute("FaseIntento", fase)
		datos.modelo:SetAttribute("IslaActual", detector.actual)
		datos.modelo:SetAttribute("VerticesRecorridos", table.concat(historial.vertices, " → "))
		datos.modelo:SetAttribute("AristasRecorridas", table.concat(historial.aristas, ", "))
		datos.modelo:SetAttribute("PeligroDesde", peligroDesde)
		acciones.alEstado(estado())
	end
	local function finalizar(victoria: boolean, codigo: string, mensaje: string)
		if fase ~= "activo" then return end
		fase = if victoria then "victoria" else "derrota"
		cerberus.detener()
		local nuevoResultado: Resultado = {
			outcome = if victoria then "victory" else "defeat",
			message = Textos.explicarResultado(objetivo, historial, Reglas.evaluar(objetivo, datos.aristas, historial), codigo, mensaje),
			codigo = codigo, intentoId = intentoId,
			vertices = table.clone(historial.vertices), aristas = table.clone(historial.aristas),
		}
		resultado = nuevoResultado
		publicar()
		acciones.alResultado(nuevoResultado)
	end
	local function sinSalida()
		if detector.cruce then return end
		local salidas = Reglas.salidasLegales(objetivo, datos.aristas, historial, derrumbe.bloqueadas)
		if #salidas == 0 then
			finalizar(false, "sin_salida", "Te quedaste sin un puente legal y transitable.")
		end
	end
	local function reiniciar(nueva: Configuracion)
		config = nueva
		intentoId += 1
		fase, resultado, peligroDesde = "preparacion", nil, nil
		historial = {vertices = {objetivo.inicio}, aristas = {}}
		detector = Detector.nuevo(objetivo.inicio)
		derrumbe.restaurar(intentoId)
		cerberus.restaurar()
		publicar()
	end
	local function comenzar(id: number, ahora: number)
		if id ~= intentoId or fase ~= "preparacion" then return end
		fase, peligroDesde = "activo", ahora + config.ventajaInicial
		publicar()
	end
	local function actualizar(ahora: number, dt: number, posicion: Vector3)
		if fase ~= "activo" then return end
		if posicion.Y <= datos.lavaY + 3 then
			finalizar(false, "lava", "Caíste a la lava. Reintenta desde la isla inicial.")
			return
		end
		local evento = Detector.actualizar(datos, detector, posicion, dt, config.velocidadJugador)
		if evento then
			if evento.tipo == "atajo" then
				finalizar(false, "desplazamiento_invalido", "El desplazamiento no completó un puente válido entre islas.")
				return
			end
			local cruce = evento.cruce
			cerberus.registrar(evento)
			if cruce and evento.tipo == "entrada" and objetivo.tipo ~= "camino_cerrado" then
				derrumbe.iniciar(cruce.ruta.id, cruce.inverso, ahora, config.retardoDerrumbe, config.velocidadJugador, intentoId)
			elseif cruce and evento.tipo == "llegada" then
				historial = Reglas.agregar(historial, cruce.ruta.id, cruce.hasta)
				local evaluacion = Reglas.evaluar(objetivo, datos.aristas, historial)
				if not evaluacion.valido then
					finalizar(false, evaluacion.codigo or "regla", evaluacion.mensaje or "El recorrido incumple una regla.")
					return
				elseif evaluacion.victoria then
					finalizar(true, "objetivo_completo", "¡Nivel " .. tostring(datos.modelo:GetAttribute("LevelId") or 1) .. " completado!")
					return
				end
				publicar()
			end
			if evento.tipo == "llegada" or evento.tipo == "regreso" then
				sinSalida()
				if fase ~= "activo" then return end
			end
		end
		derrumbe.actualizar(ahora)
		if peligroDesde and ahora >= peligroDesde then
			cerberus.activar()
			if cerberus.actualizar(ahora, dt, posicion, detector, derrumbe.bloqueadas, config) then
				finalizar(false, "captura", "Cerberus te alcanzó. Reintenta y elige tus movimientos con anticipación.")
			end
		end
	end
	reiniciar(config)
	return {
		estado = estado, reiniciar = reiniciar, comenzar = comenzar, actualizar = actualizar,
		derrotar = function(codigo: string, mensaje: string) finalizar(false, codigo, mensaje) end,
		historial = function(): Historial return {vertices = table.clone(historial.vertices), aristas = table.clone(historial.aristas)} end,
	}
end
return Motor

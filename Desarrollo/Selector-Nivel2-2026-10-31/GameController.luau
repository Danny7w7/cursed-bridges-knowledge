--!strict
-- El servidor controla la partida; los remotos solo solicitan acciones, nunca declaran cruces.
-- Cada carpeta Workspace.Niveles.NivelN con objetivo en LevelData es un nivel jugable.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Contratos = require(ReplicatedStorage.ContratosJuego)
local LevelData = require(ReplicatedStorage.LevelData)
local Escenario = require(script.Parent.EscenarioNivel)
local Configuracion = require(script.Parent.ConfiguracionJuego)
local Motor = require(script.Parent.MotorPartida)
type EstadoPresentacion = Contratos.EstadoPresentacion
type Resultado = Contratos.Resultado
type Configuracion = Contratos.Configuracion
type Sesion = {
	id: number, nivel: Instance, datos: Escenario.Datos, objetivo: Contratos.Objetivo,
	partida: any, configuracion: Configuracion,
}

local niveles = workspace:WaitForChild("Niveles")
local remotos = ReplicatedStorage:WaitForChild("RemoteEvents")
local comenzar = remotos:WaitForChild("ComenzarIntento") :: RemoteEvent
local reiniciar = remotos:WaitForChild("RestartLevel") :: RemoteEvent
local consultar = remotos:WaitForChild("RequestState") :: RemoteEvent
local seleccionar = remotos:WaitForChild("SeleccionarNivel") :: RemoteEvent
local continuar = remotos:WaitForChild("ContinuarNivel") :: RemoteEvent
local actualizarEstado = remotos:WaitForChild("StateUpdated") :: RemoteEvent
local enviarResultado = remotos:WaitForChild("LevelResult") :: RemoteEvent
local jugador: Player? = nil
local ultimaAccion = 0
local ultimaConsulta: {[Player]: number} = {}
local personajePreparado = false
local conexionMuerte: RBXScriptConnection? = nil
local sesiones: {[number]: Sesion} = {}
local actual: Sesion

local function definicion(id: number): LevelData.LevelDef?
	for _, nivel in LevelData.Levels do
		if nivel.id == id then return nivel end
	end
	return nil
end

local function disponible(id: number): boolean
	local def = definicion(id)
	return def ~= nil and def.objetivo ~= nil and niveles:FindFirstChild("Nivel" .. id) ~= nil
end

local function raizActual(): BasePart?
	local propietario = jugador
	local personaje = propietario and propietario.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	return if raiz and raiz:IsA("BasePart") then raiz else nil
end

local function obtenerSesion(id: number): Sesion
	local existente = sesiones[id]
	if existente then return existente end
	local nivel = niveles:FindFirstChild("Nivel" .. id)
	local def = definicion(id)
	assert(nivel and def and def.objetivo, "El nivel " .. id .. " no está preparado.")
	local datos = Escenario.cargar(nivel)
	local configuracion = Configuracion.leer(nivel)
	local sesion: Sesion
	sesion = {
		id = id, nivel = nivel, datos = datos, objetivo = def.objetivo :: Contratos.Objetivo,
		configuracion = configuracion, partida = nil,
	}
	sesion.partida = Motor.crear(datos, sesion.objetivo, configuracion, {
		alEstado = function(estado: EstadoPresentacion)
			local propietario = jugador
			if not propietario or actual ~= sesion then return end
			estado.puedeContinuar = estado.fase == "victoria" and disponible(id + 1)
			local raiz = raizActual()
			if raiz then raiz.Anchored = estado.fase ~= "activo" end
			actualizarEstado:FireClient(propietario, estado)
		end,
		alResultado = function(resultado: Resultado)
			local propietario = jugador
			if propietario and actual == sesion then enviarResultado:FireClient(propietario, resultado) end
		end,
	})
	local lava = nivel:FindFirstChild("MarDeLava") or workspace:FindFirstChild("MarDeLava")
	if lava and lava:IsA("BasePart") then
		lava.Touched:Connect(function(parte)
			if actual ~= sesion then return end
			local personaje = jugador and jugador.Character
			if personaje and parte:IsDescendantOf(personaje) then
				sesion.partida.derrotar("lava", "Caíste a la lava. Reintenta desde la isla inicial.")
			end
		end)
	end
	Configuracion.iniciar(nivel)
	sesiones[id] = sesion
	return sesion
end

actual = obtenerSesion(1)

local function publicar()
	local propietario = jugador
	if not propietario then return end
	local estado = actual.partida.estado()
	estado.puedeContinuar = estado.fase == "victoria" and disponible(actual.id + 1)
	local raiz = raizActual()
	if raiz then raiz.Anchored = estado.fase ~= "activo" end
	actualizarEstado:FireClient(propietario, estado)
end

local function colocarPersonaje(personaje: Model)
	local raiz = personaje:WaitForChild("HumanoidRootPart", 10)
	local humanoide = personaje:WaitForChild("Humanoid", 10)
	if not (raiz and raiz:IsA("BasePart") and humanoide and humanoide:IsA("Humanoid")) then return end
	if not jugador or jugador.Character ~= personaje then return end
	personajePreparado = false
	raiz.Anchored = true
	local datos, objetivo = actual.datos, actual.objetivo
	local posicion = datos.islas[objetivo.inicio].centro
	-- mira hacia la primera isla obligatoria para que el primer puente quede a la vista
	local siguiente = datos.islas[objetivo.islasObligatorias[1] or objetivo.final]
	local destino = if siguiente then siguiente.centro else posicion + Vector3.new(0, 0, -1)
	personaje:PivotTo(CFrame.lookAt(posicion + Vector3.new(0, 5, 0), Vector3.new(destino.X, posicion.Y + 5, destino.Z)))
	raiz.AssemblyLinearVelocity, raiz.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	humanoide.WalkSpeed = actual.configuracion.velocidadJugador
	personajePreparado = true
	if conexionMuerte then conexionMuerte:Disconnect() end
	conexionMuerte = humanoide.Died:Connect(function()
		if jugador and jugador.Character == personaje then actual.partida.derrotar("caida", "Tu personaje cayó. Reintenta desde " .. actual.objetivo.inicio .. ".") end
	end)
	publicar()
end

local function reiniciarActual()
	actual.configuracion = Configuracion.leer(actual.nivel)
	actual.partida.reiniciar(actual.configuracion)
end

local function recolocar(solicitante: Player)
	local personaje = solicitante.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if personaje and humanoide and humanoide.Health > 0 then
		colocarPersonaje(personaje)
	else
		task.spawn(function() solicitante:LoadCharacterAsync() end)
	end
end

local function cambiarNivel(id: number)
	if actual.id ~= id then
		-- el nivel que se deja queda listo para la próxima visita
		actual.partida.reiniciar(Configuracion.leer(actual.nivel))
		actual = obtenerSesion(id)
	end
	reiniciarActual()
end

local function recibirJugador(nuevo: Player)
	if jugador then return end
	jugador = nuevo
	nuevo.CharacterAdded:Connect(colocarPersonaje)
	if nuevo.Character then task.spawn(colocarPersonaje, nuevo.Character) end
end
Players.PlayerAdded:Connect(recibirJugador)
for _, conectado in Players:GetPlayers() do recibirJugador(conectado) end
Players.PlayerRemoving:Connect(function(sale)
	ultimaConsulta[sale] = nil
	if jugador == sale then
		jugador, personajePreparado = nil, false
		if conexionMuerte then conexionMuerte:Disconnect() conexionMuerte = nil end
		reiniciarActual()
		for _, conectado in Players:GetPlayers() do if conectado ~= sale then recibirJugador(conectado) break end end
	end
end)

local function permitido(): boolean
	local ahora = os.clock()
	if ahora - ultimaAccion < 0.75 then return false end
	ultimaAccion = ahora
	return true
end

comenzar.OnServerEvent:Connect(function(solicitante: Player, intentoId: number)
	if solicitante ~= jugador or not personajePreparado or typeof(intentoId) ~= "number" then return end
	local estado = actual.partida.estado()
	if estado.fase ~= "preparacion" or intentoId ~= estado.intentoId then return end
	local raiz = raizActual()
	if not raiz or Escenario.islaEn(actual.datos, raiz.Position) ~= actual.objetivo.inicio then return end
	local personaje = solicitante.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if humanoide then humanoide.WalkSpeed = actual.configuracion.velocidadJugador end
	actual.partida.comenzar(intentoId, workspace:GetServerTimeNow())
end)

reiniciar.OnServerEvent:Connect(function(solicitante: Player, intentoId: number)
	if solicitante ~= jugador or typeof(intentoId) ~= "number" or intentoId ~= actual.partida.estado().intentoId then return end
	if not permitido() then return end
	reiniciarActual()
	recolocar(solicitante)
end)

seleccionar.OnServerEvent:Connect(function(solicitante: Player, id: number)
	if solicitante ~= jugador or typeof(id) ~= "number" or not disponible(id) then return end
	if not permitido() then return end
	cambiarNivel(id)
	recolocar(solicitante)
end)

continuar.OnServerEvent:Connect(function(solicitante: Player, intentoId: number)
	if solicitante ~= jugador or typeof(intentoId) ~= "number" then return end
	local estado = actual.partida.estado()
	if estado.fase ~= "victoria" or intentoId ~= estado.intentoId or not disponible(actual.id + 1) then return end
	if not permitido() then return end
	cambiarNivel(actual.id + 1)
	recolocar(solicitante)
end)

consultar.OnServerEvent:Connect(function(solicitante: Player)
	local ahora = os.clock()
	if ahora - (ultimaConsulta[solicitante] or -math.huge) < 0.25 then return end
	ultimaConsulta[solicitante] = ahora
	if solicitante == jugador then publicar() end
end)

local acumulado = 0
RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 0.05 then return end
	local paso = acumulado
	acumulado = 0
	local raiz = raizActual()
	if raiz and personajePreparado then actual.partida.actualizar(workspace:GetServerTimeNow(), paso, raiz.Position) end
end)


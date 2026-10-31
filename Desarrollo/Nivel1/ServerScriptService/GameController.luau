--!strict
-- El servidor controla la partida; los remotos solo solicitan acciones, nunca declaran cruces.
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

local niveles = workspace:FindFirstChild("Niveles")
local nivel = (niveles and niveles:FindFirstChild("Nivel1")) or workspace:FindFirstChild("LevelFolder")
assert(nivel, "Falta el nivel 1 editable en Workspace.")
local datos = Escenario.cargar(nivel)
local objetivo = LevelData.Levels[1].objetivo
assert(objetivo, "Falta el objetivo del nivel 1.")
local remotos = ReplicatedStorage:WaitForChild("RemoteEvents")
local comenzar = remotos:WaitForChild("ComenzarIntento") :: RemoteEvent
local reiniciar = remotos:WaitForChild("RestartLevel") :: RemoteEvent
local consultar = remotos:WaitForChild("RequestState") :: RemoteEvent
local actualizarEstado = remotos:WaitForChild("StateUpdated") :: RemoteEvent
local enviarResultado = remotos:WaitForChild("LevelResult") :: RemoteEvent
local jugador: Player? = nil
local ultimaAccion = 0
local ultimaConsulta: {[Player]: number} = {}
local personajePreparado = false
local configuracionIntento = Configuracion.leer(nivel)
local conexionMuerte: RBXScriptConnection? = nil

local function raizActual(): BasePart?
	local propietario = jugador
	local personaje = propietario and propietario.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	return if raiz and raiz:IsA("BasePart") then raiz else nil
end

local function alEstado(estado: EstadoPresentacion)
	local propietario = jugador
	if not propietario then return end
	local raiz = raizActual()
	if raiz then raiz.Anchored = estado.fase ~= "activo" end
	actualizarEstado:FireClient(propietario, estado)
end
local partida = Motor.crear(datos, objetivo, configuracionIntento, {
	alEstado = alEstado,
	alResultado = function(resultado: Resultado)
		local propietario = jugador
		if propietario then enviarResultado:FireClient(propietario, resultado) end
	end,
})
Configuracion.iniciar(nivel)

local function colocarPersonaje(personaje: Model)
	local raiz = personaje:WaitForChild("HumanoidRootPart", 10)
	local humanoide = personaje:WaitForChild("Humanoid", 10)
	if not (raiz and raiz:IsA("BasePart") and humanoide and humanoide:IsA("Humanoid")) then return end
	if not jugador or jugador.Character ~= personaje then return end
	personajePreparado = false
	raiz.Anchored = true
	local posicion = datos.islas[objetivo.inicio].centro
	local destino = datos.islas.B and datos.islas.B.centro or posicion + Vector3.new(0, 0, -1)
	personaje:PivotTo(CFrame.lookAt(posicion + Vector3.new(0, 5, 0), Vector3.new(destino.X, posicion.Y + 5, destino.Z)))
	raiz.AssemblyLinearVelocity, raiz.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	humanoide.WalkSpeed = configuracionIntento.velocidadJugador
	personajePreparado = true
	if conexionMuerte then conexionMuerte:Disconnect() end
	conexionMuerte = humanoide.Died:Connect(function()
		if jugador and jugador.Character == personaje then partida.derrotar("caida", "Tu personaje cayó. Reintenta desde A.") end
	end)
	alEstado(partida.estado())
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
		configuracionIntento = Configuracion.leer(nivel)
		partida.reiniciar(configuracionIntento)
		for _, conectado in Players:GetPlayers() do if conectado ~= sale then recibirJugador(conectado) break end end
	end
end)

comenzar.OnServerEvent:Connect(function(solicitante: Player, intentoId: number)
	if solicitante ~= jugador or not personajePreparado or typeof(intentoId) ~= "number" then return end
	local estado = partida.estado()
	if estado.fase ~= "preparacion" or intentoId ~= estado.intentoId then return end
	local raiz = raizActual()
	if not raiz or Escenario.islaEn(datos, raiz.Position) ~= objetivo.inicio then return end
	local personaje = solicitante.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if humanoide then humanoide.WalkSpeed = configuracionIntento.velocidadJugador end
	partida.comenzar(intentoId, workspace:GetServerTimeNow())
end)

reiniciar.OnServerEvent:Connect(function(solicitante: Player, intentoId: number)
	if solicitante ~= jugador or typeof(intentoId) ~= "number" or intentoId ~= partida.estado().intentoId then return end
	local ahora = os.clock()
	if ahora - ultimaAccion < 0.75 then return end
	ultimaAccion = ahora
	configuracionIntento = Configuracion.leer(nivel)
	partida.reiniciar(configuracionIntento)
	local personaje = solicitante.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if personaje and humanoide and humanoide.Health > 0 then
		colocarPersonaje(personaje)
	else
		task.spawn(function() solicitante:LoadCharacterAsync() end)
	end
end)

consultar.OnServerEvent:Connect(function(solicitante: Player)
	local ahora = os.clock()
	if ahora - (ultimaConsulta[solicitante] or -math.huge) < 0.25 then return end
	ultimaConsulta[solicitante] = ahora
	if solicitante == jugador then alEstado(partida.estado()) end
end)

local acumulado = 0
RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 0.05 then return end
	local paso = acumulado
	acumulado = 0
	local raiz = raizActual()
	if raiz and personajePreparado then partida.actualizar(workspace:GetServerTimeNow(), paso, raiz.Position) end
end)

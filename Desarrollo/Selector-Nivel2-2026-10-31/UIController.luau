--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Contratos = require(ReplicatedStorage:WaitForChild("ContratosJuego"))
local Interfaz = require(ReplicatedStorage:WaitForChild("InterfazIntento"))
type Estado = Contratos.EstadoPresentacion
type Resultado = Contratos.Resultado
local jugador = Players.LocalPlayer
local remotos = ReplicatedStorage:WaitForChild("RemoteEvents")
local comenzar = remotos:WaitForChild("ComenzarIntento") :: RemoteEvent
local reiniciar = remotos:WaitForChild("RestartLevel") :: RemoteEvent
local continuar = remotos:WaitForChild("ContinuarNivel") :: RemoteEvent
local actualizar = remotos:WaitForChild("StateUpdated") :: RemoteEvent
local resultado = remotos:WaitForChild("LevelResult") :: RemoteEvent
local consultar = remotos:WaitForChild("RequestState") :: RemoteEvent
local estado: Estado? = nil
local mapaListo = false
local preparando: string? = nil
local interfaz = Interfaz.crear(jugador:WaitForChild("PlayerGui"), {
	alComenzar = function()
		local actual = estado
		if actual and mapaListo and actual.fase == "preparacion" then comenzar:FireServer(actual.intentoId) end
	end,
	alReintentar = function()
		local actual = estado
		if actual then reiniciar:FireServer(actual.intentoId) end
	end,
	alContinuar = function()
		local actual = estado
		if actual and actual.puedeContinuar then continuar:FireServer(actual.intentoId) end
	end,
})
local function presentar()
	local actual = estado
	if not actual then return end
	local presentacion = table.clone(actual)
	presentacion.mapaListo = mapaListo
	interfaz.actualizar(presentacion)
end
local function recibir(nuevo: Estado)
	if estado and estado.levelId == nuevo.levelId and nuevo.intentoId < estado.intentoId then return end
	if not estado or estado.levelId ~= nuevo.levelId then mapaListo = false end
	estado = nuevo
	presentar()
	local clave = tostring(nuevo.levelId) .. ":" .. tostring(nuevo.intentoId)
	if nuevo.fase == "preparacion" and preparando ~= clave then
		preparando = clave
		mapaListo = false
		presentar()
		task.spawn(function()
			local niveles = workspace:WaitForChild("Niveles", 20)
			local nivel = niveles and niveles:WaitForChild("Nivel" .. nuevo.levelId, 20)
			local islas = nivel and nivel:WaitForChild("Islands", 20)
			local isla = islas and islas:WaitForChild("Island_A", 20)
			local superficie = isla and isla:WaitForChild("Superficie", 20)
			if superficie and superficie:IsA("BasePart") then
				pcall(function() jugador:RequestStreamAroundAsync(superficie.Position, 5) end)
				if estado and estado.levelId == nuevo.levelId and estado.intentoId == nuevo.intentoId then
					mapaListo = true
					presentar()
				end
			end
		end)
	end
end
actualizar.OnClientEvent:Connect(recibir)
resultado.OnClientEvent:Connect(function(nuevo: Resultado)
	if estado and nuevo.intentoId == estado.intentoId then interfaz.mostrarResultado(nuevo) end
end)
consultar:FireServer()
script.Destroying:Connect(function() interfaz.destruir() end)


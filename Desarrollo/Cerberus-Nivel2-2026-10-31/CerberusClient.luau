--!strict
-- CerberusClient: anima localmente a cada Cerberus etiquetado y lo hace reaccionar a la partida

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Animator = require(ReplicatedStorage:WaitForChild("CerberusAnimator"))
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")
local LevelResult = Remotes:WaitForChild("LevelResult") :: RemoteEvent
local StateUpdated = Remotes:WaitForChild("StateUpdated") :: RemoteEvent

local player = Players.LocalPlayer
local active: {[Model]: Animator.Animator} = {}
local nivelActual = 1

local function esDelNivelActual(model: Model): boolean
	local objeto: Instance? = model
	while objeto do
		local id = objeto:GetAttribute("LevelId")
		if typeof(id) == "number" then return id == nivelActual end
		objeto = objeto.Parent
	end
	return false
end

local function countParts(model: Model): number
	local n = 0
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then n += 1 end
	end
	return n
end

local function track(model: Instance)
	if not model:IsA("Model") or active[model] then return end
	local expected = model:GetAttribute("PartCount") :: number?
	local deadline = os.clock() + 10
	while expected and countParts(model) < expected and os.clock() < deadline do
		task.wait(0.1)
	end
	if model.Parent then
		active[model] = Animator.new(model)
	end
end

CollectionService:GetInstanceAddedSignal("Cerberus"):Connect(track)
CollectionService:GetInstanceRemovedSignal("Cerberus"):Connect(function(model)
	active[model :: Model] = nil
end)
for _, model in CollectionService:GetTagged("Cerberus") do
	task.spawn(track, model)
end

RunService.RenderStepped:Connect(function(dt)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local lookAt = root and root.Position
	for model, anim in active do
		anim:step(dt, if esDelNivelActual(model) then lookAt else nil)
	end
end)

LevelResult.OnClientEvent:Connect(function(result)
	for model, anim in active do
		if esDelNivelActual(model) then
			if result.outcome == "defeat" then
				anim:setMood(0)
				anim:roar()
			else
				anim:setMood(1)
			end
		end
	end
end)

-- al reiniciar el nivel el Cerberus vuelve a vigilar
StateUpdated.OnClientEvent:Connect(function(state)
	if typeof(state.levelId) == "number" then nivelActual = state.levelId end
	if state.fase == "preparacion" then
		for _, anim in active do
			anim:setMood(0)
		end
	end
end)


-- la cinemática de entrada pide un rugido marcando la cámara
local camara = workspace.CurrentCamera
camara:GetAttributeChangedSignal("RugidoCerberus"):Connect(function()
	for model, anim in active do
		if esDelNivelActual(model) then anim:roar() end
	end
end)


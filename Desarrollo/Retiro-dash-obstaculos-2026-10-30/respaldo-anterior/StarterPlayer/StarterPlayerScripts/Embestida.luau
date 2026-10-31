--!strict
-- Embestida (dash) estilo Hades con Shift y reacción a los golpes de los obstáculos.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local BridgeFX = require(ReplicatedStorage:WaitForChild("BridgeFX"))
local remotos = ReplicatedStorage:WaitForChild("RemoteEvents")
local embestida = remotos:WaitForChild("Embestida") :: RemoteEvent
local golpe = remotos:WaitForChild("GolpeJugador") :: RemoteEvent
local estadoActualizado = remotos:WaitForChild("StateUpdated") :: RemoteEvent
local jugador = Players.LocalPlayer
local guiJugador = jugador:WaitForChild("PlayerGui")
local camara = workspace.CurrentCamera

local VELOCIDAD = 78
local DURACION = 0.17
local RECARGA = 0.9
local ORO = Color3.fromRGB(255, 205, 110)
local NOCHE = Color3.fromRGB(18, 9, 22)

local fase = "preparacion"
local ultima = -math.huge
local activaHasta = 0
local direccion = Vector3.zero

estadoActualizado.OnClientEvent:Connect(function(estado) fase = estado.fase end)

-- indicador de recarga junto al minimapa
local pantalla = Instance.new("ScreenGui")
pantalla.Name = "HUDEmbestida"
pantalla.ResetOnSpawn = false
pantalla.DisplayOrder = 6
pantalla.Enabled = false
pantalla.Parent = guiJugador
local caja = Instance.new("Frame")
caja.AnchorPoint = Vector2.new(0, 1)
caja.Position = UDim2.new(0, 280, 1, -24)
caja.Size = UDim2.fromOffset(64, 84)
caja.BackgroundTransparency = 1
caja.Parent = pantalla
local escala = Instance.new("UIScale")
escala.Parent = caja
local rombo = Instance.new("Frame")
rombo.AnchorPoint = Vector2.new(0.5, 0.5)
rombo.Position = UDim2.new(0.5, 0, 0, 30)
rombo.Size = UDim2.fromOffset(40, 40)
rombo.Rotation = 45
rombo.BackgroundColor3 = NOCHE
rombo.Parent = caja
local trazo = Instance.new("UIStroke")
trazo.Color = ORO
trazo.Thickness = 2
trazo.Parent = rombo
local carga = Instance.new("Frame")
carga.AnchorPoint = Vector2.new(0.5, 1)
carga.Position = UDim2.fromScale(0.5, 1)
carga.Size = UDim2.fromScale(1, 1)
carga.BackgroundColor3 = ORO
carga.BorderSizePixel = 0
carga.Parent = rombo
local icono = Instance.new("TextLabel")
icono.BackgroundTransparency = 1
icono.Size = UDim2.fromOffset(40, 40)
icono.AnchorPoint = Vector2.new(0.5, 0.5)
icono.Position = UDim2.new(0.5, 0, 0, 30)
icono.Text = "»"
icono.TextSize = 26
icono.FontFace = Font.new(Font.fromEnum(Enum.Font.Bodoni).Family, Enum.FontWeight.Bold)
icono.TextColor3 = NOCHE
icono.ZIndex = 3
icono.Parent = caja
local tecla = Instance.new("TextLabel")
tecla.BackgroundTransparency = 1
tecla.Position = UDim2.fromOffset(0, 58)
tecla.Size = UDim2.new(1, 0, 0, 20)
tecla.Text = "SHIFT"
tecla.TextSize = 14
tecla.FontFace = Font.new(Font.fromEnum(Enum.Font.Bodoni).Family, Enum.FontWeight.Bold)
tecla.TextColor3 = ORO
tecla.Parent = caja
local trazoTecla = Instance.new("UIStroke")
trazoTecla.Color = Color3.new(0, 0, 0)
trazoTecla.Thickness = 1.5
trazoTecla.Parent = tecla

local function sincronizarHUD()
	local hud = guiJugador:FindFirstChild("HUDPartida")
	pantalla.Enabled = hud ~= nil and (hud :: ScreenGui).Enabled
	escala.Scale = math.clamp(camara.ViewportSize.Y / 950, 0.55, 1.3)
	caja.Position = UDim2.new(0, 24 + 252 * escala.Scale, 1, -24)
end

local function raizYHumanoide(): (BasePart?, Humanoid?)
	local personaje = jugador.Character
	if not personaje then return nil, nil end
	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	return if raiz and raiz:IsA("BasePart") then raiz else nil, personaje:FindFirstChildOfClass("Humanoid")
end

-- silueta fantasma dorada que queda atrás
local function fantasma()
	local personaje = jugador.Character
	if not personaje then return end
	for _, p in personaje:GetDescendants() do
		if p:IsA("BasePart") and p.Transparency < 0.9 and p.Name ~= "HumanoidRootPart" then
			local copia = p:Clone()
			copia:ClearAllChildren()
			copia.Anchored, copia.CanCollide, copia.CanQuery, copia.CanTouch, copia.CastShadow = true, false, false, false, false
			copia.Material = Enum.Material.Neon
			copia.Color = Color3.fromRGB(255, 170, 80)
			copia.Transparency = 0.45
			if copia:IsA("MeshPart") then copia.TextureID = "" end
			copia.Parent = workspace
			TweenService:Create(copia, TweenInfo.new(0.35), {Transparency = 1}):Play()
			task.delay(0.4, function() copia:Destroy() end)
		end
	end
end

local function embestir()
	if fase ~= "activo" then return end
	local ahora = os.clock()
	if ahora - ultima < RECARGA then return end
	local raiz, humanoide = raizYHumanoide()
	if not raiz or not humanoide or humanoide.Health <= 0 or raiz.Anchored then return end
	local mover = humanoide.MoveDirection
	direccion = if mover.Magnitude > 0.1 then Vector3.new(mover.X, 0, mover.Z).Unit else Vector3.new(raiz.CFrame.LookVector.X, 0, raiz.CFrame.LookVector.Z).Unit
	ultima = ahora
	activaHasta = ahora + DURACION
	embestida:FireServer()
	camara.FieldOfView += 8
	fantasma()
	task.delay(0.06, fantasma)
	task.delay(0.12, fantasma)
	carga.Size = UDim2.fromScale(1, 0)
end

UserInputService.InputBegan:Connect(function(input, procesado)
	if procesado then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.ButtonB then
		embestir()
	end
end)

RunService.Heartbeat:Connect(function()
	local ahora = os.clock()
	if ahora < activaHasta then
		local raiz = raizYHumanoide()
		if raiz then
			local v = raiz.AssemblyLinearVelocity
			raiz.AssemblyLinearVelocity = direccion * VELOCIDAD + Vector3.new(0, math.max(v.Y, -4), 0)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	sincronizarHUD()
	local listo = math.clamp((os.clock() - ultima) / RECARGA, 0, 1)
	carga.Size = UDim2.fromScale(1, listo)
	trazo.Transparency = if listo >= 1 then 0 else 0.6
end)

-- golpe de un obstáculo: empujón, sacudida y destello rojo
local destello = Instance.new("Frame")
destello.Size = UDim2.fromScale(1, 1)
destello.BackgroundColor3 = Color3.fromRGB(200, 30, 20)
destello.BackgroundTransparency = 1
destello.BorderSizePixel = 0
local capa = Instance.new("ScreenGui")
capa.Name = "GolpeFX"
capa.IgnoreGuiInset = true
capa.ResetOnSpawn = false
capa.DisplayOrder = 3
capa.Parent = guiJugador
destello.Parent = capa
golpe.OnClientEvent:Connect(function(dir: Vector3)
	local raiz = raizYHumanoide()
	if raiz then raiz.AssemblyLinearVelocity = Vector3.new(dir.X, 0, dir.Z) * 24 + Vector3.new(0, 12, 0) end
	BridgeFX.temblor = math.min(1, BridgeFX.temblor + 0.55)
	destello.BackgroundTransparency = 0.55
	TweenService:Create(destello, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
end)


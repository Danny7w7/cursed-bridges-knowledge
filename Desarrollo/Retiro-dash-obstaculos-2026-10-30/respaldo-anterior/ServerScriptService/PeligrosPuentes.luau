--!strict
-- Obstáculos de los puentes: rejillas de fuego con ritmo y rocas que caen delante del jugador.
-- Un golpe empuja y aturde (no derrota): la penalización real es que Cerberus se acerca.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local remotos = ReplicatedStorage:WaitForChild("RemoteEvents")
local golpeRemoto = remotos:WaitForChild("GolpeJugador") :: RemoteEvent
local embestida = remotos:WaitForChild("Embestida") :: RemoteEvent
local niveles = workspace:WaitForChild("Niveles")

local CICLO = 3.4
local AVISO = 1.1
local FUEGO = 0.9
local INMUNE_EMBESTIDA = 0.3
local ATURDIDO = 1.1

type Rejilla = {parte: Part, brasa: Part, fuego: ParticleEmitter, luz: PointLight, ancho: number, desfase: number, puente: Model, tablones: {BasePart}}
type Puente = {modelo: Model, puntos: {Vector3}, ancho: number, tablones: {BasePart}}
local rejillas: {Rejilla} = {}
local puentes: {Puente} = {}
local ultimaEmbestida: {[Player]: number} = {}
local ultimoGolpe: {[Player]: number} = {}
local proximaRoca: {[Player]: number} = {}

local function caido(p: Puente | Rejilla): boolean
	local t = p.tablones[math.ceil(#p.tablones / 2)]
	return t == nil or not t.CanCollide
end

local function prepararPuente(modelo: Model, carpeta: Folder)
	local tablones: {BasePart} = {}
	for _, d in modelo:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("Kind") == "Tablon" then table.insert(tablones, d) end
	end
	if #tablones < 4 then return end
	table.sort(tablones, function(a, b) return (a:GetAttribute("Order") :: number) < (b:GetAttribute("Order") :: number) end)
	local puntos, ancho = {}, math.huge
	for _, t in tablones do
		table.insert(puntos, t.Position + Vector3.new(0, t.Size.Y / 2, 0))
		ancho = math.min(ancho, math.max(t.Size.X, t.Size.Z))
	end
	table.insert(puentes, {modelo = modelo, puntos = puntos, ancho = ancho, tablones = tablones})
	for k, f in {0.36, 0.68} do
		local i = math.clamp(math.floor(f * (#tablones - 1)) + 1, 1, #tablones - 1)
		local a, b = tablones[i], tablones[i + 1]
		local centro = (a.Position + b.Position) / 2
		local eje = Vector3.new(b.Position.X - a.Position.X, 0, b.Position.Z - a.Position.Z)
		eje = if eje.Magnitude > 0.01 then eje.Unit else Vector3.zAxis
		local superficie = math.max(a.Position.Y + a.Size.Y / 2, b.Position.Y + b.Size.Y / 2)
		local marco = CFrame.lookAt(Vector3.new(centro.X, superficie + 0.15, centro.Z), Vector3.new(centro.X, superficie + 0.15, centro.Z) + eje)
		local parte = Instance.new("Part")
		parte.Name = "RejillaFuego"
		parte.Size = Vector3.new(ancho * 0.9, 0.3, 3.4)
		parte.CFrame = marco
		parte.Anchored, parte.CanCollide, parte.CanQuery, parte.CanTouch = true, false, false, false
		parte.Material = Enum.Material.DiamondPlate
		parte.Color = Color3.fromRGB(46, 34, 32)
		parte.Parent = carpeta
		local brasa = Instance.new("Part")
		brasa.Name = "Brasa"
		brasa.Size = Vector3.new(ancho * 0.86, 0.2, 1.4)
		brasa.CFrame = marco + Vector3.new(0, 0.12, 0)
		brasa.Anchored, brasa.CanCollide, brasa.CanQuery, brasa.CanTouch = true, false, false, false
		brasa.Material = Enum.Material.Neon
		brasa.Color = Color3.fromRGB(70, 18, 8)
		brasa.Parent = carpeta
		local fuego = Instance.new("ParticleEmitter")
		fuego.Enabled = false
		fuego.Rate = 220
		fuego.Lifetime = NumberRange.new(0.45, 0.75)
		fuego.Speed = NumberRange.new(20, 30)
		fuego.SpreadAngle = Vector2.new(6, 6)
		fuego.EmissionDirection = Enum.NormalId.Top
		fuego.Shape = Enum.ParticleEmitterShape.Box
		fuego.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.6), NumberSequenceKeypoint.new(0.5, 3.2), NumberSequenceKeypoint.new(1, 0.5)})
		fuego.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.7, 0.3), NumberSequenceKeypoint.new(1, 1)})
		fuego.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 160)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 120, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 20, 10))})
		fuego.LightEmission = 1
		fuego.Drag = 1.5
		fuego.Parent = brasa
		local luz = Instance.new("PointLight")
		luz.Color = Color3.fromRGB(255, 110, 40)
		luz.Range = 22
		luz.Brightness = 0
		luz.Parent = brasa
		table.insert(rejillas, {parte = parte, brasa = brasa, fuego = fuego, luz = luz, ancho = ancho, desfase = (k - 1) * CICLO / 2 + math.random() * 0.4, puente = modelo, tablones = tablones})
	end
end

for _, nivel in niveles:GetChildren() do
	local puentesNivel = nivel:FindFirstChild("Bridges")
	if puentesNivel then
		local carpeta = nivel:FindFirstChild("Peligros") or Instance.new("Folder")
		carpeta.Name = "Peligros"
		carpeta:ClearAllChildren()
		carpeta.Parent = nivel
		for _, m in puentesNivel:GetChildren() do
			if m:IsA("Model") then prepararPuente(m, carpeta) end
		end
	end
end

local function nivelActivo(): Instance?
	for _, nivel in niveles:GetChildren() do
		if nivel:GetAttribute("FaseIntento") == "activo" then return nivel end
	end
	return nil
end

local function golpear(jugador: Player, direccion: Vector3)
	local ahora = os.clock()
	if ahora - (ultimaEmbestida[jugador] or -10) < INMUNE_EMBESTIDA then return end
	if ahora - (ultimoGolpe[jugador] or -10) < ATURDIDO + 0.4 then return end
	ultimoGolpe[jugador] = ahora
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if humanoide then
		local base = humanoide.WalkSpeed
		humanoide.WalkSpeed = math.min(base, 6)
		task.delay(ATURDIDO, function()
			if humanoide.Parent and humanoide.WalkSpeed <= 6 then humanoide.WalkSpeed = math.max(base, 16) end
		end)
	end
	golpeRemoto:FireClient(jugador, direccion)
end

-- roca que cae delante del jugador mientras cruza
local function lanzarRoca(jugador: Player, objetivo: Vector3, nivel: Instance, eje: Vector3)
	local carpeta = nivel:FindFirstChild("Peligros")
	local aviso = Instance.new("Part")
	aviso.Name = "AvisoRoca"
	aviso.Shape = Enum.PartType.Cylinder
	aviso.Size = Vector3.new(0.15, 2, 2)
	aviso.CFrame = CFrame.new(objetivo + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.pi / 2)
	aviso.Anchored, aviso.CanCollide, aviso.CanQuery, aviso.CanTouch = true, false, false, false
	aviso.Material = Enum.Material.Neon
	aviso.Color = Color3.fromRGB(255, 70, 40)
	aviso.Transparency = 0.35
	aviso.Parent = carpeta
	TweenService:Create(aviso, TweenInfo.new(1.1, Enum.EasingStyle.Quad), {Size = Vector3.new(0.15, 11, 11)}):Play()
	local roca = Instance.new("Part")
	roca.Name = "Roca"
	roca.Shape = Enum.PartType.Ball
	roca.Size = Vector3.new(5, 4.4, 5.2)
	roca.Material = Enum.Material.Basalt
	roca.Color = Color3.fromRGB(58, 44, 46)
	roca.CFrame = CFrame.new(objetivo + Vector3.new(0, 70, 0)) * CFrame.Angles(math.random(), math.random(), math.random())
	roca.Anchored, roca.CanCollide, roca.CanQuery, roca.CanTouch = true, false, false, false
	local fuego = Instance.new("Fire")
	fuego.Size = 6
	fuego.Heat = 12
	fuego.Parent = roca
	roca.Parent = carpeta
	task.delay(0.75, function()
		TweenService:Create(roca, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = CFrame.new(objetivo + Vector3.new(0, 2.2, 0))}):Play()
	end)
	task.delay(1.1, function()
		aviso:Destroy()
		local personaje = jugador.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
		if raiz and raiz:IsA("BasePart") then
			local d = Vector3.new(raiz.Position.X - objetivo.X, 0, raiz.Position.Z - objetivo.Z)
			if d.Magnitude < 5.5 and math.abs(raiz.Position.Y - objetivo.Y) < 8 then
				-- el empujón siempre va a lo largo del puente, nunca hacia el borde
				golpear(jugador, if d:Dot(eje) >= 0 then eje else -eje)
			end
		end
		local polvo = Instance.new("ParticleEmitter")
		polvo.Rate = 0
		polvo.Lifetime = NumberRange.new(0.5, 1)
		polvo.Speed = NumberRange.new(10, 20)
		polvo.SpreadAngle = Vector2.new(70, 70)
		polvo.Acceleration = Vector3.new(0, -30, 0)
		polvo.Size = NumberSequence.new(0.6, 0)
		polvo.Color = ColorSequence.new(Color3.fromRGB(255, 180, 90), Color3.fromRGB(120, 40, 20))
		polvo.LightEmission = 0.6
		polvo.Parent = roca
		polvo:Emit(30)
		local sonido = ReplicatedStorage:FindFirstChild("Sonidos") and ReplicatedStorage.Sonidos:FindFirstChild("DerrumbeGrande")
		if sonido then
			local s = (sonido :: Sound):Clone()
			s.Volume *= 0.6
			s.Parent = roca
			s:Play()
		end
		task.wait(0.25)
		TweenService:Create(roca, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = roca.CFrame + Vector3.new(math.random(-8, 8), -90, math.random(-8, 8)), Transparency = 1}):Play()
		task.delay(1.4, function() roca:Destroy() end)
	end)
end

-- ¿en qué puente está la posición? devuelve el puente y la dirección de avance
local function puenteEn(pos: Vector3): (Puente?, Vector3?, number?)
	for _, p in puentes do
		if not caido(p) then
			for i = 1, #p.puntos - 1 do
				local a, b = p.puntos[i], p.puntos[i + 1]
				local seg = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
				local rel = Vector3.new(pos.X - a.X, 0, pos.Z - a.Z)
				local largo = seg.Magnitude
				if largo > 0 then
					local t = rel:Dot(seg) / (largo * largo)
					if t >= 0 and t <= 1 and (rel - seg * t).Magnitude < p.ancho / 2 and math.abs(pos.Y - a.Y) < 10 then
						return p, seg.Unit, i
					end
				end
			end
		end
	end
	return nil
end

embestida.OnServerEvent:Connect(function(jugador: Player)
	local ahora = os.clock()
	if ahora - (ultimaEmbestida[jugador] or -10) < 0.6 then return end
	ultimaEmbestida[jugador] = ahora
end)
Players.PlayerRemoving:Connect(function(j) ultimaEmbestida[j], ultimoGolpe[j], proximaRoca[j] = nil, nil, nil end)

RunService.Heartbeat:Connect(function()
	local nivel = nivelActivo()
	local t = workspace:GetServerTimeNow()
	for _, r in rejillas do
		local activoAqui = nivel ~= nil and r.puente:IsDescendantOf(nivel) and not caido(r)
		local fase = (t + r.desfase) % CICLO
		local avisando = activoAqui and fase < AVISO
		local ardiendo = activoAqui and fase >= AVISO and fase < AVISO + FUEGO
		r.fuego.Enabled = ardiendo
		local pulso = if avisando then 0.5 + 0.5 * math.sin(t * 18) else 0
		r.brasa.Color = if ardiendo then Color3.fromRGB(255, 200, 90) elseif avisando then Color3.fromRGB(110 + 145 * (fase / AVISO), 40 + 60 * pulso, 12) else Color3.fromRGB(70, 18, 8)
		r.luz.Brightness = if ardiendo then 4 elseif avisando then 1.5 * fase / AVISO else 0
		local visible = not caido(r)
		r.parte.Transparency = if visible then 0 else 1
		r.brasa.Transparency = if visible then 0 else 1
		if ardiendo and nivel then
			for _, jugador in Players:GetPlayers() do
				local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
				if raiz and raiz:IsA("BasePart") then
					local rel = r.brasa.CFrame:PointToObjectSpace(raiz.Position)
					if math.abs(rel.X) < r.ancho / 2 and math.abs(rel.Z) < 2.4 and rel.Y > -1 and rel.Y < 9 then
						local sentido = if rel.Z > 0 then r.brasa.CFrame.LookVector * -1 else r.brasa.CFrame.LookVector
						golpear(jugador, -sentido)
					end
				end
			end
		end
	end
	if not nivel then
		table.clear(proximaRoca)
		return
	end
	for _, jugador in Players:GetPlayers() do
		local raiz = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
		if raiz and raiz:IsA("BasePart") then
			local p, eje = puenteEn(raiz.Position)
			if p and eje then
				local cuando = proximaRoca[jugador]
				if not cuando then
					proximaRoca[jugador] = os.clock() + 1.5
				elseif os.clock() >= cuando then
					proximaRoca[jugador] = os.clock() + math.random(26, 38) / 10
					local vel = Vector3.new(raiz.AssemblyLinearVelocity.X, 0, raiz.AssemblyLinearVelocity.Z)
					local avance = if vel.Magnitude > 2 and vel:Dot(eje) < 0 then -eje else eje
					local objetivo = raiz.Position + avance * math.random(9, 15) + Vector3.new(-avance.Z, 0, avance.X) * math.random(-4, 4)
					local _, _, i = puenteEn(objetivo)
					if i then
						lanzarRoca(jugador, Vector3.new(objetivo.X, p.puntos[i].Y, objetivo.Z), nivel, avance)
					end
				end
			else
				proximaRoca[jugador] = nil
			end
		end
	end
end)


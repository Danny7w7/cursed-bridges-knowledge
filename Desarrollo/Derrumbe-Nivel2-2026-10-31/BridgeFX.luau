--!strict
-- Efectos visuales de los puentes en el cliente: aviso, derrumbe con fisica simulada,
-- salpicadura en la lava y reconstruccion dorada al reiniciar el intento.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

export type Mode = "idle" | "available" | "blocked" | "hint"

type Reposo = {cframe: CFrame, transparency: number, color: Color3, collide: boolean}
type Info = {
	model: Model,
	rest: {[BasePart]: Reposo},
	runes: {BasePart},
	flames: {{part: BasePart, light: PointLight?, seed: number}},
	mode: Mode,
	generation: number,
}
-- una pieza en caida: primero tiembla (aviso), luego cae con gravedad y gira
type Caida = {
	info: Info, part: BasePart, inicio: number, origen: CFrame, aviso: number,
	deriva: Vector3, giro: Vector3, salto: number, pesado: boolean, bisagra: Vector3?, eje: Vector3?,
	salpico: boolean,
}
-- una pieza que vuelve a su sitio desde la lava
type Subida = {part: BasePart, inicio: number, duracion: number, desde: CFrame, hasta: CFrame, color: Color3, transparencia: number}

local RUNE_COLORS: {[Mode]: Color3} = {
	idle = Color3.fromRGB(110, 30, 10),
	available = Color3.fromRGB(255, 120, 30),
	blocked = Color3.fromRGB(45, 14, 8),
	hint = Color3.fromRGB(255, 215, 90),
}
local BRASA = Color3.fromRGB(255, 120, 40)
local CARBON = Color3.fromRGB(45, 24, 20)
local ORO = Color3.fromRGB(255, 205, 110)
local GRAVEDAD = 80
local AVISO_TABLON = 0.4
local AVISO_PESADO = 0.9
local GIRO_BISAGRA = 0.85

local BridgeFX = {}
-- intensidad de temblor de camara acumulada; la camara la consume cada frame
BridgeFX.temblor = 0

local infos: {[Model]: Info} = {}
local caidas: {[BasePart]: Caida} = {}
local subidas: {[BasePart]: Subida} = {}
local efectos = Instance.new("Folder")
efectos.Name = "EfectosPuentes"
efectos.Parent = Workspace

local function lavaY(): number
	local lava = Workspace:FindFirstChild("MarDeLava")
	return if lava and lava:IsA("BasePart") then lava.Position.Y + lava.Size.Y / 2 else -52
end

local function sonar(nombre: string, posicion: Vector3, volumen: number?)
	local carpeta = ReplicatedStorage:FindFirstChild("Sonidos")
	local plantilla = carpeta and carpeta:FindFirstChild(nombre)
	if not (plantilla and plantilla:IsA("Sound")) then return end
	local ancla = Instance.new("Attachment")
	ancla.WorldPosition = posicion
	ancla.Parent = Workspace.Terrain
	local s = plantilla:Clone()
	s.Volume = plantilla.Volume * (volumen or 1)
	s.PlaybackSpeed = plantilla.PlaybackSpeed * (0.9 + math.random() * 0.2)
	s.Parent = ancla
	s:Play()
	task.delay(math.max(s.TimeLength, 3) + 0.5, function() ancla:Destroy() end)
end
BridgeFX.sonar = sonar

local function cercania(posicion: Vector3): number
	local camara = Workspace.CurrentCamera
	if not camara then return 0 end
	return math.clamp(1 - (camara.CFrame.Position - posicion).Magnitude / 120, 0, 1)
end

function BridgeFX.get(model: Model): Info
	local existing = infos[model]
	if existing then return existing end
	local info: Info = {model = model, rest = {}, runes = {}, flames = {}, mode = "idle", generation = 0}
	local function registrar(p: BasePart)
		if info.rest[p] then return end
		local marco = p:GetAttribute("MarcoReposo")
		local transparencia = p:GetAttribute("TransparenciaReposo")
		local colision = p:GetAttribute("ColisionReposo")
		info.rest[p] = {
			cframe = if typeof(marco) == "CFrame" then marco else p.CFrame,
			transparency = if typeof(transparencia) == "number" then transparencia else p.Transparency,
			color = p.Color,
			collide = if typeof(colision) == "boolean" then colision else p.CanCollide,
		}
		local kind = p:GetAttribute("Kind")
		if kind == "Runas" then table.insert(info.runes, p)
		elseif kind == "Llama" then table.insert(info.flames, {part = p, light = p:FindFirstChildOfClass("PointLight"), seed = math.random() * 100})
		end
	end
	for _, p in model:GetDescendants() do if p:IsA("BasePart") then registrar(p) end end
	model.DescendantAdded:Connect(function(p) if p:IsA("BasePart") then registrar(p) end end)
	infos[model] = info
	model.Destroying:Connect(function() infos[model] = nil end)
	return info
end

function BridgeFX.setMode(model: Model, mode: Mode)
	local info = BridgeFX.get(model)
	if info.mode == mode then return end
	info.mode = mode
	for _, rune in info.runes do
		TweenService:Create(rune, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {Color = RUNE_COLORS[mode]}):Play()
	end
end

local function emisor(part: BasePart, nombre: string, config: (ParticleEmitter) -> ()): ParticleEmitter
	local existente = part:FindFirstChild(nombre)
	if existente and existente:IsA("ParticleEmitter") then return existente end
	local pe = Instance.new("ParticleEmitter")
	pe.Name = nombre
	pe.Rate = 0
	pe.Parent = part
	config(pe)
	return pe
end

local function chispas(part: BasePart, cantidad: number, color: Color3?)
	local pe = emisor(part, "Chispas", function(pe)
		pe.Lifetime = NumberRange.new(0.5, 1.2)
		pe.Speed = NumberRange.new(6, 16)
		pe.SpreadAngle = Vector2.new(80, 80)
		pe.Acceleration = Vector3.new(0, -30, 0)
		pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0)})
		pe.LightEmission = 1
		pe.Drag = 1
	end)
	local c = color or Color3.fromRGB(255, 190, 80)
	pe.Color = ColorSequence.new(c, Color3.fromRGB(255, 60, 10))
	pe:Emit(cantidad)
end

local function polvo(part: BasePart, cantidad: number)
	emisor(part, "Polvo", function(pe)
		pe.Lifetime = NumberRange.new(0.8, 1.6)
		pe.Speed = NumberRange.new(2, 5)
		pe.SpreadAngle = Vector2.new(180, 180)
		pe.Acceleration = Vector3.new(0, 2, 0)
		pe.Drag = 2
		pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 3.5)})
		pe.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1)})
		pe.Color = ColorSequence.new(Color3.fromRGB(70, 55, 55))
		pe.RotSpeed = NumberRange.new(-40, 40)
	end):Emit(cantidad)
end

-- anillo incandescente + columna de brasas donde la pieza toca la lava
local function salpicar(posicion: Vector3, fuerza: number)
	local y = lavaY()
	local anillo = Instance.new("Part")
	anillo.Name = "Salpicadura"
	anillo.Shape = Enum.PartType.Cylinder
	anillo.Material = Enum.Material.Neon
	anillo.Color = Color3.fromRGB(255, 150, 50)
	anillo.Anchored, anillo.CanCollide, anillo.CanQuery, anillo.CanTouch = true, false, false, false
	anillo.CastShadow = false
	anillo.Size = Vector3.new(0.3, 2, 2)
	anillo.CFrame = CFrame.new(posicion.X, y + 0.2, posicion.Z) * CFrame.Angles(0, 0, math.pi / 2)
	anillo.Parent = efectos
	local radio = 8 + 10 * fuerza
	TweenService:Create(anillo, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {Size = Vector3.new(0.3, radio, radio), Transparency = 1}):Play()
	local luz = Instance.new("PointLight")
	luz.Color = Color3.fromRGB(255, 130, 40)
	luz.Range = 20 + 20 * fuerza
	luz.Brightness = 4
	luz.Parent = anillo
	TweenService:Create(luz, TweenInfo.new(0.7), {Brightness = 0}):Play()
	local pe = Instance.new("ParticleEmitter")
	pe.Rate = 0
	pe.Lifetime = NumberRange.new(0.8, 1.6)
	pe.Speed = NumberRange.new(14, 30 + 20 * fuerza)
	pe.SpreadAngle = Vector2.new(25, 25)
	pe.EmissionDirection = Enum.NormalId.Right
	pe.Acceleration = Vector3.new(0, -45, 0)
	pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0)})
	pe.Color = ColorSequence.new(Color3.fromRGB(255, 220, 120), Color3.fromRGB(255, 70, 10))
	pe.LightEmission = 1
	pe.Parent = anillo
	pe:Emit(math.floor(14 + 30 * fuerza))
	sonar("Salpicadura", posicion, 0.6 + 0.6 * fuerza)
	task.delay(2, function() anillo:Destroy() end)
end

-- El soporte lo retira el servidor; aqui solo se representa la caida, sincronizada con su reloj.
function BridgeFX.representarCaida(model: Model, part: BasePart, inicio: number)
	local info = BridgeFX.get(model)
	local rest = info.rest[part]
	if not rest then return end
	local marco = part:GetAttribute("MarcoReposo")
	if typeof(marco) == "CFrame" then rest.cframe = marco end
	subidas[part] = nil
	part.CanCollide = false
	local pesado = part:GetAttribute("Kind") ~= "Tablon"
	local bisagra = model:GetAttribute("BisagraDerrumbe")
	local direccion = rest.cframe.Position - (if typeof(bisagra) == "Vector3" then bisagra else rest.cframe.Position)
	local eje: Vector3? = nil
	if pesado and typeof(bisagra) == "Vector3" and direccion.Magnitude > 1 then
		eje = Vector3.new(direccion.Z, 0, -direccion.X).Unit
	end
	caidas[part] = {
		info = info, part = part, inicio = inicio, origen = rest.cframe,
		aviso = if pesado then AVISO_PESADO else AVISO_TABLON,
		deriva = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * (if pesado then 2 else 6),
		giro = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * (if pesado then 0.6 else 5),
		salto = if pesado then 0 else 3 + math.random() * 4,
		pesado = pesado,
		bisagra = if eje then bisagra :: Vector3 else nil,
		eje = eje,
		salpico = false,
	}
	local cerca = cercania(rest.cframe.Position)
	if part:GetAttribute("Kind") == "Tablon" or part:GetAttribute("Kind") == "Estructura" then
		chispas(part, if pesado then 40 else 8)
		polvo(part, if pesado then 18 else 3)
		BridgeFX.temblor = math.min(1, BridgeFX.temblor + cerca * (if pesado then 0.9 else 0.12))
		sonar(if pesado then "DerrumbeGrande" else "Crujido", rest.cframe.Position, if pesado then 1 else 0.35)
	end
end

-- reconstruccion: las piezas emergen de la lava en orden, con un destello dorado
function BridgeFX.restore(model: Model, animado: boolean?)
	local info = BridgeFX.get(model)
	info.generation += 1
	info.mode = "idle"
	local ahora = os.clock()
	local orden: {BasePart} = {}
	for part, rest in info.rest do
		local cayendo = caidas[part] ~= nil or part.Transparency > rest.transparency + 0.01 or (part.Position - rest.cframe.Position).Magnitude > 0.05
		caidas[part] = nil
		part.CanCollide = rest.collide
		if animado and cayendo then
			table.insert(orden, part)
		else
			subidas[part] = nil
			part.CFrame, part.Transparency, part.Color = rest.cframe, rest.transparency, rest.color
		end
	end
	local function clave(p: BasePart): number
		local o = p:GetAttribute("Order")
		return if typeof(o) == "number" then o else 1000
	end
	table.sort(orden, function(a, b) return clave(a) < clave(b) end)
	-- Mantener la reconstrucción breve también en puentes con varios tramos.
	local intervalo = math.min(0.035, 1 / math.max(1, #orden))
	for i, part in orden do
		local rest = info.rest[part]
		local pesado = part:GetAttribute("Kind") ~= "Tablon"
		local giro = CFrame.Angles((math.random() - 0.5) * 2, (math.random() - 0.5) * 2, (math.random() - 0.5) * 2)
		subidas[part] = {
			part = part,
			inicio = ahora + (if pesado then 0 else i * intervalo),
			duracion = if pesado then 1.1 else 0.75,
			desde = (rest.cframe - Vector3.new(0, if pesado then 40 else 26, 0)) * (if pesado then CFrame.identity else giro),
			hasta = rest.cframe,
			color = rest.color,
			transparencia = rest.transparency,
		}
		part.Transparency = 1
	end
	if #orden > 0 then sonar("Reconstruir", model:GetPivot().Position, 0.8) end
end

function BridgeFX.isCollapsed(model: Model): boolean
	for part in BridgeFX.get(model).rest do
		if caidas[part] then return true end
	end
	return false
end

local function easeOutBack(x: number): number
	local c1 = 1.70158
	local c3 = c1 + 1
	return 1 + c3 * (x - 1) ^ 3 + c1 * (x - 1) ^ 2
end

-- llamar cada frame: mueve piezas en caida y en reconstruccion, parpadeo de braseros
function BridgeFX.update()
	local ahoraServidor = Workspace:GetServerTimeNow()
	local ahora = os.clock()
	local piezas, marcos = {}, {}
	local fondo = lavaY()

	for part, c in caidas do
		local t = ahoraServidor - c.inicio
		local rest = c.info.rest[part]
		local marco: CFrame
		if t < c.aviso then
			-- aviso: vibra y se pone al rojo antes de soltarse
			local k = math.max(0, t) / c.aviso
			local amplitud = (if c.pesado then 0.25 else 0.12) * k
			marco = c.origen * CFrame.new(
				math.noise(ahora * 30, 1) * amplitud, math.noise(ahora * 30, 2) * amplitud, math.noise(ahora * 30, 3) * amplitud
			) * CFrame.Angles(math.noise(ahora * 25, 4) * amplitud * 0.15, 0, math.noise(ahora * 25, 5) * amplitud * 0.15)
			if not c.pesado then part.Color = rest.color:Lerp(BRASA, k * 0.8) end
			part.Transparency = rest.transparency
		else
			local tf = t - c.aviso
			if c.bisagra and c.eje then
				-- la estructura se descuelga girando sobre el extremo de llegada y luego se suelta
				local giro = math.min(1, tf / 1.1) ^ 2 * GIRO_BISAGRA
				local soltar = math.max(0, tf - 0.9)
				local pivote = CFrame.new(c.bisagra :: Vector3)
				marco = pivote * CFrame.fromAxisAngle(c.eje :: Vector3, giro) * pivote:Inverse() * c.origen
				marco = marco - Vector3.new(0, 0.5 * GRAVEDAD * soltar * soltar, 0)
			else
				local y = c.salto * tf - 0.5 * GRAVEDAD * tf * tf
				marco = CFrame.new(c.origen.Position + c.deriva * tf + Vector3.new(0, y, 0)) * c.origen.Rotation
					* CFrame.Angles(c.giro.X * tf, c.giro.Y * tf, c.giro.Z * tf)
			end
			part.Color = BRASA:Lerp(CARBON, math.min(1, tf * 1.5))
			if not c.salpico and marco.Position.Y < fondo + 2 then
				c.salpico = true
				salpicar(marco.Position, if c.pesado then 1 else 0.25)
			end
			if marco.Position.Y < fondo - 8 then
				part.Transparency = 1
				marco = c.origen - Vector3.new(0, 400, 0)
				caidas[part] = nil
			end
		end
		table.insert(piezas, part)
		table.insert(marcos, marco)
	end

	for part, s in subidas do
		local x = (ahora - s.inicio) / s.duracion
		if x < 0 then continue end
		if x >= 1 then
			subidas[part] = nil
			table.insert(piezas, part)
			table.insert(marcos, s.hasta)
			part.Color, part.Transparency = s.color, s.transparencia
			chispas(part, 6, ORO)
		else
			table.insert(piezas, part)
			table.insert(marcos, s.desde:Lerp(s.hasta, easeOutBack(x)))
			part.Transparency = s.transparencia + (1 - s.transparencia) * math.max(0, 1 - x * 2.5)
			part.Color = ORO:Lerp(s.color, x * x)
		end
	end
	if #piezas > 0 then
		Workspace:BulkMoveTo(piezas, marcos, Enum.BulkMoveMode.FireCFrameChanged)
	end

	for _, info in infos do
		for _, f in info.flames do
			if f.light then f.light.Brightness = 1.6 * (0.7 + 0.6 * math.noise(ahora * 5, f.seed)) end
		end
		if info.mode == "hint" then
			local pulse = 0.5 + 0.5 * math.sin(ahora * 8)
			for _, rune in info.runes do rune.Color = RUNE_COLORS.available:Lerp(RUNE_COLORS.hint, pulse) end
		end
	end
end

return BridgeFX


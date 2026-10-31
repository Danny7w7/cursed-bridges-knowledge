--!strict
-- Efectos visuales de los puentes en el cliente: estados de las runas, derrumbe y restauracion

local TweenService = game:GetService("TweenService")

export type Mode = "idle" | "available" | "blocked" | "hint"

type Info = {
	model: Model,
	planks: {BasePart},
	rails: {BasePart},
	runes: {BasePart},
	eyes: {BasePart},
	flames: {{part: BasePart, light: PointLight?, seed: number}},
	rest: {[BasePart]: {cframe: CFrame, transparency: number, color: Color3, collide: boolean}},
	tweens: {Tween},
	mode: Mode,
	collapsed: boolean,
	generation: number,
}

local RUNE_COLORS: {[Mode]: Color3} = {
	idle = Color3.fromRGB(110, 30, 10),
	available = Color3.fromRGB(255, 120, 30),
	blocked = Color3.fromRGB(45, 14, 8),
	hint = Color3.fromRGB(255, 215, 90),
}
local EYE_ON = Color3.fromRGB(255, 140, 30)
local EYE_DEAD = Color3.fromRGB(25, 10, 8)
local FALL_DEPTH = 90

local BridgeFX = {}
local infos: {[Model]: Info} = {}

local function track(info: Info, tween: Tween)
	table.insert(info.tweens, tween)
	tween:Play()
end

function BridgeFX.get(model: Model): Info
	local existing = infos[model]
	if existing then return existing end

	local info: Info = {
		model = model,
		planks = {},
		rails = {},
		runes = {},
		eyes = {},
		flames = {},
		rest = {},
		tweens = {},
		mode = "idle",
		collapsed = false,
		generation = 0,
	}
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
		if kind == "Tablon" then table.insert(info.planks, p)
		elseif kind == "Barandal" then table.insert(info.rails, p)
		elseif kind == "Runas" then table.insert(info.runes, p)
		elseif kind == "Ojos" then table.insert(info.eyes, p)
		elseif kind == "Llama" then table.insert(info.flames, {part = p, light = p:FindFirstChildOfClass("PointLight"), seed = math.random() * 100})
		end
	end
	for _, p in model:GetDescendants() do if p:IsA("BasePart") then registrar(p) end end
	model.DescendantAdded:Connect(function(p) if p:IsA("BasePart") then registrar(p) end end)
	infos[model] = info
	model.Destroying:Connect(function()
		infos[model] = nil
	end)
	return info
end

function BridgeFX.setMode(model: Model, mode: Mode)
	local info = BridgeFX.get(model)
	if info.collapsed or info.mode == mode then return end
	info.mode = mode
	local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Sine)
	for _, rune in info.runes do
		TweenService:Create(rune, tweenInfo, {
			Color = RUNE_COLORS[mode],
			Transparency = if mode == "blocked" then 0.35 else 0,
		}):Play()
	end
	for _, eye in info.eyes do
		TweenService:Create(eye, tweenInfo, { Color = EYE_ON }):Play()
	end
end

local function emitSparks(part: BasePart, amount: number)
	local emitter = part:FindFirstChild("Chispas") :: ParticleEmitter?
	if not emitter then
		local pe = Instance.new("ParticleEmitter")
		pe.Name = "Chispas"
		pe.Rate = 0
		pe.Lifetime = NumberRange.new(0.6, 1.3)
		pe.Speed = NumberRange.new(4, 10)
		pe.SpreadAngle = Vector2.new(70, 70)
		pe.Acceleration = Vector3.new(0, -12, 0)
		pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
		pe.Color = ColorSequence.new(Color3.fromRGB(255, 200, 90), Color3.fromRGB(255, 50, 10))
		pe.LightEmission = 1
		pe.Parent = part
		emitter = pe
	end
	(emitter :: ParticleEmitter):Emit(amount)
end

local function fall(info: Info, part: BasePart, delay: number, duration: number, spin: number)
	local generation = info.generation
	task.delay(delay, function()
		if info.generation ~= generation then return end
		emitSparks(part, 10)
		part.CanCollide = false
		local rx, rz = (math.random() - 0.5) * spin, (math.random() - 0.5) * spin
		local target = (part.CFrame + Vector3.new(0, -FALL_DEPTH, 0)) * CFrame.Angles(rx, (math.random() - 0.5) * spin, rz)
		track(info, TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { CFrame = target }))
		track(info, TweenService:Create(part, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, duration * 0.5), { Transparency = 1 }))
	end)
end

-- derrumba el puente empezando por el extremo mas cercano a fromPos; instant para clientes que llegan tarde
function BridgeFX.collapse(model: Model, fromPos: Vector3?, instant: boolean?)
	local info = BridgeFX.get(model)
	if info.collapsed then return end
	info.collapsed = true
	info.generation += 1

	if instant then
		for _, list in { info.planks, info.rails, info.runes } do
			for _, p in list do
				p.Transparency = 1
				p.CanCollide = false
			end
		end
		for _, eye in info.eyes do eye.Color = EYE_DEAD end
		return
	end

	local origin = fromPos or model:GetPivot().Position
	local planks = table.clone(info.planks)
	table.sort(planks, function(a, b)
		return (a.Position - origin).Magnitude < (b.Position - origin).Magnitude
	end)

	for _, rune in info.runes do
		rune.Color = Color3.fromRGB(255, 240, 200)
		track(info, TweenService:Create(rune, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Transparency = 1, Color = Color3.fromRGB(255, 60, 10) }))
	end
	for _, eye in info.eyes do
		track(info, TweenService:Create(eye, TweenInfo.new(1.2), { Color = EYE_DEAD }))
	end
	local step = 1.4 / math.max(1, #planks)
	for i, plank in planks do
		fall(info, plank, 0.15 + i * step, 1.6, 0.9)
	end
	for i, rail in info.rails do
		fall(info, rail, 0.6 + i * 0.25, 2.2, 0.4)
	end
end

function BridgeFX.restore(model: Model)
	local info = BridgeFX.get(model)
	info.generation += 1
	for _, tween in info.tweens do tween:Cancel() end
	info.tweens = {}
	for part, rest in info.rest do
		part.CFrame = rest.cframe
		part.Transparency = rest.transparency
		part.Color = rest.color
		part.CanCollide = rest.collide
	end
	info.collapsed = false
	info.mode = "idle"
end

function BridgeFX.isCollapsed(model: Model): boolean
	return BridgeFX.get(model).collapsed
end

-- El soporte lo retira el servidor; este método solo representa una pieza ya caída.
function BridgeFX.representarCaida(model: Model, part: BasePart, inicio: number)
	local info = BridgeFX.get(model)
	local rest = info.rest[part]
	if not rest then return end
	local marco = part:GetAttribute("MarcoReposo")
	if typeof(marco) == "CFrame" then rest.cframe = marco end
	local transparencia = part:GetAttribute("TransparenciaReposo")
	if typeof(transparencia) == "number" then rest.transparency = transparencia end
	local transcurrido = math.max(0, workspace:GetServerTimeNow() - inicio)
	local duracion = 1.6
	local destino = rest.cframe + Vector3.new(0, -FALL_DEPTH, 0)
	part.CanCollide = false
	if transcurrido >= duracion then
		part.CFrame = destino
		part.Transparency = 1
		return
	end
	local proporcion = math.clamp(transcurrido / duracion, 0, 1)
	part.CFrame = rest.cframe:Lerp(destino, proporcion * proporcion)
	part.Transparency = rest.transparency
	emitSparks(part, 8)
	track(info, TweenService:Create(part, TweenInfo.new(duracion - transcurrido, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = destino, Transparency = 1}))
end

-- parpadeo de braseros y pulso de pista; llamar cada frame
function BridgeFX.update()
	local t = os.clock()
	for _, info in infos do
		for _, f in info.flames do
			if f.light then
				f.light.Brightness = 1.6 * (0.7 + 0.6 * math.noise(t * 5, f.seed))
			end
		end
		if info.mode == "hint" and not info.collapsed then
			local pulse = 0.5 + 0.5 * math.sin(t * 8)
			for _, rune in info.runes do
				rune.Color = RUNE_COLORS.available:Lerp(RUNE_COLORS.hint, pulse)
			end
			for _, eye in info.eyes do
				eye.Color = EYE_ON:Lerp(Color3.fromRGB(255, 240, 180), pulse)
			end
		end
	end
end

return BridgeFX


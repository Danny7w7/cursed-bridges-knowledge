--!strict
-- Animacion procedural del Cerberus por cinematica directa sobre las articulaciones (atributo JointPos)

local Workspace = game:GetService("Workspace")

type Joint = {
	name: string,
	parent: Joint?,
	pos: Vector3,
	parts: {BasePart},
	offsets: {CFrame},
	heading: number,
	frame: CFrame,
}

local HEADS = { "C", "I", "D" }
local PHASE = { C = 0, I = 2.1, D = 4.2 }
local LOOK_LIMIT = math.rad(38)
local ROAR_TIME = 1.8

local Animator = {}
Animator.__index = Animator

export type Animator = typeof(setmetatable({} :: {
	model: Model,
	rootCFrame: CFrame,
	scale: number,
	joints: {Joint},
	byName: {[string]: Joint},
	lights: {{light: PointLight, base: number, seed: number}},
	embers: {ParticleEmitter},
	lookYaw: number,
	roarStart: number,
	mood: number,
	moodTarget: number,
	movimiento: number,
	estadoMovimiento: string,
	ultimoReinicio: number?,
}, Animator))

local function headingOf(fromPos: Vector3, toPos: Vector3): number
	local d = toPos - fromPos
	return math.atan2(-d.X, -d.Z)
end

-- pitch/roll en el marco hacia donde apunta el hueso, yaw en el marco del cuerpo
local function headingRotation(heading: number, pitch: number, yaw: number, roll: number): CFrame
	local h = CFrame.Angles(0, heading, 0)
	return CFrame.Angles(0, yaw, 0) * h * CFrame.Angles(pitch, 0, roll) * h:Inverse()
end

function Animator.new(model: Model): Animator
	local self = setmetatable({}, Animator) :: any
	self.model = model
	self.rootCFrame = model:GetPivot()
	self.scale = model:GetScale()
	self.joints = {}
	self.byName = {}
	self.lights = {}
	self.embers = {}
	self.lookYaw = 0
	self.roarStart = -math.huge
	self.mood = 0
	self.moodTarget = 0
	self.movimiento = 0
	self.estadoMovimiento = "reposo"
	self.ultimoReinicio = nil

	local function addJoint(inst: Instance, parent: Joint?): Joint
		local j: Joint = {
			name = if parent then inst.Name else "Torso",
			parent = parent,
			pos = (inst:GetAttribute("JointPos") :: Vector3) * self.scale,
			parts = {},
			offsets = {},
			heading = 0,
			frame = CFrame.identity,
		}
		table.insert(self.joints, j)
		self.byName[j.name] = j
		return j
	end

	local function walk(inst: Instance, owner: Joint)
		for _, child in inst:GetChildren() do
			if child:IsA("Model") then
				if child:GetAttribute("JointPos") then
					walk(child, addJoint(child, owner))
				else
					walk(child, owner)
				end
			elseif child:IsA("BasePart") and not child:GetAttribute("ControlMovimiento") then
				table.insert(owner.parts, child)
			end
		end
	end
	walk(model, addJoint(model, nil))

	for _, j in self.joints do
		local rest = self.rootCFrame * CFrame.new(j.pos)
		for _, p in j.parts do
			table.insert(j.offsets, rest:ToObjectSpace(p.CFrame))
		end
	end
	for _, side in HEADS do
		local neck, head = self.byName["Cuello_" .. side], self.byName["Cabeza_" .. side]
		if neck and head then
			neck.heading = headingOf(neck.pos, head.pos)
			head.heading = neck.heading
			local jaw = self.byName["Mandibula_" .. side]
			if jaw then jaw.heading = neck.heading end
		end
	end

	for _, d in model:GetDescendants() do
		if d:IsA("PointLight") then
			table.insert(self.lights, { light = d, base = d.Brightness, seed = math.random() * 100 })
		elseif d:IsA("ParticleEmitter") then
			table.insert(self.embers, d)
		end
	end
	return self
end

function Animator.roar(self: Animator)
	self.roarStart = os.clock()
	for _, pe in self.embers do
		pe:Emit(25)
	end
end

-- mood: 0 normal, 1 sumiso (el jugador gano)
function Animator.setMood(self: Animator, mood: number)
	self.moodTarget = mood
end

local function roarCurve(t: number): number
	if t < 0 or t > ROAR_TIME then return 0 end
	local x = t / ROAR_TIME
	if x < 0.2 then return x / 0.2 end
	if x < 0.7 then return 1 + math.sin(t * 40) * 0.04 end
	return (1 - x) / 0.3
end

function Animator.pose(self: Animator, j: Joint, t: number, roar: number): CFrame
	local s = self.scale
	local name = j.name
	local mood = self.mood
	local breath = math.sin(t * 1.6)

	if name == "Torso" then
		local marcha = math.sin(t * 12) * 0.045 * s * self.movimiento
		local preparacion = if self.estadoMovimiento == "preparando_salto" then 0.3 * s else 0
		return CFrame.new(0, breath * 0.05 * s - mood * 0.2 * s + marcha - preparacion, 0) * CFrame.Angles(breath * 0.012 - roar * 0.05, 0, 0)
	end
	if name:match("^Pata%a+_[ID]$") then
		-- compensa la respiracion para que las patas no se despeguen del suelo
		local fase = if name == "PataDel_I" or name == "PataTras_D" then 0 else math.pi
		local paso = math.sin(t * 6 + fase) * self.movimiento
		return CFrame.new(0, -breath * 0.05 * s + mood * 0.2 * s + math.max(0, paso) * 0.3 * s, 0) * CFrame.Angles(paso * 0.3, 0, 0)
	end

	local side = name:match("_([CID])$")
	if side and name:match("^Cuello") then
		local ph = PHASE[side]
		local pitch = math.sin(t * 0.9 + ph) * 0.05 + roar * 0.22 - mood * 0.35
		local yaw = math.sin(t * 0.6 + ph) * 0.08 + self.lookYaw * 0.6
		return headingRotation(j.heading, pitch, yaw, math.sin(t * 0.7 + ph) * 0.03)
	elseif side and name:match("^Cabeza") then
		local ph = PHASE[side]
		local pitch = math.sin(t * 1.3 + ph) * 0.06 + roar * 0.18 - mood * 0.25
		return headingRotation(j.heading, pitch, self.lookYaw * 0.4, math.sin(t * 2.6 + ph) * roar * 0.08)
	elseif side and name:match("^Mandibula") then
		local ph = PHASE[side]
		local pant = 0.06 + 0.05 * math.max(0, math.sin(t * 2.4 + ph))
		local open = pant * (1 - mood) + roar * 0.5
		return headingRotation(j.heading, -open, 0, 0)
	end

	local seg = tonumber(name:match("^Cola_(%d)$"))
	if seg then
		local wag = 1 + roar * 2 - mood * 0.7
		return CFrame.Angles(math.sin(t * 1.3 - seg * 0.4) * 0.04 - mood * 0.05, math.sin(t * 2.1 - seg * 0.55) * 0.12 * wag, 0)
	end
	return CFrame.identity
end

function Animator.step(self: Animator, dt: number, lookAt: Vector3?)
	local t = os.clock()
	local raiz = self.model:FindFirstChild("RaizMovimiento")
	if raiz and raiz:IsA("BasePart") then
		local reinicio = raiz:GetAttribute("Reinicio")
		if typeof(reinicio) == "number" and reinicio ~= self.ultimoReinicio then
			self.rootCFrame = raiz.CFrame
			self.ultimoReinicio = reinicio
		else
			self.rootCFrame = self.rootCFrame:Lerp(raiz.CFrame, 1 - math.exp(-dt * 16))
		end
		local estado = raiz:GetAttribute("EstadoMovimiento")
		self.estadoMovimiento = if typeof(estado) == "string" then estado else "reposo"
		local objetivo = if self.estadoMovimiento == "caminando" then 1 else 0
		self.movimiento += (objetivo - self.movimiento) * math.min(1, dt * 8)
	end
	local roar = roarCurve(t - self.roarStart)
	self.mood += (self.moodTarget - self.mood) * math.min(1, dt * 2)

	local targetYaw = 0
	if lookAt then
		local rel = self.rootCFrame:PointToObjectSpace(lookAt)
		targetYaw = math.clamp(math.atan2(-rel.X, -rel.Z), -LOOK_LIMIT, LOOK_LIMIT)
	end
	self.lookYaw += (targetYaw - self.lookYaw) * math.min(1, dt * 2.5)

	local parts, cframes = {}, {}
	for _, j in self.joints do
		local pose = self:pose(j, t, roar)
		if j.parent then
			j.frame = j.parent.frame * CFrame.new(j.pos - j.parent.pos) * pose
		else
			j.frame = CFrame.new(j.pos) * pose
		end
		local world = self.rootCFrame * j.frame
		for i, p in j.parts do
			table.insert(parts, p)
			table.insert(cframes, world * j.offsets[i])
		end
	end
	Workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)

	for _, l in self.lights do
		local flicker = 0.75 + 0.5 * math.noise(t * 6, l.seed)
		l.light.Brightness = l.base * (flicker + roar * 1.5)
	end
end

return Animator


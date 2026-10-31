--!strict
-- GeneradorNivel: construye un escenario editable solo cuando no existe en Workspace

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local LevelData = require(ReplicatedStorage:WaitForChild("LevelData"))

-- LevelData usa unidades de diseno; el mundo se escala para que quepa el Cerberus en islas y puentes
local LAYOUT_SCALE = 3.5
-- la isla se escala para que la puerta de cada muelle deje pasar el cuerpo del Cerberus
local ISLAND_SCALE = 1.8
local ISLAND_HEIGHT = 6
local BASE_Y = 12
-- los pilares del puente quedan esta distancia mas alla de la punta del muelle
local PIER_GAP = 3
local DECK_LIFT = 0.5
local LOOP_SCALE = 1.1
local GUARDIAN_SCALE = 1.2
local GUARDIAN_DISTANCE = 70
local GUARDIAN_ROCK_SCALE = 2

local islandTemplate = ServerStorage:WaitForChild("Isla") :: Model
local FLOOR_RADIUS = (islandTemplate:GetAttribute("FloorRadius") :: number) * ISLAND_SCALE
local PIER_REACH = (islandTemplate:GetAttribute("PierTipRadius") :: number) * ISLAND_SCALE + PIER_GAP
local PIER_LOCAL: {Vector3} = {}
for i = 1, 4 do
	table.insert(PIER_LOCAL, islandTemplate:GetAttribute("Pier" .. i) :: Vector3)
end

type IslandPlan = {
	pos: Vector3,
	rotation: number,
	pierFor: {[string]: Vector3}, -- id de la isla vecina (o "lazo") -> direccion del muelle en el mundo
}

local function getLevel(levelId: number): LevelData.LevelDef
	for _, lvl in LevelData.Levels do
		if lvl.id == levelId then
			return lvl
		end
	end
	error("Nivel no encontrado: " .. tostring(levelId))
end

local function buildIsland(folder: Folder, node: LevelData.NodeDef, plan: IslandPlan)
	local island = Instance.new("Model")
	island.Name = "Island_" .. node.id
	island:SetAttribute("NodeId", node.id)
	island.ModelStreamingMode = Enum.ModelStreamingMode.Atomic

	-- cilindro invisible: superficie caminable plana y objetivo de clic; el modelo visual va dentro
	local part = Instance.new("Part")
	part.Name = "Superficie"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(ISLAND_HEIGHT, FLOOR_RADIUS * 2, FLOOR_RADIUS * 2)
	part.CFrame = CFrame.new(node.position - Vector3.new(0, ISLAND_HEIGHT / 2, 0)) * CFrame.Angles(0, 0, math.rad(90))
	part.Anchored = true
	part.Transparency = 1
	part.Parent = island

	local visual = islandTemplate:Clone()
	visual.Name = "Visual"
	visual:ScaleTo(ISLAND_SCALE)
	visual:PivotTo(CFrame.new(node.position) * CFrame.Angles(0, plan.rotation, 0))
	visual.Parent = part

	-- la runa central (piezas con atributo Sello) muestra la paridad; esta luz la acompana
	local sealLight = Instance.new("Part")
	sealLight.Name = "SelloLuz"
	sealLight.Size = Vector3.new(1, 1, 1)
	sealLight.CFrame = CFrame.new(node.position + Vector3.new(0, 3, 0))
	sealLight.Anchored = true
	sealLight.CanCollide = false
	sealLight.CanQuery = false
	sealLight.Transparency = 1
	sealLight.Parent = part

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(60, 220, 190)
	light.Range = 22
	light.Brightness = 1.2
	light.Parent = sealLight

	local label = Instance.new("BillboardGui")
	label.Name = "GradeLabel"
	label.Size = UDim2.fromOffset(160, 64)
	label.StudsOffset = Vector3.new(0, 16, 0)
	label.AlwaysOnTop = true
	label.Parent = part

	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.FredokaOne
	text.TextScaled = true
	text.Text = node.name .. "\n(0)"
	text.TextColor3 = Color3.fromRGB(255, 140, 60)
	text.TextStrokeTransparency = 0
	text.Parent = label

	local marker = Instance.new("ClickDetector")
	marker.MaxActivationDistance = 400
	marker.Parent = part

	part:SetAttribute("NodeId", node.id)
	island.PrimaryPart = part
	island.Parent = folder

	return island
end

local function flat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

-- asigna cada direccion a un muelle distinto minimizando el desvio total (n <= 4, busqueda completa)
local function bestAssignment(dirs: {Vector3}, piers: {Vector3}): (number, {number})
	local bestCost, best = math.huge, {}
	local used, current = {}, {}
	local function search(i: number, cost: number)
		if cost >= bestCost then return end
		if i > #dirs then
			bestCost, best = cost, table.clone(current)
			return
		end
		for p = 1, #piers do
			if not used[p] or #dirs > #piers then
				used[p] = true
				current[i] = p
				search(i + 1, cost + (1 - dirs[i]:Dot(piers[p])))
				used[p] = false
			end
		end
	end
	search(1, 0)
	return bestCost, best
end

-- gira cada isla para que sus 4 muelles apunten lo mejor posible a sus vecinas
local function planIslands(level: LevelData.LevelDef, nodePositions: {[string]: Vector3}): {[string]: IslandPlan}
	local center, count = Vector3.zero, 0
	for _, p in nodePositions do
		center += p
		count += 1
	end
	center /= count

	local plans: {[string]: IslandPlan} = {}
	for _, node in level.nodes do
		local pos = nodePositions[node.id]
		local targets, dirs = {}, {}
		for _, edge in level.edges do
			local other = if edge.from == node.id then edge.to elseif edge.to == node.id then edge.from else nil
			if other then
				local key = if other == node.id then "lazo" else other
				if not table.find(targets, key) then
					local d = if key == "lazo" then flat(pos - center) else flat(nodePositions[other] - pos)
					if d.Magnitude < 1e-3 then d = Vector3.zAxis end
					table.insert(targets, key)
					table.insert(dirs, d.Unit)
				end
			end
		end

		local bestCost, bestRot, bestMap = math.huge, 0, {}
		for deg = 0, 89 do
			local rot = CFrame.Angles(0, math.rad(deg), 0)
			local piers = {}
			for i, p in PIER_LOCAL do piers[i] = rot:VectorToWorldSpace(p) end
			local cost, map = bestAssignment(dirs, piers)
			if cost < bestCost then
				bestCost, bestRot, bestMap = cost, math.rad(deg), map
			end
		end

		local rot = CFrame.Angles(0, bestRot, 0)
		local pierFor = {}
		for i, key in targets do
			pierFor[key] = rot:VectorToWorldSpace(PIER_LOCAL[bestMap[i]])
		end
		plans[node.id] = { pos = pos, rotation = bestRot, pierFor = pierFor }
	end
	return plans
end

local function pierTip(plan: IslandPlan, key: string): Vector3
	local tip = plan.pos + plan.pierFor[key] * PIER_REACH
	return Vector3.new(tip.X, BASE_Y + DECK_LIFT, tip.Z)
end

-- la plantilla tiene el pivote en el extremo A a la altura de la losa, mirando al extremo B
local function placeSpan(template: Model, a: Vector3, b: Vector3): Model
	local model = template:Clone()
	model:ScaleTo((b - a).Magnitude / (template:GetAttribute("Span") :: number))
	model:PivotTo(CFrame.lookAt(a, b))
	return model
end

local function placeLoop(template: Model, plan: IslandPlan): Model
	local a = pierTip(plan, "lazo")
	local model = template:Clone()
	model:ScaleTo(LOOP_SCALE)
	model:PivotTo(CFrame.lookAt(a, a + plan.pierFor.lazo))
	return model
end

-- cada arista termina en su propio Model "Bridge_<id>" con sus piezas marcadas
local function finishEdge(source: Model, edgeIndex: string, edge: LevelData.EdgeDef, folder: Folder)
	local model = Instance.new("Model")
	model.Name = "Bridge_" .. edge.id
	model:SetAttribute("EdgeId", edge.id)
	model:SetAttribute("From", edge.from)
	model:SetAttribute("To", edge.to)
	for _, p in source:GetDescendants() do
		if p:IsA("MeshPart") and p:GetAttribute("Edge") == edgeIndex then
			p:SetAttribute("EdgeId", edge.id)
			if p:GetAttribute("Kind") == "Tablon" then
				local click = Instance.new("ClickDetector")
				click.MaxActivationDistance = 400
				click.Parent = p
			end
			p.Parent = model
		end
	end
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	model.Parent = folder
end

local function buildBridges(folder: Folder, level: LevelData.LevelDef, plans: {[string]: IslandPlan})
	local recto = ServerStorage:WaitForChild("PuenteRecto") :: Model
	local paralelas = ServerStorage:WaitForChild("PuenteParalelas") :: Model
	local lazo = ServerStorage:WaitForChild("PuenteLazo") :: Model

	local byPair: {[string]: {LevelData.EdgeDef}} = {}
	local order = {}
	for _, edge in level.edges do
		local key = if edge.from < edge.to then edge.from .. "|" .. edge.to else edge.to .. "|" .. edge.from
		if not byPair[key] then
			byPair[key] = {}
			table.insert(order, key)
		end
		table.insert(byPair[key], edge)
	end

	for _, key in order do
		local edges = byPair[key]
		local first = edges[1]
		if first.from == first.to then
			for _, edge in edges do
				local model = placeLoop(lazo, plans[first.from])
				finishEdge(model, "1", edge, folder)
				model:Destroy()
			end
			continue
		end
		local a = pierTip(plans[first.from], first.to)
		local b = pierTip(plans[first.to], first.from)
		if #edges >= 2 then
			local model = placeSpan(paralelas, a, b)
			finishEdge(model, "1", edges[1], folder)
			finishEdge(model, "2", edges[2], folder)
			model:Destroy()
			for i = 3, #edges do
				warn("Mas de 2 aristas entre " .. key .. "; la arista " .. edges[i].id .. " no tiene modelo")
			end
		else
			local model = placeSpan(recto, a, b)
			finishEdge(model, "1", first, folder)
			model:Destroy()
		end
	end
end

-- el Cerberus vigila el archipielago desde su propia roca, mirando al centro del nivel
local function spawnGuardian(folder: Folder, nodePositions: {[string]: Vector3})
	local template = ServerStorage:FindFirstChild("Cerberus") :: Model?
	if not template then return end

	local center, count = Vector3.zero, 0
	for _, p in nodePositions do
		center += p
		count += 1
	end
	center /= count
	local radius = 0
	for _, p in nodePositions do
		radius = math.max(radius, (p - center).Magnitude)
	end
	local pos = center - Vector3.new(0, 0, radius + FLOOR_RADIUS + GUARDIAN_DISTANCE)

	local rock = islandTemplate:Clone()
	rock.Name = "GuardianRock"
	rock:ScaleTo(GUARDIAN_ROCK_SCALE)
	rock:PivotTo(CFrame.lookAt(pos, Vector3.new(center.X, pos.Y, center.Z)))
	rock.Parent = folder
	task.wait()

	local rim = Instance.new("Part")
	rim.Name = "GuardianGlow"
	rim.Size = Vector3.new(1, 1, 1)
	rim.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
	rim.Anchored = true
	rim.CanCollide = false
	rim.CanQuery = false
	rim.Transparency = 1
	rim.Parent = folder

	-- resplandor de brasas desde abajo para recortar la silueta del Cerberus
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(255, 110, 50)
	glow.Range = 45
	glow.Brightness = 1.6
	glow.Parent = rim

	local cerberus = template:Clone()
	cerberus:ScaleTo(GUARDIAN_SCALE)
	cerberus:PivotTo(CFrame.lookAt(pos, Vector3.new(center.X, pos.Y, center.Z)))
	cerberus.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	local partCount = 0
	for _, d in cerberus:GetDescendants() do
		if d:IsA("BasePart") then partCount += 1 end
	end
	cerberus:SetAttribute("PartCount", partCount)
	cerberus:AddTag("Cerberus")
	cerberus.Parent = folder
end

local function buildLevel(levelId: number)
	assert(not Workspace:FindFirstChild("LevelFolder"), "El escenario ya existe; no se reemplazan las ediciones manuales.")
	local level = getLevel(levelId)

	local folder = Instance.new("Folder")
	folder.Name = "LevelFolder"
	folder:SetAttribute("LevelId", levelId)
	folder.Parent = Workspace

	local islandsFolder = Instance.new("Folder")
	islandsFolder.Name = "Islands"
	islandsFolder.Parent = folder

	local bridgesFolder = Instance.new("Folder")
	bridgesFolder.Name = "Bridges"
	bridgesFolder.Parent = folder

	local nodePositions: {[string]: Vector3} = {}
	for _, node in level.nodes do
		nodePositions[node.id] = node.position * LAYOUT_SCALE + Vector3.new(0, BASE_Y, 0)
	end
	local plans = planIslands(level, nodePositions)
	for _, node in level.nodes do
		buildIsland(islandsFolder, { id = node.id, name = node.name, position = nodePositions[node.id] }, plans[node.id])
		task.wait()
	end

	buildBridges(bridgesFolder, level, plans)

	local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
	local firstIsland = nodePositions[level.nodes[1].id]
	if spawn and firstIsland then
		spawn.CFrame = CFrame.new(firstIsland + Vector3.new(0, spawn.Size.Y / 2, 0))
		-- el jugador pisa la isla; el spawn solo marca el punto de aparicion
		spawn.Transparency = 1
		spawn.CanCollide = false
		for _, d in spawn:GetChildren() do
			if d:IsA("Decal") then d.Transparency = 1 end
		end
	end

	spawnGuardian(folder, nodePositions)

	return folder
end

return { crear = buildLevel }

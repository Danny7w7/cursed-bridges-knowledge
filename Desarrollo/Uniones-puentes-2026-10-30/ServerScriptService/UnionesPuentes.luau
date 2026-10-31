--!strict
-- Herramienta de autoría: hornea accesos visibles en Edición; no reconstruye el mapa al jugar.
local Uniones = {}
type Plan = {isla: Model, nombre: string, puenteId: string, extremo: string, marco: CFrame, tamano: Vector3, color: Color3, material: Enum.Material}
local SOLAPE_INTERIOR = 1
local SOLAPE_TABLON = 1.25
local MARGEN_LATERAL = 0.25
local ESPESOR = 1.5

local function plano(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

local function planificar(nivel: Instance): {Plan}
	local islasFolder, puentesFolder = nivel:FindFirstChild("Islands"), nivel:FindFirstChild("Bridges")
	assert(islasFolder and puentesFolder, "El nivel necesita Islands y Bridges.")
	local islas: {[string]: Model} = {}
	for _, isla in islasFolder:GetChildren() do
		assert(isla:IsA("Model") and isla.PrimaryPart, "Una isla no tiene superficie principal.")
		local id = isla:GetAttribute("NodeId")
		assert(typeof(id) == "string" and not islas[id], "NodeId ausente o duplicado.")
		islas[id] = isla
	end
	local planes: {Plan} = {}
	for _, puente in puentesFolder:GetChildren() do
		local id, desde, hasta = puente:GetAttribute("EdgeId"), puente:GetAttribute("From"), puente:GetAttribute("To")
		assert(typeof(id) == "string" and typeof(desde) == "string" and typeof(hasta) == "string", "Puente sin identificadores.")
		assert(islas[desde] and islas[hasta], "El puente apunta a una isla inexistente.")
		local tablas: {BasePart} = {}
		for _, pieza in puente:GetDescendants() do
			if pieza:IsA("BasePart") and pieza:GetAttribute("Kind") == "Tablon" then
				assert(typeof(pieza:GetAttribute("Order")) == "number", "Tablón sin Order.")
				table.insert(tablas, pieza)
			end
		end
		assert(#tablas >= 2, "El puente necesita al menos dos tablones.")
		table.sort(tablas, function(a, b) return (a:GetAttribute("Order") :: number) < (b:GetAttribute("Order") :: number) end)
		local origen = islas[desde].PrimaryPart :: BasePart
		if desde ~= hasta and plano(tablas[1].Position - origen.Position).Magnitude > plano(tablas[#tablas].Position - origen.Position).Magnitude then
			local invertidos: {BasePart} = {}
			for i = #tablas, 1, -1 do table.insert(invertidos, tablas[i]) end
			tablas = invertidos
		end
		for _, extremo in {"From", "To"} do
			local isla = islas[if extremo == "From" then desde else hasta]
			local superficie = isla.PrimaryPart :: BasePart
			local tablon = tablas[if extremo == "From" then 1 else #tablas]
			local vecino = tablas[if extremo == "From" then 2 else #tablas - 1]
			local tangente = plano(vecino.Position - tablon.Position).Unit
			local lateral = Vector3.new(tangente.Z, 0, -tangente.X)
			local ancho = math.max(tablon.Size.X, tablon.Size.Z) + MARGEN_LATERAL * 2
			local radio = math.min(superficie.Size.Y, superficie.Size.Z) / 2 - SOLAPE_INTERIOR
			local profundidad, limite = 0, math.huge
			-- Ambos bordes del acceso deben quedar dentro del disco, también en uniones oblicuas.
			for _, signo in {-1, 1} do
				local relativo = plano(tablon.Position - superficie.Position) + lateral * ancho / 2 * signo
				local proyeccion = relativo:Dot(tangente)
				local discriminante = proyeccion^2 - relativo:Dot(relativo) + radio^2
				assert(discriminante > 0, "No se puede unir " .. id .. ": el acceso no intersecta la isla.")
				local raiz = math.sqrt(discriminante)
				profundidad = math.max(profundidad, proyeccion - raiz)
				limite = math.min(limite, proyeccion + raiz)
			end
			profundidad = math.max(2, profundidad + 1)
			assert(profundidad < limite and profundidad < radio, "Unión demasiado alejada: revisar " .. id)
			local color, material = Color3.fromRGB(100, 42, 32), Enum.Material.Cobblestone
			local altura = superficie.Position.Y + superficie.Size.X / 2
			local distancia = math.huge
			for _, pieza in isla:GetDescendants() do
				if pieza:IsA("BasePart") and string.match(pieza.Name, "^04_Muelle_%d+_placa_") then
					local separacion = (pieza.Position - tablon.Position).Magnitude
					if separacion < distancia then
						distancia, color, material = separacion, pieza.Color, pieza.Material
						altura = pieza.Position.Y + pieza.Size.Y / 2
					end
				end
			end
			local interior = tablon.Position - tangente * profundidad
			interior = Vector3.new(interior.X, altura + 0.03, interior.Z)
			local exterior = tablon.Position + tangente * (math.min(tablon.Size.X, tablon.Size.Z) / 2 + SOLAPE_TABLON)
			exterior = Vector3.new(exterior.X, tablon.Position.Y + tablon.Size.Y / 2 + 0.03, exterior.Z)
			local marco = CFrame.lookAt((interior + exterior) / 2, exterior)
			table.insert(planes, {isla = isla, nombre = "Union_" .. id .. "_" .. extremo, puenteId = id, extremo = extremo,
				marco = marco - marco.UpVector * ESPESOR / 2, tamano = Vector3.new(ancho, ESPESOR, (exterior - interior).Magnitude),
				color = color, material = material})
		end
	end
	return planes
end

function Uniones.crear(nivel: Instance): {BasePart}
	assert(not game:GetService("RunService"):IsRunning(), "Preparar las uniones en Edición y guardar el escenario.")
	local planes = planificar(nivel)
	-- Validar todos los nombres antes de escribir; nunca sustituir piezas manuales.
	for _, plan in planes do
		local carpeta = plan.isla:FindFirstChild("AccesosPuentes")
		assert(not carpeta or carpeta:IsA("Folder"), "AccesosPuentes debe ser una carpeta.")
		local existente = carpeta and carpeta:FindFirstChild(plan.nombre)
		assert(not existente or (existente:IsA("Part") and existente:GetAttribute("UnionGenerada") == true), "El acceso coincide con una pieza manual.")
	end
	local creadas: {BasePart} = {}
	for _, plan in planes do
		local carpeta = plan.isla:FindFirstChild("AccesosPuentes")
		if not carpeta then
			carpeta = Instance.new("Folder")
			carpeta.Name = "AccesosPuentes"
			carpeta.Parent = plan.isla
		end
		local pieza = (carpeta:FindFirstChild(plan.nombre) or Instance.new("Part")) :: Part
		pieza.Name = plan.nombre
		pieza.Size, pieza.CFrame = plan.tamano, plan.marco
		pieza.Color, pieza.Material = plan.color, plan.material
		pieza.Anchored, pieza.CanCollide, pieza.CanQuery, pieza.CanTouch = true, true, true, false
		pieza.Transparency = 0
		pieza.TopSurface, pieza.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		pieza:SetAttribute("Kind", "Acceso")
		pieza:SetAttribute("UnionGenerada", true)
		pieza:SetAttribute("PuenteId", plan.puenteId)
		pieza:SetAttribute("Extremo", plan.extremo)
		pieza:SetAttribute("NodeId", plan.isla:GetAttribute("NodeId"))
		pieza.Parent = carpeta
		table.insert(creadas, pieza)
	end
	return creadas
end

return Uniones

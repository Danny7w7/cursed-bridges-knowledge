--!strict
-- Representa en el cliente el derrumbe y la reconstruccion de los puentes de todos los niveles.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BridgeFX = require(ReplicatedStorage:WaitForChild("BridgeFX"))
local niveles = workspace:WaitForChild("Niveles")
local registradas: {[BasePart]: {RBXScriptConnection}} = {}
local ultimas: {[BasePart]: number} = {}

local function vigilarNivel(nivel: Instance)
	local puentes = nivel:WaitForChild("Bridges", 30)
	if not puentes then return end
	local function registrar(objeto: Instance)
		if not objeto:IsA("BasePart") or registradas[objeto] then return end
		local modelo = objeto:FindFirstAncestorOfClass("Model")
		if not modelo or not modelo:GetAttribute("EdgeId") then return end
		local function representar()
			local inicio = objeto:GetAttribute("CaidaDesde")
			local intento = objeto:GetAttribute("IntentoCaida")
			if typeof(inicio) ~= "number" or intento ~= nivel:GetAttribute("IntentoId") or ultimas[objeto] == inicio then return end
			ultimas[objeto] = inicio
			BridgeFX.representarCaida(modelo, objeto, inicio)
		end
		registradas[objeto] = {
			objeto:GetAttributeChangedSignal("CaidaDesde"):Connect(representar),
			objeto:GetAttributeChangedSignal("IntentoCaida"):Connect(representar),
			objeto.Destroying:Connect(function()
				local conexiones = registradas[objeto]
				if conexiones then for _, conexion in conexiones do conexion:Disconnect() end end
				registradas[objeto], ultimas[objeto] = nil, nil
			end),
		}
		representar()
	end
	for _, objeto in puentes:GetDescendants() do registrar(objeto) end
	puentes.DescendantAdded:Connect(registrar)
	nivel:GetAttributeChangedSignal("IntentoId"):Connect(function()
		for _, modelo in puentes:GetChildren() do
			if modelo:IsA("Model") then
				for _, parte in modelo:GetDescendants() do
					if parte:IsA("BasePart") then ultimas[parte] = nil end
				end
				BridgeFX.restore(modelo, true)
			end
		end
	end)
end
for _, nivel in niveles:GetChildren() do task.spawn(vigilarNivel, nivel) end
niveles.ChildAdded:Connect(vigilarNivel)

RunService.RenderStepped:Connect(function() BridgeFX.update() end)

-- temblor de camara cuando un puente cae cerca; se aplica despues de que la camara se actualiza
RunService:BindToRenderStep("TemblorPuentes", Enum.RenderPriority.Camera.Value + 1, function(dt)
	local temblor = BridgeFX.temblor
	if temblor <= 0.001 then return end
	BridgeFX.temblor = math.max(0, temblor - dt * 1.6)
	local camara = workspace.CurrentCamera
	if not camara then return end
	local t = os.clock() * 22
	local fuerza = temblor * temblor * 0.035
	camara.CFrame *= CFrame.Angles(math.noise(t, 1) * fuerza, math.noise(t, 2) * fuerza, math.noise(t, 3) * fuerza * 0.5)
end)


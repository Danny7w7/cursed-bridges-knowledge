--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BridgeFX = require(ReplicatedStorage:WaitForChild("BridgeFX"))
local niveles = workspace:WaitForChild("Niveles")
local nivel = niveles:WaitForChild("Nivel1")
local puentes = nivel:WaitForChild("Bridges")
local registradas: {[BasePart]: {RBXScriptConnection}} = {}
local ultimas: {[BasePart]: number} = {}

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
	table.clear(ultimas)
	for _, modelo in puentes:GetChildren() do
		if modelo:IsA("Model") then BridgeFX.restore(modelo) end
	end
end)
RunService.RenderStepped:Connect(function() BridgeFX.update() end)

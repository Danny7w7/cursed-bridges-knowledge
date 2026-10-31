local jugador = game:GetService("Players").LocalPlayer
local nivel = workspace.Niveles.Nivel1
local personaje = jugador.Character
local raiz, humanoide = personaje.HumanoidRootPart, personaje.Humanoid
local remotos = game:GetService("ReplicatedStorage").RemoteEvents
local anteriorId = nivel:GetAttribute("IntentoId")
remotos.RestartLevel:FireServer(anteriorId)
local limitePreparacion = os.clock()+12
repeat task.wait(0.1) until (nivel:GetAttribute("IntentoId")~=anteriorId and nivel:GetAttribute("FaseIntento")=="preparacion") or os.clock()>limitePreparacion
assert(nivel:GetAttribute("IntentoId")~=anteriorId,"No se restauró el intento")
repeat task.wait(0.1) until jugador.PlayerGui.PuentesMalditosUI.ResultadoOPreparacion.Comenzar.Active or os.clock()>limitePreparacion
assert(raiz.Anchored,"El personaje no quedó preparado")
local rutas = {}
for _, puente in nivel.Bridges:GetChildren() do
	local puntos = {}
	for _, pieza in puente:GetDescendants() do
		if pieza:IsA("BasePart") and pieza:GetAttribute("Kind") == "Tablon" then
			local marco = pieza:GetAttribute("MarcoReposo") or pieza.CFrame
			table.insert(puntos, {orden = pieza:GetAttribute("Order"), posicion = marco.Position + Vector3.new(0,pieza.Size.Y/2,0)})
		end
	end
	table.sort(puntos, function(a,b) return a.orden < b.orden end)
	rutas[puente:GetAttribute("EdgeId")] = {from=puente:GetAttribute("From"), to=puente:GetAttribute("To"), puntos=puntos}
end
local vertices = {"A","B","C","A","D"}
local puntos = {}
for paso=1,#vertices-1 do
	local desde,hasta = vertices[paso],vertices[paso+1]
	local ruta
	for _, candidata in rutas do
		if (candidata.from==desde and candidata.to==hasta) or (candidata.to==desde and candidata.from==hasta) then ruta=candidata break end
	end
	local centroDesde = nivel.Islands:FindFirstChild("Island_"..desde).PrimaryPart.Position+Vector3.new(0,3,0)
	local primero = if ruta.from==desde then ruta.puntos[1].posicion else ruta.puntos[#ruta.puntos].posicion
	local direccionDesde = Vector3.new(primero.X-centroDesde.X,0,primero.Z-centroDesde.Z).Unit
	table.insert(puntos,centroDesde+direccionDesde*30)
	if ruta.from==desde then
		for _, punto in ruta.puntos do table.insert(puntos,punto.posicion) end
	else
		for i=#ruta.puntos,1,-1 do table.insert(puntos,ruta.puntos[i].posicion) end
	end
	local centroHasta = nivel.Islands:FindFirstChild("Island_"..hasta).PrimaryPart.Position+Vector3.new(0,3,0)
	local ultimo = if ruta.from==desde then ruta.puntos[#ruta.puntos].posicion else ruta.puntos[1].posicion
	local direccionHasta = Vector3.new(ultimo.X-centroHasta.X,0,ultimo.Z-centroHasta.Z).Unit
	table.insert(puntos,centroHasta+direccionHasta*30)
end
table.insert(puntos, nivel.Islands.Island_D.PrimaryPart.Position+Vector3.new(0,3,0))
remotos.ComenzarIntento:FireServer(nivel:GetAttribute("IntentoId"))
local limiteComienzo = os.clock()+3
repeat task.wait(0.05) until nivel:GetAttribute("FaseIntento")~="preparacion" or os.clock()>limiteComienzo
assert(nivel:GetAttribute("FaseIntento")=="activo","No comenzó el intento")
local comienzo = workspace:GetServerTimeNow()
local atasco = nil
local function distancia(a,b) return Vector2.new(a.X-b.X,a.Z-b.Z).Magnitude end
for _, punto in puntos do
	humanoide:MoveTo(punto)
	local limite = os.clock()+distancia(raiz.Position,punto)/humanoide.WalkSpeed+3
	local anterior = raiz.Position
	local inmovil = 0
	while distancia(raiz.Position,punto)>1.5 and nivel:GetAttribute("FaseIntento")=="activo" do
		if os.clock()>limite then
			local parametros=RaycastParams.new()
			parametros.FilterType=Enum.RaycastFilterType.Exclude
			parametros.FilterDescendantsInstances={personaje}
			parametros.RespectCanCollide=true
			local direccion=Vector3.new(punto.X-raiz.Position.X,0,punto.Z-raiz.Position.Z)
			local impacto=workspace:Raycast(raiz.Position,direccion.Unit*10,parametros)
			atasco={posicion=tostring(raiz.Position),objetivo=tostring(punto),obstaculo=impacto and impacto.Instance:GetFullName()}
			break
		end
		if distancia(raiz.Position,anterior)<0.1 then inmovil+=0.05 else inmovil=0 end
		if inmovil>0.6 then humanoide.Jump=true inmovil=0 end
		anterior=raiz.Position
		task.wait(0.05)
	end
	if atasco or nivel:GetAttribute("FaseIntento")~="activo" then break end
end
return game:GetService("HttpService"):JSONEncode({
	fase=nivel:GetAttribute("FaseIntento"),vertices=nivel:GetAttribute("VerticesRecorridos"),
	aristas=nivel:GetAttribute("AristasRecorridas"),posicion=tostring(raiz.Position),atasco=atasco,
	mensaje=jugador.PlayerGui.PuentesMalditosUI.ResultadoOPreparacion.Contenido.Explicacion.Text,
	segundos=workspace:GetServerTimeNow()-comienzo,
})

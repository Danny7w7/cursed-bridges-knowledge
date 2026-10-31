--!strict
-- Autoría manual en Edición. No activa niveles ni reconstruye escenas al jugar.
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Constructor = {}
local NOMBRE = "Nivel2_Escenario"
local ORIGEN = Vector3.new(2500, 12, 0)
local RADIO = 44.82
local ALCANCE_MINIMO = 44
local ALCANCES_ESPECIALES: {[string]: number} = {B = 58, C = 58, G = 58}
local ESPESOR_ACCESO = 1.5
local POSICIONES: {[string]: Vector3} = {
	A = Vector3.new(220, 0, 350), B = Vector3.new(-100, 0, 40),
	C = Vector3.new(-20, 0, 520), D = Vector3.new(20, 0, 210),
	E = Vector3.new(0, 0, -140), F = Vector3.new(-190, 0, 330),
	G = Vector3.new(110, 0, 20), H = Vector3.new(25, 0, 365),
}
local ARISTAS = {"AC", "AG", "CF", "CH", "FB", "BE", "BG", "BD", "EG", "GD", "DH"}
local DIRECCIONES = {Vector3.new(-1, 0, 0), Vector3.new(0, 0, -1), Vector3.new(1, 0, 0), Vector3.new(0, 0, 1)}
local function plano(v: Vector3): Vector3 return Vector3.new(v.X, 0, v.Z) end
local function centro(id: string): Vector3 return ORIGEN + POSICIONES[id] end
local function exigirEdicion()
	assert(not RunService:IsRunning(), "La construcción se ejecuta únicamente en Edición.")
end
local function escenario(): Folder
	exigirEdicion()
	local n = Workspace.Niveles:FindFirstChild(NOMBRE)
	assert(n and n:IsA("Folder") and n:GetAttribute("AutorEscenario") == "ConstructorEscenarioNivel2", "No existe el escenario de esta herramienta.")
	return n
end
local function registro<T>(nombre: string, accion: () -> T): T
	exigirEdicion()
	local historia = game:GetService("ChangeHistoryService")
	local id = if historia:IsRecordingInProgress() then nil else historia:TryBeginRecording("EscenarioNivel2", nombre)
	local ok, resultado = pcall(accion)
	if id then historia:FinishRecording(id, if ok then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel) end
	assert(ok, tostring(resultado))
	return resultado
end
local function huella(texto: string): string
	local a, b = 0, 0
	for i = 1, #texto do
		local c = string.byte(texto, i)
		a, b = (a * 131 + c) % 2147483647, (b * 257 + c) % 2147483629
	end
	return tostring(a) .. ":" .. tostring(b)
end
local function numeros(valores: {number}): string
	local salida = {}
	for _,v in valores do table.insert(salida, string.format("%.9g", v)) end
	return table.concat(salida, ",")
end
local function propiedades(p: BasePart): string
	local datos = {
		numeros({p.Size.X, p.Size.Y, p.Size.Z}), numeros({p.Color.R, p.Color.G, p.Color.B}),
		p.Material.Name, p.MaterialVariant, tostring(p.Transparency), tostring(p.Reflectance),
		tostring(p.Anchored), tostring(p.CanCollide), tostring(p.CanQuery), tostring(p.CanTouch),
	}
	if p:IsA("MeshPart") then
		table.insert(datos, p.MeshId)
		table.insert(datos, p.TextureID)
		table.insert(datos, p.CollisionFidelity.Name)
	end
	for _,h in p:GetChildren() do if h:IsA("SurfaceAppearance") then
		table.insert(datos, h.ColorMap .. "|" .. h.NormalMap .. "|" .. h.MetalnessMap .. "|" .. h.RoughnessMap)
	end end
	return table.concat(datos, "|")
end
local function firmaAcabados(modelo: Instance): string
	local piezas = {}
	for _,p in modelo:GetDescendants() do if p:IsA("BasePart") then table.insert(piezas, p.Name .. "|" .. propiedades(p)) end end
	table.sort(piezas)
	return huella(table.concat(piezas, "\n"))
end
local function firmaCompleta(modelo: Instance): string
	local datos = {}
	local objetos = modelo:GetDescendants()
	table.insert(objetos, modelo)
	for i,p in objetos do
		local atributos = {}
		for k,v in p:GetAttributes() do table.insert(atributos, k .. "=" .. tostring(v)) end
		table.sort(atributos)
		local texto = p:GetFullName() .. "|" .. p.ClassName .. "|" .. table.concat(atributos, ";")
		if p:IsA("BasePart") then texto ..= "|" .. propiedades(p) .. "|" .. numeros({p.CFrame:GetComponents()}) end
		if p:IsA("TextLabel") then texto ..= "|" .. p.Text end
		table.insert(datos, texto)
		if i % 200 == 0 then task.wait() end
	end
	table.sort(datos)
	return huella(table.concat(datos, "\n"))
end
local function protecciones(): string
	local datos = {nivel1 = firmaCompleta(Workspace.Niveles.Nivel1)}
	for _,nombre in {"Isla", "PuenteRecto", "PuenteLazo", "PuenteParalelas"} do
		datos[nombre] = firmaCompleta(ServerStorage[nombre])
	end
	return HttpService:JSONEncode(datos)
end
local function comprobarProtecciones(n: Instance)
	local antes = HttpService:JSONDecode(n:GetAttribute("ProteccionesOrigen") :: string)
	local ahora = HttpService:JSONDecode(protecciones())
	for k,v in antes do assert(ahora[k] == v, "Cambió un objeto protegido: " .. k) end
end
local function limpiarInteraccion(m: Instance)
	for _,p in m:GetDescendants() do if p:IsA("ClickDetector") or p:IsA("LuaSourceContainer") then p:Destroy() end end
end

function Constructor.iniciar()
	return registro("Preparar escenario del nivel 2", function()
		assert(not Workspace.Niveles:FindFirstChild(NOMBRE), "El escenario ya existe. No se sustituyen ediciones manuales.")
		assert(not Workspace.Niveles:FindFirstChild("Nivel2"), "Ya existe un Nivel2: revisar antes de construir otro.")
		local firmas = protecciones()
		local n = Instance.new("Folder")
		n.Name = NOMBRE
		n:SetAttribute("LevelId", 2)
		n:SetAttribute("NombreNivel", "La ruta sin retorno")
		n:SetAttribute("SoloEscenario", true)
		n:SetAttribute("AutorEscenario", "ConstructorEscenarioNivel2")
		n:SetAttribute("EstadoConstruccion", "en_construccion")
		n:SetAttribute("OrigenEscenario", ORIGEN)
		n:SetAttribute("ProteccionesOrigen", firmas)
		for _,nombre in {"Islands", "Bridges"} do local f = Instance.new("Folder") f.Name = nombre f.Parent = n end
		n.Parent = Workspace.Niveles
		return {ruta = n:GetFullName()}
	end)
end

local function angulo(v: Vector3): number return math.atan2(v.Z, v.X) % (2 * math.pi) end
local function diferencia(a: number, b: number): number return (a - b + math.pi) % (2 * math.pi) - math.pi end
local function destinosMuelles(id: string): ({number}, {[number]: string})
	local objetivos: {number} = {}
	local vecinos: {[number]: string} = {}
	for _,arista in ARISTAS do
		local a,b = string.sub(arista, 1, 1), string.sub(arista, 2, 2)
		if a == id or b == id then
			local vecino = if a == id then b else a
			table.insert(objetivos, angulo(centro(vecino) - centro(id)))
			vecinos[#objetivos] = vecino
		end
	end
	while #objetivos < 4 do
		local ordenados = table.clone(objetivos)
		table.sort(ordenados)
		local mayor, mitad = -1, 0
		for i,a in ordenados do
			local b = ordenados[i % #ordenados + 1]
			local abertura = (b - a) % (2 * math.pi)
			if abertura > mayor then mayor, mitad = abertura, (a + abertura / 2) % (2 * math.pi) end
		end
		table.insert(objetivos, mitad)
	end
	return objetivos, vecinos
end
local function asignar(objetivos: {number}): {number}
	local mejor, coste = {}, math.huge
	local usados, actual = {}, {}
	local function visitar(i: number, valor: number)
		if i == 5 then if valor < coste then mejor, coste = table.clone(actual), valor end return end
		for j,objetivo in objetivos do if not usados[j] then
			usados[j], actual[i] = true, j
			visitar(i + 1, valor + diferencia(objetivo, angulo(DIRECCIONES[i]))^2)
			usados[j] = nil
		end end
	end
	visitar(1, 0)
	return mejor
end

function Constructor.crearIsla(id: string)
	return registro("Construir isla " .. id, function()
		local n = escenario()
		assert(POSICIONES[id] and not n.Islands:FindFirstChild("Island_" .. id), "Isla ausente en el plan o ya construida.")
		local isla = Instance.new("Model")
		isla.Name = "Island_" .. id
		isla:SetAttribute("NodeId", id)
		isla.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
		local superficie = Instance.new("Part")
		superficie.Name, superficie.Shape = "Superficie", Enum.PartType.Cylinder
		superficie.Size = Vector3.new(6, RADIO * 2, RADIO * 2)
		superficie.Anchored, superficie.Transparency = true, 1
		superficie.CFrame = CFrame.new(centro(id) - Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		superficie:SetAttribute("NodeId", id)
		superficie.Parent, isla.PrimaryPart = isla, superficie
		local visual = ServerStorage.Isla:Clone() :: Model
		visual.Name = "Visual"
		visual:ScaleTo(1.8)
		visual:PivotTo(CFrame.new(centro(id)))
		limpiarInteraccion(visual)
		local firma = firmaAcabados(visual)
		local hijos = visual:GetChildren()
		for _,h in hijos do h.Parent = nil end
		visual.Parent = superficie
		isla.Parent = n.Islands
		local cargados = 0
		for _,h in hijos do
			h.Parent = visual
			cargados += 1 + #h:GetDescendants()
			if cargados >= 400 then task.wait() cargados = 0 end
		end
		local grupos: {Model} = {}
		for i = 1,4 do
			local grupo = Instance.new("Model")
			grupo.Name = "Muelle_" .. i
			grupo.Parent = visual
			table.insert(grupos, grupo)
		end
		for _,p in visual:GetDescendants() do
			if p:IsA("BasePart") and string.find(p.Name, "Muelle", 1, true) then
				local d = plano(p.Position - centro(id))
				local mejor, parecido = 1, -math.huge
				for i,v in DIRECCIONES do local parecidoActual = d:Dot(v) if parecidoActual > parecido then mejor, parecido = i, parecidoActual end end
				p.Parent = grupos[mejor]
			end
		end
		local objetivos, vecinos = destinosMuelles(id)
		local mapa = asignar(objetivos)
		for i,grupo in grupos do
			local objetivo = objetivos[mapa[i]]
			-- En Roblox el giro positivo alrededor de Y reduce el ángulo en XZ.
			local giro = -diferencia(objetivo, angulo(DIRECCIONES[i]))
			local delta = CFrame.new(centro(id)) * CFrame.Angles(0, giro, 0) * CFrame.new(-centro(id))
			for _,p in grupo:GetDescendants() do if p:IsA("BasePart") then p.CFrame = delta * p.CFrame end end
			grupo:SetAttribute("Vecino", vecinos[mapa[i]] or "")
			grupo:SetAttribute("Direccion", Vector3.new(math.cos(objetivo), 0, math.sin(objetivo)))
			grupo:SetAttribute("MuelleOriginal", i)
			task.wait()
		end
		assert(firmaAcabados(visual) == firma, "La orientación alteró dimensiones o materiales de la isla.")
		isla:SetAttribute("FirmaAcabados", firma)
		isla:SetAttribute("EscalaVisual", 1.8)
		local label = Workspace.Niveles.Nivel1.Islands.Island_A.PrimaryPart.GradeLabel:Clone()
		label.Parent = superficie
		local texto = label:FindFirstChildWhichIsA("TextLabel")
		assert(texto, "Falta el texto de la letra.")
		texto.Text = id .. (if id == "A" then "\nINICIO" elseif id == "H" then "\nDESTINO" else "")
		local accesos = Instance.new("Folder") accesos.Name = "AccesosPuentes" accesos.Parent = isla
		return {isla = id, piezas = #visual:GetDescendants(), muelles = #grupos}
	end)
end

local function fuentePuente(): (Model, {BasePart}, CFrame, number, number)
	local m = Workspace.Niveles.Nivel1.Bridges.Bridge_AB
	local tablas: {BasePart} = {}
	for _,p in m:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("Kind") == "Tablon" then table.insert(tablas, p) end end
	table.sort(tablas, function(a,b) return (a:GetAttribute("Order") :: number) < (b:GetAttribute("Order") :: number) end)
	local primero, ultimo = tablas[1], tablas[#tablas]
	local direccion = plano(ultimo.Position - primero.Position).Unit
	local marco = CFrame.lookAt(primero.Position, primero.Position + direccion)
	local minimo, maximo = math.huge, -math.huge
	for _,p in m:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("Kind") == "Barandal" then
		local mitad = p.Size / 2
		for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
			local distancia = (p.CFrame:PointToWorldSpace(mitad * Vector3.new(x,y,z)) - primero.Position):Dot(direccion)
			minimo, maximo = math.min(minimo, distancia), math.max(maximo, distancia)
		end end end
	end end
	return m, tablas, marco, plano(ultimo.Position - primero.Position).Magnitude, maximo - minimo + 0.2
end
local function acceso(isla: Model, extremo: Vector3, direccion: Vector3, ancho: number, arista: string, lado: string)
	local c = centro(isla:GetAttribute("NodeId") :: string)
	local radioSeguro = RADIO - 1
	local interior = math.sqrt(radioSeguro^2 - (ancho / 2)^2) - 1
	local puntoInterior = c + direccion * interior
	local a = Vector3.new(puntoInterior.X, 12.35, puntoInterior.Z)
	local b = extremo + direccion * 2
	local marco = CFrame.lookAt((a + b) / 2, b)
	local pieza = Instance.new("Part")
	pieza.Name = "Union_" .. arista .. "_" .. lado
	pieza.Size = Vector3.new(ancho, ESPESOR_ACCESO, (b - a).Magnitude)
	pieza.CFrame = marco - marco.UpVector * ESPESOR_ACCESO / 2
	pieza.Material, pieza.Color = Enum.Material.Cobblestone, Color3.fromRGB(100, 42, 32)
	pieza.Anchored, pieza.CanCollide, pieza.CanTouch = true, true, false
	pieza.TopSurface, pieza.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	pieza:SetAttribute("Kind", "Acceso")
	pieza:SetAttribute("UnionGenerada", true)
	pieza:SetAttribute("PuenteId", arista)
	pieza:SetAttribute("Extremo", lado)
	pieza:SetAttribute("NodeId", isla:GetAttribute("NodeId"))
	pieza.Parent = isla.AccesosPuentes
end
local function eslabonReferencia(): BasePart
	for _,p in Workspace.Niveles.Nivel1.Islands.Island_A:GetDescendants() do
		if p:IsA("MeshPart") and string.find(p.Name, "Cadena", 1, true) and p.Size.X < p.Size.Y and p.Size.X < p.Size.Z then return p end
	end
	error("Falta el modelo de eslabón existente.")
end
local function cadenasJunta(padre: Instance, a: Vector3, b: Vector3, direccion: Vector3, ancho: number)
	local lateral = Vector3.new(direccion.Z, 0, -direccion.X)
	local fuente = eslabonReferencia()
	local largo = plano(b - a).Magnitude
	local cantidad = math.ceil(largo / (fuente.Size.Z * 0.65))
	for _,signo in {-1,1} do
		for i = 0,cantidad do
			local t = i / cantidad
			local posicion = a:Lerp(b,t) + lateral * ancho / 2 * signo + Vector3.new(0,4 - math.sin(t * math.pi) * 0.45,0)
			local p = fuente:Clone()
			p.Name = "CadenaJunta"
			local rotacion = CFrame.lookAt(posicion, posicion + direccion)
			p.CFrame = rotacion * CFrame.Angles(0,0,if i % 2 == 0 then 0 else math.pi / 2)
			p:SetAttribute("ReferenciaOriginal", huella(propiedades(fuente)))
			p:SetAttribute("Kind", "Cadena")
			p.Parent = padre
			if i % 40 == 0 then task.wait() end
		end
	end
end

function Constructor.crearPuente(id: string)
	return registro("Construir puente " .. id, function()
		local n = escenario()
		assert(table.find(ARISTAS,id) and not n.Bridges:FindFirstChild("Bridge_" .. id), "Puente no previsto o ya construido.")
		local desde, hasta = string.sub(id,1,1), string.sub(id,2,2)
		local islaDesde, islaHasta = n.Islands:FindFirstChild("Island_" .. desde), n.Islands:FindFirstChild("Island_" .. hasta)
		assert(islaDesde and islaDesde:IsA("Model") and islaHasta and islaHasta:IsA("Model"), "Crear primero ambas islas.")
		local origen, destino = centro(desde), centro(hasta)
		local direccion = plano(destino - origen).Unit
		local distancia = plano(destino - origen).Magnitude
		local fuente, tablas, marcoFuente, largo, separacion = fuentePuente()
		local minimoDesde = ALCANCES_ESPECIALES[desde] or ALCANCE_MINIMO
		local minimoHasta = ALCANCES_ESPECIALES[hasta] or ALCANCE_MINIMO
		local hueco = distancia - minimoDesde - minimoHasta
		assert(hueco >= largo, "La conexión no admite un tramo a escala fija.")
		local cantidad = math.max(1, math.floor((hueco - largo) / separacion) + 1)
		local longitudModular = largo + (cantidad - 1) * separacion
		local resto = (hueco - longitudModular) / 2
		local alcance = minimoDesde + resto
		local alcanceHasta = minimoHasta + resto
		local primero = origen + direccion * alcance
		primero = Vector3.new(primero.X, tablas[1].Position.Y, primero.Z)
		local modelo = Instance.new("Model")
		modelo.Name = "Bridge_" .. id
		modelo:SetAttribute("EdgeId", id) modelo:SetAttribute("From", desde) modelo:SetAttribute("To", hasta)
		modelo:SetAttribute("Tramos", cantidad)
		modelo:SetAttribute("EscalaTramos", fuente:GetScale())
		modelo:SetAttribute("AnchoTablero", math.max(tablas[1].Size.X, tablas[1].Size.Z))
		modelo.Parent = n.Bridges
		local firma = firmaAcabados(fuente)
		for i = 1,cantidad do
			local m = fuente:Clone()
			m.Name = "Tramo_" .. string.format("%02d", i)
			limpiarInteraccion(m)
			local lateral = Vector3.new(direccion.Z, 0, -direccion.X)
			local desfase = if i % 2 == 0 then 0.03 else 0
			local posicion = primero + direccion * separacion * (i - 1) + lateral * desfase + Vector3.new(0,desfase,0)
			local objetivo = CFrame.lookAt(posicion, posicion + direccion)
			m:PivotTo(objetivo * marcoFuente:ToObjectSpace(fuente:GetPivot()))
			assert(firmaAcabados(m) == firma, "El tramo cambió escala, materiales o texturas.")
			m:SetAttribute("FirmaAcabados", firma)
			m:SetAttribute("EdgeId", id) m:SetAttribute("From", desde) m:SetAttribute("To", hasta)
			for _,p in m:GetDescendants() do if p:IsA("BasePart") then
				p:SetAttribute("EdgeId", id)
				for _,a in {"MarcoReposo","TransparenciaReposo","ColisionReposo","IntentoCaida","CaidaDesde"} do p:SetAttribute(a,nil) end
			end end
			m.Parent = modelo
			task.wait()
		end
		local juntas = Instance.new("Folder") juntas.Name = "Juntas" juntas.Parent = modelo
		local pasoOriginal = largo / (#tablas - 1)
		for i = 1,cantidad - 1 do
			local a = primero + direccion * ((i - 1) * separacion + largo)
			local b = primero + direccion * i * separacion
			local pasos = math.ceil((b - a).Magnitude / pasoOriginal)
			for j = 1,pasos - 1 do
				local p = tablas[1]:Clone()
				limpiarInteraccion(p)
				p.Name = "TablonJunta"
				local posicion = a:Lerp(b,j / pasos)
				p.CFrame = CFrame.lookAt(posicion, posicion + direccion) * marcoFuente:ToObjectSpace(tablas[1].CFrame)
				p:SetAttribute("Kind","Tablon") p:SetAttribute("EdgeId",id)
				p:SetAttribute("ReferenciaOriginal", huella(propiedades(tablas[1])))
				p.Parent = juntas
			end
			cadenasJunta(juntas, a + direccion * 2.5 + Vector3.new(0,tablas[1].Size.Y / 2,0), b - direccion * 2.5 + Vector3.new(0,tablas[1].Size.Y / 2,0), direccion, math.max(tablas[1].Size.X,tablas[1].Size.Z))
		end
		local ordenadas: {BasePart} = {}
		for _,p in modelo:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("Kind") == "Tablon" then table.insert(ordenadas,p) end end
		table.sort(ordenadas,function(a,b) return (a.Position - primero):Dot(direccion) < (b.Position - primero):Dot(direccion) end)
		for i,p in ordenadas do p:SetAttribute("Order",i) end
		local ancho = math.max(tablas[1].Size.X,tablas[1].Size.Z) + 0.5
		acceso(islaDesde, primero + Vector3.new(0,tablas[1].Size.Y / 2 + 0.03,0), direccion, ancho,id,"From")
		local ultimo = primero + direccion * longitudModular
		acceso(islaHasta, ultimo + Vector3.new(0,tablas[#tablas].Size.Y / 2 + 0.03,0), -direccion, ancho,id,"To")
		modelo:SetAttribute("Tablones",#ordenadas)
		return {puente=id,tramos=cantidad,tablones=#ordenadas,alcance=alcance,alcanceHasta=alcanceHasta,separacion=separacion}
	end)
end

function Constructor.verificar()
	local n = escenario()
	assert(#n.Islands:GetChildren() == 8 and #n.Bridges:GetChildren() == 11, "El escenario no tiene ocho islas y once puentes.")
	local grados: {[string]: number} = {}
	local tramos, tablones, accesos, piezas = 0,0,0,0
	for _,id in ARISTAS do
		local m = n.Bridges:FindFirstChild("Bridge_" .. id)
		assert(m and m:GetAttribute("From") == string.sub(id,1,1) and m:GetAttribute("To") == string.sub(id,2,2), "Conexión incorrecta: " .. id)
		grados[string.sub(id,1,1)] = (grados[string.sub(id,1,1)] or 0) + 1
		grados[string.sub(id,2,2)] = (grados[string.sub(id,2,2)] or 0) + 1
		local ordenes = {}
		for _,p in m:GetDescendants() do
			if p:IsA("BasePart") then
				if p:GetAttribute("Kind") == "Tablon" then
					local orden = p:GetAttribute("Order")
					assert(typeof(orden) == "number" and not ordenes[orden], "Orden de tablón duplicado.")
					ordenes[orden] = true tablones += 1
				end
				local referencia = p:GetAttribute("ReferenciaOriginal")
				if referencia then assert(huella(propiedades(p)) == referencia, "Se alteró una pieza de junta.") end
			elseif p:IsA("Model") and p:GetAttribute("FirmaAcabados") then
				assert(firmaAcabados(p) == p:GetAttribute("FirmaAcabados"), "Cambió el acabado de un tramo.")
				tramos += 1
			end
		end
	end
	for id in POSICIONES do
		local isla = n.Islands["Island_" .. id]
		assert(isla:IsA("Model") and isla.PrimaryPart and (isla.PrimaryPart.Position - (centro(id) - Vector3.new(0,3,0))).Magnitude < 0.01, "La isla se desvió de la distribución.")
		assert(firmaAcabados(isla.PrimaryPart.Visual) == isla:GetAttribute("FirmaAcabados"), "Cambió un acabado de isla.")
		local conexiones = 0
		for _,grupo in isla.PrimaryPart.Visual:GetChildren() do if grupo:IsA("Model") and grupo:GetAttribute("Vecino") ~= nil then
			local vecino = grupo:GetAttribute("Vecino")
			if vecino ~= "" then
				conexiones += 1
				assert((grupo:GetAttribute("Direccion") :: Vector3):Dot(plano(centro(vecino :: string) - centro(id)).Unit) > 0.99999, "Muelle desalineado.")
			end
		end end
		assert(conexiones == grados[id], "Cantidad de muelles incorrecta en " .. id)
		assert(#isla.AccesosPuentes:GetChildren() == grados[id], "Faltan accesos en " .. id)
		accesos += #isla.AccesosPuentes:GetChildren()
	end
	for _,p in n:GetDescendants() do if p:IsA("BasePart") then piezas += 1 end end
	comprobarProtecciones(n)
	return {islas=8,puentes=11,grados=grados,tramos=tramos,tablones=tablones,accesos=accesos,piezas=piezas,nivel1YPlantillasSinCambios=true}
end

function Constructor.finalizar()
	return registro("Finalizar escenario del nivel 2", function()
		local n = escenario()
		if not n:FindFirstChild("MarDeLava") then
			local lava = Workspace.MarDeLava:Clone()
			lava.Position += Vector3.new(ORIGEN.X,0,ORIGEN.Z)
			lava.Parent = n
		end
		local resumen = Constructor.verificar()
		n:SetAttribute("EstadoConstruccion","escenario_listo")
		n:SetAttribute("ResumenConstruccion", HttpService:JSONEncode(resumen))
		return resumen
	end)
end


function Constructor.compactar()
	return registro("Compactar escenario y juntas del nivel 2", function()
		local n = escenario()
		-- La reconexión de Studio puede normalizar CFrames; se conserva el registro previo.
		local actuales = protecciones()
		if actuales ~= n:GetAttribute("ProteccionesOrigen") then
			n:SetAttribute("ProteccionesAntesDeReconectar", n:GetAttribute("ProteccionesOrigen"))
			n:SetAttribute("NotaReferencia", "Referencia renovada tras reconexión de Studio; no se escribe sobre el nivel 1 ni las plantillas.")
			n:SetAttribute("ProteccionesOrigen", actuales)
		end
		for _,m in n.Bridges:GetChildren() do m:Destroy() task.wait() end
		for id in POSICIONES do
			local isla = n.Islands["Island_" .. id] :: Model
			local superficie = isla.PrimaryPart :: BasePart
			for _,p in isla.AccesosPuentes:GetChildren() do p:Destroy() end
			local delta = centro(id) - Vector3.new(0,3,0) - superficie.Position
			isla:PivotTo(isla:GetPivot() + delta)
			local objetivos, vecinos = destinosMuelles(id)
			local mapa = asignar(objetivos)
			local visual = superficie.Visual
			for _,grupo in visual:GetChildren() do
				if grupo:IsA("Model") and typeof(grupo:GetAttribute("MuelleOriginal")) == "number" then
					local i = grupo:GetAttribute("MuelleOriginal") :: number
					local objetivo = objetivos[mapa[i]]
					local antes = grupo:GetAttribute("Direccion") :: Vector3
					local giro = -diferencia(objetivo, angulo(antes))
					local transformacion = CFrame.new(centro(id)) * CFrame.Angles(0,giro,0) * CFrame.new(-centro(id))
					for _,p in grupo:GetDescendants() do if p:IsA("BasePart") then p.CFrame = transformacion * p.CFrame end end
					grupo:SetAttribute("Vecino", vecinos[mapa[i]] or "")
					grupo:SetAttribute("Direccion", Vector3.new(math.cos(objetivo),0,math.sin(objetivo)))
				end
			end
			assert(firmaAcabados(visual) == isla:GetAttribute("FirmaAcabados"), "La compactación alteró el acabado.")
			task.wait()
		end
		n:SetAttribute("EstadoConstruccion","ajustando_separacion")
		n:SetAttribute("Distribucion","compacta")
		return {islas=8,puentesPendientes=11}
	end)
end

Constructor.posiciones = POSICIONES
Constructor.aristas = ARISTAS
return Constructor

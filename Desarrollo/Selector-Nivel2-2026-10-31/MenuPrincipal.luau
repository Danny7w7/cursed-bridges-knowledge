--!strict
-- Menú principal, selector de niveles y cinemática de entrada de cada nivel.
-- Controla la cámara mientras el jugador no está en partida y oculta la interfaz del intento.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Catalogo = require(ReplicatedStorage:WaitForChild("CatalogoNiveles"))
local Estilo = require(ReplicatedStorage:WaitForChild("EstiloHades"))
local Textos = require(ReplicatedStorage:WaitForChild("TextosEducativos"))
local remotos = ReplicatedStorage:WaitForChild("RemoteEvents")
local seleccionarNivel = remotos:WaitForChild("SeleccionarNivel") :: RemoteEvent
local reiniciarNivel = remotos:WaitForChild("RestartLevel") :: RemoteEvent
local estadoActualizado = remotos:WaitForChild("StateUpdated") :: RemoteEvent
local sonidos = ReplicatedStorage:WaitForChild("Sonidos")
local niveles = workspace:WaitForChild("Niveles")
local jugador = Players.LocalPlayer
local guiJugador = jugador:WaitForChild("PlayerGui")
local camara = workspace.CurrentCamera

local TITULO = Font.new(Font.fromEnum(Enum.Font.Bodoni).Family, Enum.FontWeight.Bold)
local TEXTO = Font.fromEnum(Enum.Font.Merriweather)
local CURSIVA = Font.new(Font.fromEnum(Enum.Font.Merriweather).Family, Enum.FontWeight.Regular, Enum.FontStyle.Italic)
local ORO = Color3.fromRGB(255, 205, 110)
local ORO_OSCURO = Color3.fromRGB(214, 120, 44)
local CREMA = Color3.fromRGB(248, 234, 214)
local TURQUESA = Color3.fromRGB(70, 225, 195)
local BRASA = Color3.fromRGB(255, 112, 52)
local NOCHE = Color3.fromRGB(18, 9, 22)

type Modo = "menu" | "transicion" | "cinematica" | "juego"
local modo: Modo = "menu"
local ultimoEstado: any = nil
local nivelEnCurso = 0
local saltar = false

-- utilidades -----------------------------------------------------------------------------------
local function crear(clase: string, props: {[string]: any}, padre: Instance?): any
	local obj = Instance.new(clase)
	for k, v in props do (obj :: any)[k] = v end
	if padre then obj.Parent = padre end
	return obj
end
local function tween(obj: Instance, t: number, props: {[string]: any}, estilo: Enum.EasingStyle?, dir: Enum.EasingDirection?): Tween
	local tw = TweenService:Create(obj, TweenInfo.new(t, estilo or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end
local function esquinas(obj: Instance, r: number) crear("UICorner", {CornerRadius = UDim.new(0, r)}, obj) end
local function dorado(obj: Instance)
	crear("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 190)),
			ColorSequenceKeypoint.new(0.5, ORO),
			ColorSequenceKeypoint.new(1, ORO_OSCURO),
		}),
		Rotation = 90,
	}, obj)
end
local function texto(props: {[string]: any}, padre: Instance): TextLabel
	local base = {BackgroundTransparency = 1, TextColor3 = CREMA, FontFace = TEXTO, TextSize = 18, TextWrapped = true, RichText = true}
	for k, v in props do base[k] = v end
	return crear("TextLabel", base, padre)
end

local musicas: {[string]: Sound} = {}
local sonando: Sound? = nil
local function musica(nombre: string)
	local plantilla = sonidos:FindFirstChild(nombre)
	if not plantilla then return end
	local s = musicas[nombre]
	if not s then
		s = plantilla:Clone()
		s.Parent = SoundService
		musicas[nombre] = s
	end
	if sonando == s then return end
	local anterior = sonando
	if anterior then
		tween(anterior, 1.5, {Volume = 0}, Enum.EasingStyle.Linear).Completed:Once(function() anterior:Stop() end)
	end
	local volumen = (plantilla :: Sound).Volume
	s.Volume = 0
	s:Play()
	tween(s, 2, {Volume = volumen}, Enum.EasingStyle.Linear)
	sonando = s
end
local function efecto(nombre: string)
	local plantilla = sonidos:FindFirstChild(nombre)
	if plantilla then SoundService:PlayLocalSound(plantilla :: Sound) end
end

-- datos del nivel en el mundo ------------------------------------------------------------------
type IslaInfo = {id: string, centro: Vector3, grado: number}
local function leerNivel(id: number): ({IslaInfo}, Vector3, Model?)
	local nivel = niveles:FindFirstChild("Nivel" .. id)
	local islas: {IslaInfo} = {}
	if not nivel then return islas, Vector3.new(0, 10, 0), nil end
	local grados: {[string]: number} = {}
	local puentes = nivel:FindFirstChild("Bridges")
	if puentes then
		for _, p in puentes:GetChildren() do
			local a, b = p:GetAttribute("From"), p:GetAttribute("To")
			if typeof(a) == "string" and typeof(b) == "string" then
				grados[a] = (grados[a] or 0) + 1
				grados[b] = (grados[b] or 0) + 1
			end
		end
	end
	local suma = Vector3.zero
	local contenedor = nivel:FindFirstChild("Islands")
	if contenedor then
		for _, m in contenedor:GetChildren() do
			local nodo = m:GetAttribute("NodeId")
			if m:IsA("Model") and typeof(nodo) == "string" then
				local c = m:GetPivot().Position
				if m.PrimaryPart then c = m.PrimaryPart.Position + Vector3.new(0, 3, 0) end
				table.insert(islas, {id = nodo, centro = c, grado = grados[nodo] or 0})
				suma += c
			end
		end
	end
	table.sort(islas, function(x, y) return x.id < y.id end)
	local centro = if #islas > 0 then suma / #islas else Vector3.new(0, 10, 0)
	local cerberus = nivel:FindFirstChild("Cerberus")
	return islas, centro, if cerberus and cerberus:IsA("Model") then cerberus else nil
end
local function disponible(id: number): boolean
	return niveles:FindFirstChild("Nivel" .. id) ~= nil
end
local function entrada(id: number)
	for _, e in Catalogo do if e.id == id then return e end end
	return nil
end

-- interfaz ------------------------------------------------------------------------------------
local pantalla = crear("ScreenGui", {Name = "MenuPrincipal", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 20, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, guiJugador)
local barraArriba = crear("Frame", {Name = "BarraCine", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0.1, 0), ZIndex = 50}, pantalla)
local barraAbajo = crear("Frame", {Name = "BarraCine", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0.1, 0), AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), ZIndex = 50}, pantalla)
local velo = crear("Frame", {Name = "Velo", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0, ZIndex = 100}, pantalla)
local function barras(visible: boolean)
	local alto = if visible then 0.1 else 0
	tween(barraArriba, 0.8, {Size = UDim2.new(1, 0, alto, 0)})
	tween(barraAbajo, 0.8, {Size = UDim2.new(1, 0, alto, 0)})
end

-- portada
local portada = crear("CanvasGroup", {Name = "Portada", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 10}, pantalla)
local sombra = crear("Frame", {BackgroundColor3 = NOCHE, BorderSizePixel = 0, Size = UDim2.fromScale(0.62, 1)}, portada)
crear("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.55, 0.35), NumberSequenceKeypoint.new(1, 1)})}, sombra)

local brasasUI = crear("Frame", {Name = "BrasasUI", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, portada)
local logo = crear("Frame", {Name = "Logo", BackgroundTransparency = 1, Position = UDim2.fromScale(0.065, 0.12), Size = UDim2.new(0, 640, 0, 260)}, portada)
local l1 = texto({Text = "PUENTES", FontFace = TITULO, TextSize = 84, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1, 0, 0, 86)}, logo)
dorado(l1)
crear("UIStroke", {Color = Color3.fromRGB(70, 20, 8), Thickness = 2}, l1)
local l2 = texto({Text = "MALDITOS", FontFace = TITULO, TextSize = 112, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.new(1, 1, 1), Position = UDim2.fromOffset(0, 70), Size = UDim2.new(1, 0, 0, 112)}, logo)
dorado(l2)
crear("UIStroke", {Color = Color3.fromRGB(70, 20, 8), Thickness = 2.5}, l2)
local adorno = crear("Frame", {BackgroundColor3 = ORO, BorderSizePixel = 0, Position = UDim2.fromOffset(4, 196), Size = UDim2.new(0, 420, 0, 2)}, logo)
crear("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 0.2), NumberSequenceKeypoint.new(1, 1)})}, adorno)
crear("Frame", {BackgroundColor3 = ORO, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(4, 197), Size = UDim2.fromOffset(12, 12), Rotation = 45}, logo)
texto({Text = "Un descenso por los recorridos de un grafo", FontFace = CURSIVA, TextSize = 22, TextColor3 = Color3.fromRGB(230, 200, 175), TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(22, 208), Size = UDim2.new(1, 0, 0, 30)}, logo)

local lista = crear("Frame", {Name = "Botones", BackgroundTransparency = 1, Position = UDim2.fromScale(0.07, 0.12), Size = UDim2.new(0, 420, 0, 260)}, portada)
crear("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, lista)
local function botonMenu(etiqueta: string, orden: number, accion: () -> ()): TextButton
	local fila = crear("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 54), LayoutOrder = orden}, lista)
	local marca = crear("Frame", {BackgroundColor3 = BRASA, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(0, 0), Rotation = 45}, fila)
	local brillo = crear("Frame", {BackgroundColor3 = ORO, BorderSizePixel = 0, Position = UDim2.new(0, 28, 1, -6), Size = UDim2.new(0, 0, 0, 2)}, fila)
	crear("UIGradient", {Transparency = NumberSequence.new(0, 1)}, brillo)
	local b = crear("TextButton", {
		Text = etiqueta, FontFace = TITULO, TextSize = 32, TextColor3 = CREMA, BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -28, 1, 0), AutoButtonColor = false,
	}, fila)
	b.MouseEnter:Connect(function()
		tween(b, 0.25, {Position = UDim2.fromOffset(42, 0), TextColor3 = ORO})
		tween(marca, 0.25, {Size = UDim2.fromOffset(12, 12)})
		tween(brillo, 0.35, {Size = UDim2.new(0, 260, 0, 2)})
	end)
	b.MouseLeave:Connect(function()
		tween(b, 0.25, {Position = UDim2.fromOffset(28, 0), TextColor3 = CREMA})
		tween(marca, 0.25, {Size = UDim2.fromOffset(0, 0)})
		tween(brillo, 0.25, {Size = UDim2.new(0, 0, 0, 2)})
	end)
	b.Activated:Connect(accion)
	return b
end
texto({Text = "Proyecto de Matemáticas Discretas · Teoría de grafos", TextSize = 15, TextColor3 = Color3.fromRGB(190, 160, 150), TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0.07, 0, 1, -24), Size = UDim2.new(0, 600, 0, 20)}, portada)

-- panel lateral (niveles, teoría, créditos)
local panel = crear("CanvasGroup", {Name = "Panel", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.97, 0.5), Size = UDim2.fromOffset(1000, 640), Visible = false, GroupTransparency = 1}, portada)
Estilo.losa(panel, {Size = UDim2.fromScale(1, 1), corte = 28, anchoDiseno = 1000})
local _, tituloPanel = Estilo.estandarte(panel, "", {Size = UDim2.fromOffset(520, 56), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 30), TextSize = 30, alto = 56, ZIndex = 8})

local cuerpo = crear("Frame", {Name = "Cuerpo", BackgroundTransparency = 1, Position = UDim2.fromOffset(48, 104), Size = UDim2.new(1, -96, 1, -150), ZIndex = 6}, panel)

local function limpiarPanel() for _, c in cuerpo:GetChildren() do c:Destroy() end end
local function abrirPanel(titulo: string, construir: () -> ())
	efecto("Crujido")
	limpiarPanel()
	tituloPanel.Text = titulo
	construir()
	panel.Visible = true
	panel.Position = UDim2.new(0.97, 80, 0.5, 0)
	panel.GroupTransparency = 1
	tween(panel, 0.5, {Position = UDim2.fromScale(0.97, 0.5), GroupTransparency = 0})
end

-- mini grafo: aristas como barras giradas (paralelas desplazadas) y nodos coloreados por paridad
local function dibujarGrafo(contenedor: Frame, e: any, encendido: boolean)
	local grados: {[string]: number} = {}
	local repetidas: {[string]: number} = {}
	for _, a in e.aristas do
		grados[a[1]] = (grados[a[1]] or 0) + 1
		grados[a[2]] = (grados[a[2]] or 0) + 1
	end
	local function punto(id: string): Vector2 return e.nodos[id] end
	for _, a in e.aristas do
		local clave = if a[1] < a[2] then a[1] .. a[2] else a[2] .. a[1]
		repetidas[clave] = (repetidas[clave] or 0) + 1
		local n = repetidas[clave]
		local total = 0
		for _, b in e.aristas do if (b[1] == a[1] and b[2] == a[2]) or (b[1] == a[2] and b[2] == a[1]) then total += 1 end end
		local desplazamiento = if total > 1 then (n - (total + 1) / 2) * 7 else 0
		local p, q = punto(a[1]), punto(a[2])
		local linea = crear("Frame", {BackgroundColor3 = if encendido then ORO else Color3.fromRGB(120, 100, 100), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 2}, contenedor)
		local function ajustar()
			-- AbsoluteSize ya incluye el UIScale del panel; las medidas en offset se vuelven a escalar
			local escala = panel:FindFirstChildOfClass("UIScale")
			local k = if escala then escala.Scale else 1
			local tam = contenedor.AbsoluteSize / k
			local a2, b2 = Vector2.new(p.X * tam.X, p.Y * tam.Y), Vector2.new(q.X * tam.X, q.Y * tam.Y)
			local d = b2 - a2
			local normal = if d.Magnitude > 0 then Vector2.new(-d.Y, d.X).Unit else Vector2.zero
			local medio = (a2 + b2) / 2 + normal * desplazamiento
			linea.Position = UDim2.fromOffset(medio.X, medio.Y)
			linea.Size = UDim2.fromOffset(d.Magnitude, 3)
			linea.Rotation = math.deg(math.atan2(d.Y, d.X))
		end
		contenedor:GetPropertyChangedSignal("AbsoluteSize"):Connect(ajustar)
		ajustar()
	end
	for id, pos in e.nodos do
		local g = grados[id] or 0
		local color = if not encendido then Color3.fromRGB(110, 95, 100) elseif g % 2 == 0 then TURQUESA else BRASA
		local nodo = crear("Frame", {BackgroundColor3 = color, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(pos.X, pos.Y), Size = UDim2.fromOffset(20, 20), ZIndex = 3}, contenedor)
		esquinas(nodo, 10)
		crear("UIStroke", {Color = NOCHE, Thickness = 2}, nodo)
		texto({Text = id, FontFace = TITULO, TextSize = 13, TextColor3 = NOCHE, Size = UDim2.fromScale(1, 1), ZIndex = 4}, nodo)
	end
end

local iniciarNivel: (number) -> ()
local function construirNiveles()
	local rejilla = crear("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ScrollBarThickness = 4, ScrollBarImageColor3 = ORO, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()}, cuerpo)
	crear("UIGridLayout", {CellSize = UDim2.new(0.32, -6, 0, 250), CellPadding = UDim2.fromOffset(10, 12), SortOrder = Enum.SortOrder.LayoutOrder}, rejilla)
	for _, e in Catalogo do
		local abierto = disponible(e.id)
		local tarjeta = crear("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, LayoutOrder = e.id}, rejilla)
		Estilo.octogono(tarjeta, 0, 16, Estilo.color.tinta, 1)
		local filo = Estilo.octogono(tarjeta, 3, 15, if abierto then Estilo.color.bronce else Estilo.color.bronceOscuro, 1)
		Estilo.octogono(tarjeta, 6, 13, Estilo.color.piedra, 1)
		local function pintarFilo(color: Color3) for _, f in filo:GetChildren() do tween(f, 0.15, {BackgroundColor3 = color}) end end
		local romano = texto({Text = e.romano, FontFace = TITULO, TextSize = 34, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 36)}, tarjeta)
		if abierto then dorado(romano) else romano.TextColor3 = Color3.fromRGB(120, 100, 105) end
		texto({Text = e.nombre, FontFace = TITULO, TextSize = 19, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(14, 44), Size = UDim2.new(1, -28, 0, 24), TextColor3 = if abierto then CREMA else Color3.fromRGB(150, 130, 130)}, tarjeta)
		local etiqueta = texto({Text = e.concepto, TextSize = 12, TextColor3 = if abierto then NOCHE else Color3.fromRGB(170, 150, 150), AutomaticSize = Enum.AutomaticSize.X, Position = UDim2.fromOffset(14, 72), Size = UDim2.fromOffset(0, 20), BackgroundTransparency = 0, BackgroundColor3 = if abierto then ORO else Color3.fromRGB(60, 45, 55)}, tarjeta)
		esquinas(etiqueta, 10)
		crear("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, etiqueta)
		local lienzo = crear("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 104), Size = UDim2.new(1, -48, 0, 120)}, tarjeta)
		dibujarGrafo(lienzo, e, abierto)
		if not abierto then
			local candado = texto({Text = "PRÓXIMAMENTE", FontFace = TITULO, TextSize = 16, TextColor3 = ORO, BackgroundTransparency = 0.25, BackgroundColor3 = NOCHE, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.68), Size = UDim2.fromOffset(160, 30), ZIndex = 6}, tarjeta)
			esquinas(candado, 6)
		end
		for _, c in tarjeta:GetChildren() do if c:IsA("GuiObject") and c.Name ~= "Octogono" then c.ZIndex = math.max(c.ZIndex, 3) end end
		tarjeta.MouseEnter:Connect(function() pintarFilo(if abierto then Estilo.color.oro else Estilo.color.bronce) end)
		tarjeta.MouseLeave:Connect(function() pintarFilo(if abierto then Estilo.color.bronce else Estilo.color.bronceOscuro) end)
		tarjeta.Activated:Connect(function()
			if abierto then iniciarNivel(e.id) else efecto("Crujido") end
		end)
	end
end

local function construirTeoria()
	local marco = crear("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ScrollBarThickness = 4, ScrollBarImageColor3 = ORO, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()}, cuerpo)
	texto({
		AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, -12, 0, 0), TextSize = 18, LineHeight = 1.25,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Text = Textos.teoria,
	}, marco)
end

local function construirCreditos()
	texto({
		Size = UDim2.fromScale(1, 1), TextSize = 19, LineHeight = 1.3, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Text = table.concat({
			'<font color="#FFCD6E"><b>Puentes Malditos</b></font>',
			"Videojuego educativo sobre recorridos en grafos.",
			"Proyecto de Matemáticas Discretas · Teoría de grafos.",
			"",
			'<font color="#FFCD6E"><b>Equipo</b></font>',
			"Diseño, modelado 3D y programación: equipo Puentes Malditos.",
			"",
			'<font color="#FFCD6E"><b>Inspiración</b></font>',
			"La estética del inframundo griego de <i>Hades</i> (Supergiant Games).",
			"",
			'<font color="#FFCD6E"><b>Audio</b></font>',
			"Música: APM Music · Efectos: Pro Sound Effects (biblioteca de Roblox).",
		}, "\n"),
	}, cuerpo)
end

-- brasas que suben por la portada
task.spawn(function()
	local azar = Random.new()
	while true do
		if portada.Visible then
			local tam = azar:NextNumber(3, 7)
			local brasa = crear("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, azar:NextInteger(120, 210), 70), BorderSizePixel = 0,
				Position = UDim2.new(azar:NextNumber(0, 1), 0, 1.02, 0), Size = UDim2.fromOffset(tam, tam), BackgroundTransparency = 0.1,
			}, brasasUI)
			esquinas(brasa, 4)
			local dur = azar:NextNumber(5, 9)
			tween(brasa, dur, {Position = UDim2.new(brasa.Position.X.Scale + azar:NextNumber(-0.08, 0.08), 0, azar:NextNumber(0.1, 0.6), 0), BackgroundTransparency = 1}, Enum.EasingStyle.Sine)
			task.delay(dur, function() brasa:Destroy() end)
		end
		task.wait(0.12)
	end
end)

-- interfaz del intento (la crea UIController) ----------------------------------------------------
local function interfazIntento(visible: boolean)
	local ui = guiJugador:FindFirstChild("PuentesMalditosUI")
	if ui and ui:IsA("ScreenGui") then ui.Enabled = visible end
end
guiJugador.ChildAdded:Connect(function(c)
	if c.Name == "PuentesMalditosUI" and modo ~= "juego" then (c :: ScreenGui).Enabled = false end
end)

-- botón para volver al menú durante la partida
local botonVolver = crear("TextButton", {
	Text = "MENÚ", FontFace = TITULO, TextSize = 18, TextColor3 = ORO, BackgroundColor3 = NOCHE, BackgroundTransparency = 0.2,
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 14), Size = UDim2.fromOffset(96, 36), Visible = false, ZIndex = 30,
}, pantalla)
botonVolver.BackgroundTransparency = 1
botonVolver.TextTransparency = 1
Estilo.octogono(botonVolver, 0, 9, Estilo.color.tinta, 29)
Estilo.octogono(botonVolver, 3, 8, Estilo.color.bronce, 29)
Estilo.octogono(botonVolver, 5, 7, Estilo.color.piedra, 29)
local etiquetaVolver = texto({Text = "MENÚ", FontFace = TITULO, TextSize = 18, TextColor3 = ORO, Size = UDim2.fromScale(1, 1), ZIndex = 31}, botonVolver)
crear("UIStroke", {Color = Estilo.color.tinta, Thickness = 1.5}, etiquetaVolver)

-- rótulos de la cinemática
local tarjeta = crear("CanvasGroup", {Name = "TituloNivel", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.16), Size = UDim2.new(0.8, 0, 0, 190), GroupTransparency = 1, ZIndex = 40}, pantalla)
local tNumero = texto({FontFace = TITULO, TextSize = 26, TextColor3 = ORO, Size = UDim2.new(1, 0, 0, 30)}, tarjeta)
local tNombre = texto({FontFace = TITULO, TextSize = 76, TextColor3 = Color3.new(1, 1, 1), Position = UDim2.fromOffset(0, 32), Size = UDim2.new(1, 0, 0, 84)}, tarjeta)
dorado(tNombre)
crear("UIStroke", {Color = Color3.fromRGB(60, 18, 8), Thickness = 2}, tNombre)
local tConcepto = texto({FontFace = CURSIVA, TextSize = 24, Position = UDim2.fromOffset(0, 124), Size = UDim2.new(1, 0, 0, 56)}, tarjeta)

local rotulo = crear("CanvasGroup", {Name = "Rotulo", BackgroundTransparency = 1, Position = UDim2.new(0.06, 0, 0.66, 0), Size = UDim2.new(0, 560, 0, 140), GroupTransparency = 1, ZIndex = 40}, pantalla)
local rLinea = crear("Frame", {BackgroundColor3 = ORO, BorderSizePixel = 0, Size = UDim2.new(0, 4, 1, -20), Position = UDim2.fromOffset(0, 10)}, rotulo)
local rTitulo = texto({FontFace = TITULO, TextSize = 48, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(20, 4), Size = UDim2.new(1, -20, 0, 56)}, rotulo)
local rDetalle = texto({TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(20, 62), Size = UDim2.new(1, -20, 0, 70)}, rotulo)

local botonSaltar = crear("TextButton", {
	Text = "Saltar  ›", FontFace = TITULO, TextSize = 20, TextColor3 = CREMA, BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -40, 1, -24), Size = UDim2.fromOffset(140, 36), Visible = false, ZIndex = 60,
}, pantalla)
botonSaltar.Activated:Connect(function() saltar = true end)
UserInputService.InputBegan:Connect(function(input, procesado)
	if modo == "cinematica" and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return) then saltar = true end
end)

local function mostrarRotulo(titulo: string, detalle: string, color: Color3)
	rTitulo.Text, rDetalle.Text = titulo, detalle
	rTitulo.TextColor3, rLinea.BackgroundColor3 = color, color
	rotulo.Position = UDim2.new(0.04, 0, 0.66, 0)
	tween(rotulo, 0.45, {GroupTransparency = 0, Position = UDim2.new(0.06, 0, 0.66, 0)})
end
local function ocultarRotulo() tween(rotulo, 0.3, {GroupTransparency = 1}) end

-- escala: todo se diseña para 950 px de alto y se ajusta a la pantalla real
local escalables: {GuiObject} = {logo, lista, panel, tarjeta, rotulo, botonVolver, botonSaltar}
local escalas: {UIScale} = {}
for _, g in escalables do table.insert(escalas, crear("UIScale", {}, g)) end
local function ajustarEscala()
	local alto = camara.ViewportSize.Y
	local k = math.clamp(alto / 950, 0.45, 1.4)
	for _, u in escalas do u.Scale = k end
	-- los botones quedan debajo del logo, que mide 250 px de diseño
	lista.Position = UDim2.new(0.07, 0, 0.12, 270 * k)
end
camara:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala)
ajustarEscala()

-- cámara ----------------------------------------------------------------------------------------
local orbitaCentro = Vector3.new(0, 10, 0)

-- tomas del menú: cortes a negro y un zoom lento desde abajo hacia el modelo ("lookup")
type Toma = {desde: CFrame, hasta: CFrame, fovDesde: number, fovHasta: number, titulo: string, detalle: string}
local tomas: {Toma} = {}
local tomaIndice = 0
local tomaInicio = 0
local DURACION_TOMA = 6.5
local cortina = crear("Frame", {Name = "Cortina", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 5}, pantalla)
local leyenda = crear("CanvasGroup", {Name = "Leyenda", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -48, 1, -96), Size = UDim2.fromOffset(520, 80), GroupTransparency = 1}, portada)
table.insert(escalas, crear("UIScale", {Scale = escalas[1].Scale}, leyenda))
crear("Frame", {BackgroundColor3 = ORO, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 6), Size = UDim2.new(0, 3, 1, -12)}, leyenda)
local lTitulo = texto({FontFace = TITULO, TextSize = 32, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -16, 0, 38)}, leyenda)
dorado(lTitulo)
local lDetalle = texto({FontFace = CURSIVA, TextSize = 18, TextColor3 = Color3.fromRGB(235, 210, 190), TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, -16, 0, 26)}, leyenda)

local function plano(v: Vector3, respaldo: Vector3): Vector3
	local p = Vector3.new(v.X, 0, v.Z)
	return if p.Magnitude > 0.01 then p.Unit else respaldo
end
local function girar(v: Vector3, grados: number): Vector3
	return CFrame.Angles(0, math.rad(grados), 0):VectorToWorldSpace(v)
end
-- base: pie del sujeto; alto: altura a recorrer con la mirada; dir: del sujeto hacia la cámara
local function agregarToma(base: Vector3, alto: number, dir: Vector3, dist: number, titulo: string, detalle: string)
	local lateral = Vector3.new(-dir.Z, 0, dir.X)
	local desdePos = base + dir * dist + lateral * dist * 0.12 + Vector3.new(0, alto * 0.08, 0)
	local hastaPos = base + dir * dist * 0.7 - lateral * dist * 0.05 + Vector3.new(0, alto * 0.04, 0)
	table.insert(tomas, {
		desde = CFrame.lookAt(desdePos, base + Vector3.new(0, alto * 0.45, 0)),
		hasta = CFrame.lookAt(hastaPos, base + Vector3.new(0, alto * 0.95, 0)),
		fovDesde = 60, fovHasta = 48, titulo = titulo, detalle = detalle,
	})
end

local function construirTomas()
	table.clear(tomas)
	local islas, centro, cerberus = leerNivel(if nivelEnCurso > 0 then nivelEnCurso else 1)
	local nivel = niveles:FindFirstChild("Nivel" .. (if nivelEnCurso > 0 then nivelEnCurso else 1))
	if cerberus then
		local piv = cerberus:GetPivot()
		local alto = cerberus:GetExtentsSize().Y
		agregarToma(piv.Position, alto, girar(plano(piv.LookVector, Vector3.zAxis), 28), alto * 1.35, "CERBERUS", "Guardián de tres cabezas")
	end
	local puentes = nivel and nivel:FindFirstChild("Bridges")
	if puentes then
		for _, p in puentes:GetDescendants() do
			if p:IsA("BasePart") and p:GetAttribute("Kind") == "Llama" then
				local modelo = p:FindFirstAncestorOfClass("Model")
				local eje = if modelo then plano(modelo:GetPivot().LookVector, Vector3.xAxis) else Vector3.xAxis
				local base = p.Position - Vector3.new(0, 9, 0)
				agregarToma(base, 11, plano(girar(eje, 110), Vector3.xAxis), 15, "LOS PUENTES MALDITOS", "Cada uno se derrumba cuando lo cruzas")
				break
			end
		end
	end
	local fondo = workspace:FindFirstChild("FondoPalacio")
	local torre = fondo and fondo:FindFirstChild("Palacio_Hades_Torre", true)
	if torre and torre:IsA("BasePart") then
		local base = torre.Position - Vector3.new(0, torre.Size.Y / 2 + 20, 0)
		agregarToma(base, torre.Size.Y * 1.9, plano(centro - torre.Position, Vector3.zAxis), 170, "EL PALACIO DE HADES", "Nadie escapa del inframundo… todavía")
	end
	if nivel and #islas > 0 then
		local isla = islas[1]
		for _, p in nivel:GetDescendants() do
			if p:IsA("BasePart") and p.Name:find("obelisco") and (p.Position - isla.centro).Magnitude < 70 then
				local fuera = plano(p.Position - isla.centro, Vector3.zAxis)
				agregarToma(p.Position - Vector3.new(0, p.Size.Y / 2, 0), p.Size.Y * 1.6, girar(fuera, 35), 18, "LAS ISLAS", "Cada isla es un vértice del grafo")
				break
			end
		end
	end
	local saliente = fondo and fondo:FindFirstChild("Saliente", true)
	if saliente and saliente:IsA("BasePart") then
		local base = Vector3.new(saliente.Position.X, -50, saliente.Position.Z)
		agregarToma(base, saliente.Position.Y + saliente.Size.Y / 2 + 50, plano(centro - saliente.Position, Vector3.zAxis), 90, "EL ABISMO", "Bajo los puentes solo hay lava")
	end
	table.insert(tomas, {
		desde = CFrame.lookAt(centro + Vector3.new(60, 230, 210), centro),
		hasta = CFrame.lookAt(centro + Vector3.new(20, 170, 150), centro),
		fovDesde = 55, fovHasta = 50, titulo = "EL ARCHIPIÉLAGO", detalle = "Islas y puentes: un grafo que debes recorrer",
	})
end

RunService:BindToRenderStep("CamaraMenu", Enum.RenderPriority.Camera.Value + 2, function()
	if modo ~= "menu" and modo ~= "transicion" then return end
	camara.CameraType = Enum.CameraType.Scriptable
	if #tomas == 0 then construirTomas() end
	if #tomas == 0 then return end
	local ahora = os.clock()
	if tomaIndice == 0 or ahora - tomaInicio >= DURACION_TOMA then
		-- con streaming, los modelos lejanos llegan después: se reintenta hasta tener todas las tomas
		if #tomas < 6 then construirTomas() end
		tomaIndice = tomaIndice % #tomas + 1
		tomaInicio = ahora
		lTitulo.Text = tomas[tomaIndice].titulo
		lDetalle.Text = tomas[tomaIndice].detalle
	end
	local toma = tomas[tomaIndice]
	local transcurrido = ahora - tomaInicio
	local t = transcurrido / DURACION_TOMA
	local k = 1 - (1 - t) ^ 1.7
	camara.CFrame = toma.desde:Lerp(toma.hasta, k)
	camara.FieldOfView = toma.fovDesde + (toma.fovHasta - toma.fovDesde) * k
	-- corte a negro al entrar y al salir de cada toma
	local negro = math.max(1 - transcurrido / 0.6, 1 - (DURACION_TOMA - transcurrido) / 0.5, 0)
	cortina.BackgroundTransparency = 1 - math.clamp(negro, 0, 1)
	local visible = math.clamp(math.min((transcurrido - 0.9) / 0.5, (DURACION_TOMA - 0.7 - transcurrido) / 0.4), 0, 1)
	if panel.Visible then visible = 0 end
	leyenda.GroupTransparency = 1 - visible
	leyenda.Position = UDim2.new(1, -48 + (1 - visible) * 30, 1, -96)
end)

local function esperar(t: number)
	local fin = os.clock() + t
	while os.clock() < fin and not saltar do task.wait() end
end
local function mover(destino: CFrame, t: number)
	if saltar then return end
	local tw = TweenService:Create(camara, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = destino})
	tw:Play()
	esperar(t)
	if saltar then tw:Cancel() end
end

local function conclusion(id: number): (string, string)
	if id == 1 then return Textos.tituloNivel1, Textos.detalleNivel1 end
	return "Elige tu recorrido", "Observa el grafo y construye el recorrido solicitado por el objetivo."
end

local function raizJugador(): BasePart?
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	return if raiz and raiz:IsA("BasePart") then raiz else nil
end

local function cinematica(id: number)
	modo = "cinematica"
	saltar = false
	camara.FieldOfView = 70
	cortina.BackgroundTransparency = 1
	local e = entrada(id)
	local _, centro, cerberus = leerNivel(id)
	camara.CameraType = Enum.CameraType.Scriptable
	barras(true)
	botonSaltar.Visible = true
	interfazIntento(false)

	-- 1. plano general con el título
	camara.CFrame = CFrame.lookAt(centro + Vector3.new(-40, 170, 330), centro)
	tween(velo, 1, {BackgroundTransparency = 1})
	tNumero.Text = "NIVEL " .. (if e then e.romano else tostring(id))
	tNombre.Text = if e then string.upper(e.nombre) else "NIVEL " .. id
	tConcepto.Text = if id == 1 then "Sendero · " .. Textos.presentacionSendero else "Observa el grafo y elige tu recorrido."
	efecto("Gong")
	tarjeta.Position = UDim2.fromScale(0.5, 0.12)
	tween(tarjeta, 1.2, {GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.16)})
	mover(CFrame.lookAt(centro + Vector3.new(30, 110, 230), centro), 4.2)
	tween(tarjeta, 0.6, {GroupTransparency = 1})

	-- 2. panorama del grafo, sin sugerir una secuencia de islas.
	if not saltar then
		mover(CFrame.lookAt(centro + Vector3.new(-95, 145, 175), centro), 2.2)
		mostrarRotulo("Un mapa, un grafo", Textos.fundamentos, ORO)
		esperar(2.5)
		ocultarRotulo()
	end

	-- 3. presentación del desafío sin revelar soluciones.
	if not saltar then
		mover(CFrame.lookAt(centro + Vector3.new(0, 190, 120), centro), 1.8)
		local t1, t2 = conclusion(id)
		mostrarRotulo(t1, t2, ORO)
		esperar(3.2)
		ocultarRotulo()
	end

	-- 4. Cerberus
	if cerberus and not saltar then
		local piv = cerberus:GetPivot()
		local alto = cerberus:GetExtentsSize().Y
		mover(CFrame.lookAt(piv.Position + piv.LookVector * (alto * 1.4) + Vector3.new(0, alto * 0.45, 0), piv.Position + Vector3.new(0, alto * 0.55, 0)), 1.8)
		camara:SetAttribute("RugidoCerberus", os.clock())
		efecto("Rugido")
		mostrarRotulo("CERBERUS", "Seguirá tu recorrido después de la ventaja inicial. No dejes que te alcance.", BRASA)
		esperar(2.4)
		ocultarRotulo()
	end

	-- 5. de vuelta al jugador
	tween(tarjeta, 0.2, {GroupTransparency = 1})
	ocultarRotulo()
	local raiz = raizJugador()
	if raiz then
		saltar = false
		mover(raiz.CFrame * CFrame.new(0, 6, 15) * CFrame.Angles(math.rad(-12), 0, 0), 1.4)
	end
	botonSaltar.Visible = false
	barras(false)
	camara.CameraType = Enum.CameraType.Custom
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if humanoide then camara.CameraSubject = humanoide end
	modo = "juego"
	nivelEnCurso = id
	interfazIntento(true)
	botonVolver.Visible = true
	musica("MusicaPartida")
end

local function esperarEstado(id: number, intentoMinimo: number)
	local fin = os.clock() + 4
	while os.clock() < fin do
		local e = ultimoEstado
		if e and e.levelId == id and e.fase == "preparacion" and e.intentoId > intentoMinimo then return end
		task.wait(0.05)
	end
end

iniciarNivel = function(id: number)
	if modo ~= "menu" or not disponible(id) then return end
	modo = "transicion"
	efecto("Gong")
	tween(portada, 0.6, {GroupTransparency = 1})
	tween(velo, 0.8, {BackgroundTransparency = 0})
	task.wait(0.8)
	portada.Visible = false
	local previo = if ultimoEstado and ultimoEstado.levelId == id then ultimoEstado.intentoId else -1
	seleccionarNivel:FireServer(id)
	esperarEstado(id, previo)
	local nivel = niveles:WaitForChild("Nivel" .. id, 15)
	local islas = nivel and nivel:WaitForChild("Islands", 15)
	local isla = islas and islas:WaitForChild("Island_A", 15)
	local superficie = isla and isla:WaitForChild("Superficie", 15)
	if not (superficie and superficie:IsA("BasePart")) then
		warn("El mapa no terminó de cargar para la presentación del nivel " .. id)
		modo = "menu"
		portada.Visible, portada.GroupTransparency = true, 0
		velo.BackgroundTransparency = 1
		return
	end
	pcall(function() jugador:RequestStreamAroundAsync(superficie.Position, 5) end)
	cinematica(id)
end

local function mostrarMenu()
	modo = "menu"
	botonVolver.Visible = false
	botonSaltar.Visible = false
	interfazIntento(false)
	local _, centro = leerNivel(if nivelEnCurso > 0 then nivelEnCurso else 1)
	orbitaCentro = centro
	table.clear(tomas)
	tomaIndice = 0
	portada.Visible = true
	panel.Visible = false
	portada.GroupTransparency = 1
	barras(true)
	tween(velo, 1.2, {BackgroundTransparency = 1})
	tween(portada, 1.4, {GroupTransparency = 0})
	musica("MusicaMenu")
end

botonMenu("JUGAR", 1, function()
	local siguiente = 1
	for _, e in Catalogo do if disponible(e.id) then siguiente = math.max(siguiente, if e.id <= nivelEnCurso + 1 then e.id else siguiente) end end
	iniciarNivel(siguiente)
end)
botonMenu("NIVELES", 2, function() abrirPanel("Elige tu descenso", construirNiveles) end)
botonMenu("CÓMO SE JUEGA", 3, function() abrirPanel("Islas, puentes y recorridos", construirTeoria) end)
botonMenu("CRÉDITOS", 4, function() abrirPanel("Créditos", construirCreditos) end)

botonVolver.Activated:Connect(function()
	if modo ~= "juego" then return end
	local e = ultimoEstado
	if e and e.fase == "activo" then reiniciarNivel:FireServer(e.intentoId) end
	tween(velo, 0.5, {BackgroundTransparency = 0})
	task.wait(0.5)
	mostrarMenu()
end)

-- si el servidor cambia de nivel durante la partida (Continuar), se presenta el nuevo nivel
estadoActualizado.OnClientEvent:Connect(function(estado)
	local anterior = ultimoEstado
	ultimoEstado = estado
	if modo == "juego" and estado.levelId ~= nivelEnCurso and estado.fase == "preparacion" then
		task.spawn(cinematica, estado.levelId)
	elseif modo == "juego" and anterior and anterior.fase ~= "activo" and estado.fase == "activo" then
		musica("MusicaPartida")
	end
end)

mostrarMenu()


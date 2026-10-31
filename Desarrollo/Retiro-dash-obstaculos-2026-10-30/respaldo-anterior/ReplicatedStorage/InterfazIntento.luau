--!strict
-- Interfaz del intento con el estilo de Puentes Malditos (losas de bronce, estandartes y constelaciones).
local Contratos = require(script.Parent.ContratosJuego)
local Textos = require(script.Parent.TextosEducativos)
local Estilo = require(script.Parent.EstiloHades)
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
type Estado = Contratos.EstadoPresentacion
type Resultado = Contratos.Resultado
export type Acciones = {alComenzar: () -> (), alReintentar: () -> (), alContinuar: () -> ()}
local Interfaz = {}
local C = Estilo.color

function Interfaz.crear(contenedor: Instance, acciones: Acciones)
	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "PuentesMalditosUI"
	pantalla.ResetOnSpawn = false
	pantalla.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pantalla.Parent = contenedor
	local conexiones: {RBXScriptConnection} = {}
	local camara = workspace.CurrentCamera

	-- objetivo durante la partida: losa con estandarte
	local cabecera = Instance.new("Frame")
	cabecera.Name = "Objetivo"
	cabecera.BackgroundTransparency = 1
	cabecera.AnchorPoint = Vector2.new(0.5, 0)
	cabecera.Position = UDim2.new(0.5, 0, 0, 24)
	cabecera.Size = UDim2.fromOffset(620, 118)
	cabecera.Parent = pantalla
	local escalaCabecera = Instance.new("UIScale")
	escalaCabecera.Parent = cabecera
	local losaCabecera = Estilo.losa(cabecera, {Size = UDim2.fromScale(1, 1), corte = 16, anchoDiseno = 620, constelacion = true})
	local _, titulo = Estilo.estandarte(cabecera, "", {Size = UDim2.fromOffset(380, 38), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 2), TextSize = 20, ZIndex = 8})
	titulo.Name = "TipoRecorrido"
	local objetivo = Estilo.crear("TextLabel", {
		Name = "Condiciones", BackgroundTransparency = 1, FontFace = Estilo.fuente.texto, TextSize = 18, TextColor3 = C.crema,
		TextWrapped = true, Position = UDim2.fromOffset(0, 10), Size = UDim2.new(1, 0, 1, -10), ZIndex = 6,
	}, losaCabecera.contenido)

	-- ventana de preparación y resultado
	local ventana = Instance.new("Frame")
	ventana.Name = "ResultadoOPreparacion"
	ventana.BackgroundTransparency = 1
	ventana.AnchorPoint = Vector2.new(0.5, 0.5)
	ventana.Position = UDim2.fromScale(0.5, 0.52)
	ventana.Size = UDim2.fromScale(0.85, 0.75)
	ventana.Parent = pantalla
	local limites = Instance.new("UISizeConstraint")
	limites.MaxSize = Vector2.new(720, 560)
	limites.Parent = ventana
	local losa = Estilo.losa(ventana, {Size = UDim2.fromScale(1, 1), corte = 22, meandro = false})
	local bandera, encabezado = Estilo.estandarte(ventana, "", {Size = UDim2.new(0.72, 0, 0, 50), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 4), TextSize = 26, alto = 50, ZIndex = 8})
	encabezado.Name = "Encabezado"
	Estilo.separador(losa.contenido, {Position = UDim2.new(0.1, 0, 0, 24), Size = UDim2.new(0.8, 0, 0, 12), ZIndex = 6})
	local contenido = Instance.new("ScrollingFrame")
	contenido.Name = "Contenido"
	contenido.BackgroundTransparency, contenido.BorderSizePixel = 1, 0
	contenido.Position, contenido.Size = UDim2.fromOffset(8, 46), UDim2.new(1, -16, 1, -120)
	contenido.CanvasSize = UDim2.new()
	contenido.ScrollingDirection = Enum.ScrollingDirection.Y
	contenido.ScrollBarThickness = 4
	contenido.ScrollBarImageColor3 = C.bronce
	contenido.ZIndex = 6
	contenido.Parent = losa.contenido
	local mensaje = Estilo.crear("TextLabel", {
		Name = "Explicacion", BackgroundTransparency = 1, FontFace = Estilo.fuente.texto, TextSize = 18, TextColor3 = C.crema,
		TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, -12, 0, 0), ZIndex = 6,
	}, contenido)
	local function ajustarTexto()
		local ancho = math.floor(contenido.AbsoluteSize.X) - 12
		if ancho <= 0 then return end
		local params = Instance.new("GetTextBoundsParams")
		params.Text, params.Font, params.Size, params.Width = mensaje.ContentText, mensaje.FontFace, mensaje.TextSize, ancho
		local ok, limites2 = pcall(function() return TextService:GetTextBoundsAsync(params) end)
		local altura = (if ok then math.ceil(limites2.Y) else 400) + 8
		mensaje.Size = UDim2.new(1, -12, 0, altura)
		contenido.CanvasSize = UDim2.fromOffset(0, altura + 4)
	end
	table.insert(conexiones, contenido:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() task.spawn(ajustarTexto) end))
	local function establecerMensaje(texto: string)
		if mensaje.Text ~= texto then
			mensaje.Text = texto
			task.spawn(ajustarTexto)
			contenido.CanvasPosition = Vector2.zero
		end
	end
	local function boton(nombre: string, texto: string, posicion: UDim2, accion: () -> ()): TextButton
		local b = Estilo.boton(losa.contenido, texto, {Name = nombre, Size = UDim2.new(0.5, -12, 0, 50), Position = posicion, AnchorPoint = Vector2.new(0, 1), ZIndex = 6}, accion)
		return b
	end
	local function ponerTexto(b: TextButton, texto: string) (b:FindFirstChild("Etiqueta") :: TextLabel).Text = texto end
	local empezar = boton("Comenzar", "COMENZAR", UDim2.new(0, 0, 1, 0), acciones.alComenzar)
	local repetir = boton("Reintentar", "REINTENTAR", UDim2.new(0, 0, 1, 0), acciones.alReintentar)
	local continuar = boton("Continuar", "CONTINUAR", UDim2.new(0.5, 12, 1, 0), acciones.alContinuar)

	-- escala según la pantalla
	local function ajustarEscala()
		escalaCabecera.Scale = math.clamp(camara.ViewportSize.Y / 950, 0.55, 1.3)
	end
	table.insert(conexiones, camara:GetPropertyChangedSignal("ViewportSize"):Connect(ajustarEscala))
	ajustarEscala()

	local function aparecer(obj: GuiObject)
		if obj.Visible then return end
		obj.Visible = true
		local inicio = obj.Position
		obj.Position = inicio + UDim2.fromOffset(0, -20)
		TweenService:Create(obj, TweenInfo.new(0.45, Enum.EasingStyle.Back), {Position = inicio}):Play()
	end

	local function mostrarResultado(resultado: Resultado)
		cabecera.Visible = false
		aparecer(ventana)
		empezar.Visible, repetir.Visible = false, true
		local victoria = resultado.outcome == "victory"
		encabezado.Text = if victoria then "¡NIVEL SUPERADO!" else "FIN DEL INTENTO"
		encabezado.TextColor3 = if victoria then C.oro else C.crema
		establecerMensaje(resultado.message)
		ponerTexto(repetir, if victoria then "REPETIR NIVEL" else "REINTENTAR")
	end
	local function actualizar(estado: Estado)
		titulo.Text = "NIVEL " .. estado.levelId .. " · " .. string.upper(estado.titulo)
		objetivo.Text = estado.instruccion
		cabecera.Visible = estado.fase == "activo"
		continuar.Visible = estado.fase == "victoria" and estado.puedeContinuar
		if estado.fase == "preparacion" then
			aparecer(ventana)
			empezar.Visible, repetir.Visible = true, false
			empezar.Active = estado.mapaListo ~= false
			ponerTexto(empezar, if empezar.Active then "COMENZAR" else "CARGANDO…")
			encabezado.Text, encabezado.TextColor3 = "NIVEL " .. estado.levelId .. " · " .. string.upper(estado.titulo), C.crema
			establecerMensaje(Textos.preparacion(estado.instruccion, estado.definicion, estado.levelId) .. "\n\nEMBESTIDA\nPulsa Shift para embestir hacia donde te mueves. Úsala para cruzar las rejillas de fuego y esquivar las rocas que caen.")
		elseif estado.resultado then
			mostrarResultado(estado.resultado)
		else
			ventana.Visible = false
		end
	end
	return {
		actualizar = actualizar,
		mostrarResultado = mostrarResultado,
		destruir = function()
			for _, conexion in conexiones do conexion:Disconnect() end
			pantalla:Destroy()
		end,
	}
end
return Interfaz


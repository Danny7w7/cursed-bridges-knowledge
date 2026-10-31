--!strict
local Contratos = require(script.Parent.ContratosJuego)
local Textos = require(script.Parent.TextosEducativos)
local TextService = game:GetService("TextService")
type Estado = Contratos.EstadoPresentacion
type Resultado = Contratos.Resultado
export type Acciones = {alComenzar: () -> (), alReintentar: () -> (), alContinuar: () -> ()}
local Interfaz = {}

function Interfaz.crear(contenedor: Instance, acciones: Acciones)
	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "PuentesMalditosUI"
	pantalla.ResetOnSpawn = false
	pantalla.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pantalla.Parent = contenedor
	local conexiones: {RBXScriptConnection} = {}
	local function marco(nombre: string, padre: Instance, tamano: UDim2, posicion: UDim2): Frame
		local fondo = Instance.new("Frame")
		fondo.Name, fondo.Size, fondo.Position = nombre, tamano, posicion
		fondo.BackgroundColor3 = Color3.fromRGB(18, 9, 22)
		fondo.BackgroundTransparency = 0.12
		fondo.BorderSizePixel = 0
		fondo.Parent = padre
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(0, 8)
		esquina.Parent = fondo
		local borde = Instance.new("UIStroke")
		borde.Color = Color3.fromRGB(255, 205, 110)
		borde.Transparency = 0.5
		borde.Thickness = 1.5
		borde.Parent = fondo
		return fondo
	end
	local function etiqueta(nombre: string, padre: Instance, tamano: UDim2, posicion: UDim2, fuente: Enum.Font, medida: number): TextLabel
		local texto = Instance.new("TextLabel")
		texto.Name, texto.Size, texto.Position = nombre, tamano, posicion
		texto.BackgroundTransparency = 1
		texto.Font, texto.TextSize = fuente, medida
		if fuente == Enum.Font.Bodoni then texto.FontFace = Font.new(texto.FontFace.Family, Enum.FontWeight.Bold) end
		texto.TextColor3 = Color3.fromRGB(248, 229, 211)
		texto.TextWrapped = true
		texto.TextXAlignment = Enum.TextXAlignment.Left
		texto.TextYAlignment = Enum.TextYAlignment.Top
		texto.Parent = padre
		return texto
	end
	local cabecera = marco("Objetivo", pantalla, UDim2.fromOffset(590, 116), UDim2.new(0.5, -295, 0, 20))
	local titulo = etiqueta("TipoRecorrido", cabecera, UDim2.new(1, -36, 0, 25), UDim2.fromOffset(18, 13), Enum.Font.Bodoni, 20)
	titulo.TextColor3 = Color3.fromRGB(255, 205, 110)
	local objetivo = etiqueta("Condiciones", cabecera, UDim2.new(1, -36, 0, 62), UDim2.fromOffset(18, 43), Enum.Font.Merriweather, 18)
	local ventana = marco("ResultadoOPreparacion", pantalla, UDim2.fromScale(0.85, 0.75), UDim2.fromScale(0.5, 0.5))
	ventana.AnchorPoint = Vector2.new(0.5, 0.5)
	local limites = Instance.new("UISizeConstraint")
	limites.MaxSize = Vector2.new(720, 560)
	limites.Parent = ventana
	local encabezado = etiqueta("Encabezado", ventana, UDim2.new(1, -48, 0, 42), UDim2.fromOffset(24, 22), Enum.Font.Bodoni, 28)
	local contenido = Instance.new("ScrollingFrame")
	contenido.Name = "Contenido"
	contenido.BackgroundTransparency, contenido.BorderSizePixel = 1, 0
	contenido.Position, contenido.Size = UDim2.fromOffset(24, 77), UDim2.new(1, -48, 1, -155)
	contenido.AutomaticCanvasSize = Enum.AutomaticSize.None
	contenido.CanvasSize = UDim2.new()
	contenido.ScrollingDirection = Enum.ScrollingDirection.Y
	contenido.ScrollBarThickness = 4
	contenido.ScrollBarImageColor3 = Color3.fromRGB(255, 205, 110)
	contenido.Parent = ventana
	local mensaje = etiqueta("Explicacion", contenido, UDim2.new(1, -12, 0, 0), UDim2.fromOffset(0, 0), Enum.Font.Merriweather, 18)
	local function ajustarTexto()
		local ancho = math.floor(contenido.AbsoluteSize.X) - 12
		if ancho <= 0 then return end
		local altura = math.ceil(TextService:GetTextSize(mensaje.Text, mensaje.TextSize, mensaje.Font, Vector2.new(ancho, 100000)).Y) + 4
		mensaje.Size = UDim2.new(1, -12, 0, altura)
		contenido.CanvasSize = UDim2.fromOffset(0, altura + 4)
	end
	table.insert(conexiones, contenido:GetPropertyChangedSignal("AbsoluteSize"):Connect(ajustarTexto))
	local function establecerMensaje(texto: string)
		if mensaje.Text ~= texto then
			mensaje.Text = texto
			ajustarTexto()
			contenido.CanvasPosition = Vector2.zero
		end
	end
	local function boton(nombre: string, texto: string, posicion: UDim2, accion: () -> ()): TextButton
		local objeto = Instance.new("TextButton")
		objeto.Name, objeto.Text = nombre, texto
		objeto.Size, objeto.Position = UDim2.new(0.5, -36, 0, 48), posicion
		objeto.BackgroundColor3 = Color3.fromRGB(70, 24, 30)
		objeto.Font, objeto.TextSize = Enum.Font.Bodoni, 22
		objeto.FontFace = Font.new(objeto.FontFace.Family, Enum.FontWeight.Bold)
		objeto.TextColor3 = Color3.fromRGB(255, 205, 110)
		local trazo = Instance.new("UIStroke")
		trazo.Color = Color3.fromRGB(255, 205, 110)
		trazo.Transparency = 0.35
		trazo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		trazo.Parent = objeto
		objeto.BorderSizePixel = 0
		objeto.Parent = ventana
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(0, 9)
		esquina.Parent = objeto
		table.insert(conexiones, objeto.Activated:Connect(accion))
		return objeto
	end
	local empezar = boton("Comenzar", "Comenzar", UDim2.new(0, 24, 1, -64), acciones.alComenzar)
	local repetir = boton("Reintentar", "Reintentar", UDim2.new(0, 24, 1, -64), acciones.alReintentar)
	local continuar = boton("Continuar", "Continuar", UDim2.new(0.5, 12, 1, -64), acciones.alContinuar)
	local function mostrarResultado(resultado: Resultado)
		cabecera.Visible = false
		ventana.Visible = true
		empezar.Visible, repetir.Visible = false, true
		encabezado.Text = if resultado.outcome == "victory" then "¡Nivel superado!" else "Fin del intento"
		encabezado.TextColor3 = if resultado.outcome == "victory" then Color3.fromRGB(133, 233, 175) else Color3.fromRGB(255, 151, 108)
		establecerMensaje(resultado.message)
		repetir.Text = if resultado.outcome == "victory" then "Repetir nivel" else "Reintentar"
	end
	local function actualizar(estado: Estado)
		titulo.Text = "NIVEL " .. estado.levelId .. " · " .. string.upper(estado.titulo)
		objetivo.Text = estado.instruccion
		cabecera.Visible = estado.fase == "activo"
		continuar.Visible = estado.fase == "victoria" and estado.puedeContinuar
		if estado.fase == "preparacion" then
			ventana.Visible = true
			empezar.Visible, repetir.Visible = true, false
			empezar.Active = estado.mapaListo ~= false
			empezar.AutoButtonColor = empezar.Active
			empezar.Text = if empezar.Active then "Comenzar" else "Cargando escenario…"
			encabezado.Text, encabezado.TextColor3 = "Nivel " .. estado.levelId .. " · " .. estado.titulo, Color3.fromRGB(255, 205, 110)
			establecerMensaje(Textos.preparacion(estado.instruccion, estado.definicion, estado.levelId))
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

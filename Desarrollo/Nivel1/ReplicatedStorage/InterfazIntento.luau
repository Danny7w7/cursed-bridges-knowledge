--!strict
local Contratos = require(script.Parent.ContratosJuego)
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
		fondo.BackgroundColor3 = Color3.fromRGB(19, 14, 23)
		fondo.BackgroundTransparency = 0.08
		fondo.BorderSizePixel = 0
		fondo.Parent = padre
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(0, 14)
		esquina.Parent = fondo
		local borde = Instance.new("UIStroke")
		borde.Color = Color3.fromRGB(221, 125, 63)
		borde.Transparency = 0.45
		borde.Parent = fondo
		return fondo
	end
	local function etiqueta(nombre: string, padre: Instance, tamano: UDim2, posicion: UDim2, fuente: Enum.Font, medida: number): TextLabel
		local texto = Instance.new("TextLabel")
		texto.Name, texto.Size, texto.Position = nombre, tamano, posicion
		texto.BackgroundTransparency = 1
		texto.Font, texto.TextSize = fuente, medida
		texto.TextColor3 = Color3.fromRGB(248, 229, 211)
		texto.TextWrapped = true
		texto.TextXAlignment = Enum.TextXAlignment.Left
		texto.TextYAlignment = Enum.TextYAlignment.Top
		texto.Parent = padre
		return texto
	end
	local cabecera = marco("Objetivo", pantalla, UDim2.fromOffset(590, 116), UDim2.new(0.5, -295, 0, 20))
	local titulo = etiqueta("TipoRecorrido", cabecera, UDim2.new(1, -36, 0, 25), UDim2.fromOffset(18, 13), Enum.Font.FredokaOne, 20)
	titulo.TextColor3 = Color3.fromRGB(255, 166, 86)
	local objetivo = etiqueta("Condiciones", cabecera, UDim2.new(1, -36, 0, 62), UDim2.fromOffset(18, 43), Enum.Font.GothamMedium, 18)
	local ventana = marco("ResultadoOPreparacion", pantalla, UDim2.fromOffset(620, 350), UDim2.fromScale(0.5, 0.56))
	ventana.AnchorPoint = Vector2.new(0.5, 0.5)
	local encabezado = etiqueta("Encabezado", ventana, UDim2.new(1, -48, 0, 42), UDim2.fromOffset(24, 22), Enum.Font.FredokaOne, 28)
	local mensaje = etiqueta("Explicacion", ventana, UDim2.new(1, -48, 0, 188), UDim2.fromOffset(24, 77), Enum.Font.GothamMedium, 18)
	local function boton(nombre: string, texto: string, posicion: UDim2, accion: () -> ()): TextButton
		local objeto = Instance.new("TextButton")
		objeto.Name, objeto.Text = nombre, texto
		objeto.Size, objeto.Position = UDim2.fromOffset(240, 48), posicion
		objeto.BackgroundColor3 = Color3.fromRGB(143, 62, 34)
		objeto.Font, objeto.TextSize = Enum.Font.FredokaOne, 20
		objeto.TextColor3 = Color3.fromRGB(255, 240, 218)
		objeto.BorderSizePixel = 0
		objeto.Parent = ventana
		local esquina = Instance.new("UICorner")
		esquina.CornerRadius = UDim.new(0, 9)
		esquina.Parent = objeto
		table.insert(conexiones, objeto.Activated:Connect(accion))
		return objeto
	end
	local empezar = boton("Comenzar", "Comenzar", UDim2.fromOffset(24, 278), acciones.alComenzar)
	local repetir = boton("Reintentar", "Reintentar", UDim2.fromOffset(24, 278), acciones.alReintentar)
	local continuar = boton("Continuar", "Continuar", UDim2.fromOffset(350, 278), acciones.alContinuar)
	local function mostrarResultado(resultado: Resultado)
		ventana.Visible = true
		empezar.Visible, repetir.Visible = false, true
		encabezado.Text = if resultado.outcome == "victory" then "¡Nivel superado!" else "Fin del intento"
		encabezado.TextColor3 = if resultado.outcome == "victory" then Color3.fromRGB(133, 233, 175) else Color3.fromRGB(255, 151, 108)
		mensaje.Text = resultado.message
		repetir.Text = if resultado.outcome == "victory" then "Repetir nivel" else "Reintentar"
	end
	local function actualizar(estado: Estado)
		titulo.Text = "NIVEL " .. estado.levelId .. " · " .. string.upper(estado.titulo)
		objetivo.Text = estado.instruccion
		continuar.Visible = estado.fase == "victoria" and estado.puedeContinuar
		if estado.fase == "preparacion" then
			ventana.Visible = true
			empezar.Visible, repetir.Visible = true, false
			empezar.Active = estado.mapaListo ~= false
			empezar.AutoButtonColor = empezar.Active
			empezar.Text = if empezar.Active then "Comenzar" else "Cargando escenario…"
			encabezado.Text, encabezado.TextColor3 = "Prepara tu recorrido", Color3.fromRGB(255, 180, 100)
			mensaje.Text = estado.instruccion .. "\n\nMuévete con WASD y salta con Espacio. Los puentes caerán detrás de ti. Cerberus empezará a perseguirte después de la ventaja inicial."
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

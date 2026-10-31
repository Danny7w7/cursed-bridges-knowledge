--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Contratos = require(ReplicatedStorage.ContratosJuego)
local Escenario = require(script.Parent.EscenarioNivel)
local Navegacion = require(script.Parent.NavegacionGrafo)
local Detector = require(script.Parent.DetectorCruces)
type Datos = Escenario.Datos
type Configuracion = Contratos.Configuracion
type EstadoDetector = Detector.Estado
type Salto = {desde: Vector3, hasta: Vector3, nodo: string, despega: number, aterriza: number, libera: number}
export type Control = {
	raiz: BasePart,
	activar: () -> (),
	detener: () -> (),
	restaurar: () -> (),
	actualizar: (number, number, Vector3, EstadoDetector, {[string]: boolean}, Configuracion) -> boolean,
}

local Persecucion = {}

function Persecucion.crear(datos: Datos, inicio: string): Control
	local modelo = datos.cerberus
	local reposo = modelo:GetPivot()
	local raiz = Instance.new("Part")
	raiz.Name = "RaizMovimiento"
	raiz.Size = Vector3.new(1, 1, 1)
	raiz.Transparency = 1
	raiz.Anchored, raiz.CanCollide, raiz.CanTouch, raiz.CanQuery = true, false, false, false
	raiz.CFrame = reposo
	raiz:SetAttribute("ControlMovimiento", true)
	raiz:SetAttribute("EstadoMovimiento", "reposo")
	raiz:SetAttribute("VelocidadActual", 0)
	raiz.Parent = modelo

	-- Proyectar el cuerpo sobre el suelo evita capturar por llamas, cola o adornos.
	local minimo, maximo = Vector3.new(math.huge, 0, math.huge), Vector3.new(-math.huge, 0, -math.huge)
	local cuerpos = {pecho_Node = true, costillas_Node = true, cadera_Node = true, vientre_Node = true}
	for _, pieza in modelo:GetDescendants() do
		if pieza:IsA("BasePart") and pieza ~= raiz then
			pieza.CanCollide, pieza.CanTouch = false, false
			if pieza.Parent and cuerpos[pieza.Parent.Name] then
				for _, x in {-1, 1} do for _, y in {-1, 1} do for _, z in {-1, 1} do
					local esquina = reposo:PointToObjectSpace(pieza.CFrame:PointToWorldSpace(pieza.Size * Vector3.new(x, y, z) / 2))
					minimo = Vector3.new(math.min(minimo.X, esquina.X), 0, math.min(minimo.Z, esquina.Z))
					maximo = Vector3.new(math.max(maximo.X, esquina.X), math.max(maximo.Y, esquina.Y), math.max(maximo.Z, esquina.Z))
				end end end
			end
		end
	end
	assert(minimo.X < maximo.X and minimo.Z < maximo.Z, "No se pudo localizar el cuerpo del Cerberus.")
	raiz:SetAttribute("CapturaMinimo", minimo)
	raiz:SetAttribute("CapturaMaximo", maximo)

	local aviso = Instance.new("Part")
	aviso.Name = "AvisoSaltoCerberus"
	aviso.Shape = Enum.PartType.Cylinder
	aviso.Size = Vector3.new(0.15, 34, 34)
	aviso.Material = Enum.Material.Neon
	aviso.Color = Color3.fromRGB(255, 82, 38)
	aviso.Transparency = 1
	aviso.Anchored, aviso.CanCollide, aviso.CanTouch, aviso.CanQuery = true, false, false, false
	aviso.Parent = datos.modelo
	local letrero = Instance.new("BillboardGui")
	letrero.Name = "Advertencia"
	letrero.Size = UDim2.fromOffset(240, 52)
	letrero.StudsOffset = Vector3.new(0, 8, 0)
	letrero.AlwaysOnTop = true
	letrero.Enabled = false
	letrero.Parent = aviso
	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.fromScale(1, 1)
	texto.BackgroundTransparency = 1
	texto.Font = Enum.Font.FredokaOne
	texto.TextScaled = true
	texto.Text = "¡CERBERUS VA A SALTAR!"
	texto.TextColor3 = Color3.fromRGB(255, 202, 115)
	texto.TextStrokeTransparency = 0
	texto.Parent = letrero

	local activo = false
	local nodo: string? = nil
	local salto: Salto? = nil
	local camino: {Vector3} = {}
	local indice = 1
	local destinoRuta: string? = nil
	local rutaEnUso: string? = nil
	local reinicios = 0

	local function colocar(posicion: Vector3, direccion: Vector3)
		local plana = Vector3.new(direccion.X, 0, direccion.Z)
		raiz.CFrame = if plana.Magnitude > 0.01 then CFrame.lookAt(posicion, posicion + plana) else CFrame.new(posicion) * raiz.CFrame.Rotation
	end

	local function anunciar(ahora: number, jugador: Vector3, objetivo: string, bloqueadas: {[string]: boolean}, config: Configuracion)
		local mejor: string? = nil
		local distancia = math.huge
		local prioridadMejor = math.huge
		local llegada = Vector3.zero
		for id, isla in datos.islas do
			if not nodo and id ~= inicio then continue end
			if not nodo or Navegacion.buscar(datos, objetivo, id, bloqueadas) then
				local punto = isla.centro
				if Escenario.distanciaPlana(punto, jugador) < isla.radio then
					local lejos = Vector3.new(punto.X - jugador.X, 0, punto.Z - jugador.Z)
					if lejos.Magnitude < 0.1 then lejos = Vector3.new(1, 0, 0) end
					punto += lejos.Unit * math.max(0, isla.radio - 19)
				end
				local separacion = Escenario.distanciaPlana(raiz.Position, punto)
				-- Preferir otra isla del componente evita cerrar la llegada con un salto inevitable.
				local prioridad = if nodo and id == objetivo then 1 else 0
				if prioridad < prioridadMejor or (prioridad == prioridadMejor and separacion < distancia) then
					mejor, distancia, llegada, prioridadMejor = id, separacion, punto, prioridad
				end
			end
		end
		if not mejor then return end
		salto = {
			desde = raiz.Position, hasta = llegada, nodo = mejor,
			despega = ahora + config.avisoSalto,
			aterriza = ahora + config.avisoSalto + config.duracionSalto,
			libera = ahora + config.avisoSalto + config.duracionSalto + config.graciaAterrizaje,
		}
		table.clear(camino)
		indice, rutaEnUso, destinoRuta = 1, nil, nil
		aviso.CFrame = CFrame.new(llegada + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		aviso.Transparency, letrero.Enabled = 0.35, true
		raiz:SetAttribute("EstadoMovimiento", "preparando_salto")
	end

	local function restaurar()
		reinicios += 1
		activo, nodo, salto = false, nil, nil
		table.clear(camino)
		indice, rutaEnUso, destinoRuta = 1, nil, nil
		raiz.CFrame = reposo
		raiz:SetAttribute("Reinicio", reinicios)
		raiz:SetAttribute("EstadoMovimiento", "reposo")
		raiz:SetAttribute("VelocidadActual", 0)
		aviso.Transparency, letrero.Enabled = 1, false
	end

	local function actualizar(ahora: number, dt: number, jugador: Vector3, detector: EstadoDetector, bloqueadas: {[string]: boolean}, config: Configuracion): boolean
		if not activo then return false end
		local objetivo = if detector.cruce then detector.cruce.hasta else detector.actual
		local antes = raiz.Position
		local volando = salto
		if volando then
			if ahora < volando.despega then
				raiz:SetAttribute("EstadoMovimiento", "preparando_salto")
				return false
			elseif ahora < volando.aterriza then
				local t = (ahora - volando.despega) / (volando.aterriza - volando.despega)
				local altura = math.max(28, Escenario.distanciaPlana(volando.desde, volando.hasta) * 0.2)
				colocar(volando.desde:Lerp(volando.hasta, t) + Vector3.new(0, math.sin(t * math.pi) * altura, 0), volando.hasta - volando.desde)
				raiz:SetAttribute("EstadoMovimiento", "saltando")
				return false
			elseif ahora < volando.libera then
				colocar(volando.hasta, jugador - volando.hasta)
				nodo = volando.nodo
				aviso.Transparency, letrero.Enabled = 1, false
				raiz:SetAttribute("EstadoMovimiento", "aterrizando")
				raiz:SetAttribute("VelocidadActual", 0)
				return false
			end
			colocar(volando.hasta, jugador - volando.hasta)
			nodo, salto = volando.nodo, nil
		end
		if not nodo or (rutaEnUso and bloqueadas[rutaEnUso]) then
			anunciar(ahora, jugador, objetivo, bloqueadas, config)
			return false
		end
		if indice > #camino then
			if destinoRuta then nodo = destinoRuta end
			destinoRuta, rutaEnUso = nil, nil
			table.clear(camino)
			indice = 1
			if nodo == objetivo then
				if not detector.cruce and Escenario.islaEn(datos, jugador) == nodo then
					table.insert(camino, Vector3.new(jugador.X, datos.islas[nodo].centro.Y, jugador.Z))
				end
			else
				local ruta = Navegacion.buscar(datos, nodo, objetivo, bloqueadas)
				if not ruta or not ruta.aristas[1] then
					anunciar(ahora, jugador, objetivo, bloqueadas, config)
					return false
				end
				local puente = datos.rutas[ruta.aristas[1]]
				local inverso = puente.to == nodo
				table.insert(camino, datos.islas[nodo].centro)
				if inverso then
					for i = #puente.puntos, 1, -1 do table.insert(camino, puente.puntos[i]) end
				else
					for _, punto in puente.puntos do table.insert(camino, punto) end
				end
				destinoRuta = if inverso then puente.from else puente.to
				table.insert(camino, datos.islas[destinoRuta].centro)
				rutaEnUso = puente.id
			end
		end
		local restante = config.velocidadJugador * dt
		while indice <= #camino and restante > 0 do
			local punto = camino[indice]
			local distancia = Escenario.distanciaPlana(raiz.Position, punto)
			if distancia < 0.05 then
				colocar(punto, raiz.CFrame.LookVector)
				indice += 1
			else
				local paso = math.min(restante, distancia)
				colocar(raiz.Position:Lerp(punto, paso / distancia), punto - raiz.Position)
				restante -= paso
				if paso >= distancia then indice += 1 end
			end
		end
		local velocidad = Escenario.distanciaPlana(antes, raiz.Position) / math.max(dt, 0.001)
		raiz:SetAttribute("VelocidadActual", velocidad)
		raiz:SetAttribute("EstadoMovimiento", if velocidad > 0.2 then "caminando" else "reposo")
		local relativo = raiz.CFrame:PointToObjectSpace(jugador)
		return relativo.X >= minimo.X - 2 and relativo.X <= maximo.X + 2
			and relativo.Z >= minimo.Z - 2 and relativo.Z <= maximo.Z + 2
			and relativo.Y >= -2 and relativo.Y <= maximo.Y + 4
	end
	return {
		raiz = raiz,
		activar = function() activo = true end,
		detener = function()
			activo = false
			aviso.Transparency, letrero.Enabled = 1, false
			raiz:SetAttribute("EstadoMovimiento", "reposo")
			raiz:SetAttribute("VelocidadActual", 0)
		end,
		restaurar = restaurar, actualizar = actualizar,
	}
end
return Persecucion

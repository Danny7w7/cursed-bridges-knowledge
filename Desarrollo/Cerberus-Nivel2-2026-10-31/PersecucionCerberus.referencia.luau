--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Contratos = require(ReplicatedStorage.ContratosJuego)
local Escenario = require(script.Parent.EscenarioNivel)
local Detector = require(script.Parent.DetectorCruces)
type Datos = Escenario.Datos
type Configuracion = Contratos.Configuracion
type EstadoDetector = Detector.Estado
type Trayecto = {puntos: {Vector3}, distancias: {number}, longitud: number}
type Registro = {cruce: Detector.Cruce, terminado: boolean, regreso: boolean}
type Salto = {camino: Trayecto, hasta: Vector3, nodo: string, registro: Registro?, despega: number, aterriza: number, libera: number}
export type Control = {
	raiz: BasePart,
	registrar: (Detector.Evento) -> (),
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
	aviso.Size = Vector3.new(0.15, 22, 22)
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
	local registros: {Registro} = {}
	local primero = 1
	local abierto: Registro? = nil
	local seguido: Registro? = nil
	local trayecto: Trayecto? = nil
	local avance = 0
	local acercando = true
	local aristasSeguidas: {string} = {}
	local reinicios = 0

	local function colocar(posicion: Vector3, direccion: Vector3)
		local plana = Vector3.new(direccion.X, 0, direccion.Z)
		raiz.CFrame = if plana.Magnitude > 0.01 then CFrame.lookAt(posicion, posicion + plana) else CFrame.new(posicion) * raiz.CFrame.Rotation
	end

	local function construir(puntos: {Vector3}): Trayecto
		local distancias = {0}
		local longitud = 0
		for i = 2, #puntos do
			longitud += Escenario.distanciaPlana(puntos[i - 1], puntos[i])
			table.insert(distancias, longitud)
		end
		return {puntos = puntos, distancias = distancias, longitud = longitud}
	end

	local function puntoEn(camino: Trayecto, distancia: number): Vector3
		distancia = math.clamp(distancia, 0, camino.longitud)
		for i = 2, #camino.puntos do
			if distancia <= camino.distancias[i] then
				local tramo = camino.distancias[i] - camino.distancias[i - 1]
				return camino.puntos[i - 1]:Lerp(camino.puntos[i], if tramo > 0 then (distancia - camino.distancias[i - 1]) / tramo else 0)
			end
		end
		return camino.puntos[#camino.puntos]
	end

	local function acceso(id: string, extremo: Vector3): Vector3
		local isla = datos.islas[id]
		local direccion = Vector3.new(extremo.X - isla.centro.X, 0, extremo.Z - isla.centro.Z)
		if direccion.Magnitude < 0.01 then return isla.centro end
		return isla.centro + direccion.Unit * math.min(direccion.Magnitude, math.max(0, isla.radio - 12))
	end

	local function caminoRegistro(registro: Registro): Trayecto
		local cruce, ruta = registro.cruce, registro.cruce.ruta
		local origen = if cruce.inverso then ruta.puntos[#ruta.puntos] else ruta.puntos[1]
		local llegada = if cruce.inverso then ruta.puntos[1] else ruta.puntos[#ruta.puntos]
		local puntos = {acceso(cruce.desde, origen), origen}
		local tope = if registro.regreso then cruce.maximo else ruta.longitud
		if cruce.inverso then
			for i = #ruta.puntos - 1, 1, -1 do
				if ruta.longitud - ruta.distancias[i] < tope then table.insert(puntos, ruta.puntos[i]) end
			end
		else
			for i = 2, #ruta.puntos do
				if ruta.distancias[i] < tope then table.insert(puntos, ruta.puntos[i]) end
			end
		end
		table.insert(puntos, Escenario.punto(ruta, if cruce.inverso then ruta.longitud - tope else tope))
		if registro.regreso then
			for i = #puntos - 1, 1, -1 do table.insert(puntos, puntos[i]) end
		else
			table.insert(puntos, acceso(cruce.hasta, llegada))
		end
		return construir(puntos)
	end

	local function completar(registro: Registro)
		nodo = if registro.regreso then registro.cruce.desde else registro.cruce.hasta
		if not registro.regreso then
			table.insert(aristasSeguidas, registro.cruce.ruta.id)
			raiz:SetAttribute("AristasSeguidas", table.concat(aristasSeguidas, ", "))
		end
		raiz:SetAttribute("IslaActual", nodo)
		raiz:SetAttribute("RutaEnUso", nil)
		primero += 1
		-- Liberar cruces consumidos sin perder el tramo que todavía sigue el jugador.
		if primero > 64 then
			local pendientes: {Registro} = {}
			for i = primero, #registros do table.insert(pendientes, registros[i]) end
			registros, primero = pendientes, 1
		end
		seguido, trayecto, avance, acercando = nil, nil, 0, true
	end

	local function registrar(evento: Detector.Evento)
		local cruce = evento.cruce
		if not cruce then return end
		if evento.tipo == "entrada" then
			if abierto and abierto.cruce == cruce then return end
			assert(not abierto, "Hay un cruce anterior sin terminar en el rastro de Cerberus.")
			local registro: Registro = {cruce = cruce, terminado = false, regreso = false}
			table.insert(registros, registro)
			abierto = registro
		elseif abierto and abierto.cruce == cruce and (evento.tipo == "llegada" or evento.tipo == "regreso") then
			abierto.terminado, abierto.regreso = true, evento.tipo == "regreso"
			if abierto == seguido and abierto.regreso then trayecto = nil end
			abierto = nil
		end
	end

	local function anunciar(ahora: number, camino: Trayecto, destino: string, registro: Registro?, config: Configuracion)
		local llegada = camino.puntos[#camino.puntos]
		salto = {
			camino = camino, hasta = llegada, nodo = destino, registro = registro,
			despega = ahora + config.avisoSalto,
			aterriza = ahora + config.avisoSalto + config.duracionSalto,
			libera = ahora + config.avisoSalto + config.duracionSalto + config.graciaAterrizaje,
		}
		aviso.CFrame = CFrame.new(llegada + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		aviso.Transparency, letrero.Enabled = 0.35, true
		raiz:SetAttribute("EstadoMovimiento", "preparando_salto")
		raiz:SetAttribute("VelocidadActual", 0)
	end

	local function restaurar()
		reinicios += 1
		activo, nodo, salto, abierto, seguido, trayecto = false, nil, nil, nil, nil, nil
		table.clear(registros)
		table.clear(aristasSeguidas)
		primero, avance, acercando = 1, 0, true
		raiz.CFrame = reposo
		raiz:SetAttribute("Reinicio", reinicios)
		raiz:SetAttribute("EstadoMovimiento", "reposo")
		raiz:SetAttribute("VelocidadActual", 0)
		raiz:SetAttribute("AristasSeguidas", "")
		raiz:SetAttribute("RutaEnUso", nil)
		raiz:SetAttribute("IslaActual", nil)
		aviso.Transparency, letrero.Enabled = 1, false
	end

	local function actualizar(ahora: number, dt: number, jugador: Vector3, detector: EstadoDetector, bloqueadas: {[string]: boolean}, config: Configuracion): boolean
		if not activo then return false end
		local antes = raiz.Position
		local volando = salto
		if volando then
			if ahora < volando.despega then return false end
			if ahora < volando.aterriza then
				local t = (ahora - volando.despega) / (volando.aterriza - volando.despega)
				local base = puntoEn(volando.camino, volando.camino.longitud * t)
				local siguiente = puntoEn(volando.camino, math.min(volando.camino.longitud, volando.camino.longitud * t + 1))
				local altura = math.max(28, volando.camino.longitud * 0.2)
				colocar(base + Vector3.new(0, math.sin(t * math.pi) * altura, 0), siguiente - base)
				raiz:SetAttribute("EstadoMovimiento", "saltando")
				return false
			end
			colocar(volando.hasta, jugador - volando.hasta)
			nodo = volando.nodo
			raiz:SetAttribute("IslaActual", nodo)
			aviso.Transparency, letrero.Enabled = 1, false
			if ahora < volando.libera then
				raiz:SetAttribute("EstadoMovimiento", "aterrizando")
				raiz:SetAttribute("VelocidadActual", 0)
				return false
			end
			salto = nil
			if volando.registro then completar(volando.registro) end
		end
		if not nodo then
			-- El único ingreso desde la roca siempre es a la isla inicial.
			local isla = datos.islas[inicio]
			local punto = isla.centro
			if Escenario.islaEn(datos, jugador) == inicio then
				local lejos = Vector3.new(punto.X - jugador.X, 0, punto.Z - jugador.Z)
				if lejos.Magnitude < 0.1 then lejos = Vector3.xAxis end
				punto += lejos.Unit * math.max(0, isla.radio - 12)
			end
			anunciar(ahora, construir({raiz.Position, punto}), inicio, nil, config)
			return false
		end
		local registro = registros[primero]
		local destino: Vector3? = nil
		local presupuesto = config.velocidadJugador * dt
		if registro then
			if seguido ~= registro then
				seguido, trayecto, avance, acercando = registro, nil, 0, true
				raiz:SetAttribute("RutaEnUso", registro.cruce.ruta.id)
			end
			if not trayecto then trayecto = caminoRegistro(registro) end
			local camino = trayecto :: Trayecto
			if acercando then
				destino = camino.puntos[1]
				if Escenario.distanciaPlana(raiz.Position, destino) < 0.1 then acercando = false end
			end
			if not acercando then
				if bloqueadas[registro.cruce.ruta.id] then
					-- Esperar una llegada real impide saltar a una isla que el jugador aún no visitó.
					if registro.terminado then
						local pendientes = {raiz.Position}
						for i, punto in camino.puntos do
							if camino.distancias[i] > avance + 0.05 then table.insert(pendientes, punto) end
						end
						if #pendientes == 1 then table.insert(pendientes, camino.puntos[#camino.puntos]) end
						anunciar(ahora, construir(pendientes), if registro.regreso then registro.cruce.desde else registro.cruce.hasta, registro, config)
						return false
					end
				else
					local limite = camino.longitud
					if not registro.terminado then
						limite = camino.distancias[2] + registro.cruce.avance
					end
					local diferencia = limite - avance
					avance += math.sign(diferencia) * math.min(presupuesto, math.abs(diferencia))
					destino = puntoEn(camino, avance)
					colocar(destino, destino - raiz.Position)
					destino = nil
					if registro.terminado and avance >= camino.longitud - 0.05 then completar(registro) end
				end
			end
		elseif not detector.cruce and Escenario.islaEn(datos, jugador) == nodo then
			destino = Vector3.new(jugador.X, datos.islas[nodo].centro.Y, jugador.Z)
		end
		if destino then
			local distancia = Escenario.distanciaPlana(raiz.Position, destino)
			if distancia > 0.01 then colocar(raiz.Position:Lerp(destino, math.min(1, presupuesto / distancia)), destino - raiz.Position) end
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
		raiz = raiz, registrar = registrar,
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


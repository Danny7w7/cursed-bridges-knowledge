--!strict
-- Pruebas de la secuencia perseguida en una copia aislada del nivel.
return function()
	assert(not game:GetService("RunService"):IsRunning(), "Ejecutar en Edición.")
	local carpeta = Instance.new("Folder")
	carpeta.Name = "PruebasTemporalesCerberusSeguidor"
	carpeta.Parent = game:GetService("ServerStorage")
	local total = 0
	local function comprobar(condicion: boolean, mensaje: string)
		assert(condicion, mensaje)
		total += 1
	end
	local ok, fallo = pcall(function()
		for _, nombre in {"EscenarioNivel", "DetectorCruces", "PersecucionCerberus"} do
			script.Parent[nombre]:Clone().Parent = carpeta
		end
		local E = require(carpeta.EscenarioNivel)
		local P = require(carpeta.PersecucionCerberus)
		local copia = workspace.Niveles.Nivel1:Clone()
		copia.Parent = carpeta
		task.wait()
		local datos = E.cargar(copia)
		local enemigo = P.crear(datos, "A")
		local raiz = enemigo.raiz
		local config = {ventajaInicial = 12, retardoDerrumbe = 1, avisoSalto = 2, duracionSalto = 1.2, graciaAterrizaje = 1, velocidadJugador = 16}
		local ahora = 100
		local detector = {actual = "C", cruce = nil, anterior = nil}
		local jugador = datos.islas.C.centro + Vector3.new(0, 3, 0)
		local bloqueadas: {[string]: boolean} = {}
		local function reiniciar()
			enemigo.restaurar()
			enemigo.activar()
			ahora = 100
			bloqueadas = {}
		end
		local function registrar(id: string, inverso: boolean, terminar: boolean)
			local ruta = datos.rutas[id]
			local cruce = {ruta = ruta, desde = if inverso then ruta.to else ruta.from,
				hasta = if inverso then ruta.from else ruta.to, inverso = inverso, avance = ruta.longitud, maximo = ruta.longitud}
			enemigo.registrar({tipo = "entrada", cruce = cruce})
			enemigo.registrar({tipo = "entrada", cruce = cruce})
			if terminar then enemigo.registrar({tipo = "llegada", cruce = cruce}) end
			return cruce
		end
		local function avanzar(segundos: number)
			for _ = 1, math.ceil(segundos / 0.05) do
				ahora += 0.05
				local captura = enemigo.actualizar(ahora, 0.05, jugador, detector, bloqueadas, config)
				local estado = raiz:GetAttribute("EstadoMovimiento")
				assert(not captura or (estado ~= "preparando_salto" and estado ~= "saltando" and estado ~= "aterrizando"), "Captura durante un salto o su gracia.")
			end
		end
		local function esperarSecuencia(esperada: string)
			local limite = ahora + 70
			repeat avanzar(0.05) until raiz:GetAttribute("AristasSeguidas") == esperada or ahora >= limite
			comprobar(raiz:GetAttribute("AristasSeguidas") == esperada, "No siguió la secuencia " .. esperada)
		end

		reiniciar()
		registrar("AB", false, true)
		registrar("BC", false, true)
		bloqueadas = {AB = true, BC = true, CA = true, AD = true}
		enemigo.actualizar(ahora, 0.05, jugador, detector, bloqueadas, config)
		local aviso = copia.AvisoSaltoCerberus
		comprobar(E.islaEn(datos, aviso.Position) == "A", "El ingreso inicial debe ser en A aunque el jugador ya esté en C.")
		avanzar(4.3)
		comprobar(raiz:GetAttribute("IslaActual") == "A", "Saltó directamente a la isla actual del jugador.")
		local limite = ahora + 20
		repeat avanzar(0.05) until raiz:GetAttribute("EstadoMovimiento") == "preparando_salto" or ahora > limite
		comprobar(raiz:GetAttribute("RutaEnUso") == "AB", "Tomó otra arista en lugar de AB.")
		comprobar(E.islaEn(datos, aviso.Position) == "B", "El salto debe terminar en B, sin atajar a C.")
		esperarSecuencia("AB")
		comprobar(raiz:GetAttribute("IslaActual") == "B", "No respetó la isla intermedia B.")
		esperarSecuencia("AB, BC")
		comprobar(raiz:GetAttribute("IslaActual") == "C", "No terminó en C siguiendo AB y BC.")

		reiniciar()
		comprobar(raiz:GetAttribute("AristasSeguidas") == "" and raiz:GetAttribute("RutaEnUso") == nil, "El reintento conserva el rastro anterior.")
		registrar("CA", true, true)
		registrar("BC", true, true)
		registrar("AB", true, true)
		bloqueadas = {AB = true, BC = true, CA = true}
		detector.actual = "A"
		jugador = datos.islas.A.centro + Vector3.new(0, 3, 0)
		esperarSecuencia("CA, BC, AB")
		comprobar(raiz:GetAttribute("IslaActual") == "A", "No respetó los sentidos inversos.")

		reiniciar()
		registrar("AB", false, true)
		registrar("AB", true, true)
		esperarSecuencia("AB, AB")
		comprobar(raiz:GetAttribute("IslaActual") == "A", "No permite seguir un puente reutilizado.")

		reiniciar()
		local abierto = registrar("AB", false, false)
		abierto.avance, abierto.maximo = abierto.ruta.longitud / 2, abierto.ruta.longitud / 2
		detector.actual, detector.cruce = "A", abierto
		jugador = E.punto(abierto.ruta, abierto.avance) + Vector3.new(0, 3, 0)
		avanzar(20)
		local progreso = E.proyectar(abierto.ruta, raiz.Position)
		comprobar(progreso <= abierto.avance + 0.1, "Se adelantó al jugador en un cruce incompleto.")
		comprobar(raiz:GetAttribute("AristasSeguidas") == "", "Contó un cruce que el jugador no terminó.")
		abierto.avance = 0
		enemigo.registrar({tipo = "regreso", cruce = abierto})
		detector.cruce = nil
		jugador = datos.islas.A.centro + Vector3.new(0, 3, 0)
		avanzar(15)
		comprobar(raiz:GetAttribute("IslaActual") == "A" and raiz:GetAttribute("RutaEnUso") == nil, "No siguió el regreso de un cruce incompleto.")
		comprobar(raiz:GetAttribute("AristasSeguidas") == "", "Añadió una arista completa al seguir un regreso.")

		reiniciar()
		local pendiente = registrar("AB", false, false)
		pendiente.avance, pendiente.maximo = pendiente.ruta.longitud / 2, pendiente.ruta.longitud / 2
		detector.cruce = pendiente
		bloqueadas = {AB = true}
		avanzar(15)
		comprobar(raiz:GetAttribute("IslaActual") == "A", "Saltó a B antes de que llegara el jugador.")
		pendiente.avance = 0
		enemigo.registrar({tipo = "regreso", cruce = pendiente})
		detector.cruce = nil
		avanzar(10)
		comprobar(raiz:GetAttribute("IslaActual") == "A" and raiz:GetAttribute("AristasSeguidas") == "", "El regreso por un puente caído inventó una visita a B.")

		-- La identidad de arista distingue dos puentes que conectan las mismas islas.
		local paralelo = table.clone(datos.rutas.AB)
		paralelo.id = "AB2"
		datos.rutas.AB2 = paralelo
		reiniciar()
		registrar("AB2", false, true)
		registrar("AB", true, true)
		bloqueadas = {AB2 = true, AB = true}
		esperarSecuencia("AB2, AB")

		-- Un salto de lazo debe recorrer su curva, aunque ambos extremos pertenezcan a A.
		local lazo = table.clone(datos.rutas.AB)
		lazo.id, lazo.from, lazo.to = "AA", "A", "A"
		local centro = datos.islas.A.centro
		lazo.puntos = {centro + Vector3.new(30, 0, 0), centro + Vector3.new(80, 0, 0), centro + Vector3.new(80, 0, 50), centro + Vector3.new(0, 0, 30)}
		lazo.distancias, lazo.longitud = {0}, 0
		for i = 2, #lazo.puntos do
			lazo.longitud += E.distanciaPlana(lazo.puntos[i - 1], lazo.puntos[i])
			table.insert(lazo.distancias, lazo.longitud)
		end
		datos.rutas.AA = lazo
		reiniciar()
		registrar("AA", false, true)
		bloqueadas = {AA = true}
		local salioPorElLazo = false
		limite = ahora + 30
		repeat
			avanzar(0.05)
			if raiz:GetAttribute("RutaEnUso") == "AA" and raiz:GetAttribute("EstadoMovimiento") == "saltando" and E.distanciaPlana(raiz.Position, centro) > 60 then salioPorElLazo = true end
		until raiz:GetAttribute("AristasSeguidas") == "AA" or ahora > limite
		comprobar(salioPorElLazo, "El salto cortó el lazo en lugar de seguir su curva.")
		comprobar(raiz:GetAttribute("AristasSeguidas") == "AA" and raiz:GetAttribute("IslaActual") == "A", "No completó el lazo en A.")
		enemigo.detener()
		local posicion = raiz.Position
		avanzar(1)
		comprobar(raiz.Position == posicion, "Se mueve después de detener el intento.")
	end)
	carpeta:Destroy()
	assert(ok, tostring(fallo))
	return {correctas = total}
end

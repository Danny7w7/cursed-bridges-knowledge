--!strict
-- Pruebas de integración en copias aisladas; nunca modifican las piezas del mapa de Edición.
return function()
	local RunService = game:GetService("RunService")
	assert(RunService:IsStudio() and not RunService:IsRunning(), "Ejecutar estas pruebas en Edición.")
	local ServerStorage = game:GetService("ServerStorage")
	local origen = workspace:FindFirstChild("Niveles")
	local nivel = origen and origen:FindFirstChild("Nivel1")
	assert(nivel, "Falta el nivel 1.")
	local suite = Instance.new("Folder")
	suite.Name = "PruebasTemporalesNivel1"
	suite.Parent = ServerStorage
	local total = 0
	local function comprobar(condicion: boolean, nombre: string)
		assert(condicion, "Falló: " .. nombre)
		total += 1
	end
	local correcto, fallo = pcall(function()
		for _, nombre in {"EscenarioNivel", "DetectorCruces", "NavegacionGrafo", "DerrumbePuentes", "PersecucionCerberus", "MotorPartida"} do
			local modulo = script.Parent:FindFirstChild(nombre)
			assert(modulo and modulo:IsA("ModuleScript"), "Falta el módulo " .. nombre)
			modulo:Clone().Parent = suite
		end
		local E = require(suite:FindFirstChild("EscenarioNivel") :: ModuleScript)
		local M = require(suite:FindFirstChild("MotorPartida") :: ModuleScript)
		local copia = nivel:Clone()
		copia.Name = "EscenarioDePrueba"
		copia.Parent = suite
		task.wait()
		local datos = E.cargar(copia)
		local config = {ventajaInicial = 60, retardoDerrumbe = 1, avisoSalto = 2, duracionSalto = 1.2, graciaAterrizaje = 1, velocidadJugador = 16}
		local objetivo = {tipo = "sendero", inicio = "A", final = "D", islasObligatorias = {"B", "C"}}
		local partida = M.crear(datos, objetivo, config, {alEstado = function() end, alResultado = function() end})
		comprobar(partida.estado().fase == "preparacion", "preparación")
		partida.comenzar(-1, 100)
		comprobar(partida.estado().fase == "preparacion", "rechazar intento incorrecto")
		partida.comenzar(partida.estado().intentoId, 100)
		local ahora = 100
		local anterior = datos.islas.A.centro + Vector3.new(0, 3, 0)
		partida.actualizar(ahora, 1/16, anterior)
		local function caminar(punto: Vector3)
			local destino = punto + Vector3.new(0, 3, 0)
			local comienzo = anterior
			local pasos = math.max(1, math.ceil((destino - comienzo).Magnitude))
			for i = 1, pasos do
				ahora += 1/16
				partida.actualizar(ahora, 1/16, comienzo:Lerp(destino, i/pasos))
			end
			anterior = destino
		end
		for _, id in {"AB", "BC", "CA", "AD"} do
			local ruta = datos.rutas[id]
			for _, punto in ruta.puntos do caminar(punto) end
			caminar(datos.islas[ruta.to].centro)
		end
		comprobar(partida.estado().fase == "victoria", "victoria por recorrido físico")
		comprobar(table.concat(partida.historial().aristas, ",") == "AB,BC,CA,AD", "historial completo")
		partida.derrotar("captura", "evento atrasado")
		comprobar(partida.estado().fase == "victoria", "resultado terminal único")
		local anteriorId = partida.estado().intentoId
		partida.reiniciar(config)
		comprobar(partida.estado().intentoId == anteriorId + 1 and #partida.historial().aristas == 0, "reintento limpio")
		for _, ruta in datos.rutas do
			for _, tablon in ruta.tablones do comprobar(tablon.CanCollide and tablon:GetAttribute("CaidaDesde") == nil, "restaurar soporte") end
		end
		partida.comenzar(anteriorId, 200)
		comprobar(partida.estado().fase == "preparacion", "rechazar comenzar atrasado")
		partida.comenzar(partida.estado().intentoId, 200)
		partida.actualizar(201, 0.05, Vector3.new(0, -100, 0))
		local resultadoLava = partida.estado().resultado
		comprobar(resultadoLava ~= nil and resultadoLava.codigo == "lava", "caída a lava")
		partida.reiniciar(config)
		partida.comenzar(partida.estado().intentoId, 300)
		ahora, anterior = 300, datos.islas.A.centro + Vector3.new(0,3,0)
		partida.actualizar(ahora, 1/16, anterior)
		for _, punto in datos.rutas.AD.puntos do caminar(punto) end
		caminar(datos.islas.D.centro)
		local resultadoBloqueo = partida.estado().resultado
		comprobar(partida.estado().fase == "derrota" and resultadoBloqueo ~= nil and resultadoBloqueo.codigo == "sin_salida", "meta sin visitas obligatorias")
		copia:Destroy()

		local copiaEnemigo = nivel:Clone()
		copiaEnemigo.Name = "EnemigoDePrueba"
		copiaEnemigo.Parent = suite
		task.wait()
		local datosEnemigo = E.cargar(copiaEnemigo)
		local P = require(suite:FindFirstChild("PersecucionCerberus") :: ModuleScript)
		local enemigo = P.crear(datosEnemigo, "A")
		local centro = datosEnemigo.islas.A.centro
		local detector = {actual = "A", cruce = nil, anterior = nil}
		enemigo.activar()
		comprobar(not enemigo.actualizar(1000, 0.05, centro+Vector3.new(0,3,0), detector, {}, config), "aviso sin captura")
		local aviso = copiaEnemigo:FindFirstChild("AvisoSaltoCerberus") :: BasePart
		local destino = aviso.Position + Vector3.new(0, 3, 0)
		comprobar(not enemigo.actualizar(1002.5, 0.05, destino, detector, {}, config), "salto sin captura")
		comprobar(not enemigo.actualizar(1003.4, 0.05, destino, detector, {}, config), "aterrizaje sin captura")
		comprobar(enemigo.actualizar(1004.3, 0.05, destino, detector, {}, config), "captura después de la gracia")
		enemigo.restaurar()
		comprobar(enemigo.raiz:GetAttribute("EstadoMovimiento") == "reposo", "restaurar enemigo")
	end)
	suite:Destroy()
	assert(correcto, tostring(fallo))
	return {correctas = total}
end

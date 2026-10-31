--!strict
return function()
	local almacen = game:GetService("ReplicatedStorage")
	local Contratos = require(almacen.ContratosJuego)
	local clon = almacen.TextosEducativos:Clone()
	clon.Name = "TextosEducativosDePrueba"
	clon.Parent = almacen
	local total = 0
	local function comprobar(condicion: boolean, mensaje: string)
		assert(condicion, mensaje)
		total += 1
	end
	local ok, fallo = pcall(function()
		local T = require(clon)
		local R = require(almacen.ReglasRecorrido)
		local objetivo = require(almacen.LevelData).Levels[1].objetivo
		assert(objetivo, "Falta el objetivo del nivel 1.")
		local aristas: {Contratos.Arista} = {}
		for _,p in workspace.Niveles.Nivel1.Bridges:GetChildren() do
			local id, desde, hasta = p:GetAttribute("EdgeId"), p:GetAttribute("From"), p:GetAttribute("To")
			assert(typeof(id) == "string" and typeof(desde) == "string" and typeof(hasta) == "string", "Faltan identificadores de puente.")
			table.insert(aristas, {id = id, from = desde, to = hasta})
		end
		local function contiene(texto: string, parte: string): boolean return string.find(texto, parte, 1, true) ~= nil end
		local instruccion = T.instruccion(objetivo)
		local preparacion = T.preparacion(instruccion, T.definiciones.sendero, 1)
		comprobar(contiene(preparacion, "vértices") and contiene(preparacion, "aristas"), "Faltan equivalencias del grafo.")
		comprobar(contiene(instruccion, "en cualquier orden"), "La instrucción debe dejar libre el orden de visitas.")
		comprobar(not contiene(preparacion, "A →") and not contiene(T.presentacionSendero, "A →"), "Se reveló una solución antes de comenzar.")
		comprobar(contiene(T.detalleNivel1, "dos senderos") and not contiene(T.detalleNivel1, "empieza en"), "El rótulo debe indicar dos soluciones sin orden.")
		local soluciones: {Contratos.Historial} = {}
		local function buscar(historial: Contratos.Historial)
			local e = R.evaluar(objetivo, aristas, historial)
			if e.victoria then table.insert(soluciones, historial) return end
			for _,arista in R.salidasLegales(objetivo, aristas, historial, {}) do
				local actual = historial.vertices[#historial.vertices]
				local hasta = if arista.from == actual then arista.to else arista.from
				buscar(R.agregar(historial, arista.id, hasta))
			end
		end
		buscar({vertices = {"A"}, aristas = {}})
		comprobar(#soluciones == 2, "El nivel actual ya no tiene exactamente dos senderos válidos: actualizar el rótulo.")
		for _,h in soluciones do
			local mensaje = T.explicarResultado(objetivo, h, R.evaluar(objetivo, aristas, h), "objetivo_completo", "¡Nivel 1 completado!")
			comprobar(contiene(mensaje, "Volviste a A") and contiene(mensaje, "no repetiste ninguna arista"), "No explica por qué se permite volver a A.")
			comprobar(contiene(mensaje, table.concat(h.vertices, " → ")) and contiene(mensaje, table.concat(h.aristas, " → ")), "El resultado no usa el historial real.")
			comprobar(contiene(mensaje, "OBJETIVO CUMPLIDO"), "Falta separar objetivo y regla.")
		end
		local directo = {vertices = {"A", "D"}, aristas = {"AD"}}
		local evaluacion = R.evaluar(objetivo, aristas, directo)
		local mensaje = T.explicarResultado(objetivo, directo, evaluacion, "sin_salida", "Te quedaste sin salida.")
		comprobar(evaluacion.valido and not evaluacion.victoria and contiene(mensaje, "forman un sendero"), "Confunde sendero válido con objetivo completo.")
		comprobar(contiene(mensaje, "Faltó visitar B y C") and not contiene(mensaje, "Volviste a A"), "Inventó visitas o repeticiones.")
		local repetido = {vertices = {"A", "B", "A"}, aristas = {"AB", "AB"}}
		evaluacion = R.evaluar(objetivo, aristas, repetido)
		local codigoInfraccion, mensajeInfraccion = evaluacion.codigo, evaluacion.mensaje
		assert(codigoInfraccion and mensajeInfraccion, "Falta la explicación de la infracción.")
		mensaje = T.explicarResultado(objetivo, repetido, evaluacion, codigoInfraccion, mensajeInfraccion)
		comprobar(contiene(mensaje, "Primera infracción: cruce 2.") and contiene(mensaje, "Repetiste el puente AB"), "No explica la primera infracción.")
		comprobar(not contiene(mensaje, "no repetiste ninguna arista"), "Declara válido un recorrido con una arista repetida.")
		local _, repeticionesMensaje = string.gsub(mensaje, "Repetiste el puente AB", "")
		comprobar(repeticionesMensaje == 1, "Duplicó la explicación del validador.")
		local vacio = {vertices = {"A"}, aristas = {}}
		for _,codigo in {"captura", "lava"} do
			mensaje = T.explicarResultado(objetivo, vacio, R.evaluar(objetivo, aristas, vacio), codigo, "Causa física: " .. codigo)
			comprobar(contiene(mensaje, "Causa física: " .. codigo) and contiene(mensaje, "todavía no completaste un cruce"), "No conserva la causa física o inventa un cruce.")
			comprobar(not contiene(mensaje, "Construiste un sendero"), "Premia un recorrido vacío.")
		end
		local parcial = {vertices = {"A", "B"}, aristas = {"AB"}}
		mensaje = T.explicarResultado(objetivo, parcial, R.evaluar(objetivo, aristas, parcial), "captura", "Cerberus te alcanzó.")
		comprobar(contiene(mensaje, "Cerberus te alcanzó.") and contiene(mensaje, "Los cruces registrados forman un sendero"), "Confunde captura con infracción matemática.")
		comprobar(contiene(T.teoria, "no exige, por definición, utilizar todos los puentes"), "La teoría confunde sendero con recorrido euleriano.")
	end)
	clon:Destroy()
	assert(ok, tostring(fallo))
	return {correctas = total}
end

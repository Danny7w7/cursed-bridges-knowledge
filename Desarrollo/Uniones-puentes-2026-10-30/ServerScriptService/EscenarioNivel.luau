--!strict
local Contratos = require(game:GetService("ReplicatedStorage").ContratosJuego)
type Arista = Contratos.Arista

local Escenario = {}
export type Isla = {id: string, modelo: Model, superficie: BasePart, centro: Vector3, radio: number, accesos: {BasePart}}
export type Ruta = {
	id: string, from: string, to: string, modelo: Model,
	tablones: {BasePart}, puntos: {Vector3}, distancias: {number}, longitud: number, ancho: number,
}
export type Datos = {
	modelo: Instance, islas: {[string]: Isla}, rutas: {[string]: Ruta},
	aristas: {Arista}, cerberus: Model, lavaY: number,
}

local function distanciaPlana(a: Vector3, b: Vector3): number
	return Vector2.new(a.X - b.X, a.Z - b.Z).Magnitude
end
Escenario.distanciaPlana = distanciaPlana

function Escenario.cargar(nivel: Instance): Datos
	local islas: {[string]: Isla} = {}
	local contenedorIslas = nivel:FindFirstChild("Islands")
	local contenedorPuentes = nivel:FindFirstChild("Bridges")
	assert(contenedorIslas and contenedorPuentes, "El nivel no contiene Islands y Bridges.")
	for _, modelo in contenedorIslas:GetChildren() do
		assert(modelo:IsA("Model") and modelo.PrimaryPart, "Una isla no tiene modelo o superficie principal.")
		local id = modelo:GetAttribute("NodeId")
		assert(typeof(id) == "string" and not islas[id], "Identificador de isla ausente o duplicado.")
		local superficie = modelo.PrimaryPart
		local centro = superficie.Position + Vector3.new(0, superficie.Size.X / 2, 0)
		local accesos: {BasePart} = {}
		local carpetaAccesos = modelo:FindFirstChild("AccesosPuentes")
		if carpetaAccesos then
			for _, pieza in carpetaAccesos:GetChildren() do
				if pieza:IsA("BasePart") and pieza:GetAttribute("UnionGenerada") == true and pieza:GetAttribute("NodeId") == id then
					table.insert(accesos, pieza)
				end
			end
		end
		islas[id] = {id = id, modelo = modelo, superficie = superficie, centro = centro, radio = math.min(superficie.Size.Y, superficie.Size.Z) / 2, accesos = accesos}
	end
	local rutas: {[string]: Ruta} = {}
	local aristas: {Arista} = {}
	for _, modelo in contenedorPuentes:GetChildren() do
		assert(modelo:IsA("Model"), "Un puente no está agrupado como modelo.")
		local id, desde, hasta = modelo:GetAttribute("EdgeId"), modelo:GetAttribute("From"), modelo:GetAttribute("To")
		assert(typeof(id) == "string" and typeof(desde) == "string" and typeof(hasta) == "string", "Faltan identificadores de puente.")
		assert(not rutas[id] and islas[desde] and islas[hasta], "Puente duplicado o conectado a una isla inexistente.")
		local tablones: {BasePart} = {}
		local ordenes: {[number]: boolean} = {}
		for _, pieza in modelo:GetDescendants() do
			if pieza:IsA("BasePart") and pieza:GetAttribute("Kind") == "Tablon" then
				local orden = pieza:GetAttribute("Order")
				assert(typeof(orden) == "number" and not ordenes[orden], "Los tablones necesitan un orden único.")
				ordenes[orden] = true
				table.insert(tablones, pieza)
			end
		end
		assert(#tablones >= 2, "El puente " .. id .. " no tiene una ruta de tablones.")
		table.sort(tablones, function(a, b) return (a:GetAttribute("Order") :: number) < (b:GetAttribute("Order") :: number) end)
		if desde ~= hasta and distanciaPlana(tablones[1].Position, islas[desde].centro) > distanciaPlana(tablones[#tablones].Position, islas[desde].centro) then
			local invertidos: {BasePart} = {}
			for i = #tablones, 1, -1 do table.insert(invertidos, tablones[i]) end
			tablones = invertidos
		end
		local puntos: {Vector3}, distancias: {number} = {}, {}
		local longitud, ancho = 0, math.huge
		for i, tablon in tablones do
			local punto = tablon.Position + Vector3.new(0, tablon.Size.Y / 2, 0)
			if i > 1 then longitud += distanciaPlana(punto, puntos[i - 1]) end
			table.insert(puntos, punto)
			table.insert(distancias, longitud)
			ancho = math.min(ancho, math.max(tablon.Size.X, tablon.Size.Z))
		end
		assert(longitud > 1, "El puente tiene longitud insuficiente.")
		rutas[id] = {id = id, from = desde, to = hasta, modelo = modelo, tablones = tablones, puntos = puntos, distancias = distancias, longitud = longitud, ancho = ancho}
		table.insert(aristas, {id = id, from = desde, to = hasta})
	end
	table.sort(aristas, function(a,b) return a.id < b.id end)
	local cerberus = nivel:FindFirstChild("Cerberus")
	assert(cerberus and cerberus:IsA("Model"), "Falta el modelo Cerberus.")
	local lava = workspace:FindFirstChild("MarDeLava")
	local lavaY = if lava and lava:IsA("BasePart") then lava.Position.Y + lava.Size.Y / 2 else -52
	return {modelo = nivel, islas = islas, rutas = rutas, aristas = aristas, cerberus = cerberus, lavaY = lavaY}
end

function Escenario.islaEn(datos: Datos, posicion: Vector3): string?
	local mejor: string? = nil
	local distancia = math.huge
	for id, isla in datos.islas do
		local separacion = distanciaPlana(posicion, isla.centro)
		local enIsla = separacion <= isla.radio + 4 and posicion.Y >= isla.centro.Y - 3 and posicion.Y <= isla.centro.Y + 16
		if not enIsla then
			for _, acceso in isla.accesos do
				local localPos = acceso.CFrame:PointToObjectSpace(posicion)
				if math.abs(localPos.X) <= acceso.Size.X / 2 and math.abs(localPos.Z) <= acceso.Size.Z / 2 + 0.5
					and localPos.Y >= acceso.Size.Y / 2 - 3 and localPos.Y <= acceso.Size.Y / 2 + 16 then
					enIsla = true
					break
				end
			end
		end
		if enIsla and separacion < distancia then
			mejor, distancia = id, separacion
		end
	end
	return mejor
end

function Escenario.proyectar(ruta: Ruta, posicion: Vector3): (number, number, number)
	local avance, distancia, altura = 0, math.huge, ruta.puntos[1].Y
	for i = 1, #ruta.puntos - 1 do
		local a, b = ruta.puntos[i], ruta.puntos[i + 1]
		local segmento = Vector2.new(b.X - a.X, b.Z - a.Z)
		local relativo = Vector2.new(posicion.X - a.X, posicion.Z - a.Z)
		local t = if segmento:Dot(segmento) > 0 then math.clamp(relativo:Dot(segmento) / segmento:Dot(segmento), 0, 1) else 0
		local punto = a:Lerp(b, t)
		local separacion = distanciaPlana(posicion, punto)
		if separacion < distancia then
			distancia, avance, altura = separacion, ruta.distancias[i] + segmento.Magnitude * t, punto.Y
		end
	end
	return avance, distancia, altura
end

function Escenario.punto(ruta: Ruta, avance: number): Vector3
	avance = math.clamp(avance, 0, ruta.longitud)
	for i = 1, #ruta.puntos - 1 do
		if avance <= ruta.distancias[i + 1] then
			local tramo = ruta.distancias[i + 1] - ruta.distancias[i]
			return ruta.puntos[i]:Lerp(ruta.puntos[i + 1], if tramo > 0 then (avance - ruta.distancias[i]) / tramo else 0)
		end
	end
	return ruta.puntos[#ruta.puntos]
end

return Escenario

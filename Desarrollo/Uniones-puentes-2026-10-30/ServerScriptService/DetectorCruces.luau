--!strict
local Escenario = require(script.Parent.EscenarioNivel)
type Datos = Escenario.Datos
type Ruta = Escenario.Ruta
export type Cruce = {ruta: Ruta, desde: string, hasta: string, inverso: boolean, avance: number, maximo: number}
export type Estado = {actual: string, cruce: Cruce?, anterior: Vector3?}
export type Evento = {tipo: string, cruce: Cruce?}
local Detector = {}

function Detector.nuevo(inicio: string): Estado
	return {actual = inicio, cruce = nil, anterior = nil}
end

function Detector.actualizar(datos: Datos, estado: Estado, posicion: Vector3, dt: number, velocidad: number): Evento?
	local anterior = estado.anterior
	estado.anterior = posicion
	if anterior and (posicion - anterior).Magnitude > math.max(16, velocidad * dt * 4) then
		return {tipo = "atajo"}
	end
	local isla = Escenario.islaEn(datos, posicion)
	local cruce = estado.cruce
	if cruce then
		local progreso, distancia, altura = Escenario.proyectar(cruce.ruta, posicion)
		local avance = if cruce.inverso then cruce.ruta.longitud - progreso else progreso
		if distancia <= cruce.ruta.ancho / 2 + 3 and math.abs(posicion.Y - altura) < 17 then
			cruce.avance = avance
			cruce.maximo = math.max(cruce.maximo, avance)
		end
		if isla == cruce.hasta and cruce.maximo >= cruce.ruta.longitud - 3 and avance >= cruce.ruta.longitud - 3 then
			estado.actual, estado.cruce = cruce.hasta, nil
			return {tipo = "llegada", cruce = cruce}
		end
		if isla == cruce.desde and avance <= 2 and cruce.maximo >= 1 then
			estado.cruce = nil
			return {tipo = "regreso", cruce = cruce}
		end
		if isla and isla ~= cruce.desde and isla ~= cruce.hasta then return {tipo = "atajo"} end
		return nil
	end
	if isla and isla ~= estado.actual then return {tipo = "atajo"} end
	if isla == estado.actual then return nil end
	local candidata: Ruta? = nil
	local separacion = math.huge
	local inverso, distanciaInicial = false, 0
	for _, arista in datos.aristas do
		local ruta = datos.rutas[arista.id]
		if ruta.from == estado.actual or ruta.to == estado.actual then
			local progreso, distancia, altura = Escenario.proyectar(ruta, posicion)
			local alReves = ruta.to == estado.actual and ruta.from ~= estado.actual
			if ruta.from == ruta.to then alReves = progreso > ruta.longitud / 2 end
			local avance = if alReves then ruta.longitud - progreso else progreso
			if avance >= 0.5 and avance <= math.min(10, ruta.longitud / 3) and distancia < ruta.ancho / 2 + 1 and math.abs(posicion.Y - altura) < 17 and distancia < separacion then
				candidata, separacion, inverso, distanciaInicial = ruta, distancia, alReves, avance
			end
		end
	end
	if candidata then
		local nuevo: Cruce = {
			ruta = candidata, desde = estado.actual,
			hasta = if inverso then candidata.from else candidata.to,
			inverso = inverso, avance = distanciaInicial, maximo = distanciaInicial,
		}
		estado.cruce = nuevo
		return {tipo = "entrada", cruce = nuevo}
	end
	return nil
end

return Detector

--!strict
local Escenario = require(script.Parent.EscenarioNivel)
type Datos = Escenario.Datos
type Ruta = Escenario.Ruta
type Reposo = {marco: CFrame, transparencia: number, colision: boolean, color: Color3}
type Onda = {ruta: Ruta, inverso: boolean, inicio: number, retardo: number, velocidad: number, intentoId: number}
export type Control = {
	bloqueadas: {[string]: boolean},
	iniciar: (string, boolean, number, number, number, number) -> (),
	actualizar: (number) -> (),
	restaurar: (number) -> (),
}

local Derrumbe = {}
function Derrumbe.crear(datos: Datos): Control
	local reposo: {[BasePart]: Reposo} = {}
	local posicionEnRuta: {[BasePart]: number} = {}
	local ondas: {[string]: Onda} = {}
	local bloqueadas: {[string]: boolean} = {}
	for _, ruta in datos.rutas do
		for _, pieza in ruta.modelo:GetDescendants() do
			if pieza:IsA("BasePart") then
				reposo[pieza] = {marco = pieza.CFrame, transparencia = pieza.Transparency, colision = pieza.CanCollide, color = pieza.Color}
				-- Estructura, barandales y braseros caen juntos al final, cuando ya no queda tablón bajo ellos.
				posicionEnRuta[pieza] = if pieza:GetAttribute("Kind") == "Tablon" then Escenario.proyectar(ruta, pieza.Position) else ruta.longitud + 2
				pieza:SetAttribute("MarcoReposo", pieza.CFrame)
				pieza:SetAttribute("TransparenciaReposo", pieza.Transparency)
				pieza:SetAttribute("ColisionReposo", pieza.CanCollide)
			end
		end
	end
	local function iniciar(id: string, inverso: boolean, ahora: number, retardo: number, velocidad: number, intentoId: number)
		if ondas[id] then return end
		local ruta = datos.rutas[id]
		assert(ruta, "Puente desconocido al iniciar el derrumbe.")
		ondas[id] = {ruta = ruta, inverso = inverso, inicio = ahora, retardo = retardo, velocidad = velocidad, intentoId = intentoId}
		bloqueadas[id] = true
		-- El cliente usa el extremo de llegada como bisagra cuando cae la estructura.
		ruta.modelo:SetAttribute("BisagraDerrumbe", if inverso then ruta.puntos[1] else ruta.puntos[#ruta.puntos])
	end
	local function actualizar(ahora: number)
		for _, onda in ondas do
			local frente = (ahora - onda.inicio - onda.retardo) * onda.velocidad
			if frente < 0 then continue end
			for _, pieza in onda.ruta.modelo:GetDescendants() do
				if pieza:IsA("BasePart") and reposo[pieza] and not pieza:GetAttribute("CaidaDesde") then
					local avance = posicionEnRuta[pieza]
					if onda.inverso then avance = onda.ruta.longitud - avance end
					if avance <= frente then
						pieza:SetAttribute("IntentoCaida", onda.intentoId)
						pieza:SetAttribute("CaidaDesde", ahora)
						-- Solo se retira el soporte; la caída visible la anima cada cliente.
						pieza.CanCollide = false
					end
				end
			end
		end
	end
	local function restaurar(intentoId: number)
		table.clear(ondas)
		table.clear(bloqueadas)
		for _, ruta in datos.rutas do ruta.modelo:SetAttribute("BisagraDerrumbe", nil) end
		datos.modelo:SetAttribute("IntentoId", intentoId)
		for pieza, original in reposo do
			if pieza.Parent then
				pieza:SetAttribute("CaidaDesde", nil)
				pieza:SetAttribute("IntentoCaida", nil)
				pieza.CFrame = original.marco
				pieza.Transparency = original.transparencia
				pieza.CanCollide = original.colision
				pieza.Color = original.color
			end
		end
	end
	return {bloqueadas = bloqueadas, iniciar = iniciar, actualizar = actualizar, restaurar = restaurar}
end
return Derrumbe


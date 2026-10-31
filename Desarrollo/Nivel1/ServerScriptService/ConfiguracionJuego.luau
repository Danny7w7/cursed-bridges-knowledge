--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Contratos = require(ReplicatedStorage.ContratosJuego)
type Configuracion = Contratos.Configuracion

local ConfiguracionJuego = {}
local instantanea: ConfigSnapshot? = nil
local iniciada = false

-- Los valores publicados son opcionales. Los atributos del mapa permiten probar sin servicios externos.
function ConfiguracionJuego.iniciar(nivel: Instance)
	if iniciada or nivel:GetAttribute("UsarConfiguracionPublicada") ~= true then return end
	iniciada = true
	task.spawn(function()
		local correcto, configuracion = pcall(function()
			return game:GetService("ConfigService"):GetConfigAsync()
		end)
		if correcto then
			instantanea = configuracion
			configuracion.UpdateAvailable:Connect(function()
				pcall(function() configuracion:Refresh() end)
			end)
		end
	end)
end

local function numero(nivel: Instance, atributo: string, respaldo: number, minimo: number, maximo: number): number
	local valor = nivel:GetAttribute(atributo)
	local publicada = instantanea
	if publicada and nivel:GetAttribute("UsarConfiguracionPublicada") == true then
		local remoto = publicada:GetValue("nivel" .. tostring(nivel:GetAttribute("LevelId") or 1) .. "_" .. atributo)
		if typeof(remoto) == "number" then valor = remoto end
	end
	if typeof(valor) ~= "number" or valor ~= valor then return respaldo end
	return math.clamp(valor, minimo, maximo)
end

function ConfiguracionJuego.leer(nivel: Instance): Configuracion
	return {
		ventajaInicial = numero(nivel, "VentajaInicial", 12, 0, 60),
		retardoDerrumbe = numero(nivel, "RetardoDerrumbe", 1, 0.25, 5),
		avisoSalto = numero(nivel, "AvisoSalto", 2, 1, 8),
		duracionSalto = numero(nivel, "DuracionSalto", 1.2, 0.5, 4),
		graciaAterrizaje = numero(nivel, "GraciaAterrizaje", 1, 0.5, 5),
		velocidadJugador = numero(nivel, "VelocidadJugador", 16, 8, 32),
	}
end

return ConfiguracionJuego

--!strict
-- Contratos compartidos; no ejecutan lógica de partida ni modifican el escenario.
export type TipoRecorrido = "sendero" | "trayectoria" | "camino_cerrado" | "circuito" | "circuito_simple"
export type Fase = "preparacion" | "activo" | "victoria" | "derrota"
export type Objetivo = {
	tipo: TipoRecorrido,
	inicio: string,
	final: string,
	islasObligatorias: {string},
}
export type Arista = {id: string, from: string, to: string}
export type Historial = {vertices: {string}, aristas: {string}}
export type Evaluacion = {
	valido: boolean,
	victoria: boolean,
	faltantes: {string},
	codigo: string?,
	mensaje: string?,
	paso: number?,
}
export type Resultado = {
	outcome: string,
	message: string,
	codigo: string,
	intentoId: number,
	vertices: {string},
	aristas: {string},
}
export type EstadoPresentacion = {
	intentoId: number,
	levelId: number,
	fase: Fase,
	titulo: string,
	instruccion: string,
	definicion: string,
	peligroDesde: number?,
	puedeContinuar: boolean,
	mapaListo: boolean?,
	resultado: Resultado?,
}
export type Configuracion = {
	ventajaInicial: number,
	retardoDerrumbe: number,
	avisoSalto: number,
	duracionSalto: number,
	graciaAterrizaje: number,
	velocidadJugador: number,
}
return table.freeze({version = "1.0.0"})

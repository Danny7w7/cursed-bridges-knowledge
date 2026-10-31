--!strict
-- Catálogo que ve el menú: nombre, concepto y un grafo esquemático (coordenadas 0..1) por nivel.
-- Un nivel es jugable cuando además existe Workspace.Niveles.NivelN; el resto se muestra como "Próximamente".
export type Entrada = {
	id: number, romano: string, nombre: string, concepto: string, descripcion: string,
	nodos: {[string]: Vector2}, aristas: {{string}},
}
local Catalogo: {Entrada} = {
	{
		id = 1, romano = "I", nombre = "El primer sendero", concepto = "Sendero",
		descripcion = "Sal de A y termina en D. Visita ambas islas intermedias en cualquier orden, sin repetir puentes.",
		nodos = {A = Vector2.new(0.42, 0.42), B = Vector2.new(0.12, 0.85), C = Vector2.new(0.72, 0.85), D = Vector2.new(0.88, 0.12)},
		aristas = {{"A", "B"}, {"B", "C"}, {"C", "A"}, {"A", "D"}},
	},
	{
		id = 2, romano = "II", nombre = "El regreso de Orfeo", concepto = "Circuito euleriano",
		descripcion = "Recorre todos los puentes y vuelve a la isla de partida.",
		nodos = {A = Vector2.new(0.1, 0.2), B = Vector2.new(0.1, 0.8), C = Vector2.new(0.5, 0.5), D = Vector2.new(0.9, 0.2), E = Vector2.new(0.9, 0.8)},
		aristas = {{"A", "B"}, {"B", "C"}, {"C", "A"}, {"C", "D"}, {"D", "E"}, {"E", "C"}},
	},
	{
		id = 3, romano = "III", nombre = "Los siete puentes", concepto = "Königsberg",
		descripcion = "El problema que Euler resolvió en 1736. ¿Puedes cruzar los siete puentes una sola vez?",
		nodos = {A = Vector2.new(0.5, 0.5), B = Vector2.new(0.5, 0.08), C = Vector2.new(0.5, 0.92), D = Vector2.new(0.92, 0.5)},
		aristas = {{"A", "B"}, {"A", "B"}, {"A", "C"}, {"A", "C"}, {"A", "D"}, {"B", "D"}, {"C", "D"}},
	},
	{
		id = 4, romano = "IV", nombre = "La casa de Hades", concepto = "Camino euleriano",
		descripcion = "Dos islas impares: descubre dónde debe empezar y terminar tu recorrido.",
		nodos = {A = Vector2.new(0.2, 0.92), B = Vector2.new(0.8, 0.92), C = Vector2.new(0.8, 0.45), D = Vector2.new(0.2, 0.45), E = Vector2.new(0.5, 0.08)},
		aristas = {{"A", "B"}, {"B", "C"}, {"C", "D"}, {"D", "A"}, {"A", "C"}, {"B", "D"}, {"D", "E"}, {"E", "C"}},
	},
	{
		id = 5, romano = "V", nombre = "Modo arquitecto", concepto = "Diseña tu grafo",
		descripcion = "Coloca islas y puentes, y comprueba si tu archipiélago tiene recorrido euleriano.",
		nodos = {A = Vector2.new(0.15, 0.3), B = Vector2.new(0.5, 0.12), C = Vector2.new(0.85, 0.35), D = Vector2.new(0.65, 0.85), E = Vector2.new(0.25, 0.8)},
		aristas = {},
	},
}
return Catalogo


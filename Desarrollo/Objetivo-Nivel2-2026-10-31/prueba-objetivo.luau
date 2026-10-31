local Rep=game:GetService("ReplicatedStorage")
local copias={}
local function modulo(fuente,nombre,source)
 local m=fuente:Clone()
 m.Name=nombre
 if source then m.Source=source end
 m.Parent=fuente.Parent
 table.insert(copias,m)
 return require(m)
end
local function iguales(a,b)
 if typeof(a)~=typeof(b) then return false end
 if type(a)~="table" then return a==b end
 for k,v in a do if not iguales(v,b[k]) then return false end end
 for k in b do if a[k]==nil then return false end end
 return true
end
local ok,resultado=pcall(function()
 local actual=modulo(Rep.LevelData,"LevelData_PruebaObjetivo2")
 local anterior=modulo(Rep.LevelData,"LevelData_AnteriorPruebaObjetivo2","--!strict\n-- El catálogo define objetivos. La topología y posiciones jugables se leen del escenario guardado.\nlocal Contratos = require(script.Parent.ContratosJuego)\nexport type NodeDef = {id: string, name: string, position: Vector3}\nexport type EdgeDef = {id: string, from: string, to: string}\nexport type LevelDef = {\n\tid: number, name: string, requiresCircuit: boolean, allowedStarts: {string}?,\n\tnodes: {NodeDef}, edges: {EdgeDef}, solvable: boolean, hint: string,\n\tobjetivo: Contratos.Objetivo?,\n}\nlocal LevelData = {}\nLevelData.Levels = {} :: {LevelDef}\nLevelData.Levels[1] = {\n\tid = 1, name = \"El primer sendero\", requiresCircuit = false, allowedStarts = {\"A\"},\n\tobjetivo = {tipo = \"sendero\", inicio = \"A\", final = \"D\", islasObligatorias = {\"B\", \"C\"}},\n\t-- Coordenadas de diseño para la herramienta de autoría, nunca para recolocar mapas al iniciar.\n\tnodes = {\n\t\t{id = \"A\", name = \"A\", position = Vector3.new(0, 0, 20)},\n\t\t{id = \"B\", name = \"B\", position = Vector3.new(-20, 0, -15)},\n\t\t{id = \"C\", name = \"C\", position = Vector3.new(20, 0, -15)},\n\t\t{id = \"D\", name = \"D\", position = Vector3.new(30.3045785, 0, 50.3045785)},\n\t},\n\tedges = {\n\t\t{id = \"AB\", from = \"A\", to = \"B\"}, {id = \"BC\", from = \"B\", to = \"C\"},\n\t\t{id = \"CA\", from = \"C\", to = \"A\"}, {id = \"AD\", from = \"A\", to = \"D\"},\n\t},\n\tsolvable = true, hint = \"\",\n}\nreturn LevelData\n")
 local Reglas=modulo(Rep.ReglasRecorrido,"Reglas_PruebaObjetivo2")
 local total=0
 local function comprobar(nombre,condicion)
  assert(condicion,"Falló: "..nombre)
  total+=1
 end
 comprobar("objetivo y datos del nivel 1 conservados",iguales(actual.Levels[1],anterior.Levels[1]))
 comprobar("solo dos niveles registrados",#actual.Levels==2)
 local d=actual.Levels[2]
 comprobar("identidad del nivel 2",d.id==2 and d.name=="La ruta sin retorno")
 local o=d.objetivo
 comprobar("tipo trayectoria",o.tipo=="trayectoria")
 comprobar("inicio A y final H",o.inicio=="A" and o.final=="H")
 comprobar("sin visitas adicionales",#o.islasObligatorias==0)
 comprobar("sin circuito obligatorio",d.requiresCircuit==false)
 comprobar("único inicio permitido",#d.allowedStarts==1 and d.allowedStarts[1]=="A")
 comprobar("sin pista de solución",d.hint=="")
 local escenario=workspace.Niveles.Nivel2_Escenario
 comprobar("ocho islas definidas",#d.nodes==8)
 local nodos={}
 local posicionesCorrectas=true
 for _,node in d.nodes do
  comprobar("isla única "..node.id,not nodos[node.id])
  nodos[node.id]=true
  local isla=escenario.Islands:FindFirstChild("Island_"..node.id)
  if not isla or isla:GetAttribute("NodeId")~=node.id then posicionesCorrectas=false
  else
   local centro=isla.PrimaryPart.Position+Vector3.new(0,3,0)
   posicionesCorrectas=posicionesCorrectas and (node.position*3.5+Vector3.new(0,12,0)-centro).Magnitude<0.001
  end
 end
 comprobar("datos de posición coinciden con el escenario guardado",posicionesCorrectas)
 comprobar("once aristas definidas",#d.edges==11)
 local mapa={}
 local conexionesCorrectas=true
 local adyacentes={}
 for id in nodos do adyacentes[id]={} end
 for _,e in d.edges do
  comprobar("arista única "..e.id,not mapa[e.id])
  mapa[e.id]=e
  local puente=escenario.Bridges:FindFirstChild("Bridge_"..e.id)
  conexionesCorrectas=conexionesCorrectas and nodos[e.from]~=nil and nodos[e.to]~=nil
   and puente~=nil and puente:GetAttribute("EdgeId")==e.id and puente:GetAttribute("From")==e.from and puente:GetAttribute("To")==e.to
  table.insert(adyacentes[e.from],{id=e.id,hasta=e.to})
  table.insert(adyacentes[e.to],{id=e.id,hasta=e.from})
 end
 comprobar("conexiones coinciden exactamente con las once del mapa",conexionesCorrectas and #escenario.Bridges:GetChildren()==#d.edges)
 local function evaluar(vertices,aristas)
  return Reglas.evaluar(o,d.edges,{vertices=vertices,aristas=aristas})
 end
 local corto=evaluar({"A","C","H"},{"AC","CH"})
 comprobar("gana con dos puentes sin exigir ocho islas ni once puentes",corto.valido and corto.victoria)
 local largo=evaluar({"A","C","F","B","E","G","D","H"},{"AC","CF","FB","BE","EG","GD","DH"})
 comprobar("acepta también una trayectoria de siete puentes",largo.valido and largo.victoria)
 local inverso=evaluar({"A","G","B","F","C","H"},{"AG","BG","FB","CF","CH"})
 comprobar("conexiones no dirigidas",inverso.valido and inverso.victoria)
 local vacio=evaluar({"A"},{})
 comprobar("aparecer en A no gana",vacio.valido and not vacio.victoria)
 local prefijo=evaluar({"A","C"},{"AC"})
 comprobar("trayectoria incompleta válida sin victoria",prefijo.valido and not prefijo.victoria)
 local repetido={vertices={"A","C","F","B","G","A"},aristas={"AC","CF","FB","BG","AG"}}
 local infraccion=Reglas.evaluar(o,d.edges,repetido)
 comprobar("rechaza vértice repetido con cinco puentes distintos",not infraccion.valido and not infraccion.victoria and infraccion.codigo=="vertice_repetido" and infraccion.paso==5)
 local sendero=table.clone(o)
 sendero.tipo="sendero"
 comprobar("el mismo recorrido sí cumple la regla de sendero",Reglas.evaluar(sendero,d.edges,repetido).valido)
 comprobar("rechaza repetir puente en sentido contrario",evaluar({"A","C","A"},{"AC","AC"}).codigo=="arista_repetida")
 comprobar("rechaza conexión inexistente",evaluar({"A","B"},{"AB"}).codigo=="conexion_invalida")
 comprobar("rechaza inicio distinto de A",evaluar({"G","D","H"},{"GD","DH"}).codigo=="historial_invalido")
 local salidas=Reglas.salidasLegales(o,d.edges,{vertices={"A","C"},aristas={"AC"}},{})
 local ids={}
 for _,e in salidas do ids[e.id]=true end
 comprobar("desde C no permite volver a A",#salidas==2 and ids.CF==true and ids.CH==true and not ids.AC)
 local bloqueadas=Reglas.salidasLegales(o,d.edges,{vertices={"A","C"},aristas={"AC"}},{CF=true})
 comprobar("respeta el bloqueo físico sin modificar las reglas",#bloqueadas==1 and bloqueadas[1].id=="CH")
 local rutas={}
 local function recorrer(vertices,aristas,visitadas)
  local v=vertices[#vertices]
  if v=="H" then
   table.insert(rutas,{vertices=table.clone(vertices),aristas=table.clone(aristas)})
   return
  end
  for _,e in adyacentes[v] do
   if not visitadas[e.hasta] then
    visitadas[e.hasta]=true table.insert(vertices,e.hasta) table.insert(aristas,e.id)
    recorrer(vertices,aristas,visitadas)
    table.remove(vertices) table.remove(aristas) visitadas[e.hasta]=nil
   end
  end
 end
 recorrer({"A"},{},{A=true})
 comprobar("hay diez trayectorias A-H según enumeración independiente",#rutas==10)
 local minimo,maximo=math.huge,0
 for i,ruta in rutas do
  local e=Reglas.evaluar(o,d.edges,ruta)
  comprobar("el validador acepta la trayectoria independiente "..i,e.valido and e.victoria)
  minimo=math.min(minimo,#ruta.aristas)
  maximo=math.max(maximo,#ruta.aristas)
 end
 comprobar("las soluciones tienen longitudes diversas",minimo==2 and maximo==7)
 comprobar("solvable corresponde a soluciones reales",d.solvable==true and #rutas>0)
 comprobar("registro no habilita la partida",not workspace.Niveles:FindFirstChild("Nivel2") and escenario:GetAttribute("SoloEscenario")==true)
 local base=modulo(game.ServerScriptService.PruebasReglasRecorrido,"PruebasReglas_BaseObjetivo2")()
 comprobar("pruebas previas de cinco tipos",base.correctas==18)
 return {correctas=total,regresionReglas=base.correctas,trayectoriasValidas=#rutas,minPuentes=minimo,maxPuentes=maximo,nivel1SinCambios=true,nivel2Activado=false}
end)
for i=#copias,1,-1 do copias[i]:Destroy() end
assert(ok,resultado)
return game:GetService("HttpService"):JSONEncode(resultado)


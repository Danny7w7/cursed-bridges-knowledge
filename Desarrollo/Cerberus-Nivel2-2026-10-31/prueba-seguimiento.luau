assert(not game:GetService("RunService"):IsRunning(),"Ejecutar en Edición.")
local temporal=Instance.new("Folder")
temporal.Name="PruebaTemporalCerberusNivel2"
temporal:SetAttribute("LevelId",2)
temporal.Parent=game.ServerStorage
local total=0
local function comprobar(ok,mensaje) assert(ok,mensaje) total+=1 end
local ok,resultado=pcall(function()
 for _,nombre in {"EscenarioNivel","DetectorCruces","PersecucionCerberus","ConfiguracionJuego"} do
  game.ServerScriptService[nombre]:Clone().Parent=temporal
 end
 local E=require(temporal.EscenarioNivel)
 local P=require(temporal.PersecucionCerberus)
 local config=require(temporal.ConfiguracionJuego).leer(workspace.Niveles.Nivel2_Escenario)
 comprobar(config.velocidadJugador==16 and config.ventajaInicial==4,"Configuración de velocidad/ventaja incorrecta.")
 comprobar(config.avisoSalto==2 and config.duracionSalto==1.2 and config.graciaAterrizaje==1,"Los tiempos de salto cambiaron.")
 local datos=E.cargar(workspace.Niveles.Nivel2_Escenario)
 local copia=datos.cerberus:Clone()
 copia.Parent=temporal
 datos.cerberus=copia
 datos.modelo=temporal
 local enemigo=P.crear(datos,"A")
 local raiz=enemigo.raiz
 local reposo=raiz.CFrame
 local aviso=temporal.AvisoSaltoCerberus
 local ahora=0
 local dt=0.1
 local jugador=datos.islas.H.centro+Vector3.new(0,3,0)
 local detector={actual="H",cruce=nil,anterior=nil}
 local bloqueadas={}
 local pasos=0
 local maxVelocidad=0
 local muestrasSalto=0
 local function avanzar()
  local antes=raiz.Position
  local previo=raiz:GetAttribute("EstadoMovimiento")
  ahora+=dt
  local captura=enemigo.actualizar(ahora,dt,jugador,detector,bloqueadas,config)
  local estado=raiz:GetAttribute("EstadoMovimiento")
  assert(not captura or (estado~="preparando_salto" and estado~="saltando" and estado~="aterrizando"),"Captura durante aviso, salto o gracia.")
  if previo=="caminando" and estado=="caminando" then
   local velocidad=E.distanciaPlana(antes,raiz.Position)/dt
   maxVelocidad=math.max(maxVelocidad,velocidad)
   assert(velocidad<=config.velocidadJugador+0.02,"Superó la velocidad de caminata.")
  end
  if estado=="saltando" then
   local id=raiz:GetAttribute("RutaEnUso")
   local ruta=id and datos.rutas[id]
   if ruta then
    local avance,distancia=E.proyectar(ruta,raiz.Position)
    if avance>1 and avance<ruta.longitud-1 then
     assert(distancia<0.1,"El salto se apartó del mismo puente.")
     muestrasSalto+=1
    end
   end
  end
  pasos+=1 if pasos%100==0 then task.wait() end
  return captura
 end
 local function reiniciar()
  enemigo.restaurar()
  ahora=0
  bloqueadas={}
  jugador=datos.islas.H.centro+Vector3.new(0,3,0)
  detector.actual,detector.cruce="H",nil
 end
 local function registrar(id,desde,terminado)
  local r=datos.rutas[id]
  local inverso=r.to==desde
  local c={ruta=r,desde=desde,hasta=if inverso then r.from else r.to,inverso=inverso,avance=r.longitud,maximo=r.longitud}
  enemigo.registrar({tipo="entrada",cruce=c})
  enemigo.registrar({tipo="entrada",cruce=c})
  if terminado then enemigo.registrar({tipo="llegada",cruce=c}) end
  return c
 end
 local rutas={}
 local adyacentes={}
 for id in datos.islas do adyacentes[id]={} end
 for _,a in datos.aristas do
  table.insert(adyacentes[a.from],{id=a.id,hasta=a.to})
  table.insert(adyacentes[a.to],{id=a.id,hasta=a.from})
 end
 local function explorar(vertices,aristas,visitadas)
  local v=vertices[#vertices]
  if v=="H" then table.insert(rutas,{vertices=table.clone(vertices),aristas=table.clone(aristas)}) return end
  for _,a in adyacentes[v] do if not visitadas[a.hasta] then
   visitadas[a.hasta]=true table.insert(vertices,a.hasta) table.insert(aristas,a.id)
   explorar(vertices,aristas,visitadas)
   table.remove(vertices) table.remove(aristas) visitadas[a.hasta]=nil
  end end
 end
 explorar({"A"},{},{A=true})
 comprobar(#rutas==10,"El grafo ya no tiene las diez trayectorias registradas.")
 for _,caidos in {false,true} do
  for i,ruta in rutas do
   reiniciar()
   local limite=20
   for j,id in ruta.aristas do
    registrar(id,ruta.vertices[j],true)
    limite+=(datos.rutas[id].longitud+100)/16
    if caidos then bloqueadas[id]=true end
   end
   local origen=raiz.CFrame
   for _=1,40 do avanzar() end
   comprobar(raiz.CFrame==origen and raiz:GetAttribute("AristasSeguidas")=="","Se movió antes de activar la persecución o perdió la cola.")
   enemigo.activar()
   avanzar()
   comprobar(E.islaEn(datos,aviso.Position)=="A","Ingresó por otra isla en lugar de A.")
   local esperada=table.concat(ruta.aristas,", ")
   repeat avanzar() until raiz:GetAttribute("AristasSeguidas")==esperada or ahora>limite
   comprobar(raiz:GetAttribute("AristasSeguidas")==esperada,"No siguió el orden de la trayectoria "..i.." (caídos="..tostring(caidos)..").")
   comprobar(raiz:GetAttribute("IslaActual")=="H","No terminó en H siguiendo todos los extremos.")
  end
 end
 comprobar(muestrasSalto>0,"No se muestreó el salto sobre los puentes reales.")
 reiniciar()
 local c=registrar("AC","A",false)
 c.avance,c.maximo=c.ruta.longitud/2,c.ruta.longitud/2
 detector.actual,detector.cruce="A",c
 jugador=E.punto(c.ruta,c.avance)+Vector3.new(0,3,0)
 bloqueadas.AC=true
 enemigo.activar()
 for _=1,300 do avanzar() end
 comprobar(raiz:GetAttribute("IslaActual")=="A" and raiz:GetAttribute("AristasSeguidas")=="","Saltó a C sin una llegada del jugador.")
 comprobar(aviso.Transparency==1,"Anunció un destino de cruce incompleto.")
 c.avance=c.ruta.longitud
 enemigo.registrar({tipo="llegada",cruce=c})
 detector.actual,detector.cruce="C",nil
 local limite=ahora+20
 repeat avanzar() until raiz:GetAttribute("EstadoMovimiento")=="preparando_salto" or ahora>limite
 comprobar(E.islaEn(datos,aviso.Position)=="C","El aviso no conserva el extremo real de AC.")
 local destino=aviso.Position
 jugador=datos.islas.F.centro+Vector3.new(0,3,0)
 avanzar()
 comprobar(aviso.Position==destino,"El aviso cambió para interceptar otra isla.")
 limite=ahora+10
 repeat avanzar() until raiz:GetAttribute("AristasSeguidas")=="AC" or ahora>limite
 comprobar(raiz:GetAttribute("IslaActual")=="C","Tomó un atajo después del anuncio.")
 reiniciar()
 c=registrar("AC","A",false)
 c.avance,c.maximo=c.ruta.longitud/2,c.ruta.longitud/2
 detector.actual,detector.cruce="A",c
 bloqueadas.AC=true
 enemigo.activar()
 for _=1,180 do avanzar() end
 c.avance=0
 enemigo.registrar({tipo="regreso",cruce=c})
 detector.cruce=nil
 jugador=datos.islas.A.centro+Vector3.new(0,3,0)
 limite=ahora+30
 repeat avanzar() until raiz:GetAttribute("RutaEnUso")==nil or ahora>limite
 comprobar(raiz:GetAttribute("IslaActual")=="A" and raiz:GetAttribute("AristasSeguidas")=="","El regreso inventó una visita completa a C.")
 reiniciar()
 jugador=datos.islas.A.centro+Vector3.new(0,3,0)
 detector.actual="A"
 for _=1,40 do comprobar(not avanzar(),"Captura antes de activar.") end
 enemigo.activar()
 local captura=false
 repeat captura=avanzar() until captura or ahora>20
 comprobar(captura,"No captura al jugador inmóvil en A.")
 local tiempoCaptura=ahora
 enemigo.detener()
 local detenido=raiz.CFrame
 for _=1,10 do comprobar(not avanzar(),"Captura después de detener.") end
 comprobar(raiz.CFrame==detenido,"Se mueve después de detener.")
 enemigo.restaurar()
 comprobar(raiz.CFrame==reposo,"El reinicio no volvió a la roca.")
 comprobar(raiz:GetAttribute("AristasSeguidas")=="" and raiz:GetAttribute("RutaEnUso")==nil and raiz:GetAttribute("IslaActual")==nil,"El reinicio conserva el rastro.")
 comprobar(aviso.Transparency==1 and not aviso.Advertencia.Enabled,"El reinicio conserva la advertencia.")
 comprobar(not workspace.Niveles.Nivel2_Escenario.Cerberus:FindFirstChild("RaizMovimiento"),"La prueba dejó un controlador en el mapa de Edición.")
 return {correctas=total,trayectoriasProbadas=#rutas,escenariosDeSeguimiento=2*#rutas,maxVelocidad=maxVelocidad,muestrasSalto=muestrasSalto,tiempoCapturaSimulado=tiempoCaptura,ventajaInicial=config.ventajaInicial}
end)
temporal:Destroy()
assert(ok,resultado)
return game:GetService("HttpService"):JSONEncode(resultado)


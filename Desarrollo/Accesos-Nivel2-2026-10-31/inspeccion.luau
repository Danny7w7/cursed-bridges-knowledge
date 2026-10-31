local n=workspace.Niveles.Nivel2_Escenario
local Http=game:GetService("HttpService")
local function radio(p,e)
 return (math.abs(p.CFrame.RightVector:Dot(e))*p.Size.X+math.abs(p.CFrame.UpVector:Dot(e))*p.Size.Y+math.abs(p.CFrame.LookVector:Dot(e))*p.Size.Z)/2
end
local function corredores(isla)
 local c=isla.PrimaryPart.Position+Vector3.new(0,3,0)
 local salida={}
 local id=isla:GetAttribute("NodeId")
 for _,b in n.Bridges:GetChildren() do
 if b:GetAttribute("From")==id or b:GetAttribute("To")==id then
  local tablas={}
  for _,p in b:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("Kind")=="Tablon" then table.insert(tablas,p) end end
  table.sort(tablas,function(a,b)return a:GetAttribute("Order")<b:GetAttribute("Order") end)
  local primero=if b:GetAttribute("From")==id then tablas[1] else tablas[#tablas]
  local v=Vector3.new(primero.Position.X-c.X,0,primero.Position.Z-c.Z)
  local t=v.Unit
  local r=Vector3.new(t.Z,0,-t.X)
  table.insert(salida,{centro=c,t=t,r=r,ancho=radio(primero,r)*2,largo=v.Magnitude,arista=b:GetAttribute("EdgeId")})
 end end
 return salida
end
local function invade(p,c,minimo,altura)
 local d=p.Position-c.centro
 local x,z=d:Dot(c.t),d:Dot(c.r)
 return x+radio(p,c.t)>=minimo and x-radio(p,c.t)<=c.largo+6
  and math.abs(z)<=c.ancho/2+radio(p,c.r) and p.Position.Y+radio(p,Vector3.yAxis)>=altura
end
local function objetivos()
 local lista,mapa,resumen={},{},{}
 local accesos=0
 local function agregar(p,id,tipo,grupo)
  if mapa[p] then return end
  mapa[p]=true
  table.insert(lista,{p=p,isla=id,tipo=tipo,grupo=grupo})
 end
 for _,isla in n.Islands:GetChildren() do
  local id=isla:GetAttribute("NodeId")
  local visual=isla.PrimaryPart.Visual
  local entradas=corredores(isla)
  accesos+=#entradas
  local gruposActivos=0
  for _,g in visual:GetChildren() do
   if g:GetAttribute("MuelleOriginal")~=nil and typeof(g:GetAttribute("Vecino"))=="string" and g:GetAttribute("Vecino")~="" then
    gruposActivos+=1
    for _,p in g:GetChildren() do
     if p:IsA("BasePart") and (p.Name:match("^05_Muelle_") or p.Name:match("^Muelle_")) then agregar(p,id,"portal",g.Name) end
    end
   end
  end
  assert(gruposActivos==#entradas,"Los muelles no coinciden con las conexiones de "..id)
  local altares={}
  local rocas=0
  for _,p in visual:GetDescendants() do
   if p:IsA("BasePart") then
    if p.Name:match("^06_Aguja_") then
     for _,c in entradas do if invade(p,c,24,13) then
      local raiz=p
      while raiz.Parent~=visual.world do
       assert(raiz.Parent and raiz.Parent:IsDescendantOf(visual.world),"Roca fuera del modelo previsto.")
       raiz=raiz.Parent
      end
      agregar(raiz,id,"roca","Rocas")
      break
     end end
    elseif p.Name:match("^11_Altar_") then
     for _,c in entradas do if invade(p,c,30,15) then altares[p.Name:match("^11_Altar_(%d+)_")]=true break end end
    end
   end
  end
  for _,p in visual.world:GetChildren() do
   local indice=p.Name:match("^11_Altar_(%d+)_")
   if indice and altares[indice] then agregar(p,id,"altar","Altares") end
  end
  local altaresN=0 for _ in altares do altaresN+=1 end
  table.insert(resumen,{isla=id,accesos=#entradas,altares=altaresN})
  task.wait()
 end
 local piezas,fuegos=0,0
 local categorias={portal=0,roca=0,altar=0}
 local partes={}
 for _,o in lista do
  categorias[o.tipo]+=1
  if o.p:IsA("BasePart") then piezas+=1 table.insert(partes,o.p) end
  for _,p in o.p:GetDescendants() do
   if p:IsA("BasePart") then piezas+=1 table.insert(partes,p) end
   if p:IsA("Fire") then fuegos+=1 end
  end
 end
 return lista,partes,{accesos=accesos,raices=#lista,BaseParts=piezas,fuegos=fuegos,categorias=categorias,islas=resumen}
end
local function firma(partes)
 local datos={}
 for i,p in partes do
  local cf={p.CFrame:GetComponents()}
  for j,v in cf do cf[j]=string.format("%.9g",v) end
  local x={p:GetFullName(),table.concat(cf,","),tostring(p.Size),tostring(p.Color),p.Material.Name,p.MaterialVariant,tostring(p.Transparency),tostring(p.Reflectance),tostring(p.Anchored),tostring(p.CanCollide),tostring(p.CanQuery),tostring(p.CanTouch)}
  if p:IsA("MeshPart") then table.insert(x,p.MeshId) table.insert(x,p.TextureID) table.insert(x,p.CollisionFidelity.Name) end
  for _,h in p:GetChildren() do if h:IsA("SurfaceAppearance") then table.insert(x,h.ColorMap.."|"..h.NormalMap.."|"..h.RoughnessMap.."|"..h.MetalnessMap) end end
  table.insert(datos,table.concat(x,"|"))
  if i%500==0 then task.wait() end
 end
 table.sort(datos)
 local a,b=0,0
 for i,linea in datos do
  for j=1,#linea do local c=string.byte(linea,j) a,b=(a*131+c)%2147483647,(b*257+c)%2147483629 end
  if i%500==0 then task.wait() end
 end
 return {piezas=#partes,huella=tostring(a)..":"..tostring(b)}
end
local function proteccion(excluidas)
 local partes={}
 local excluir={}
 for _,p in excluidas do excluir[p]=true end
 for _,root in {workspace.Niveles,game.ServerStorage.Isla} do
  for _,p in root:GetDescendants() do if p:IsA("BasePart") and not excluir[p] then table.insert(partes,p) end end
 end
 return firma(partes)
end

local _,partes,resumen=objetivos()
return Http:JSONEncode({resumen=resumen,objetivosFirma=firma(partes),proteccion=proteccion(partes)})


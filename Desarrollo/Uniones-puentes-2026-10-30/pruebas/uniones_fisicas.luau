local INICIO, FIN = 1, 4
local nivel=workspace.Niveles.Nivel1
local jugador=game:GetService("Players"):GetPlayers()[1]
local personaje=jugador.Character or jugador.CharacterAdded:Wait()
local anterior=personaje.Archivable
personaje.Archivable=true
local modelo=personaje:Clone()
personaje.Archivable=anterior
modelo.Name="PruebaTemporalUniones"
for _,d in modelo:GetDescendants() do if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ForceField") or d:IsA("Tool") then d:Destroy() end end
local h=modelo.Humanoid
local raiz=modelo.HumanoidRootPart
raiz.Anchored=false
h.WalkSpeed=16
h.JumpPower=0
h.JumpHeight=0
h:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
local contenedor=Instance.new("Folder")
contenedor.Name="PruebaTemporalAccesos"
contenedor.Parent=workspace
local desplazamiento=Vector3.new(0,150,1000)
for _,contenedorOrigen in {nivel.Islands,nivel.Bridges} do
 local cantidad=0
 for _,p in contenedorOrigen:GetDescendants() do
 if p:IsA("BasePart") then
 local colision=p:GetAttribute("ColisionReposo")
 if colision==nil then colision=p.CanCollide end
 if colision then
 local copia=p:Clone()
 for _,hijo in copia:GetChildren() do hijo:Destroy() end
 copia.CFrame=(p:GetAttribute("MarcoReposo") or p.CFrame)+desplazamiento
 copia.CanCollide=true
 copia.Transparency=0
 copia.Anchored=true
 copia.Parent=contenedor
 cantidad+=1
 if cantidad%100==0 then task.wait() end
 end
 end
 end
end
local uniones={}
for _,p in nivel.Islands:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("UnionGenerada")==true then table.insert(uniones,p) end end
table.sort(uniones,function(a,b) return a.Name<b.Name end)
local resultados={}
local function distancia(a,b) return Vector2.new(a.X-b.X,a.Z-b.Z).Magnitude end
local ok,fallo=pcall(function()
for indice=INICIO,FIN do
 local union=uniones[indice]
 local puente=nivel.Bridges["Bridge_"..union:GetAttribute("PuenteId")]
 local tablas={}
 for _,p in puente:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("Kind")=="Tablon" then table.insert(tablas,p) end end
 table.sort(tablas,function(a,b) return a:GetAttribute("Order")<b:GetAttribute("Order") end)
 local primero=union:GetAttribute("Extremo")=="From"
 local tabla=tablas[if primero then 1 else #tablas]
 local vecina=tablas[if primero then 2 else #tablas-1]
 local t=Vector3.new(vecina.Position.X-tabla.Position.X,0,vecina.Position.Z-tabla.Position.Z).Unit
 local r=Vector3.new(t.Z,0,-t.X)
 local ancho=math.max(tabla.Size.X,tabla.Size.Z)
 for _,fraccion in {-0.82,0,0.82} do
 local a=tabla.Position-t*8+r*ancho/2*fraccion+desplazamiento
 local b=tabla.Position+t*7+r*ancho/2*fraccion+desplazamiento
 local actor=modelo:Clone()
 actor.Parent=contenedor
 local raiz=actor.HumanoidRootPart
 local h=actor.Humanoid
 h:Move(Vector3.zero)
 raiz.Anchored=true
 actor:PivotTo(CFrame.lookAt(Vector3.new(a.X,167,a.Z),Vector3.new(b.X,167,b.Z)))
 raiz.AssemblyLinearVelocity=Vector3.zero
 raiz.AssemblyAngularVelocity=Vector3.zero
 raiz.Anchored=false
 raiz:SetNetworkOwner(nil)
 h:MoveTo(raiz.Position)
 task.wait(0.35)
 local minY=raiz.Position.Y
 local caida=false
 local atasco=false
 for _,punto in {b,a} do
 h:MoveTo(Vector3.new(punto.X,raiz.Position.Y,punto.Z))
 local limite=os.clock()+3
 while distancia(raiz.Position,punto)>1.2 do
 task.wait(0.03)
 minY=math.min(minY,raiz.Position.Y)
 if raiz.Position.Y<160 then caida=true break end
 if os.clock()>limite then atasco=true break end
 end
 if caida or atasco then break end
 end
 table.insert(resultados,{union=union.Name,carril=fraccion,caida=caida,atasco=atasco,minY=minY-150})
 actor:Destroy()
 end
end
end)
modelo:Destroy()
contenedor:Destroy()
assert(ok,fallo)
return game:GetService("HttpService"):JSONEncode(resultados)

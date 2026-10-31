local INICIO, FIN = 1, 6
local nivel=workspace.Niveles.Nivel2_Escenario
local p=game:GetService("Players"):GetPlayers()[1]
local personaje=p.Character or p.CharacterAdded:Wait()
local anterior=personaje.Archivable
personaje.Archivable=true
local prototipo=personaje:Clone()
personaje.Archivable=anterior
for _,s in prototipo:GetDescendants() do if s:IsA("LuaSourceContainer") or s:IsA("Tool") or s:IsA("ForceField") then s:Destroy() end end
local casos={}
for _,puente in nivel.Bridges:GetChildren() do
 local tablas={}
 for _,q in puente:GetDescendants() do if q:IsA("BasePart") and q:GetAttribute("Kind")=="Tablon" then table.insert(tablas,q) end end
 table.sort(tablas,function(a,b) return a:GetAttribute("Order")<b:GetAttribute("Order") end)
 local primero,ultimo=tablas[1].Position,tablas[#tablas].Position
 local t=Vector3.new(ultimo.X-primero.X,0,ultimo.Z-primero.Z).Unit
 for _,ext in {"From","To"} do
 local inicio=if ext=="From" then primero else ultimo
 local dir=if ext=="From" then t else -t
 table.insert(casos,{nombre="Acceso_"..puente:GetAttribute("EdgeId").."_"..ext,a=inicio-dir*10,b=inicio+dir*7})
 if puente:GetAttribute(ext)=="B" or puente:GetAttribute(ext)=="G" then
 local isla=nivel.Islands["Island_"..puente:GetAttribute(ext)]
 table.insert(casos,{nombre="Puerta_"..puente:GetAttribute(ext).."_"..puente:GetAttribute("EdgeId"),a=isla.PrimaryPart.Position+dir*28,b=inicio+dir*4})
 end
 end
 for _,s in puente:GetChildren() do if s:IsA("Model") then
 local numero=tonumber(s.Name:match("Tramo_(%d+)"))
 local siguiente=numero and puente:FindFirstChild("Tramo_"..string.format("%02d",numero+1))
 if siguiente then
 local finalPrimero,inicioSegundo=-math.huge,math.huge
 for _,q in s:GetDescendants() do if q:IsA("BasePart") and q:GetAttribute("Kind")=="Tablon" then finalPrimero=math.max(finalPrimero,(q.Position-primero):Dot(t)) end end
 for _,q in siguiente:GetDescendants() do if q:IsA("BasePart") and q:GetAttribute("Kind")=="Tablon" then inicioSegundo=math.min(inicioSegundo,(q.Position-primero):Dot(t)) end end
 local centro=primero+t*(finalPrimero+inicioSegundo)/2
 table.insert(casos,{nombre="Junta_"..puente:GetAttribute("EdgeId").."_"..numero,a=centro-t*7,b=centro+t*7})
 end
 end end
end
table.sort(casos,function(a,b) return a.nombre<b.nombre end)
local resultados={}
local actor
local function plano(a,b) return Vector2.new(a.X-b.X,a.Z-b.Z).Magnitude end
local ok,fallo=pcall(function()
 for indice=INICIO,math.min(FIN,#casos) do
 local caso=casos[indice]
 actor=prototipo:Clone()
 actor.Name="PruebaTemporalPasoNivel2"
 local h,raiz=actor.Humanoid,actor.HumanoidRootPart
 h.WalkSpeed=16 h.JumpPower=0 h.JumpHeight=0
 h:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
 h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 raiz.Anchored=true
 actor:PivotTo(CFrame.lookAt(Vector3.new(caso.a.X,17,caso.a.Z),Vector3.new(caso.b.X,17,caso.b.Z)))
 actor.Parent=workspace
 raiz.Anchored=false
 raiz:SetNetworkOwner(nil)
 h:MoveTo(raiz.Position)
 task.wait(0.35)
 local caida,atasco=false,false
 local minY=raiz.Position.Y
 for _,destino in {caso.b,caso.a} do
 h:MoveTo(Vector3.new(destino.X,raiz.Position.Y,destino.Z))
 local limite=os.clock()+plano(raiz.Position,destino)/16+2
 while plano(raiz.Position,destino)>1.2 do
 task.wait(0.03)
 minY=math.min(minY,raiz.Position.Y)
 if raiz.Position.Y<10 then caida=true break end
 if os.clock()>limite then atasco=true break end
 end
 if caida or atasco then break end
 end
 table.insert(resultados,{nombre=caso.nombre,caida=caida,atasco=atasco,minY=minY,posicion=if caida or atasco then tostring(raiz.Position) else nil})
 actor:Destroy() actor=nil
 end
end)
if actor then actor:Destroy() end
prototipo:Destroy()
assert(ok,fallo)
return game:GetService("HttpService"):JSONEncode({total=#casos,resultados=resultados})

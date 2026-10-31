local n=workspace.Niveles.Nivel2_Escenario
local parametros=RaycastParams.new()
parametros.FilterType=Enum.RaycastFilterType.Include
parametros.FilterDescendantsInstances={n.Islands,n.Bridges}
parametros.RespectCanCollide=true
local resultado={puentes={},muestras=0,huecos=0,solapesPuentes={}}
for _,m in n.Bridges:GetChildren() do
 local a=n.Islands["Island_"..m:GetAttribute("From")].PrimaryPart.Position
 local b=n.Islands["Island_"..m:GetAttribute("To")].PrimaryPart.Position
 local t=Vector3.new(b.X-a.X,0,b.Z-a.Z).Unit
 local lateral=Vector3.new(t.Z,0,-t.X)
 local d=Vector3.new(b.X-a.X,0,b.Z-a.Z).Magnitude
 local ancho=m:GetAttribute("AnchoTablero")
 local huecos,muestras,ejemplos=0,0,{}
 for s=25,d-25,0.5 do
 for _,fraccion in {-0.95,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,0.95} do
 local p=a+t*s+lateral*ancho/2*fraccion
 local hit=workspace:Raycast(Vector3.new(p.X,14.5,p.Z),Vector3.new(0,-6,0),parametros)
 muestras+=1
 if not hit then huecos+=1 if #ejemplos<3 then table.insert(ejemplos,{s=s,lateral=fraccion,pos=tostring(p)}) end end
 end
 if math.floor(s*2)%200==0 then task.wait() end
 end
 resultado.muestras+=muestras resultado.huecos+=huecos
 table.insert(resultado.puentes,{id=m:GetAttribute("EdgeId"),muestras=muestras,huecos=huecos,ejemplos=ejemplos})
end
local vistos={}
local superposicion=OverlapParams.new()
superposicion.FilterType=Enum.RaycastFilterType.Include
superposicion.FilterDescendantsInstances={n.Bridges}
superposicion.RespectCanCollide=true
for _,p in n.Bridges:GetDescendants() do
 if p:IsA("BasePart") and p:GetAttribute("Kind")=="Estructura" then
 for _,q in workspace:GetPartsInPart(p,superposicion) do
 local am=p:FindFirstAncestorWhichIsA("Model")
 while am and am.Parent~=n.Bridges do am=am.Parent:FindFirstAncestorWhichIsA("Model") end
 local bm=q:FindFirstAncestorWhichIsA("Model")
 while bm and bm.Parent~=n.Bridges do bm=bm.Parent:FindFirstAncestorWhichIsA("Model") end
 if am and bm and am~=bm then
 local clave=am.Name..":"..bm.Name
 if not vistos[clave] then vistos[clave]=true table.insert(resultado.solapesPuentes,{a=am.Name,b=bm.Name}) end
 end
 end
 end
end
return game:GetService("HttpService"):JSONEncode(resultado)

local jugador=game:GetService("Players").LocalPlayer
local original=jugador.PlayerScripts:WaitForChild("MenuPrincipal")
original.Enabled=false
game:GetService("RunService"):UnbindFromRenderStep("CamaraMenu")
local guiAnterior=jugador.PlayerGui:FindFirstChild("MenuPrincipal")
if guiAnterior then guiAnterior:Destroy() end
local menu=require(game.ReplicatedStorage.PruebaTemporalMenuEducativo)
local terminado,fallo=false,nil
task.spawn(function()
 local ok,err=pcall(function() menu.iniciar(1) end)
 if not ok then fallo=tostring(err) end
 terminado=true
end)
local textos={}
local titulos={}
local seMantienePreparado=true
local fin=os.clock()+40
while not terminado and os.clock()<fin do
 local gui=jugador.PlayerGui:FindFirstChild("MenuPrincipal")
 local rotulo=gui and gui:FindFirstChild("Rotulo")
 if rotulo and rotulo.GroupTransparency<0.5 then
  for _,t in rotulo:GetChildren() do if t:IsA("TextLabel") then
   assert(t.TextFits,"No cabe el rótulo: "..t.Text)
   textos[t.Text]=true
  end end
 end
 local tarjeta=gui and gui:FindFirstChild("TituloNivel")
 if tarjeta and tarjeta.GroupTransparency<0.5 then
  for _,t in tarjeta:GetChildren() do if t:IsA("TextLabel") then titulos[t.Text]=true end end
 end
 local n=workspace.Niveles.Nivel1
 if n:GetAttribute("FaseIntento")~="preparacion" then seMantienePreparado=false end
 task.wait(0.05)
end
assert(terminado and not fallo,fallo or "La cinemática no terminó")
assert(seMantienePreparado,"La persecución empezó durante la lectura")
assert(textos["Dos senderos posibles"],"No presentó los dos senderos")
for texto in textos do
 assert(not string.find(texto,"empieza en",1,true) and not string.find(texto,"euleriano",1,true),"Se conserva el rótulo antiguo")
 assert(not string.match(texto,"^Isla [ABCD]$"),"Se sugirió una secuencia de islas")
end
assert(menu.modoActual()=="juego" and jugador.PlayerGui.PuentesMalditosUI.Enabled,"No devolvió la interfaz del intento")
return game:GetService("HttpService"):JSONEncode({textos=textos,titulos=titulos,preparacionRespetada=seMantienePreparado,modo=menu.modoActual()})

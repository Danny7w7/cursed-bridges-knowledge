local jugador=game:GetService("Players").LocalPlayer
local almacenamiento=game.ReplicatedStorage
local T=require(almacenamiento.TextosEducativos)
local R=require(almacenamiento.ReglasRecorrido)
local I=require(almacenamiento.InterfazIntento)
local carpeta=Instance.new("Folder")
carpeta.Name="PruebaTemporalInterfazEducativa"
carpeta.Parent=jugador.PlayerGui
local interfaz=I.crear(carpeta,{alComenzar=function()end,alReintentar=function()end,alContinuar=function()end})
local gui=carpeta.PuentesMalditosUI
gui.Name="PruebaTemporalInterfazEducativa"
gui.Parent=jugador.PlayerGui
gui.Enabled=true
gui.DisplayOrder=-10
local total=0
local medidas={}
local function comprobar(condicion,mensaje) assert(condicion,mensaje) total+=1 end
local ok,fallo=pcall(function()
 local estado={intentoId=99001,levelId=1,fase="preparacion",titulo="Sendero",instruccion="Sal de A y termina en D. Visita B y C en cualquier orden. No repitas puentes.",definicion=T.definiciones.sendero,puedeContinuar=false,mapaListo=false}
 interfaz.actualizar(estado)
 task.wait(0.3)
 local ventana=gui.ResultadoOPreparacion
 local contenido=ventana.Contenido
 local mensaje=contenido.Explicacion
 local comenzar=ventana.Comenzar
 local pantalla=workspace.CurrentCamera.ViewportSize
 comprobar(not comenzar.Active and comenzar.Text=="Cargando escenario…","Debe esperar a que cargue el mapa.")
 comprobar(string.find(mensaje.Text,"El mapa representa un grafo",1,true)~=nil,"No muestra fundamentos en preparación.")
 comprobar(ventana.AbsoluteSize.X<=720.1 and ventana.AbsoluteSize.X<=pantalla.X*0.85+1,"La ventana supera el ancho previsto.")
 comprobar(ventana.AbsoluteSize.Y<=560.1 and ventana.AbsoluteSize.Y<=pantalla.Y*0.75+1,"La ventana supera el alto previsto.")
 comprobar(ventana.AbsolutePosition.Y>=0 and ventana.AbsolutePosition.Y+ventana.AbsoluteSize.Y<=pantalla.Y,"La ventana queda fuera de pantalla.")
 comprobar(not gui.Objetivo.Visible,"La cabecera se superpone con la preparación.")
 comprobar(mensaje.TextFits,"El texto educativo se recorta.")
 comprobar(contenido.AbsolutePosition.Y+contenido.AbsoluteSize.Y<comenzar.AbsolutePosition.Y,"El cuerpo invade los botones.")
 comprobar(string.find(mensaje.FontFace.Family,"Merriweather",1,true)~=nil,"Se perdió la tipografía actual.")
 estado.mapaListo=true
 interfaz.actualizar(estado)
 comprobar(comenzar.Active and comenzar.Text=="Comenzar","No habilita comenzar.")
 estado.fase="activo"
 interfaz.actualizar(estado)
 comprobar(not ventana.Visible and gui.Objetivo.Visible,"La teoría debe ocultarse durante la persecución.")
 task.wait(0.15)
 comprobar(gui.Objetivo.Condiciones.TextFits,"El objetivo no cabe en la cabecera.")
 local resultado={outcome="victory",codigo="objetivo_completo",intentoId=99001,vertices={"A","B","C","A","D"},aristas={"AB","BC","CA","AD"},message=string.rep("Explicación educativa extensa para verificar el desplazamiento y conservar los controles visibles. ",70)}
 interfaz.mostrarResultado(resultado)
 task.wait(0.3)
 comprobar(contenido.AbsoluteCanvasSize.Y>contenido.AbsoluteSize.Y,"Sin desplazamiento: canvas="..tostring(contenido.AbsoluteCanvasSize).." cuerpo="..tostring(contenido.AbsoluteSize).." texto="..tostring(mensaje.AbsoluteSize).." bounds="..tostring(mensaje.TextBounds))
 comprobar(ventana.Reintentar.Visible and not comenzar.Visible,"Faltan las acciones del resultado.")
 contenido.CanvasPosition=Vector2.new(0,30)
 interfaz.mostrarResultado(resultado)
 comprobar(contenido.CanvasPosition.Y>=29,"El resultado duplicado reinicia la lectura.")
 estado.fase="preparacion"
 estado.resultado=nil
 interfaz.actualizar(estado)
 comprobar(contenido.CanvasPosition.Y==0 and comenzar.Visible,"El reintento no restaura la lectura inicial.")
 medidas={ventana=tostring(ventana.AbsoluteSize),texto=tostring(mensaje.TextBounds),contenido=tostring(contenido.AbsoluteSize),pantalla=tostring(pantalla)}
end)
interfaz.destruir()
carpeta:Destroy()
assert(ok,fallo)
return game:GetService("HttpService"):JSONEncode({correctas=total,medidas=medidas})

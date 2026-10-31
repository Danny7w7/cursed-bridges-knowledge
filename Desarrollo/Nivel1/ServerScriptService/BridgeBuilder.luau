--!strict
-- Los mapas se preparan en Edición. El arranque nunca sustituye el escenario guardado.
local niveles = workspace:FindFirstChild("Niveles")
local nivel = (niveles and niveles:FindFirstChild("Nivel1")) or workspace:FindFirstChild("LevelFolder")
assert(nivel and nivel:FindFirstChild("Islands") and nivel:FindFirstChild("Bridges"), "Falta preparar el nivel editable en Workspace.")

-- Coloque este LocalScript em StarterPlayer > StarterPlayerScripts.
-- Mantém uma câmera top-down sobre o campo gerado pelo script do servidor.

local Workspace = game:GetService("Workspace")
local camera = Workspace.CurrentCamera

camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 45
camera.CFrame = CFrame.lookAt(Vector3.new(0, 112, 4), Vector3.new(0, 0, 0))


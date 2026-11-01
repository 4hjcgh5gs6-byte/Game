-- Câmera fixa de cima para mostrar apenas o campo de batalha.
-- Coloque este LocalScript em StarterPlayer > StarterPlayerScripts.

local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local camera = Workspace.CurrentCamera
while not camera do
	task.wait()
	camera = Workspace.CurrentCamera
end

camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 40
camera.CFrame = CFrame.lookAt(
	Vector3.new(0, 320, 0),
	Vector3.new(0, 0, 0),
	Vector3.new(0, 0, -1)
)

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)


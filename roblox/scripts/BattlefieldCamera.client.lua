-- Câmera fixa de cima para mostrar apenas o campo de batalha.
-- Coloque este LocalScript em StarterPlayer > StarterPlayerScripts.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local battlefield = Workspace:WaitForChild("BattlefieldGenerated")
battlefield:WaitForChild("BlackBattlefield")
battlefield:WaitForChild("WhiteTerritoryDivider")

local camera = Workspace.CurrentCamera
while not camera do
	task.wait()
	camera = Workspace.CurrentCamera
end

local cameraPosition = Vector3.new(0, 430, 0)
local cameraTarget = Vector3.new(0, 0, 0)
local cameraUp = Vector3.new(0, 0, -1)
local cameraCFrame = CFrame.lookAt(cameraPosition, cameraTarget, cameraUp)

camera.FieldOfView = 40
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = cameraCFrame

-- Mantém a câmera fixa mesmo se a câmera padrão do Roblox tentar reposicioná-la.
RunService:BindToRenderStep("BattlefieldTopDownCamera", Enum.RenderPriority.Camera.Value + 1, function()
	local currentCamera = Workspace.CurrentCamera
	if currentCamera then
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.FieldOfView = 40
		currentCamera.CFrame = cameraCFrame
	end
end)

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)


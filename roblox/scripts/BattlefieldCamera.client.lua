-- Câmera fixa diretamente acima do campo, mostrando a arena inteira.
-- Coloque este LocalScript em StarterPlayer > StarterPlayerScripts.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local DEFAULT_HEIGHT = 800
local MIN_HEIGHT = 480
local MAX_HEIGHT = 1200
local ZOOM_STEP = 60
local cameraHeight = DEFAULT_HEIGHT

local function setBattleCamera()
	local camera = Workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 40
		camera.CFrame = CFrame.lookAt(Vector3.new(0, cameraHeight, cameraHeight * 0.48), Vector3.new(0, 0, 0))
	end
end

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseWheel then
		return
	end
	cameraHeight = math.clamp(cameraHeight - input.Position.Z * ZOOM_STEP, MIN_HEIGHT, MAX_HEIGHT)
	setBattleCamera()
end)

setBattleCamera()
RunService:BindToRenderStep("BattlefieldTopDownCamera", Enum.RenderPriority.Camera.Value + 1, setBattleCamera)

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)

-- Câmera fixa diretamente acima do campo, mostrando a arena inteira.
-- Coloque este LocalScript em StarterPlayer > StarterPlayerScripts.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local cameraCFrame = CFrame.new(0, 600, 0) * CFrame.Angles(math.rad(-90), 0, 0)

local function setBattleCamera()
	local camera = Workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 40
		camera.CFrame = cameraCFrame
	end
end

setBattleCamera()
RunService:BindToRenderStep("BattlefieldTopDownCamera", Enum.RenderPriority.Camera.Value + 1, setBattleCamera)

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)


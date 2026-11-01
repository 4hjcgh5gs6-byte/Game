-- Campo de batalha minimalista para Roblox Studio.
-- Coloque este Script em ServerScriptService.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Impede que o avatar apareça e remove um avatar já carregado.
Players.CharacterAutoLoads = false
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		player.Character:Destroy()
	end
end

local FIELD_WIDTH = 320
local FIELD_DEPTH = 200
local FLOOR_THICKNESS = 2

local folder = Workspace:FindFirstChild("BattlefieldGenerated")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "BattlefieldGenerated"
	folder.Parent = Workspace
end
folder:ClearAllChildren()

local floor = Instance.new("Part")
floor.Name = "BlackBattlefield"
floor.Size = Vector3.new(FIELD_WIDTH, FLOOR_THICKNESS, FIELD_DEPTH)
floor.Position = Vector3.new(0, -FLOOR_THICKNESS / 2, 0)
floor.Anchored = true
floor.Color = Color3.fromRGB(0, 0, 0)
floor.Material = Enum.Material.SmoothPlastic
floor.TopSurface = Enum.SurfaceType.Smooth
floor.BottomSurface = Enum.SurfaceType.Smooth
floor.Parent = folder

local divider = Instance.new("Part")
divider.Name = "WhiteTerritoryDivider"
divider.Size = Vector3.new(0.6, 0.08, FIELD_DEPTH)
divider.Position = Vector3.new(0, 0.04, 0)
divider.Anchored = true
divider.CanCollide = false
divider.Color = Color3.fromRGB(255, 255, 255)
divider.Material = Enum.Material.SmoothPlastic
divider.TopSurface = Enum.SurfaceType.Smooth
divider.BottomSurface = Enum.SurfaceType.Smooth
divider.Parent = folder


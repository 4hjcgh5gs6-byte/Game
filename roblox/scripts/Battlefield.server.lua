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

local FIELD_WIDTH = 700
local FIELD_DEPTH = 430
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
floor.Color = Color3.fromRGB(22, 23, 22)
floor.Material = Enum.Material.SmoothPlastic
floor.TopSurface = Enum.SurfaceType.Smooth
floor.BottomSurface = Enum.SurfaceType.Smooth
floor.Parent = folder

local divider = Instance.new("Part")
divider.Name = "WhiteTerritoryDivider"
divider.Size = Vector3.new(FIELD_WIDTH, 0.2, 3)
divider.Position = Vector3.new(0, 0.1, 0)
divider.Anchored = true
divider.CanCollide = false
divider.Color = Color3.fromRGB(255, 255, 255)
divider.Material = Enum.Material.Neon
divider.TopSurface = Enum.SurfaceType.Smooth
divider.BottomSurface = Enum.SurfaceType.Smooth
divider.Parent = folder


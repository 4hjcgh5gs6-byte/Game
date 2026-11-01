-- Campo de batalha minimalista para Roblox Studio.
-- Coloque este Script em ServerScriptService.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Remove a névoa e o brilho do projeto que clareavam o piso preto.
Lighting.Brightness = 1
Lighting.GlobalShadows = false
Lighting.Ambient = Color3.new(0, 0, 0)
Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
for _, effect in ipairs(Lighting:GetChildren()) do
	if effect:IsA("PostEffect") then
		effect.Enabled = false
	elseif effect:IsA("Atmosphere") then
		effect.Density = 0
		effect.Haze = 0
		effect.Glare = 0
	end
end

-- Impede que o avatar apareça e remove um avatar já carregado.
Players.CharacterAutoLoads = false
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		player.Character:Destroy()
	end
end

local FIELD_WIDTH = 700
local FIELD_DEPTH = 520
local FLOOR_THICKNESS = 2

-- Remove os objetos padrão que ficam coplanares ao campo e causam cintilação.
local defaultBaseplate = Workspace:FindFirstChild("Baseplate")
if defaultBaseplate and defaultBaseplate:IsA("BasePart") then
	defaultBaseplate:Destroy()
end
local defaultSpawn = Workspace:FindFirstChildOfClass("SpawnLocation")
if defaultSpawn then
	defaultSpawn:Destroy()
end

local battlefield = Workspace:FindFirstChild("BattlefieldGenerated")
if battlefield and not battlefield:IsA("Model") then
	battlefield:Destroy()
	battlefield = nil
end
if not battlefield then
	battlefield = Instance.new("Model")
	battlefield.Name = "BattlefieldGenerated"
end
battlefield.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
battlefield.Parent = Workspace
battlefield:ClearAllChildren()

local floor = Instance.new("Part")
floor.Name = "BlackBattlefield"
floor.Size = Vector3.new(FIELD_WIDTH, FLOOR_THICKNESS, FIELD_DEPTH)
floor.Position = Vector3.new(0, 0, 0)
floor.Anchored = true
floor.Color = Color3.fromRGB(0, 0, 0)
floor.Material = Enum.Material.SmoothPlastic
floor.TopSurface = Enum.SurfaceType.Smooth
floor.BottomSurface = Enum.SurfaceType.Smooth
floor.Parent = battlefield

local divider = Instance.new("Part")
divider.Name = "WhiteTerritoryDivider"
divider.Size = Vector3.new(FIELD_WIDTH, 0.2, 3)
divider.Position = Vector3.new(0, 1.1, 0)
divider.Anchored = true
divider.CanCollide = false
divider.Color = Color3.fromRGB(255, 255, 255)
divider.Material = Enum.Material.Neon
divider.TopSurface = Enum.SurfaceType.Smooth
divider.BottomSurface = Enum.SurfaceType.Smooth
divider.Parent = battlefield


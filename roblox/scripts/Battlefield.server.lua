-- Campo vazio de preparação, sem exércitos pré-criados.
-- Coloque este Script em ServerScriptService.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

Players.CharacterAutoLoads = false
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		player.Character:Destroy()
	end
end

-- Aparência escura e limpa para combinar com a referência visual.
Lighting.Brightness = 1
Lighting.GlobalShadows = false
Lighting.Ambient = Color3.fromRGB(130, 130, 130)
Lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 130)
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

local FIELD_WIDTH = 700
local FIELD_DEPTH = 520
local FLOOR_THICKNESS = 2

-- Remove o piso e o ponto de spawn do modelo padrão durante a partida.
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

local function makePart(name, size, position, color, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent or battlefield
	return part
end

local floor = makePart(
	"BlackBattlefield",
	Vector3.new(FIELD_WIDTH, FLOOR_THICKNESS, FIELD_DEPTH),
	Vector3.new(0, 0, 0),
	Color3.fromRGB(0, 0, 0),
	Enum.Material.Neon
)
floor.CanCollide = true

local divider = makePart(
	"WhiteTerritoryDivider",
	Vector3.new(FIELD_WIDTH, 0.12, 2),
	Vector3.new(0, 1.08, 0),
	Color3.fromRGB(225, 225, 215),
	Enum.Material.SmoothPlastic
)

local function addTreeCluster(centerX, centerZ, prefix)
    local canopyOffsets = {
        {-36, -24}, {-36, 24},
        {0, -24}, {0, 24},
        {36, -24}, {36, 24},
        {0, 0},
    }

    for index, offset in ipairs(canopyOffsets) do
        local shade = ((index - 1) % 3) * 5
        local canopy = makePart(
            ("%s_Tree_%02d"):format(prefix, index),
            Vector3.new(44, 8, 40),
            Vector3.new(centerX + offset[1], 4, centerZ + offset[2]),
            Color3.fromRGB(105 + shade, 122 + shade, 110 + shade)
        )
        canopy.Shape = Enum.PartType.Ball
        canopy.CanCollide = true
    end
end

addTreeCluster(-270, -205, "NorthWest")
addTreeCluster(270, 205, "SouthEast")

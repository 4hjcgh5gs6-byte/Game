-- Arena de preparação com formações geométricas estáticas para o protótipo.
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

local blue = Color3.fromRGB(38, 137, 232)
local red = Color3.fromRGB(235, 57, 50)

local function addUnit(shape, side, index, x, z, color)
	local part
	local centerY = 2.4
	if shape == "Circle" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(7.5, 2.3, 7.5)
		part.Position = Vector3.new(x, centerY, z)
	elseif shape == "Square" then
		part = Instance.new("Part")
		part.Size = Vector3.new(7.5, 1.8, 7.5)
		part.Position = Vector3.new(x, centerY, z)
	elseif shape == "Triangle" then
		part = Instance.new("WedgePart")
		part.Size = Vector3.new(1.8, 7.5, 7.5)
		part.CFrame = CFrame.new(x, centerY, z) * CFrame.Angles(0, 0, math.rad(90))
	end

	part.Name = ("%s_%s_%03d"):format(side, shape, index)
	part.Anchored = true
	part.CanCollide = false
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("Side", side)
	part:SetAttribute("UnitShape", shape)
	part.Parent = battlefield
	return part
end

local function addGrid(shape, side, countRows, countColumns, centerX, firstZ, spacing, color)
	local index = 0
	for row = 0, countRows - 1 do
		for column = 0, countColumns - 1 do
			index += 1
			local x = centerX + (column - (countColumns - 1) / 2) * spacing
			local z = firstZ + row * spacing
			addUnit(shape, side, index, x, z, color)
		end
	end
end

local function addWedgeFormation(centerX, firstZ)
	local index = 0
	for row = 0, 3 do
		local columns = 3 + row * 2
		for column = 0, columns - 1 do
			index += 1
			local x = centerX + (column - (columns - 1) / 2) * 9
			local z = firstZ + row * 9
			addUnit("Square", "Enemy", index, x, z, red)
		end
	end
end

-- Grupos de círculos e quadrados vermelhos no território inimigo.
addGrid("Circle", "Enemy", 7, 10, -105, -178, 9, red)
addGrid("Circle", "Enemy", 7, 10, 105, -178, 9, red)
addWedgeFormation(-105, -83)
addWedgeFormation(105, -83)

-- Fileiras azuis com os três formatos na metade do jogador.
addGrid("Square", "Player", 1, 25, -20, 51, 10, blue)
addGrid("Circle", "Player", 2, 25, -20, 70, 10, blue)
addGrid("Triangle", "Player", 2, 25, -20, 107, 10, blue)
addGrid("Circle", "Player", 5, 9, 245, 84, 10, blue)

-- Copas arredondadas em dois cantos opostos, como as árvores da referência.
local function addTreeCluster(centerX, centerZ, prefix)
	local index = 0
	for row = -4, 4 do
		for column = -5, 5 do
			local ellipse = (column * column) / 30 + (row * row) / 18
			if ellipse <= 1.12 then
				index += 1
				local jitterX = ((row * 3 + column * 2) % 3) * 1.1
				local jitterZ = ((column * 2 - row) % 3) * 1.0
				local x = centerX + column * 12 + jitterX
				local z = centerZ + row * 12 + jitterZ
				local shade = ((row + column) % 3) * 5
				local canopy = makePart(
					("%s_Tree_%03d"):format(prefix, index),
					Vector3.new(15, 4, 15),
					Vector3.new(x, 3.3, z),
				Color3.fromRGB(105 + shade, 122 + shade, 110 + shade),
					Enum.Material.SmoothPlastic
				)
				canopy.Shape = Enum.PartType.Ball
				canopy.CanCollide = true
			end
		end
	end
end

addTreeCluster(-270, -205, "NorthWest")
addTreeCluster(270, 205, "SouthEast")


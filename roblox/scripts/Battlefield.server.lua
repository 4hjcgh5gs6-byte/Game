-- Campo de batalha inicial para Roblox Studio.
-- Coloque este Script em ServerScriptService e execute o jogo.

local Workspace = game:GetService("Workspace")

local CONFIG = {
	Columns = 24,
	Rows = 14,
	TileSize = 8,
	TileThickness = 1,
	Center = Vector3.new(0, 0, 0),
}

local COLORS = {
	PlayerTerritory = Color3.fromRGB(91, 160, 122),
	EnemyTerritory = Color3.fromRGB(166, 112, 103),
	PlayerAccent = Color3.fromRGB(79, 145, 215),
	EnemyAccent = Color3.fromRGB(222, 95, 83),
	GridLine = Color3.fromRGB(32, 43, 39),
	TreeTrunk = Color3.fromRGB(105, 74, 49),
	TreeCanopy = Color3.fromRGB(48, 105, 68),
	Rock = Color3.fromRGB(113, 119, 117),
	River = Color3.fromRGB(69, 151, 196),
}

local folder = Workspace:FindFirstChild("BattlefieldGenerated")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "BattlefieldGenerated"
	folder.Parent = Workspace
end
folder:ClearAllChildren()

local function makePart(name, size, position, color, material, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Parent = parent or folder
	return part
end

local halfWidth = CONFIG.Columns * CONFIG.TileSize / 2
local halfDepth = CONFIG.Rows * CONFIG.TileSize / 2
local origin = CONFIG.Center

-- Cada casa é uma peça separada para deixar a divisão do campo visível.
for row = 1, CONFIG.Rows do
	for column = 1, CONFIG.Columns do
		local isPlayerSide = column <= CONFIG.Columns / 2
		local baseColor = isPlayerSide and COLORS.PlayerTerritory or COLORS.EnemyTerritory
		local variation = ((row + column) % 2 == 0) and 0.035 or -0.015
		local tileColor = baseColor:Lerp(Color3.new(1, 1, 1), variation)
		local x = origin.X - halfWidth + (column - 0.5) * CONFIG.TileSize
		local z = origin.Z - halfDepth + (row - 0.5) * CONFIG.TileSize
		local tile = makePart(
			("Tile_%02d_%02d"):format(row, column),
			Vector3.new(CONFIG.TileSize - 0.08, CONFIG.TileThickness, CONFIG.TileSize - 0.08),
			Vector3.new(x, origin.Y, z),
			tileColor,
			Enum.Material.Grass
		)
		tile:SetAttribute("Row", row)
		tile:SetAttribute("Column", column)
		tile:SetAttribute("Territory", isPlayerSide and "Player" or "Enemy")
	end
end

-- Faixa central: marca a fronteira entre os territórios.
makePart(
	"TerritoryBoundary",
	Vector3.new(0.28, 0.12, CONFIG.Rows * CONFIG.TileSize),
	Vector3.new(origin.X, origin.Y + CONFIG.TileThickness / 2 + 0.08, origin.Z),
	Color3.fromRGB(235, 224, 186),
	Enum.Material.SmoothPlastic
)

-- Linhas discretas nas bordas do tabuleiro.
local boardWidth = CONFIG.Columns * CONFIG.TileSize
local boardDepth = CONFIG.Rows * CONFIG.TileSize
local lineY = origin.Y + CONFIG.TileThickness / 2 + 0.035
makePart("GridNorth", Vector3.new(boardWidth, 0.08, 0.08), Vector3.new(origin.X, lineY, origin.Z - halfDepth), COLORS.GridLine)
makePart("GridSouth", Vector3.new(boardWidth, 0.08, 0.08), Vector3.new(origin.X, lineY, origin.Z + halfDepth), COLORS.GridLine)
makePart("GridWest", Vector3.new(0.08, 0.08, boardDepth), Vector3.new(origin.X - halfWidth, lineY, origin.Z), COLORS.GridLine)
makePart("GridEast", Vector3.new(0.08, 0.08, boardDepth), Vector3.new(origin.X + halfWidth, lineY, origin.Z), COLORS.GridLine)

local function cellPosition(row, column, yOffset)
	return Vector3.new(
		origin.X - halfWidth + (column - 0.5) * CONFIG.TileSize,
		origin.Y + CONFIG.TileThickness / 2 + (yOffset or 0),
		origin.Z - halfDepth + (row - 0.5) * CONFIG.TileSize
	)
end

-- Árvores em grupos pequenos, fora do eixo central para preservar rotas abertas.
local treeCells = {
	{2, 3}, {3, 4}, {4, 3}, {10, 5}, {11, 4}, {12, 5},
	{3, 20}, {4, 21}, {5, 20}, {10, 18}, {11, 19}, {12, 18},
}
for index, cell in ipairs(treeCells) do
	local position = cellPosition(cell[1], cell[2])
	local model = Instance.new("Model")
	model.Name = ("Tree_%02d"):format(index)
	model.Parent = folder
	makePart("Trunk", Vector3.new(1.4, 4.2, 1.4), position + Vector3.new(0, 2.1, 0), COLORS.TreeTrunk, Enum.Material.Wood, model)
	local canopy = makePart("Canopy", Vector3.new(5.2, 4.4, 5.2), position + Vector3.new(0, 5.3, 0), COLORS.TreeCanopy, Enum.Material.Grass, model)
	canopy.Shape = Enum.PartType.Ball
	canopy.CanCollide = false
end

-- Pedras representam montanhas/rochas como obstáculos simples neste protótipo.
local rockCells = {
	{6, 8, 1.0}, {7, 9, 1.2}, {8, 8, 0.9},
	{5, 16, 1.0}, {6, 17, 1.2}, {7, 16, 0.9},
}
for index, cell in ipairs(rockCells) do
	local position = cellPosition(cell[1], cell[2])
	local rock = makePart(
		("MountainRock_%02d"):format(index),
		Vector3.new(5.2, 3.6 * cell[3], 5.2),
		position + Vector3.new(0, 1.8 * cell[3], 0),
		COLORS.Rock,
		Enum.Material.Slate
	)
	rock.Shape = Enum.PartType.Ball
end

-- Pequeno trecho de rio no fundo do mapa, sem atravessar o limite entre os lados.
local riverRow = CONFIG.Rows - 2
local river = makePart(
	"RiverObstacle",
	Vector3.new(CONFIG.TileSize * 5.5, 0.22, CONFIG.TileSize * 1.3),
	cellPosition(riverRow, CONFIG.Columns / 2, 0.18) + Vector3.new(0, 0, CONFIG.TileSize * 0.35),
	COLORS.River,
	Enum.Material.Glass
)
	river.Transparency = 0.18
	river.CanCollide = true

-- Placas de identificação acima do campo.
local function addLabel(name, text, position, color)
	local anchor = makePart(name, Vector3.new(1, 1, 1), position, color, Enum.Material.SmoothPlastic)
	anchor.Transparency = 1
	anchor.CanCollide = false
	local gui = Instance.new("BillboardGui")
	gui.Name = "TerritoryLabel"
	gui.Size = UDim2.fromOffset(220, 48)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 500
	gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.35
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
end

addLabel("PlayerTerritoryLabel", "SEU TERRITÓRIO", Vector3.new(origin.X - halfWidth / 2, origin.Y + 9, origin.Z - halfDepth - 2), COLORS.PlayerAccent)
addLabel("EnemyTerritoryLabel", "TERRITÓRIO INIMIGO", Vector3.new(origin.X + halfWidth / 2, origin.Y + 9, origin.Z - halfDepth - 2), COLORS.EnemyAccent)



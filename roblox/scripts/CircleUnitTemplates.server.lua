-- Cria apenas os modelos visuais do guerreiro circular da Fase 1.
-- Os modelos ficam em ReplicatedStorage e nao aparecem na arena ate serem clonados.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local oldTemplates = ReplicatedStorage:FindFirstChild("UnitTemplates")
if oldTemplates then
	oldTemplates:Destroy()
end

local templates = Instance.new("Folder")
templates.Name = "UnitTemplates"
templates.Parent = ReplicatedStorage

local unitColors = {
	Ally = Color3.fromRGB(45, 145, 255),
	Enemy = Color3.fromRGB(245, 65, 60),
}

-- Altura do centro da bola em relação ao pivô da unidade (topo do chão em y = 1, mais raio 8, menos pivô em y = 2,6).
local BALL_CENTER_HEIGHT = 6.4

local function createWarriorTemplate(faction, color)
	local model = Instance.new("Model")
	model.Name = "Circulo_Guerreiro_" .. faction
	model:SetAttribute("UnitType", "Warrior")
	model:SetAttribute("Faction", faction)
	model:SetAttribute("MaxHealth", 20)
	model:SetAttribute("Health", 20)
	model:SetAttribute("Damage", 2)

	local outline = Instance.new("Part")
	outline.Name = "Outline"
	outline.Shape = Enum.PartType.Ball
	outline.Size = Vector3.new(19, 19, 19)
	outline.Position = Vector3.new(0, BALL_CENTER_HEIGHT, 0)
	outline.Anchored = true
	outline.CanCollide = false
	outline.CanTouch = false
	outline.CanQuery = false
	outline.Material = Enum.Material.SmoothPlastic
	outline.Color = Color3.fromRGB(12, 12, 12)
	outline.Parent = model

	local body = Instance.new("Part")
	body.Name = "Circle"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(16, 16, 16)
	body.Position = Vector3.new(0, BALL_CENTER_HEIGHT, 0)
	body.Anchored = true
	body.CanCollide = false
	body.CanTouch = false
	body.CanQuery = false
	body.Material = Enum.Material.SmoothPlastic
	body.Color = color
	body.Parent = model

	model.PrimaryPart = body
	-- O pivô fica na base da bola: quem posiciona a unidade em y = 2.6 faz a bola
	-- "sentar" em cima do chão (topo do chão em y = 1) em vez de afundar nele.
	body.PivotOffset = CFrame.new(0, -BALL_CENTER_HEIGHT, 0)
	model.Parent = templates
end

createWarriorTemplate("Ally", unitColors.Ally)
createWarriorTemplate("Enemy", unitColors.Enemy)

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

local function createWarriorTemplate(faction, color)
	local model = Instance.new("Model")
	model.Name = "Circulo_Guerreiro_" .. faction
	model:SetAttribute("UnitType", "Warrior")
	model:SetAttribute("Faction", faction)

	local outline = Instance.new("Part")
	outline.Name = "Outline"
	outline.Shape = Enum.PartType.Ball
	outline.Size = Vector3.new(12, 2.2, 12)
	outline.Position = Vector3.new(0, 0, 0)
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
	body.Size = Vector3.new(10, 2.4, 10)
	body.Position = Vector3.new(0, 0.25, 0)
	body.Anchored = true
	body.CanCollide = false
	body.CanTouch = false
	body.CanQuery = false
	body.Material = Enum.Material.SmoothPlastic
	body.Color = color
	body.Parent = model

	model.PrimaryPart = body
	model.Parent = templates
end

createWarriorTemplate("Ally", unitColors.Ally)
createWarriorTemplate("Enemy", unitColors.Enemy)

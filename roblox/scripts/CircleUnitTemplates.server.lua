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
	model:SetAttribute("MaxHealth", 20)
	model:SetAttribute("Health", 20)
	model:SetAttribute("Damage", 2)

	local outline = Instance.new("Part")
	outline.Name = "Outline"
	outline.Shape = Enum.PartType.Cylinder
	outline.Size = Vector3.new(2.8, 19, 19)
	outline.Orientation = Vector3.new(0, 0, 90)
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
	body.Shape = Enum.PartType.Cylinder
	body.Size = Vector3.new(3, 16, 16)
	body.Orientation = Vector3.new(0, 0, 90)
	body.Position = Vector3.new(0, 0.25, 0)
	body.Anchored = true
	body.CanCollide = false
	body.CanTouch = false
	body.CanQuery = false
	body.Material = Enum.Material.SmoothPlastic
	body.Color = color
	body.Parent = model

	model.PrimaryPart = body
	-- Preserve the horizontal disc orientation when callers place an upright model pivot.
	body.PivotOffset = CFrame.Angles(0, 0, math.rad(-90))
	model.Parent = templates
end

createWarriorTemplate("Ally", unitColors.Ally)
createWarriorTemplate("Enemy", unitColors.Enemy)

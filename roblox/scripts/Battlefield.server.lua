-- Gera a arena somente quando o jogador escolhe PLAY.
-- Coloque este Script em ServerScriptService.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

Players.CharacterAutoLoads = false
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        player.Character:Destroy()
    end
end

Lighting.Brightness = 1
Lighting.GlobalShadows = true
Lighting.ClockTime = 14
Lighting.ShadowSoftness = 0.5
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

local startEvent = ReplicatedStorage:FindFirstChild("StartFirstStage")
if not startEvent or not startEvent:IsA("RemoteEvent") then
    if startEvent then
        startEvent:Destroy()
    end
    startEvent = Instance.new("RemoteEvent")
    startEvent.Name = "StartFirstStage"
    startEvent.Parent = ReplicatedStorage
end

local FIELD_WIDTH = 700
local FIELD_DEPTH = 520
local FLOOR_THICKNESS = 2
local generated = false
local generating = false

local function generateBattlefield()
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
    battlefield:SetAttribute("Ready", false)
    battlefield:ClearAllChildren()

    local function makePart(name, size, position, color, material)
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
        part.Parent = battlefield
        return part
    end

    local backdrop = makePart("DarkBackdrop", Vector3.new(10000, 2, 10000),
        Vector3.new(0, -3, 0), Color3.fromRGB(16, 17, 16), Enum.Material.Neon)
    backdrop.CastShadow = false

    local floor = makePart(
        "BlackBattlefield",
        Vector3.new(FIELD_WIDTH, FLOOR_THICKNESS, FIELD_DEPTH),
        Vector3.new(0, 0, 0),
        Color3.fromRGB(24, 25, 23),
        Enum.Material.SmoothPlastic
    )
    floor.CanCollide = true

    makePart(
        "WhiteTerritoryDivider",
        Vector3.new(FIELD_WIDTH, 0.18, 1.2),
        Vector3.new(0, 1.08, 0),
        Color3.fromRGB(175, 175, 165)
    )

    -- Exército inimigo visível desde a preparação, como referência da fase.
    -- São apenas círculos nesta primeira fase; ainda não iniciam combate.
    local unitTemplates = ReplicatedStorage:WaitForChild("UnitTemplates", 10)
    local enemyTemplate = unitTemplates and unitTemplates:FindFirstChild("Circulo_Guerreiro_Enemy")
    assert(enemyTemplate, "Template do guerreiro circular inimigo não foi carregado")
    local enemyFolder = Instance.new("Folder")
    enemyFolder.Name = "EnemyPreview"
    enemyFolder.Parent = battlefield

    local enemyPositions = {
        Vector3.new(-40, 2.6, -120),
        Vector3.new(0, 2.6, -140),
        Vector3.new(40, 2.6, -120),
        Vector3.new(-20, 2.6, -190),
        Vector3.new(20, 2.6, -190),
    }
    for index, position in ipairs(enemyPositions) do
        local enemy = enemyTemplate:Clone()
        enemy.Name = ("EnemyCircle_%02d"):format(index)
        enemy:SetAttribute("PreviewOnly", true)
        enemy:PivotTo(CFrame.new(position))
        enemy.Parent = enemyFolder
    end
    battlefield:SetAttribute("Ready", true)
end

startEvent.OnServerEvent:Connect(function(player, difficulty)
    if difficulty ~= "Normal" and difficulty ~= "Hard" then
        return
    end
    player:SetAttribute("Difficulty", difficulty)

    if generated or generating then
        return
    end

    generating = true
    local success, errorMessage = pcall(generateBattlefield)
    generating = false
    if success then
        generated = true
        startEvent:FireClient(player, "LoadComplete")
    else
        warn("Falha ao carregar a fase 1:", errorMessage)
        startEvent:FireClient(player, "LoadFailed")
    end
end)

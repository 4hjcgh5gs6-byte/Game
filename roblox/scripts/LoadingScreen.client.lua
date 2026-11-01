local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local masterVolume = SoundService:FindFirstChild("MasterVolume")
if not masterVolume or not masterVolume:IsA("SoundGroup") then
    if masterVolume then
        masterVolume:Destroy()
    end
    masterVolume = Instance.new("SoundGroup")
    masterVolume.Name = "MasterVolume"
    masterVolume.Volume = 0.5
    masterVolume.Parent = SoundService
end

local function routeSound(instance)
    if instance:IsA("Sound") then
        instance.SoundGroup = masterVolume
    end
end
for _, instance in ipairs(game:GetDescendants()) do
    routeSound(instance)
end
game.DescendantAdded:Connect(routeSound)

local camera = workspace.CurrentCamera
while not camera do
    task.wait(0.1)
    camera = workspace.CurrentCamera
end
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 40
camera.CFrame = CFrame.new(0, 600, 0) * CFrame.Angles(math.rad(-90), 0, 0)

local screen = Instance.new("ScreenGui")
screen.Name = "BattlefieldMainMenu"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.DisplayOrder = 10000
screen.Parent = playerGui

local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(8, 9, 10)
background.BorderSizePixel = 0
background.Parent = screen

local function makeText(name, text, position, size, font, color)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = position
    label.Size = size
    label.BackgroundTransparency = 1
    label.Font = font
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.Parent = background
    return label
end

local title = makeText(
    "Title",
    "BATALHA GEOMÉTRICA",
    UDim2.fromScale(0.5, 0.34),
    UDim2.fromScale(0.82, 0.1),
    Enum.Font.GothamBold,
    Color3.fromRGB(240, 240, 240)
)
local subtitle = makeText(
    "Subtitle",
    " ",
    UDim2.fromScale(0.5, 0.44),
    UDim2.fromScale(0.7, 0.04),
    Enum.Font.GothamMedium,
    Color3.fromRGB(165, 170, 175)
)

local function makeButton(name, text, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Position = position
    button.Size = UDim2.fromScale(0.19, 0.075)
    button.BackgroundColor3 = Color3.fromRGB(35, 38, 42)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(245, 245, 245)
    button.TextScaled = true
    button.Parent = background

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    return button
end

local playButton = makeButton("PlayButton", "PLAY", UDim2.fromScale(0.5, 0.55))
local menuButton = makeButton("MenuButton", "MENU", UDim2.fromScale(0.5, 0.66))

local settingsPanel = Instance.new("Frame")
settingsPanel.Name = "SettingsPanel"
settingsPanel.AnchorPoint = Vector2.new(0.5, 0.5)
settingsPanel.Position = UDim2.fromScale(0.5, 0.57)
settingsPanel.Size = UDim2.fromScale(0.42, 0.3)
settingsPanel.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
settingsPanel.BorderSizePixel = 0
settingsPanel.Visible = false
settingsPanel.Parent = background

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = settingsPanel

local settingsTitle = Instance.new("TextLabel")
settingsTitle.AnchorPoint = Vector2.new(0.5, 0.5)
settingsTitle.Position = UDim2.fromScale(0.5, 0.2)
settingsTitle.Size = UDim2.fromScale(0.8, 0.18)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.Text = "CONFIGURAÇÕES"
settingsTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
settingsTitle.TextScaled = true
settingsTitle.Parent = settingsPanel

local volumeLabel = Instance.new("TextLabel")
volumeLabel.AnchorPoint = Vector2.new(0.5, 0.5)
volumeLabel.Position = UDim2.fromScale(0.5, 0.46)
volumeLabel.Size = UDim2.fromScale(0.8, 0.15)
volumeLabel.BackgroundTransparency = 1
volumeLabel.Font = Enum.Font.GothamMedium
volumeLabel.TextColor3 = Color3.fromRGB(200, 205, 210)
volumeLabel.TextScaled = true
volumeLabel.Parent = settingsPanel

local volumeTrack = Instance.new("TextButton")
volumeTrack.Name = "VolumeSlider"
volumeTrack.AnchorPoint = Vector2.new(0.5, 0.5)
volumeTrack.Position = UDim2.fromScale(0.5, 0.66)
volumeTrack.Size = UDim2.fromScale(0.68, 0.035)
volumeTrack.BackgroundColor3 = Color3.fromRGB(55, 59, 64)
volumeTrack.BorderSizePixel = 0
volumeTrack.Text = ""
volumeTrack.AutoButtonColor = false
volumeTrack.Parent = settingsPanel

local volumeFill = Instance.new("Frame")
volumeFill.Name = "VolumeFill"
volumeFill.Size = UDim2.fromScale(masterVolume.Volume, 1)
volumeFill.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
volumeFill.BorderSizePixel = 0
volumeFill.Parent = volumeTrack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = volumeFill
local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = volumeTrack

local function updateVolumeLabel()
    volumeLabel.Text = ("VOLUME GERAL  %d%%"):format(math.floor(masterVolume.Volume * 100 + 0.5))
end
updateVolumeLabel()

local function setVolumeFromX(x)
    local width = volumeTrack.AbsoluteSize.X
    if width <= 0 then
        return
    end
    local volume = math.clamp((x - volumeTrack.AbsolutePosition.X) / width, 0, 1)
    masterVolume.Volume = volume
    volumeFill.Size = UDim2.fromScale(volume, 1)
    updateVolumeLabel()
end

local draggingVolume = false
volumeTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingVolume = true
        setVolumeFromX(input.Position.X)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingVolume and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        setVolumeFromX(input.Position.X)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingVolume = false
    end
end)

local backButton = makeButton("BackButton", "VOLTAR", UDim2.fromScale(0.5, 0.84))
backButton.Size = UDim2.fromScale(0.26, 0.17)
backButton.Parent = settingsPanel
backButton.Activated:Connect(function()
    settingsPanel.Visible = false
    playButton.Visible = true
    menuButton.Visible = true
    subtitle.Text = " "
end)

menuButton.Activated:Connect(function()
    playButton.Visible = false
    menuButton.Visible = false
    subtitle.Text = ""
    settingsPanel.Visible = true
end)

local progressBack = Instance.new("Frame")
progressBack.Name = "ProgressBarBackground"
progressBack.AnchorPoint = Vector2.new(0.5, 0.5)
progressBack.Position = UDim2.fromScale(0.5, 0.66)
progressBack.Size = UDim2.fromScale(0.36, 0.014)
progressBack.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
progressBack.BorderSizePixel = 0
progressBack.Visible = false
progressBack.Parent = background

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(1, 0)
progressCorner.Parent = progressBack

local progressFill = Instance.new("Frame")
progressFill.Name = "Progress"
progressFill.Size = UDim2.fromScale(0.025, 1)
progressFill.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBack

local progressFillCorner = Instance.new("UICorner")
progressFillCorner.CornerRadius = UDim.new(1, 0)
progressFillCorner.Parent = progressFill

local startEvent = ReplicatedStorage:WaitForChild("StartFirstStage")
local targetParts = 16
local minimumLoadTime = 5
local maximumLoadTime = 90
local playing = false

playButton.Activated:Connect(function()
    if playing then
        return
    end
    playing = true
    playButton.Visible = false
    menuButton.Visible = false
    settingsPanel.Visible = false
    progressBack.Visible = true
    subtitle.Text = "CARREGANDO A FASE 1"
    local loadStarted = os.clock()
    startEvent:FireServer()

    local lastPercent = -1
    local loadedParts = 0
    while os.clock() - loadStarted < maximumLoadTime do
        local battlefield = workspace:FindFirstChild("BattlefieldGenerated")
        loadedParts = battlefield and #battlefield:GetChildren() or 0
        local loadedFraction = math.clamp(loadedParts / targetParts, 0, 1)
        local timeFraction = math.clamp((os.clock() - loadStarted) / minimumLoadTime, 0, 1)
        local percent = math.floor(math.min(loadedFraction, timeFraction) * 95)

        if percent ~= lastPercent then
            lastPercent = percent
            subtitle.Text = ("CARREGANDO A FASE 1  %d%%"):format(percent)
            TweenService:Create(progressFill, TweenInfo.new(0.15), {
                Size = UDim2.fromScale(math.max(percent / 100, 0.025), 1),
            }):Play()
        end

        if loadedParts >= targetParts and os.clock() - loadStarted >= minimumLoadTime then
            break
        end
        task.wait(0.1)
    end

    if loadedParts < targetParts then
        subtitle.Text = "NÃO FOI POSSÍVEL CARREGAR. TENTE NOVAMENTE."
        progressBack.Visible = false
        playButton.Text = "TENTAR NOVAMENTE"
        playButton.Visible = true
        playing = false
        return
    end

    subtitle.Text = "FASE 1 PRONTA"
    TweenService:Create(progressFill, TweenInfo.new(0.3), { Size = UDim2.fromScale(1, 1) }):Play()
    task.wait(0.35)

    local fade = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, item in ipairs(screen:GetDescendants()) do
        if item:IsA("TextLabel") or item:IsA("TextButton") then
            TweenService:Create(item, fade, { TextTransparency = 1 }):Play()
        elseif item:IsA("Frame") then
            TweenService:Create(item, fade, { BackgroundTransparency = 1 }):Play()
        end
    end
    TweenService:Create(background, fade, { BackgroundTransparency = 1 }):Play()
    task.wait(0.5)
    screen:Destroy()
end)

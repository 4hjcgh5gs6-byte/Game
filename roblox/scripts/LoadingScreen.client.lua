local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local loadingStarted = os.clock()

local screen = Instance.new("ScreenGui")
screen.Name = "BattlefieldLoadingScreen"
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

local title = Instance.new("TextLabel")
title.Name = "Title"
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.fromScale(0.5, 0.42)
title.Size = UDim2.fromScale(0.8, 0.09)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "BATALHA GEOMÉTRICA"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.TextScaled = true
title.Parent = background

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
subtitle.Position = UDim2.fromScale(0.5, 0.50)
subtitle.Size = UDim2.fromScale(0.8, 0.035)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.GothamMedium
subtitle.Text = "PREPARANDO O CAMPO DE BATALHA"
subtitle.TextColor3 = Color3.fromRGB(170, 175, 180)
subtitle.TextScaled = true
subtitle.Parent = background

local barBack = Instance.new("Frame")
barBack.Name = "ProgressBarBackground"
barBack.AnchorPoint = Vector2.new(0.5, 0.5)
barBack.Position = UDim2.fromScale(0.5, 0.57)
barBack.Size = UDim2.fromScale(0.36, 0.012)
barBack.BackgroundColor3 = Color3.fromRGB(44, 47, 51)
barBack.BorderSizePixel = 0
barBack.Parent = background

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = barBack

local barFill = Instance.new("Frame")
barFill.Name = "Progress"
barFill.Size = UDim2.fromScale(0.025, 1)
barFill.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
barFill.BorderSizePixel = 0
barFill.Parent = barBack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = barFill

local status = Instance.new("TextLabel")
status.Name = "Status"
status.AnchorPoint = Vector2.new(0.5, 0.5)
status.Position = UDim2.fromScale(0.5, 0.62)
status.Size = UDim2.fromScale(0.7, 0.035)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "Carregando arena... 0%"
status.TextColor3 = Color3.fromRGB(145, 150, 155)
status.TextScaled = true
status.Parent = background

local camera = workspace.CurrentCamera
while not camera do
    task.wait(0.1)
    camera = workspace.CurrentCamera
end
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 40
camera.CFrame = CFrame.new(0, 600, 0) * CFrame.Angles(math.rad(-90), 0, 0)

local targetParts = 16
local minimumDisplayTime = 22
local maximumWaitTime = 90
local lastPercent = -1
local currentProgress = 0

while not game:IsLoaded() and os.clock() - loadingStarted < maximumWaitTime do
    task.wait(0.1)
end

while os.clock() - loadingStarted < maximumWaitTime do
    local battlefield = workspace:FindFirstChild("BattlefieldGenerated")
    local loadedParts = battlefield and #battlefield:GetChildren() or 0
    local loadedFraction = math.clamp(loadedParts / targetParts, 0, 1)
    local timeFraction = math.clamp((os.clock() - loadingStarted) / minimumDisplayTime, 0, 1)
    local progressTarget = math.floor(math.min(loadedFraction, timeFraction) * 95)
    currentProgress = math.max(currentProgress, progressTarget)

    if currentProgress ~= lastPercent then
        lastPercent = currentProgress
        status.Text = ("Carregando arena... %d%%"):format(currentProgress)
        TweenService:Create(barFill, TweenInfo.new(0.2), {
            Size = UDim2.fromScale(math.max(currentProgress / 100, 0.025), 1),
        }):Play()
    end

    local displayTimeReached = os.clock() - loadingStarted >= minimumDisplayTime
    if loadedParts >= targetParts and displayTimeReached then
        break
    end
    task.wait(0.1)
end

status.Text = "Arena pronta!"
TweenService:Create(barFill, TweenInfo.new(0.35), { Size = UDim2.fromScale(1, 1) }):Play()
task.wait(0.4)

local fade = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
for _, item in ipairs(screen:GetDescendants()) do
    if item:IsA("TextLabel") then
        TweenService:Create(item, fade, { TextTransparency = 1 }):Play()
    elseif item:IsA("Frame") then
        TweenService:Create(item, fade, { BackgroundTransparency = 1 }):Play()
    end
end
TweenService:Create(background, fade, { BackgroundTransparency = 1 }):Play()
task.wait(0.5)
screen:Destroy()



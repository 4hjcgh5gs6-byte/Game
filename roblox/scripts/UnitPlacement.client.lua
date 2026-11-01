-- Barra de preparacao da Fase 1 e posicionamento de circulos no territorio aliado.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local startEvent = ReplicatedStorage:WaitForChild("StartFirstStage")
local placementEvent = ReplicatedStorage:WaitForChild("UnitPlacementEvent")

local GRID_SIZE = 20
local PLAYER_MIN_Z = 20
local PLAYER_MAX_Z = 240
local PLAYER_MAX_X = 330

local interfaceCreated = false
local availableUnits = 5
local brushSize = 1
local painting = false
local draggingSlider = false
local draggingVolume = false
local lastPaintCell = nil
local statusVersion = 0

local screen
local unitCountLabel
local brushLabel
local brushFill
local brushKnob
local statusLabel
local menuPanel
local volumeLabel
local volumeFill
local volumeTrack

local function snapToGrid(value)
	return math.floor(value / GRID_SIZE + 0.5) * GRID_SIZE
end

local function makeButton(name, text, width, parent)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.fromOffset(width, 56)
	button.BackgroundColor3 = Color3.fromRGB(54, 57, 62)
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = Color3.fromRGB(238, 240, 242)
	button.TextScaled = true
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button
	return button
end

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

local function showStatus(message)
	if not statusLabel then
		return
	end
	statusVersion += 1
	local thisVersion = statusVersion
	statusLabel.Text = message
	statusLabel.Visible = true
	task.delay(3, function()
		if statusVersion == thisVersion and statusLabel then
			statusLabel.Visible = false
		end
	end)
end

local function setBrush(value)
	brushSize = value <= 1 and 1 or 2
	brushLabel.Text = brushSize == 1 and "BRUSH 1×1" or "BRUSH 2×2"
	brushFill.Size = UDim2.new(brushSize == 1 and 0.12 or 0.88, 0, 1, 0)
	brushKnob.Position = UDim2.new(brushSize == 1 and 0.12 or 0.88, 0, 0.5, 0)
end

local function createInterface()
	if interfaceCreated then
		return
	end
	interfaceCreated = true

	screen = Instance.new("ScreenGui")
	screen.Name = "BattlefieldPlacement"
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 100
	screen.Parent = playerGui

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Position = UDim2.fromOffset(22, 18)
	levelLabel.Size = UDim2.fromOffset(150, 34)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.Text = "FASE 1"
	levelLabel.TextColor3 = Color3.fromRGB(235, 235, 230)
	levelLabel.TextScaled = true
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.Parent = screen

	local menuButton = Instance.new("TextButton")
	menuButton.Name = "MenuButton"
	menuButton.AnchorPoint = Vector2.new(1, 0)
	menuButton.Position = UDim2.new(1, -22, 0, 18)
	menuButton.Size = UDim2.fromOffset(88, 38)
	menuButton.BackgroundColor3 = Color3.fromRGB(63, 65, 68)
	menuButton.BorderSizePixel = 0
	menuButton.Font = Enum.Font.GothamBold
	menuButton.Text = "MENU"
	menuButton.TextColor3 = Color3.fromRGB(245, 245, 245)
	menuButton.TextScaled = true
	menuButton.Parent = screen
	addCorner(menuButton, 7)

	local panel = Instance.new("Frame")
	panel.Name = "ControlBar"
	panel.AnchorPoint = Vector2.new(0.5, 1)
	panel.Position = UDim2.new(0.5, 0, 1, -18)
	panel.Size = UDim2.fromOffset(790, 82)
	panel.BackgroundColor3 = Color3.fromRGB(38, 40, 44)
	panel.BackgroundTransparency = 0.04
	panel.BorderSizePixel = 0
	panel.Parent = screen
	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 10)
	panelCorner.Parent = panel
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 9)
	layout.Parent = panel

	local unitButton = Instance.new("TextButton")
	unitButton.Name = "CircleWarrior"
	unitButton.Size = UDim2.fromOffset(58, 58)
	unitButton.BackgroundColor3 = Color3.fromRGB(45, 75, 112)
	unitButton.BorderSizePixel = 0
	unitButton.Text = ""
	unitButton.Parent = panel
	local unitCorner = Instance.new("UICorner")
	unitCorner.CornerRadius = UDim.new(0, 7)
	unitCorner.Parent = unitButton
	local selection = Instance.new("UIStroke")
	selection.Color = Color3.fromRGB(235, 238, 242)
	selection.Thickness = 2
	selection.Parent = unitButton
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Position = UDim2.fromScale(0, 0.03)
	icon.Size = UDim2.fromScale(1, 0.66)
	icon.BackgroundTransparency = 1
	icon.Font = Enum.Font.GothamBlack
	icon.Text = "●"
	icon.TextColor3 = Color3.fromRGB(86, 170, 255)
	icon.TextScaled = true
	icon.Parent = unitButton
	unitCountLabel = Instance.new("TextLabel")
	unitCountLabel.Name = "AvailableCount"
	unitCountLabel.Position = UDim2.fromScale(0, 0.69)
	unitCountLabel.Size = UDim2.fromScale(1, 0.25)
	unitCountLabel.BackgroundTransparency = 1
	unitCountLabel.Font = Enum.Font.GothamBold
	unitCountLabel.Text = tostring(availableUnits)
	unitCountLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
	unitCountLabel.TextScaled = true
	unitCountLabel.Parent = unitButton

	local brushPanel = Instance.new("Frame")
	brushPanel.Name = "BrushControl"
	brushPanel.Size = UDim2.fromOffset(150, 58)
	brushPanel.BackgroundTransparency = 1
	brushPanel.Parent = panel
	brushLabel = Instance.new("TextLabel")
	brushLabel.Name = "BrushSize"
	brushLabel.Position = UDim2.fromOffset(0, 0)
	brushLabel.Size = UDim2.new(1, 0, 0, 22)
	brushLabel.BackgroundTransparency = 1
	brushLabel.Font = Enum.Font.GothamBold
	brushLabel.TextColor3 = Color3.fromRGB(224, 226, 230)
	brushLabel.TextScaled = true
	brushLabel.TextXAlignment = Enum.TextXAlignment.Left
	brushLabel.Parent = brushPanel
	local brushTrack = Instance.new("TextButton")
	brushTrack.Name = "BrushSlider"
	brushTrack.Position = UDim2.new(0, 0, 0, 33)
	brushTrack.Size = UDim2.new(1, 0, 0, 14)
	brushTrack.BackgroundColor3 = Color3.fromRGB(22, 24, 27)
	brushTrack.BorderSizePixel = 0
	brushTrack.Text = ""
	brushTrack.AutoButtonColor = false
	brushTrack.Parent = brushPanel
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = brushTrack
	brushFill = Instance.new("Frame")
	brushFill.Name = "Fill"
	brushFill.Size = UDim2.new(0.12, 0, 1, 0)
	brushFill.BackgroundColor3 = Color3.fromRGB(155, 160, 168)
	brushFill.BorderSizePixel = 0
	brushFill.Parent = brushTrack
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = brushFill
	brushKnob = Instance.new("Frame")
	brushKnob.Name = "Knob"
	brushKnob.AnchorPoint = Vector2.new(0.5, 0.5)
	brushKnob.Position = UDim2.new(0.12, 0, 0.5, 0)
	brushKnob.Size = UDim2.fromOffset(16, 20)
	brushKnob.BackgroundColor3 = Color3.fromRGB(215, 218, 222)
	brushKnob.BorderSizePixel = 0
	brushKnob.Parent = brushTrack
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(0, 4)
	knobCorner.Parent = brushKnob
	setBrush(1)

	local undoButton = makeButton("Undo", "UNDO", 68, panel)
	local clearButton = makeButton("Clear", "CLEAR", 68, panel)
	local upgradesButton = makeButton("Upgrades", "UPGRADES", 92, panel)
	local levelsButton = makeButton("Levels", "LEVELS", 76, panel)
	local fightButton = makeButton("Fight", "FIGHT", 84, panel)

	for _, button in ipairs({ upgradesButton, levelsButton }) do
		button.Active = false
		button.AutoButtonColor = false
		button.BackgroundColor3 = Color3.fromRGB(48, 50, 54)
		button.TextColor3 = Color3.fromRGB(140, 143, 148)
	end

	statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "PreparationStatus"
	statusLabel.AnchorPoint = Vector2.new(0.5, 1)
	statusLabel.Position = UDim2.new(0.5, 0, 1, -108)
	statusLabel.Size = UDim2.fromOffset(460, 28)
	statusLabel.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
	statusLabel.BackgroundTransparency = 0.1
	statusLabel.BorderSizePixel = 0
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.Text = ""
	statusLabel.TextColor3 = Color3.fromRGB(235, 237, 240)
	statusLabel.TextScaled = true
	statusLabel.Visible = false
	statusLabel.Parent = screen
	local statusCorner = Instance.new("UICorner")
	statusCorner.CornerRadius = UDim.new(0, 6)
	statusCorner.Parent = statusLabel

	menuPanel = Instance.new("Frame")
	menuPanel.Name = "SettingsPanel"
	menuPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	menuPanel.Position = UDim2.fromScale(0.5, 0.5)
	menuPanel.Size = UDim2.fromOffset(340, 210)
	menuPanel.BackgroundColor3 = Color3.fromRGB(34, 35, 34)
	menuPanel.BorderSizePixel = 0
	menuPanel.Visible = false
	menuPanel.Parent = screen
	addCorner(menuPanel, 10)

	local settingsTitle = Instance.new("TextLabel")
	settingsTitle.Position = UDim2.fromOffset(20, 16)
	settingsTitle.Size = UDim2.new(1, -40, 0, 34)
	settingsTitle.BackgroundTransparency = 1
	settingsTitle.Font = Enum.Font.GothamBold
	settingsTitle.Text = "CONFIGURAÇÕES"
	settingsTitle.TextColor3 = Color3.fromRGB(245, 245, 240)
	settingsTitle.TextScaled = true
	settingsTitle.Parent = menuPanel

	local masterVolume = SoundService:FindFirstChild("MasterVolume")
	volumeLabel = Instance.new("TextLabel")
	volumeLabel.Position = UDim2.fromOffset(24, 70)
	volumeLabel.Size = UDim2.new(1, -48, 0, 24)
	volumeLabel.BackgroundTransparency = 1
	volumeLabel.Font = Enum.Font.GothamMedium
	volumeLabel.TextColor3 = Color3.fromRGB(215, 215, 210)
	volumeLabel.TextScaled = true
	volumeLabel.Text = masterVolume and string.format("VOLUME  %d%%", masterVolume.Volume * 100) or "VOLUME"
	volumeLabel.Parent = menuPanel

	volumeTrack = Instance.new("TextButton")
	volumeTrack.Name = "VolumeSlider"
	volumeTrack.Position = UDim2.fromOffset(28, 112)
	volumeTrack.Size = UDim2.new(1, -56, 0, 14)
	volumeTrack.BackgroundColor3 = Color3.fromRGB(18, 19, 18)
	volumeTrack.BorderSizePixel = 0
	volumeTrack.Text = ""
	volumeTrack.AutoButtonColor = false
	volumeTrack.Parent = menuPanel
	addCorner(volumeTrack, 8)

	volumeFill = Instance.new("Frame")
	volumeFill.Name = "Fill"
	volumeFill.Size = UDim2.new(masterVolume and masterVolume.Volume or 0.5, 0, 1, 0)
	volumeFill.BackgroundColor3 = Color3.fromRGB(205, 205, 195)
	volumeFill.BorderSizePixel = 0
	volumeFill.Parent = volumeTrack
	addCorner(volumeFill, 8)

	local closeMenu = makeButton("CloseSettings", "VOLTAR", 130, menuPanel)
	closeMenu.AnchorPoint = Vector2.new(0.5, 0)
	closeMenu.Position = UDim2.new(0.5, 0, 1, -58)
	closeMenu.Size = UDim2.fromOffset(130, 40)
	closeMenu.Activated:Connect(function()
		menuPanel.Visible = false
	end)
	menuButton.Activated:Connect(function()
		menuPanel.Visible = true
	end)

	local function setVolumeFromX(x)
		local master = SoundService:FindFirstChild("MasterVolume")
		local width = volumeTrack.AbsoluteSize.X
		if not master or width <= 0 then
			return
		end
		local volume = math.clamp((x - volumeTrack.AbsolutePosition.X) / width, 0, 1)
		master.Volume = volume
		volumeFill.Size = UDim2.new(volume, 0, 1, 0)
		volumeLabel.Text = string.format("VOLUME  %d%%", math.floor(volume * 100 + 0.5))
	end
	volumeTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			draggingVolume = true
			setVolumeFromX(input.Position.X)
		end
	end)

	unitButton.Activated:Connect(function()
		showStatus("Guerreiro circular selecionado")
	end)
	undoButton.Activated:Connect(function()
		placementEvent:FireServer("Undo")
	end)
	clearButton.Activated:Connect(function()
		placementEvent:FireServer("Clear")
	end)
	fightButton.Activated:Connect(function()
		showStatus("O combate automatico sera conectado na proxima etapa")
	end)

	local function updateBrushFromX(x)
		local width = brushTrack.AbsoluteSize.X
		if width > 0 then
			local position = (x - brushTrack.AbsolutePosition.X) / width
			setBrush(position < 0.5 and 1 or 2)
		end
	end
	brushTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			updateBrushFromX(input.Position.X)
		end
	end)
end

local function getWorldCell(screenPosition)
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	local mousePosition = screenPosition or UserInputService:GetMouseLocation()
	local ray = camera:ScreenPointToRay(mousePosition.X, mousePosition.Y)
	if math.abs(ray.Direction.Y) < 0.0001 then
		return nil
	end
	local distance = (1.05 - ray.Origin.Y) / ray.Direction.Y
	if distance <= 0 then
		return nil
	end
	local hit = ray.Origin + ray.Direction * distance
	local x = snapToGrid(hit.X)
	local z = snapToGrid(hit.Z)
	if math.abs(x) > PLAYER_MAX_X or z < PLAYER_MIN_Z or z > PLAYER_MAX_Z then
		return nil
	end
	return x, z
end

local function placeAtScreenPosition(screenPosition)
	local x, z = getWorldCell(screenPosition)
	if not x then
		return
	end
	if math.abs(x) > PLAYER_MAX_X or z < PLAYER_MIN_Z or z > PLAYER_MAX_Z then
		local inBattlefield = math.abs(x) <= 350 and math.abs(z) <= 260
		if inBattlefield then
			showStatus("Posição inválida")
		end
		return
	end
	local key = tostring(x) .. ":" .. tostring(z)
	if lastPaintCell == key then
		return
	end
	lastPaintCell = key

	local positions = {}
	if brushSize == 1 then
		table.insert(positions, Vector3.new(x, 0, z))
	else
		for xOffset = 0, 1 do
			for zOffset = 0, 1 do
				local cellX = x + xOffset * GRID_SIZE
				local cellZ = z + zOffset * GRID_SIZE
				if math.abs(cellX) > PLAYER_MAX_X or cellZ < PLAYER_MIN_Z or cellZ > PLAYER_MAX_Z then
					showStatus("Posição inválida")
					return
				end
				table.insert(positions, Vector3.new(cellX, 0, cellZ))
			end
		end
	end
	placementEvent:FireServer("Place", positions)
end

placementEvent.OnClientEvent:Connect(function(message, available)
	if message == "State" and typeof(available) == "number" then
		availableUnits = math.clamp(available, 0, 5)
		if unitCountLabel then
			unitCountLabel.Text = tostring(availableUnits)
		end
	elseif message == "InvalidPosition" then
		showStatus("Posição inválida")
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not interfaceCreated or gameProcessed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		painting = true
		lastPaintCell = nil
		placeAtScreenPosition(input.Position)
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		local x, z = getWorldCell(input.Position)
		if x then
			placementEvent:FireServer("RemoveAt", Vector3.new(x, 0, z))
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingVolume and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		if volumeTrack then
			local master = SoundService:FindFirstChild("MasterVolume")
			local width = volumeTrack.AbsoluteSize.X
			if master and width > 0 then
				local volume = math.clamp((input.Position.X - volumeTrack.AbsolutePosition.X) / width, 0, 1)
				master.Volume = volume
				volumeFill.Size = UDim2.new(volume, 0, 1, 0)
				volumeLabel.Text = string.format("VOLUME  %d%%", math.floor(volume * 100 + 0.5))
			end
		end
	elseif draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		local track = screen and screen:FindFirstChild("ControlBar")
			and screen.ControlBar:FindFirstChild("BrushControl")
			and screen.ControlBar.BrushControl:FindFirstChild("BrushSlider")
		if track then
			local width = track.AbsoluteSize.X
			if width > 0 then
				local position = (input.Position.X - track.AbsolutePosition.X) / width
				setBrush(position < 0.5 and 1 or 2)
			end
		end
	elseif painting and input.UserInputType == Enum.UserInputType.MouseMovement then
		placeAtScreenPosition(input.Position)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		painting = false
		lastPaintCell = nil
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		draggingSlider = false
		draggingVolume = false
	end
end)

startEvent.OnClientEvent:Connect(function(message)
	if message == "LoadComplete" then
		createInterface()
		placementEvent:FireServer("StateRequest")
	end
end)


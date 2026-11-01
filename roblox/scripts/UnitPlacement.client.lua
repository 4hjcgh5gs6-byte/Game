-- Barra de preparacao da Fase 1 e posicionamento de circulos no territorio aliado.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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
local lastPaintCell = nil
local statusVersion = 0

local screen
local unitCountLabel
local brushLabel
local brushFill
local brushKnob
local statusLabel

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

	brushTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			local width = brushTrack.AbsoluteSize.X
			if width > 0 then
				local position = (input.Position.X - brushTrack.AbsolutePosition.X) / width
				setBrush(position < 0.5 and 1 or 2)
			end
		end
	end)
end

local function getWorldCell()
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	local mousePosition = UserInputService:GetMouseLocation()
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

local function placeAtMouse()
	local x, z = getWorldCell()
	if not x then
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
				table.insert(positions, Vector3.new(x + xOffset * GRID_SIZE, 0, z + zOffset * GRID_SIZE))
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
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not interfaceCreated or gameProcessed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		painting = true
		lastPaintCell = nil
		placeAtMouse()
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		local x, z = getWorldCell()
		if x then
			placementEvent:FireServer("RemoveAt", Vector3.new(x, 0, z))
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
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
		placeAtMouse()
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
	end
end)

startEvent.OnClientEvent:Connect(function(message)
	if message == "LoadComplete" then
		createInterface()
		placementEvent:FireServer("StateRequest")
	end
end)

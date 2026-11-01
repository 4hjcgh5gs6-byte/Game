-- Gerencia a preparacao da Fase 1: somente guerreiros circulares do jogador.
-- As unidades so vao para a arena quando o jogador as posiciona.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local UNIT_LIMIT = 5
local GRID_SIZE = 20
local MIN_PLAYER_Z = 20
local MAX_PLAYER_Z = 240
local MAX_PLAYER_X = 330

local placementEvent = ReplicatedStorage:FindFirstChild("UnitPlacementEvent")
if not placementEvent or not placementEvent:IsA("RemoteEvent") then
	if placementEvent then
		placementEvent:Destroy()
	end
	placementEvent = Instance.new("RemoteEvent")
	placementEvent.Name = "UnitPlacementEvent"
	placementEvent.Parent = ReplicatedStorage
end

local states = {}

local function getState(player)
	if not states[player] then
		states[player] = { units = {}, history = {} }
	end
	return states[player]
end

local function getUnitFolder()
	local battlefield = Workspace:FindFirstChild("BattlefieldGenerated")
	if not battlefield then
		return nil
	end

	local folder = battlefield:FindFirstChild("PlayerUnits")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "PlayerUnits"
		folder.Parent = battlefield
	end
	return folder
end

local function sendState(player)
	local state = getState(player)
	placementEvent:FireClient(player, "State", math.max(UNIT_LIMIT - #state.units, 0), #state.units)
end

local function snapToGrid(value)
	return math.floor(value / GRID_SIZE + 0.5) * GRID_SIZE
end

local function removeTrackedUnit(state, model)
	for index, unit in ipairs(state.units) do
		if unit == model then
			table.remove(state.units, index)
			return
		end
	end
end

local function isCellOccupied(folder, x, z)
	for _, model in ipairs(folder:GetChildren()) do
		if model:IsA("Model") and model.PrimaryPart then
			local position = model.PrimaryPart.Position
			if math.abs(position.X - x) < GRID_SIZE * 0.75
				and math.abs(position.Z - z) < GRID_SIZE * 0.75 then
				return true
			end
		end
	end
	return false
end

local function placeUnits(player, positions)
	local state = getState(player)
	local folder = getUnitFolder()
	local templates = ReplicatedStorage:FindFirstChild("UnitTemplates")
	local template = templates and templates:FindFirstChild("Circulo_Guerreiro_Ally")
	if not folder or not template then
		sendState(player)
		return
	end
	if typeof(positions) ~= "table" or #positions > 4 then
		sendState(player)
		return
	end

	local added = {}
	local invalidPosition = false
	for _, requestedPosition in ipairs(positions) do
		if #state.units >= UNIT_LIMIT then
			break
		end
		if typeof(requestedPosition) ~= "Vector3" then
			continue
		end

		local x = snapToGrid(requestedPosition.X)
		local z = snapToGrid(requestedPosition.Z)
		if math.abs(x) > MAX_PLAYER_X or z < MIN_PLAYER_Z or z > MAX_PLAYER_Z then
			invalidPosition = true
			continue
		end
		if isCellOccupied(folder, x, z) then
			continue
		end

		local unit = template:Clone()
		unit:SetAttribute("OwnerUserId", player.UserId)
		unit:PivotTo(CFrame.new(x, 2.3, z))
		unit.Parent = folder
		table.insert(state.units, unit)
		table.insert(added, unit)
	end

	if #added > 0 then
		table.insert(state.history, { kind = "Place", units = added })
	end
	sendState(player)
	if invalidPosition then
		placementEvent:FireClient(player, "InvalidPosition")
	end
end

local function removeUnitAt(player, requestedPosition)
	if typeof(requestedPosition) ~= "Vector3" then
		return
	end

	local state = getState(player)
	local x = snapToGrid(requestedPosition.X)
	local z = snapToGrid(requestedPosition.Z)
	for index = #state.units, 1, -1 do
		local unit = state.units[index]
		if unit.Parent and unit.PrimaryPart then
			local position = unit.PrimaryPart.Position
			if math.abs(position.X - x) <= GRID_SIZE / 2
				and math.abs(position.Z - z) <= GRID_SIZE / 2 then
				local previousPivot = unit:GetPivot()
			table.remove(state.units, index)
				unit.Parent = nil
				table.insert(state.history, {
					kind = "Remove",
					unit = unit,
					pivot = previousPivot,
				})
				break
			end
		end
	end
	sendState(player)
end

local function clearUnits(player)
	local state = getState(player)
	if #state.units == 0 then
		sendState(player)
		return
	end

	local cleared = {}
	for _, unit in ipairs(state.units) do
		if unit.Parent then
			table.insert(cleared, { unit = unit, pivot = unit:GetPivot() })
			unit.Parent = nil
		end
	end
	state.units = {}
	table.insert(state.history, { kind = "Clear", units = cleared })
	sendState(player)
end

local function undo(player)
	local state = getState(player)
	local action = table.remove(state.history)
	if not action then
		sendState(player)
		return
	end

	if action.kind == "Place" then
		for _, unit in ipairs(action.units) do
			removeTrackedUnit(state, unit)
			unit:Destroy()
		end
	elseif action.kind == "Remove" then
		local folder = getUnitFolder()
		if folder and action.unit then
			action.unit:PivotTo(action.pivot)
			action.unit.Parent = folder
			table.insert(state.units, action.unit)
		end
	elseif action.kind == "Clear" then
		local folder = getUnitFolder()
		if folder then
			for _, entry in ipairs(action.units) do
				entry.unit:PivotTo(entry.pivot)
				entry.unit.Parent = folder
				table.insert(state.units, entry.unit)
			end
		end
	end
	sendState(player)
end

placementEvent.OnServerEvent:Connect(function(player, action, payload)
	if action == "StateRequest" then
		sendState(player)
	elseif action == "Place" then
		placeUnits(player, payload)
	elseif action == "RemoveAt" then
		removeUnitAt(player, payload)
	elseif action == "Clear" then
		clearUnits(player)
	elseif action == "Undo" then
		undo(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local state = states[player]
	if state then
		for _, unit in ipairs(state.units) do
			unit:Destroy()
		end
		states[player] = nil
	end
end)


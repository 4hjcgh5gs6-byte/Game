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

-- Partículas leves de impacto: uma pequena rajada de faíscas no ponto onde a unidade é atingida.
local Debris = game:GetService("Debris")
local IMPACT_COLORS = {
	Ally = Color3.fromRGB(120, 185, 255),
	Enemy = Color3.fromRGB(255, 120, 110),
}

local function emitImpact(position, ally)
	local field = Workspace:FindFirstChild("BattlefieldGenerated")
	if not field then
		return
	end

	local anchor = Instance.new("Part")
	anchor.Name = "ImpactEffect"
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = Vector3.new(position.X, 10, position.Z)
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.CastShadow = false
	anchor.Transparency = 1
	anchor.Parent = field

	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.3, 0.5)
	emitter.Speed = NumberRange.new(18, 32)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Drag = 4
	emitter.LightEmission = 0.5
	emitter.Color = ColorSequence.new(ally and IMPACT_COLORS.Ally or IMPACT_COLORS.Enemy)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.6),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Parent = anchor
	emitter:Emit(8)

	Debris:AddItem(anchor, 1)
end

local states = {}
local battleOwner
local battleState = "Preparation"
local savedFormation
local battleConnection

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
		unit:PivotTo(CFrame.new(x, 2.6, z))
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

local function resetBattle(player)
	if battleOwner ~= player or battleState ~= "Finished" then return end
	local field = Workspace:FindFirstChild("BattlefieldGenerated")
	if not field then return end
	for _, entry in ipairs(savedFormation) do
		local unit = entry.template:Clone()
		unit:PivotTo(entry.pivot)
		unit.Parent = entry.folder
		if entry.ally then table.insert(getState(player).units, unit) end
		entry.template:Destroy()
	end
	savedFormation = nil
	battleState = "Preparation"
	battleOwner = nil
	placementEvent:FireAllClients("BattleState", "Preparation")
	sendState(player)
end

local function startBattle(player)
	if battleState ~= "Preparation" then return end
	local state = getState(player)
	local field = Workspace:FindFirstChild("BattlefieldGenerated")
	local enemies = field and field:FindFirstChild("EnemyPreview")
	if not enemies or not field:GetAttribute("Ready") then return end
	if #state.units == 0 then
		placementEvent:FireClient(player, "Notice", "Posicione pelo menos um guerreiro")
		return
	end
	if #Players:GetPlayers() > 1 then
		placementEvent:FireClient(player, "Notice", "Esta batalha está disponível no modo solo")
		return
	end
	battleOwner = player
	battleState = "Fighting"
	savedFormation = {}
	local fighters = {}
	local function register(unit, ally)
		if not unit:IsA("Model") or not unit.PrimaryPart then return end
		table.insert(savedFormation, {template = unit:Clone(), pivot = unit:GetPivot(), folder = unit.Parent, ally = ally})
		unit:SetAttribute("Health", 20)
		unit:SetAttribute("PreviewOnly", false)
		local bar = Instance.new("BillboardGui")
		bar.Name = "HealthBar"
		bar.Size = UDim2.fromOffset(28, 5)
		bar.StudsOffsetWorldSpace = Vector3.new(0, 9, 0)
		bar.AlwaysOnTop = true
		bar.Adornee = unit.PrimaryPart
		bar.Parent = unit
		local fill = Instance.new("Frame")
		fill.BorderSizePixel = 0
		fill.Size = UDim2.fromScale(1, 1)
		fill.BackgroundColor3 = ally and Color3.fromRGB(65, 160, 255) or Color3.fromRGB(245, 80, 70)
		fill.Parent = bar
		table.insert(fighters, {model = unit, ally = ally, hp = 20, cooldown = 0, fill = fill})
	end
	for _, unit in ipairs(state.units) do register(unit, true) end
	for _, unit in ipairs(enemies:GetChildren()) do register(unit, false) end
	-- Discard detached undo copies before the battle starts.
	for _, action in ipairs(state.history) do
		if action.unit and not action.unit.Parent then action.unit:Destroy() end
		for _, entry in ipairs(action.units or {}) do
			local unit = typeof(entry) == "Instance" and entry or entry.unit
			if unit and not unit.Parent then unit:Destroy() end
		end
	end
	state.history = {}
	placementEvent:FireAllClients("BattleState", "Fighting")
	local elapsed, accumulator = 0, 0
	battleConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		accumulator += dt
		if accumulator < 0.05 then return end
		local step = math.min(accumulator, 0.1)
		accumulator = 0
		elapsed += step
		local damage = {}
		local positions = {}
		for _, fighter in ipairs(fighters) do
			if fighter.hp > 0 then positions[fighter] = fighter.model:GetPivot().Position end
		end
		for _, fighter in ipairs(fighters) do
			if fighter.hp <= 0 then continue end
			fighter.cooldown = math.max(0, fighter.cooldown - step)
			local target, nearest = nil, math.huge
			for _, other in ipairs(fighters) do
				if other.hp > 0 and other.ally ~= fighter.ally then
					local distance = (positions[other] - positions[fighter]).Magnitude
					if distance < nearest then target, nearest = other, distance end
				end
			end
			if target then
				if nearest <= 21 then
					if fighter.cooldown <= 0 then
						damage[target] = (damage[target] or 0) + 2
						fighter.cooldown = 1
					end
				else
					local direction = (positions[target] - positions[fighter]).Unit
					local position = positions[fighter] + direction * math.min(32 * step, (nearest - 20) / 2)
					fighter.model:PivotTo(CFrame.new(position))
				end
			end
		end
		-- Apply all attacks together so neither faction attacks first by iteration order.
		for fighter, amount in pairs(damage) do
			fighter.hp = math.max(0, fighter.hp - amount)
			fighter.model:SetAttribute("Health", fighter.hp)
			fighter.fill.Size = UDim2.fromScale(fighter.hp / 20, 1)
			emitImpact(positions[fighter] or fighter.model:GetPivot().Position, fighter.ally)
			if fighter.hp == 0 then fighter.model:Destroy() end
		end
		local alliesAlive, enemiesAlive = 0, 0
		for _, fighter in ipairs(fighters) do
			if fighter.hp > 0 then
				if fighter.ally then alliesAlive += 1 else enemiesAlive += 1 end
			end
		end
		if alliesAlive == 0 or enemiesAlive == 0 or elapsed >= 120 then
			battleConnection:Disconnect()
			battleConnection = nil
			battleState = "Finished"
			local result = "Empate"
			if alliesAlive > 0 and enemiesAlive == 0 then result = "Vitória!"
			elseif enemiesAlive > 0 and alliesAlive == 0 then result = "Derrota" end
			for _, fighter in ipairs(fighters) do fighter.model:Destroy() end
			state.units = {}
			placementEvent:FireAllClients("BattleResult", result)
		end
	end)
end

placementEvent.OnServerEvent:Connect(function(player, action, payload)
	if action == "Fight" then startBattle(player); return end
	if action == "Retry" then resetBattle(player); return end
	if battleState ~= "Preparation" then return end
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
	if battleOwner == player then
		if battleConnection then battleConnection:Disconnect(); battleConnection = nil end
		for _, entry in ipairs(savedFormation or {}) do entry.template:Destroy() end
		savedFormation = nil
		battleOwner = nil
		battleState = "Preparation"
	end
	local state = states[player]
	if state then
		for _, unit in ipairs(state.units) do
			unit:Destroy()
		end
		states[player] = nil
	end
end)

-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local DiggingTools = ReplicatedStorage.Assets.Tools.Digging
local Packages = ReplicatedStorage.Packages
local Utils = ReplicatedStorage.Source.Utils

-- Modules --
local Digging = require(ReplicatedStorage.Source.Data.Digging)

local Knit = require(Packages.Knit)

local getMaterialFromWorld = require(Utils.WorldTerrain.getMaterialFromWorld)
local isInBrick = require(Utils.isInBrick)

-- Service --
local DiggingService = Knit.CreateService {
	Name = "DiggingService",
	Client = {
		TriggerDigEffectsForPlayer = Knit.CreateSignal(),
	},
}

-- Types --
type Self = typeof(DiggingService)

-- Local --
local digDebounces: { [Player]: boolean } = {}
local equippedTools: { [Player]: Tool } = {}
local terrainParts: { BasePart } = {}

function DiggingService.Client:DigAttempt(player: Player, digPosition: Vector3)
	if not digPosition or typeof(digPosition) ~= "Vector3" then
		return
	end
	return self.Server:DigAttempt(player, digPosition)
end

function DiggingService:CheckValidMaterialOnPosition(player: Player, position: Vector3)
	local terrainPart: BasePart?
	for _, part in terrainParts do
		local pos = part:GetAttribute("TopPart") and position - Vector3.yAxis * 5 or
					part:GetAttribute("BottomPart") and position + Vector3.yAxis * 5
		if isInBrick(pos, part) then
			terrainPart = part
			break
		end
	end
	if not terrainPart then
		return
	end
	
	local playerDataFold: Folder? = player:FindFirstChild("Data")
	if not playerDataFold then
		return
	end
	local equippedToolIndex = math.min(playerDataFold.ToolEquipped.Value, 1)
	local currentWorld = playerDataFold.CurrentWorld.Value
	local material = getMaterialFromWorld(terrainPart.Name, currentWorld, true).Name
	
	return string.find(Digging.Tools[equippedToolIndex].Terrain, material) ~= nil, terrainPart
end

function DiggingService:DigAttempt(player: Player, digPosition: Vector3)
	if not digPosition or typeof(digPosition) ~= "Vector3" then
		return
	end
	
	local char = player.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hum or hum.Health <= 0 then
		return
	end
	
	if (char:GetPivot().Position - digPosition).Magnitude > Digging.MAX_DIGGING_DISTANCE then
		return
	end
	
	local valid, terrainPart = self:CheckValidMaterialOnPosition(player, digPosition)
	if not valid then
		return
	end
	local worldIndex = terrainPart:GetAttribute("WorldIndex")
	
	local profile = self.ProfileStoreService.profiles[player]
	if not profile then
		return
	end
	
	local toolData = Digging.Tools[profile.Data.ToolEquipped]
	
	if digDebounces[player] == nil or digDebounces[player] == true then
		return
	end
	digDebounces[player] = true
	task.delay(toolData.Cooldown, function()
		digDebounces[player] = false
	end)
	
	if not profile.Data.DigPoints[worldIndex] then
		profile.Data.DigPoints[worldIndex] = {}
	end
	table.insert(profile.Data.DigPoints[worldIndex], {
		position = { x = digPosition.X, y = digPosition.Y, z = digPosition.Z },
		radius = toolData.Radius,
	})
	
	for _, otherPlayer in Players:GetPlayers() do
		self.Client.TriggerDigEffectsForPlayer:Fire(otherPlayer, player, terrainPart.Name, digPosition)
	end
	
	return true
end

function DiggingService:SetupTools()
	for _, tool: Tool in DiggingTools:GetChildren() do
		local handle = tool:FindFirstChild("Handle")
		for _, p: BasePart? in tool:GetDescendants() do
			if not p:IsA("BasePart") then
				continue
			end
			
			p.CanCollide = false
			p.Massless = true
			p.CanQuery = false
			p.Anchored = false
			
			if p == handle then
				continue
			end
			
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = p
			weld.Name = p.Name
			weld.Parent = weld.Part0
		end
	end
end

function DiggingService:GetToolFromIndex(toolIndex: number)
	for _, tool: Tool in DiggingTools:GetChildren() do
		if tool:GetAttribute("Index") == toolIndex then
			return tool
		end
	end
end

function DiggingService:EquipTool(player: Player, toolIndex: number)
	local char = player.Character
	if not char then
		return
	end
	
	self:UnequipTool(player)
	
	local newTool = self:GetToolFromIndex(toolIndex):Clone()
	equippedTools[player] = newTool
	newTool.Parent = char
end

function DiggingService:UnequipTool(player: Player)
	local tool = equippedTools[player]
	if tool then
		equippedTools[player] = nil
		tool:Destroy()
	end
end

function DiggingService:ManagePlayerTools(player: Player)
	local playerDataFold: Folder = player.Data
	local toolEquipped: NumberValue = playerDataFold.ToolEquipped
	
	local function onCharacterAdded(char: Model?)
		if not char then
			return
		end
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if not hum then
			return
		end
		
		hum.Died:Once(function()
			terrainParts[player] = nil
		end)
		
		self:EquipTool(player, toolEquipped.Value)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
	onCharacterAdded(player.Character)
	
	toolEquipped.Changed:Connect(function(newToolIndex)
		self:EquipTool(player, newToolIndex)
	end)
end

function DiggingService:KnitInit()
	self.ProfileStoreService = Knit.GetService("ProfileStoreService")
	
	self:SetupTools()
	
	self.ProfileStoreService.PlayerProfileLoaded:Connect(function(player: Player)
		digDebounces[player] = false
		self:ManagePlayerTools(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		equippedTools[player] = nil
		digDebounces[player] = nil
	end)
	
	for _, worldFold: Folder in workspace.Worlds:GetChildren() do
		local terrainPartsContainer: Model = worldFold.TerrainParts
		for _, terrainPart: BasePart in terrainPartsContainer:GetChildren() do
			table.insert(terrainParts, terrainPart)
		end
	end
end

return DiggingService
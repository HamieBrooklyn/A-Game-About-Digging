local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataHandler = require(ServerScriptService.Server.DataHandler)

local Data = ReplicatedStorage.Source.Data
local Potions = require(Data.Potions)
local Types = require(Data.Types)

local Packages = ReplicatedStorage.Packages
local Janitor = require(Packages.Janitor)
local Knit = require(Packages.Knit)

local PotionService = Knit.CreateService { Name = "PotionService" }
type Self = typeof(PotionService)

function PotionService:UsePotion(player: Player, potionName: string, duration: number, ignoreSave: boolean?)
	local profile = DataHandler.Profiles[player]
	if not profile then
		local existingPotion = self.cachedPotions[player][potionName]
		if existingPotion then
			existingPotion += duration
		end
		self.cachedPotions[player][potionName] = duration
		return
	end
	
	local playerPotionsFold: Folder = player:WaitForChild("Potions")
	local existingPotionVal: NumberValue
	for _, potionVal: NumberValue in playerPotionsFold:GetChildren() do
		if potionVal.Name ~= potionName then
			continue
		end
		existingPotionVal = potionVal
		break
	end
	
	if existingPotionVal then
		existingPotionVal.Value += duration
	else
		local janitor = self.cachedJanitors[player]
		
		local potionVal: NumberValue = janitor:Add(Instance.new("NumberValue"))
		potionVal.Name = potionName
		potionVal.Value = duration
		potionVal.Parent = playerPotionsFold
		
		table.insert(self.cachedPotionValues[player], potionVal)
		
		janitor:Add(potionVal.Changed:Connect(function(value)
			if DataHandler.Profiles[player] then
				DataHandler.Profiles[player].Data.ActivePotions[potionName] = value
			end
		end))
		potionVal.Destroying:Once(function()
			if not DataHandler.Profiles[player] then
				return
			end
			DataHandler.Profiles[player].Data.ActivePotions[potionName] = nil
		end)
	end
	
	if ignoreSave then
		return
	end
	
	local existingPotion = profile.Data.ActivePotions[potionName]
	if existingPotion then
		profile.Data.ActivePotions[potionName] += duration
	else
		profile.Data.ActivePotions[potionName] = duration
	end
end

function PotionService:OnItemUsed(player: Player, category: string, itemData: Types.ItemData)
	if category ~= "Potions" then
		return
	end
	self:UsePotion(player, itemData.name, Potions[itemData.name].Duration)
end

function PotionService:OnPlayerDataLoaded(player: Player)
	local potions = Instance.new("Folder")
	potions.Name = "Potions"
	potions.Parent = player
	
	for potionName: string, duration: number in DataHandler.Profiles[player].Data.ActivePotions do
		self:UsePotion(player, potionName, duration, true)
	end
	for potionName: string, duration: number in self.cachedPotions[player] do
		self:UsePotion(player, potionName, duration)
	end
end

function PotionService:UpdatePotions()
	for _, vals in self.cachedPotionValues do
		for _, val: NumberValue in vals do
			val.Value -= 1
			if val.Value <= 0 then
				val:Destroy()
			end
		end
	end
end

function PotionService:KnitInit()
	self.cachedPotionValues = {}
	self.cachedJanitors = {}
	self.cachedPotions = {}
	Players.PlayerAdded:Connect(function(player)
		self.cachedPotionValues[player] = {}
		self.cachedJanitors[player] = Janitor.new()
		self.cachedPotions[player] = {}
	end)
	Players.PlayerRemoving:Connect(function(player)
		local janitor: Janitor.Janitor = self.cachedJanitors[player]
		janitor:Cleanup()
		janitor:Destroy()
		
		self.cachedPotions[player] = nil
		self.cachedPotionValues[player] = nil
	end)
	
	self.InventoryService = Knit.GetService("InventoryService")
	self.InventoryService.ItemUsed:Connect(function(player: Player, category: string, itemData: Types.ItemData)
		self:OnItemUsed(player, category, itemData)
	end)
	
	ServerScriptService.Server.DataLoaded.Event:Connect(function(player: Player)
		self:OnPlayerDataLoaded(player)
	end)
	
	task.spawn(function()
		while task.wait(1) do
			self:UpdatePotions()
		end
	end)
end

return PotionService
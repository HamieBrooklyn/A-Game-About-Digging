local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Types = require(ReplicatedStorage:WaitForChild("Source").Data.Types)

local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.Signal)
local Knit = require(Packages.Knit)

local DataHandler = require(ServerScriptService.Server.DataHandler)

local InventoryService = Knit.CreateService {
	Name = "InventoryService",
	Client = {
		InventoryLoaded = Knit.CreateSignal(),
		ItemAdded = Knit.CreateSignal(),
		ItemRemoved = Knit.CreateSignal(),
	},
}
InventoryService.ItemUsed = Signal.new()
InventoryService.ItemRemoved = Signal.new()

type Self = typeof(InventoryService)

function InventoryService.Client:UseItemAttempt(player: Player, category: string, itemName: string)
	return self.Server:UseItemAttempt(player, category, itemName)
end

function InventoryService:UseItemAttempt(player: Player, category: string, itemName: string)
	if not category or typeof(category) ~= "string" then
		return
	end
	if not itemName or typeof(itemName) ~= "string" then
		return
	end
	
	local playerProfile = DataHandler.Profiles[player]
	if not playerProfile then
		return
	end
	
	local inventory = playerProfile.Data.Inventory
	if not inventory[category] then
		return
	end
	if not inventory[category][itemName] then
		return
	end
	
	local item = inventory[category][itemName]
	item.amount -= 1
	
	self.ItemUsed:Fire(player, category, item)
	
	local newAmount = item.amount
	if newAmount <= 0 then
		inventory[category][itemName] = nil
		
		self.ItemRemoved:Fire(player, category, item)
		self.Client.ItemRemoved:Fire(player, category, item)
	end
	
	return newAmount
end

function InventoryService:OnPlayerDataLoaded(player: Player)
	for _, cachedItem in self.cachedItems[player] do
		self:GivePlayerItem(player, cachedItem.category, cachedItem.itemData)
	end
	self.Client.InventoryLoaded:Fire(player, DataHandler.Profiles[player].Data.Inventory)
end

function InventoryService:KnitInit()
	self.cachedItems = {}
	ServerScriptService.Server.DataLoaded.Event:Connect(function(player: Player)
		self:OnPlayerDataLoaded(player)
	end)
	
	Players.PlayerAdded:Connect(function(player)
		self.cachedItems[player] = {}
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.cachedItems[player] = nil
	end)
end

function InventoryService:GivePlayerItem(player: Player, category: string, itemData: Types.ItemData)
	if not DataHandler.Profiles[player] then
		table.insert(self.cachedItems[player], {
			category = category,
			itemData = itemData,
		})
		return
	end
	
	local playerInventory = DataHandler.Profiles[player].Data.Inventory
	
	local existingItem = playerInventory[category][itemData.name]
	if existingItem then
		existingItem.amount += itemData.amount
		self.Client.ItemAdded:Fire(player, category, itemData)
		return
	end
	
	playerInventory[category][itemData.name] = itemData
	self.Client.ItemAdded:Fire(player, category, itemData)
end

return InventoryService
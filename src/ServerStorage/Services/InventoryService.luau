local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Types = require(ReplicatedStorage:WaitForChild("Source").Data.Types)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local DataHandler = require(ServerScriptService.Server.DataHandler)

local InventoryService = Knit.CreateService {
	Name = "InventoryService",
	Client = {
		InventoryLoaded = Knit.CreateSignal(),
		ItemAdded = Knit.CreateSignal(),
	},
}
type Self = typeof(ControllerName)

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
		
		self:GivePlayerItem(player, "Potions", {
			name = "OrePotion",
			amount = 1,
		})
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.cachedItems[player] = nil
	end)
end

function InventoryService:GivePlayerItem(player: Player, category: string, itemData: Types.ItemData)
	print("Giving player item", player, category, itemData)
	if not player:GetAttribute("DataLoaded") then
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
		return
	end
	
	playerInventory[category][itemData.name] = itemData
	
	self.Client.ItemAdded:Fire(player, category, itemData)
end

return InventoryService
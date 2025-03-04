local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryTemplates = ReplicatedStorage:WaitForChild("Gui").Templates.Inventory
local Templates = script.Templates

local Types = require(ReplicatedStorage:WaitForChild("Source").Data.Types)

local Packages = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

local peek = Fusion.peek

local InventoryController = Knit.CreateController { Name = "InventoryController" }
type Self = typeof(InventoryController)

function InventoryController:OnItemAdded(category: string, itemData: Types.ItemData)
	local categoriesFold = self.inventoryMenu.Categories
	
	local cateogoryContainer = categoriesFold:FindFirstChild(category)
	if not cateogoryContainer then
		cateogoryContainer = categoriesFold:FindFirstChild("Misc")
	end
	
	local existingItem = self.inventory[category][itemData.name]
	if existingItem then
		existingItem.amount:set(peek(existingItem.amount) + itemData.amount)
		return
	end
	
	require(Templates:FindFirstChild(category)).new(InventoryTemplates:FindFirstChild(category):Clone(), cateogoryContainer)
end

function InventoryController:OnInventoryLoaded(newInventory: {[string]: {[string]: Types.ItemData}})
	for category, items in pairs(newInventory) do
		for _, itemData in pairs(items) do
			self:OnItemAdded(category, itemData)
		end
	end
end

function InventoryController:KnitInit()
	self.service = Knit.GetService("InventoryService")
	
	self.scope = Fusion:scoped()
	
	self.player = Players.LocalPlayer
	self.playerGui = self.player:WaitForChild("PlayerGui")
	self.mainGui = self.playerGui:WaitForChild("Main")
	self.inventoryMenu = self.mainGui.Menus.Inventory
	
	self.inventory = {} :: {[string]: {[string]: Types.ItemDataState}}
	
	self.service.ItemAdded:Connect(function(category: string, itemData: Types.ItemData)
		self:OnItemAdded(category, itemData)
	end)
end

return InventoryController
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryTemplates = ReplicatedStorage:WaitForChild("Gui").Templates.Inventory

local Types = require(ReplicatedStorage:WaitForChild("Source").Data.Types)

local Packages = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)
local Signal = require(Packages.Signal)
local Knit = require(Packages.Knit)

local peek = Fusion.peek

local InventoryController = Knit.CreateController { Name = "InventoryController" }
type Self = typeof(InventoryController)

function InventoryController:ManageItemTemplate(category: string, itemState: Types.ItemDataState)
	local categoriesFold = self.inventoryMenu.Categories
	local categoryContainer = categoriesFold:FindFirstChild(category)
	if not categoryContainer then
		categoryContainer = categoriesFold:FindFirstChild("Misc")
	end
	
	local itemScope = Fusion:scoped()
	
	local temp = InventoryTemplates:FindFirstChild(category):Clone()
	
	local quantityLabel: TextLabel? = temp:FindFirstChild("Quantity", true)
	if quantityLabel then
		itemScope:Hydrate(quantityLabel) {
			Text = itemScope:Computed(function(use)
				return use(itemState.amount).. "X"
			end),
			Visible = itemScope:Computed(function(use)
				return use(itemState.amount) > 0
			end),
		}
	end
	
	local interact: GuiButton? = temp:FindFirstChild("Interact", true)
	if interact then
		interact.MouseButton1Click:Connect(function()
			self.service:UseItemAttempt(category, itemState.name):andThen(function(newAmount: number?)
				if not newAmount then
					return
				end
				itemState.amount:set(newAmount)
				
				self.itemUsed:Fire(category, itemState)
			end)
		end)
	end
	
	temp.Parent = categoryContainer
end

function InventoryController:OnItemAdded(category: string, itemData: Types.ItemData)
	local existingItem = self.inventory[category][itemData.name]
	if existingItem then
		existingItem.amount:set(peek(existingItem.amount) + itemData.amount)
		return
	end
	
	self.inventory[category][itemData.name] = {
		name = itemData.name,
		amount = self.scope:Value(itemData.amount),
	} :: Types.ItemDataState
	
	self:ManageItemTemplate(category, self.inventory[category][itemData.name])
end

function InventoryController:OnInventoryLoaded(newInventory: {[string]: {[string]: Types.ItemData}})
	for category, items in pairs(newInventory) do
		for _, itemData in pairs(items) do
			self:OnItemAdded(category, itemData)
		end
	end
end

function InventoryController:KnitInit()
	self.itemUsed = Signal.new()
	
	self.service = Knit.GetService("InventoryService")
	
	self.scope = Fusion:scoped()
	
	self.player = Players.LocalPlayer
	self.playerGui = self.player:WaitForChild("PlayerGui")
	self.mainGui = self.playerGui:WaitForChild("Main")
	self.inventoryMenu = self.mainGui.Menus.Inventory.Menu
	
	self.inventory = {
		Potions = {},
	} :: {[string]: {[string]: Types.ItemDataState}}
	
	self.service.ItemAdded:Connect(function(category: string, itemData: Types.ItemData)
		self:OnItemAdded(category, itemData)
	end)
end

return InventoryController
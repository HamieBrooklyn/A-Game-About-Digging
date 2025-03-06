local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local InventoryTemplates = ReplicatedStorage:WaitForChild("Gui").Templates.Inventory
local UseSounds = SoundService.UseSounds

local Source = ReplicatedStorage:WaitForChild("Source")

local Data = Source.Data
local Potions = require(Data.Potions)
local Types = require(Data.Types)

local Sound = require(Source.Classes.Sound)

local Packages = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)
local Signal = require(Packages.Signal)
local Knit = require(Packages.Knit)

local peek = Fusion.peek

local InventoryController = Knit.CreateController { Name = "InventoryController" }
type Self = typeof(InventoryController)

InventoryController.ItemUsed = Signal.new()

function InventoryController:OnItemUsed(category: string, itemState: Types.ItemDataState)
	self.ItemUsed:Fire(category, itemState)
	
	local sounds = UseSounds:FindFirstChild(category)
	if sounds then
		sounds = sounds:GetChildren()
		Sound.new(sounds[math.random(1, #sounds)])
	end
end

function InventoryController:ManageItemTemplate(category: string, itemState: Types.ItemDataState)
	local categoriesFold = self.inventoryMenu.Categories
	local categoryContainer = categoriesFold:FindFirstChild(category)
	if not categoryContainer then
		categoryContainer = categoriesFold:FindFirstChild("Misc")
	end
	
	local itemScope = self.cachedScopes[itemState.name]
	
	local temp = InventoryTemplates:FindFirstChild(category):Clone()
	table.insert(itemScope, temp)
	
	local icon: ImageLabel? = temp:FindFirstChild("Icon", true)
	if icon then
		if category == "Potions" then
			print(itemState.name, Potions[itemState.name])
			icon.Image = Potions[itemState.name].Icon
		end
	end
	
	local quantityLabel: TextLabel? = temp:FindFirstChild("Quantity", true)
	if quantityLabel then
		itemScope:Hydrate(quantityLabel) {
			Text = itemScope:Computed(function(use)
				return use(itemState.amount).. "X"
			end),
			Visible = itemScope:Computed(function(use)
				return use(itemState.amount) > 1
			end),
		}
	end
	
	local interact: GuiButton? = temp:FindFirstChild("Interact", true)
	if interact then
		table.insert(itemScope, interact.MouseButton1Click:Connect(function()
			self.service:UseItemAttempt(category, itemState.name):andThen(function(newAmount: number?)
				if not newAmount then
					return
				end
				itemState.amount:set(newAmount)
				
				self:OnItemUsed(category, itemState)
			end)
		end))
		table.insert(itemScope, interact.MouseEnter:Connect(function()
			if category == "Potions" then
				local potionData = Potions[itemState.name]
				self.informationWindow.SetInfo:Fire(potionData.InfoWindow)
			end
		end))
		table.insert(itemScope, interact.MouseLeave:Connect(function()
			self.informationWindow.Cleanup:Fire()
		end))
	end
	
	temp.Parent = categoryContainer
end

function InventoryController:OnItemAdded(category: string, itemData: Types.ItemData)
	local existingItem = self.inventory[category][itemData.name]
	if existingItem then
		existingItem.amount:set(peek(existingItem.amount) + itemData.amount)
		return
	end
	
	local itemScope = Fusion:scoped()
	self.cachedScopes[itemData.name] = itemScope
	
	self.inventory[category][itemData.name] = {
		name = itemData.name,
		amount = itemScope:Value(itemData.amount),
	} :: Types.ItemDataState
	
	self:ManageItemTemplate(category, self.inventory[category][itemData.name])
end

function InventoryController:OnItemRemoved(category: string, itemData: Types.ItemData)
	self.inventory[category][itemData.name] = nil
	
	self.cachedScopes[itemData.name]:doCleanup()
	self.cachedScopes[itemData.name] = nil
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
	
	self.cachedScopes = {}
	
	self.player = Players.LocalPlayer
	self.playerGui = self.player:WaitForChild("PlayerGui")
	self.mainGui = self.playerGui:WaitForChild("Main")
	self.inventoryMenu = self.mainGui.Menus.Inventory.Menu
	self.informationWindow = self.mainGui.InformationWindow
	
	self.inventory = {
		Potions = {},
	} :: {[string]: {[string]: Types.ItemDataState}}
	
	self.service.InventoryLoaded:Connect(function(newInventory)
		self:OnInventoryLoaded(newInventory)
	end)
	
	self.service.ItemAdded:Connect(function(category: string, itemData: Types.ItemData)
		self:OnItemAdded(category, itemData)
	end)
	self.service.ItemRemoved:Connect(function(category: string, itemData: Types.ItemData)
		self:OnItemRemoved(category, itemData)
	end)
end

return InventoryController
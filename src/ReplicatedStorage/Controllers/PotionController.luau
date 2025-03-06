local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = ReplicatedStorage:WaitForChild("Source").Data
local Potions = require(Data.Potions)
local Types = require(Data.Types)

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)
local Knit = require(Packages.Knit)

local MessageHandler = require(ReplicatedStorage:WaitForChild("MessageHandler"))

local formatDigitalTime = require(ReplicatedStorage:WaitForChild("formatDigitalTime"))

local PotionController = Knit.CreateController { Name = "PotionController" }
type Self = typeof(PotionController)

local potionTemplate = ReplicatedStorage.Gui.Templates.Potion

function PotionController:OnPotionUsed(potionName: string)
	local potionData = Potions[potionName]
	MessageHandler.NewMessage(potionData.UseText, potionData.UseGradient)
end

function PotionController:OnPotionRunOut(potionName: string)
	local potionData = Potions[potionName]
	MessageHandler.NewMessage(potionData.RunOutText, potionData.RunOutGradient)
end

function PotionController:OnPotionAdded(potionVal: NumberValue)
	if self.potionsContainer:FindFirstChild(potionVal.Name) then
		return
	end
	
	local janitor = Janitor.new()
	
	local potionData = Potions[potionVal.Name]
	
	local newTemp: Frame = janitor:Add(potionTemplate:Clone())
	newTemp.Name = potionVal.Name
	newTemp:FindFirstChild("Icon").Image = potionData.Icon
	newTemp.Parent = self.potionsContainer
	
	local interact: GuiButton = newTemp.Interact
	interact:AddTag("Info")
	
	local infoWindowData = potionData.InfoWindow
	if infoWindowData then
		local gradients = ""
		local texts = ""
		for _, data in infoWindowData do
			if data.gradient then
				gradients = gradients == "" and data.gradient or gradients.. ",".. data.gradient
			end
			if data.text then
				texts = texts == "" and data.text or texts.. ",".. data.text
			end
		end
		interact:SetAttribute("Gradients", gradients)
		interact:SetAttribute("Texts", texts)
	end
	
	local function setDuration(duration: number)
		newTemp:FindFirstChild("Duration").Text = formatDigitalTime(duration)
	end
	janitor:Add(potionVal.Changed:Connect(function(value)
		setDuration(value)
	end))
	setDuration(potionVal.Value)
	
	self.cachedJanitors[potionVal.Name] = janitor
end

function PotionController:OnPotionRemoved(potionVal: NumberValue)
	self:OnPotionRunOut(potionVal.Name)
	
	local janitor: Janitor.Janitor = self.cachedJanitors[potionVal.Name]
	if not janitor then
		return
	end
	janitor:Cleanup()
	
	self.cachedJanitors[potionVal.Name] = nil
end

function PotionController:KnitInit()
	self.cachedJanitors = {}
	
	self.player = Players.LocalPlayer
	
	self.playerGui = self.player:WaitForChild("PlayerGui")
	self.mainGui = self.playerGui:WaitForChild("Main")
	self.potionsContainer = self.mainGui.Sides.Bottom.Potions
	self.informationWindow = self.mainGui.InformationWindow
	
	self.playerPotions = self.player:WaitForChild("Potions") :: Folder
	self.playerPotions.ChildAdded:Connect(function(child)
		self:OnPotionAdded(child)
	end)
	for _, potionVal in self.playerPotions:GetChildren() do
		self:OnPotionAdded(potionVal)
	end
	self.playerPotions.ChildRemoved:Connect(function(child)
		self:OnPotionRemoved(child)
	end)
	
	self.InventoryController = Knit.GetController("InventoryController")
	self.InventoryController.ItemUsed:Connect(function(category: string, itemState: Types.ItemDataState)
		if category ~= "Potions" then
			return
		end
		self:OnPotionUsed(itemState.name)
	end)
end

return PotionController
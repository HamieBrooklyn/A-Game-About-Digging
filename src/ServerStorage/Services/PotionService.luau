local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local InventoryService = require(ServerStorage.Source.Services.InventoryService)

local Types = require(ReplicatedStorage.Source.Data.Types)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local PotionService = Knit.CreateService { Name = "PotionService" }
type Self = typeof(PotionService)

function PotionService:OnItemUsed(player: Player, category: string, itemData: Types.ItemData)
	if category ~= "Potions" then
		return
	end
	print(player, category, itemData)
end

function PotionService:KnitInit()
	print(InventoryService)
	InventoryService.itemUsed:Connect(function(player: Player, category: string, itemData: Types.ItemData)
		self:OnItemUsed(player, category, itemData)
	end)
end

return PotionService
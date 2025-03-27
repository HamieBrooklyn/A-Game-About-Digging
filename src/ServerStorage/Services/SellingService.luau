-- Services --
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Selling = require(ReplicatedStorage.Source.Data.Stats.Selling)

local ZonePlus = require(Packages.ZonePlus)
local Knit = require(Packages.Knit)

-- Service --
local SellingService = Knit.CreateService {
	Name = "SellingService",
	Client = {
		Sold = Knit.CreateSignal(),
	},
}

-- Types --
type Self = typeof(SellingService)

function SellingService:ManageAddedSellModel(sellModel: Model)
	local function getValueFromPath(player: Player, path: string)
		local value: NumberValue = player
		local pathTable = string.split(path, "/")
		for i, waypoint in pathTable do
			value = value:FindFirstChild(waypoint)
			if not value then
				return
			end
			if i == #pathTable then
				break
			end
		end
		return value
	end
	
	ZonePlus.new(sellModel).playerEntered:Connect(function(player: Player)
		local inputVal: NumberValue? = getValueFromPath(player, sellModel:GetAttribute("InputStat"))
		if not inputVal then
			return
		end
		local outputVal: NumberValue? = getValueFromPath(player, sellModel:GetAttribute("OutputStat"))
		if not outputVal then
			return
		end
		if inputVal.Value <= 0 then
			return
		end
		
		local give = inputVal.Value * sellModel:GetAttribute("Multiplier")
		outputVal.Value += give
		inputVal.Value = 0
		
		for _, otherPlayer in Players:GetPlayers() do
			self.Client.Sold:Fire(otherPlayer, player, outputVal.Name, give)
		end
	end)
end

function SellingService:KnitInit()
	local tag = Selling.TAG
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(sellModel)
		self:ManageAddedSellModel(sellModel)
	end)
	for _, sellModel in CollectionService:GetTagged(tag) do
		self:ManageAddedSellModel(sellModel)
	end
end

return SellingService
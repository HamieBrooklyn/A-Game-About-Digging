-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Moduoles --
local Currency = require(ReplicatedStorage.Source.Data.Currency)

local Knit = require(Packages.Knit)

-- Controller
local SellingController = Knit.CreateController { Name = "SellingController" }

-- Types --
type Self = typeof(SellingController)

function SellingController:ManageOnSold(outputStatName: string, amount: number)
	self.PopupController:SendIcons({
		[Currency.PopupIcons[outputStatName]] = math.clamp(amount, 1, 50),
	}, Players.LocalPlayer.PlayerGui:WaitForChild("Main").Sides.Left.Coins.Position)
end

function SellingController:KnitInit()
	self.PopupController = Knit.GetController("PopupController")
	
	local SellingService = Knit.GetService("SellingService")
	SellingService.Sold:Connect(function(...)
		self:ManageOnSold(...)
	end)
end

return SellingController
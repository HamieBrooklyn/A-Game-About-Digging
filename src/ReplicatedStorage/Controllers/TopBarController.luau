-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

-- Controller
local TopBarController = Knit.CreateController { Name = "TopBarController" }

-- Types --
type Self = typeof(TopBarController)

function TopBarController:KnitInit()
	local Icon = require(Packages.TopbarPlus)
	
	local musicIcon;
	musicIcon = Icon.new()
		:setLabel()
		:bindEvent("selected", function()
			
		end)
		:oneClick()
end

return TopBarController
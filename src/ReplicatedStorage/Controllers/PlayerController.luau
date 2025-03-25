-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

local canTeleporToTop = require(ReplicatedStorage.Source.Utils.SharedConditions.canTeleporToTop)

-- Controller
local PlayerController = Knit.CreateController { Name = "PlayerController" }

-- Types --
type Self = typeof(PlayerController)

function PlayerController:TeleportToTopAttempt(player: Player, worldIndex: number)
	if not canTeleporToTop(player) then
		return
	end
	return self.PlayerService:TeleportToTopAttempt(worldIndex)
end

function PlayerController:KnitInit()
	self.PlayerService = Knit.GetService("PlayerService")
end

return PlayerController
-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Moduoles --
local Knit = require(Packages.Knit)

-- Controller
local PlayerController = Knit.CreateController { Name = "PlayerController" }

-- Types --
type Self = typeof(PlayerController)

function PlayerController:TeleportPlayerToWorldAttempt(player: Player, worldIndex: number)
	
end

function PlayerController:KnitInit()end

return PlayerController
-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

-- Service --
local PlayerService = Knit.CreateService { Name = "PlayerService" }

-- Types --
type Self = typeof(PlayerService)

function PlayerService.Client:TeleportToWorldAttempt(player: Player, worldIndex: number)
	if not worldIndex or typeof() ~= "number" then
		return
	end
	return self.Server:TeleportToWorldAttempt(player, worldIndex)
end

function PlayerService:TeleportToWorldAttempt(player: Player, worldIndex: number)
	
end

function PlayerService:KnitInit()end

return PlayerService
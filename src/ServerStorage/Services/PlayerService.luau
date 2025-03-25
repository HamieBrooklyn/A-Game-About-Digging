-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Utils = ReplicatedStorage.Source.Utils
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

local worldPosititonFromIndex = require(Utils.Worlds.worldPosititonFromIndex)
local canTeleporToTop = require(Utils.SharedConditions.canTeleporToTop)

-- Service --
local PlayerService = Knit.CreateService { Name = "PlayerService" }

-- Types --
type Self = typeof(PlayerService)

function PlayerService.Client:TeleportToTopAttempt(player: Player, worldIndex: number)
	if not worldIndex or typeof(worldIndex) ~= "number" then
		return
	end
	return self.Server:TeleportToTopAttempt(player, worldIndex)
end

function PlayerService:TeleportToTopAttempt(player: Player, worldIndex: number)
	local canTeleport = canTeleporToTop(player)
	if not canTeleport then
		return
	end
	
	self:TeleportPlayerToWorld(player, player.Data.CurrentWorld.Value)
	
	return true
end

function PlayerService:TeleportPlayerToWorld(player: Player, worldIndex: number)
	local char = player.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hum or hum.Health <= 0 then
		return
	end
	char:PivotTo(CFrame.new(worldPosititonFromIndex(worldIndex)))
end

function PlayerService:KnitInit()end

return PlayerService
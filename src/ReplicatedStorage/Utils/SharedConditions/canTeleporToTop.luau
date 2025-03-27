-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local Digging = require(ReplicatedStorage.Source.Data.Player.Digging)

local playerWorldDepth = require(ReplicatedStorage.Source.Utils.Worlds.playerWorldDepth)

local function canTeleporToTop(player: Player)
	local playerData = player:FindFirstChild("Data")
	if not playerData then
		return
	end
	
	local char = player.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hum or hum.Health <= 0 then
		return
	end
	
	local depth: number? = playerWorldDepth(player)
	if not depth then
		return
	end
	if depth < Digging.MIN_DEPTH_TELEPORT then
		return
	end
	
	return true, char
end

return canTeleporToTop
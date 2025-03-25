-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Modules --
local worldPositionFromIndex = require(ReplicatedStorage.Source.Utils.Worlds.worldPosititonFromIndex)

local function playerWorldDepth(player: Player)
	local dataFold: Folder? = player:FindFirstChild("Data")
	if not dataFold then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	
	local currentWorld: number = dataFold.CurrentWorld.Value
	local pos = worldPositionFromIndex(currentWorld)
	
	local diff = (char:GetPivot().Position.Y - pos.Y)
	return math.floor(math.max(-diff, 0))
end

return playerWorldDepth
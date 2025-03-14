-- Modules --
local ObjectSpawning = require(script.Parent)

local function onPlayerDug(player: Player, shovel: Tool, digPosition: Vector3)
	local spawnPoints = ObjectSpawning.playerSpawnPoints[player]
	if not spawnPoints then
		return
	end
	for category, levels in spawnPoints do
		print(category, levels)
	end
end
return onPlayerDug
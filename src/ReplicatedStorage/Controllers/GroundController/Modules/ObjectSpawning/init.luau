-- Variables --
local spawnPoints = {}

local ObjectSpawning = {}

local function onSpawningPointsLoaded(loadedSpawnPoints: {
	[string]: {
		[number]: {
			[number]: {
				name: string,
				position: Vector3,

				levelPartIndex: number,
			}
		}
	}
})
	spawnPoints = loadedSpawnPoints
end

ObjectSpawning.init = function()
	ObjectSpawning.controller = require(script.Parent.Parent)

	ObjectSpawning.controller.service.SpawningPointsLoaded:Connect(onSpawningPointsLoaded)
end

return ObjectSpawning
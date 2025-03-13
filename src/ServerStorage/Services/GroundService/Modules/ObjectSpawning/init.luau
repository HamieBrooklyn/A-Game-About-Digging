-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Containers --
local Ores = script.Ores

-- Utils --
local getOreData = require(Ores.getOreData)

-- Handlers --
local DataHandler = require(ServerScriptService.Server.DataHandler)

-- Module --
local ObjectSpawning = {}

ObjectSpawning.ores = getOreData()

ObjectSpawning.generatePointsFromPart = require(script.generatePointsFromPart)

local function sendNewPoints(player: Player, points: {
    [string]: {
            [number]: { name: string, position: Vector3 }
        }
    }
)
    
end


ObjectSpawning.init = function()
    ObjectSpawning.service = require(script.Parent.Parent) 
    
	ObjectSpawning.generateOrePoints = require(Ores.generateOrePoints)
end

ObjectSpawning.onPlayerDataLoaded = function(player: Player)
    local spawnPoints = {}
    spawnPoints["Ores"] = ObjectSpawning.generateOrePoints(player)
    print(spawnPoints   )
end

ObjectSpawning.onPlayerAdded = function(_player: Player)
	
end

ObjectSpawning.onPlayerRemoving = function(_player: Player)
	
end

return ObjectSpawning
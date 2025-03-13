-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Handlers --
local DataHandler = require(ServerScriptService.Server.DataHandler)

-- Utils --
local generatePointsFromPart = require(script.generatePointsFromPart)
local getOreData = require(script.getOreData)

-- Module --
local ObjectSpawning = {}

local function sendNewPoints(player: Player, points: {
    [string]: {
            [number]: { name: string, position: Vector3 }
        }
    }
)
    
end

ObjectSpawning.init = function()
	
end

ObjectSpawning.onPlayerDataLoaded = function(player: Player)
	getOreData()
end

ObjectSpawning.onPlayerAdded = function(_player: Player)
	
end

ObjectSpawning.onPlayerRemoving = function(_player: Player)
	
end

return ObjectSpawning
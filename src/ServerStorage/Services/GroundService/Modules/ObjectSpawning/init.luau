-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Containers --
local Ores = script.Ores

-- Utils --
local isInBrick = require(ReplicatedStorage.Source.Utils.isInBrick)
local getOreData = require(Ores.getOreData)

-- Handlers --
local DataHandler = require(ServerScriptService.Server.DataHandler)

-- Events --
local Dug = ReplicatedStorage.Events.Bindable.Dug

-- Module --
local ObjectSpawning = {}

ObjectSpawning.ores = getOreData()

ObjectSpawning.getSpawnsFromChance = require(script.getSpawnsFromChance)

ObjectSpawning.init = function()
	ObjectSpawning.service = require(script.Parent.Parent) 
	
	ObjectSpawning.generateOrePoints = require(Ores.generateOrePoints)
	ObjectSpawning.onPlayerDug = require(script.onPlayerDug)
	
	ObjectSpawning.playerSpawnPoints = {}
	
	Dug.Event:Connect(ObjectSpawning.onPlayerDug)
end

ObjectSpawning.onPlayerDataLoaded = function(player: Player)
	if not ObjectSpawning.playerSpawnPoints[player] then
		return
	end
	
	local spawnPoints = {}
	spawnPoints["Ores"] = ObjectSpawning.generateOrePoints(player)
	
	ObjectSpawning.playerSpawnPoints[player] = spawnPoints
	
	ObjectSpawning.service.Client.SpawningPointsLoaded:Fire(player, spawnPoints)
end

ObjectSpawning.onPlayerAdded = function(player: Player)
	ObjectSpawning.playerSpawnPoints[player] = {}
end

ObjectSpawning.onPlayerRemoving = function(player: Player)
	ObjectSpawning.playerSpawnPoints[player] = nil
end

return ObjectSpawning
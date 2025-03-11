-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Containers --
local Worlds = workspace.Worlds

-- Scripts --
local Server = ServerScriptService.Server

-- Handlers --
local DataHandler = require(Server.DataHandler)

-- Packages --
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Knit --
local GroundService = Knit.GetService("GroundService")

-- Local --
local playersData = {}

local dataLoaded = Server.DataLoaded

-- Module --
local RichTerrain = {}

-- Functions --
function isInsideBrick(position, brick)
	local v3 = brick.CFrame:PointToObjectSpace(position)
	return (math.abs(v3.X) <= brick.Size.X / 2)
		and (math.abs(v3.Y) <= brick.Size.Y / 2)
		and (math.abs(v3.Z) <= brick.Size.Z / 2)
end

local function generateRichTerrainPointsOnPart(player: Player, part: BasePart)
	local seed = DataHandler.Profiles[player].Data.RichTerrainSeed
	print(seed)
	local rnd = Random.new(seed)

	local minClusters = 10
	local maxClusters = 50

	local minOffset = -4
	local maxOffset = 4

	local minRadius = 1
	local maxRadius = 4

	local cluster = {}

	local position = part.CFrame.Position
	for i=1, rnd:NextInteger(minClusters, maxClusters) do
		local radius = rnd:NextInteger(minRadius, maxRadius)
		table.insert(cluster, {
			position = {X = position.X, Y = position.Y, Z = position.Z},
			radius = radius,
		})

		local nextPos = nil
		repeat
			nextPos = position + Vector3.new(
				rnd:NextInteger(minOffset, maxOffset),
				rnd:NextInteger(minOffset, maxOffset),
				rnd:NextInteger(minOffset, maxOffset)
			)
			task.wait()
		until isInsideBrick(nextPos, part)
		
		position = nextPos
	end

	local playerData = playersData[player]
	if playerData then
		table.insert(playerData.cachedClusters, cluster)
	end
end

local function onPlayerDataLoaded(player: Player)
	local cachedClusters = playersData[player].cachedClusters
	if #cachedClusters == 0 then
		for _, worldFold in Worlds:GetChildren() do
			for _, terrainPart in worldFold.TerrainParts:GetChildren() do
				--generateRichTerrainPointsOnPart(player, terrainPart)
			end
		end
	end
	generateRichTerrainPointsOnPart(player, workspace.RichTerrainSpawn)
	GroundService.Client.RichTerrainPointsLoaded:Fire(player, cachedClusters)
end

local function onPlayedAdded(player: Player)
	playersData[player] = {
		cachedClusters = {}
	}
end

local function onPlayerRemoving(player: Player)
	playersData[player] = nil
end

-- Init --
RichTerrain.init = function()
	dataLoaded.Event:Connect(onPlayerDataLoaded)

	Players.PlayerAdded:Connect(onPlayedAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return RichTerrain
-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages --
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Knit --
local GroundService = Knit.GetService("GroundService")

-- Utils --
local generateCluster = require(script.generateCluster)

-- Module --
local RichTerrain = {}

-- Functions --
local function onRichTerrainPointsLoaded(clusters: {[number]: {position: Vector3, radius: number}})
	print(clusters)
end

-- Init --
RichTerrain.init = function()
	GroundService.RichTerrainPointsLoaded:Connect(onRichTerrainPointsLoaded)
end

return RichTerrain
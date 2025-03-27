-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Types = require(ReplicatedStorage.Source.Data.Types)

local Knit = require(Packages.Knit)

-- Controller
local SpawningController = Knit.CreateController { Name = "SpawningController" }

-- Types --
type Self = typeof(SpawningController)

-- Local --
local currentSpawns: { [number]: { [number]: { Types.TerrainSpawn } } } = {}

-- function SpawningController:Update(spawns: )
-- 	for worldIndex, levelIndexes in spawns do
		
-- 	end
-- end



function SpawningController:KnitInit()
	local SpawningService = Knit.GetService("SpawningService")
	SpawningService.CurrentSpawns:Observe(function(newSpawns)
		currentSpawns = newSpawns
	end)
	
	
end

return SpawningController
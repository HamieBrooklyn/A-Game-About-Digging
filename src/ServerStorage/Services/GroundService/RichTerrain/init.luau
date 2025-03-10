-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages --
local Knit = require(ReplicatedStorage.Packages.Knit)

local GroundService = Knit.GetService("GroundService")

-- Local --
--local dug = ReplicatedStorage.Events.Bindable.Dug

local playersData = {}

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
	local amountOfClusters = 100

	local minOffset = -2
	local maxOffset = 2

	local minRadius = 1
	local maxRadius = 4

	local points = {}

	local position = part.CFrame.Position
	for i=1, amountOfClusters do
		local radius = math.random(minRadius, maxRadius)
		
		table.insert(points, {
			position = position,
			radius = radius,
		})

		local nextPos = nil
		repeat
			nextPos = position + Vector3.new(
				math.random(minOffset, maxOffset),
				math.random(minOffset, maxOffset),
				math.random(minOffset, maxOffset)
			)
			task.wait()
		until isInsideBrick(nextPos, part)
		
		position = nextPos
	end

	table.insert(playersData[player].cachedClusters, points)
end

local function onPlayerAdded(player: Player)
	print(1)
	playersData[player] = {
		cachedClusters = {},
	}
	print(2)
	generateRichTerrainPointsOnPart(player, workspace.RichTerrainTest)
	print(3)
	GroundService.Client.RichTerrainPointsLoaded:Fire(player, playersData[player].cachedClusters)
end

local function onPlayerRemoving(player: Player)
	playersData[player] = nil
end

-- local function onDug(player: Player)
	
-- end

-- Init --
RichTerrain.init = function()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	--dug.Event:Connect(onDug)
end

return RichTerrain
-- Services --
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Containers --
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Packages --
local Janitor = require(Packages.Janitor)
local Knit = require(Packages.Knit)

-- Knit --
local GroundService = Knit.GetService("GroundService")

-- Utils --
local generateCluster = require(script.generateCluster)

-- Module --
local RichTerrain = {}

-- Variables --
local clusterRenderDistance = 25

local player = Players.LocalPlayer

local hum: Humanoid?

local clusterJanitor = Janitor.new()
local clusters: {
	[Model]: {
		points: {
			[number]: {
				isGenerated: boolean,
				
				position: Vector3,
				radius: number,
			}
		}
	}
} = {}

-- Functions --
local function cleanupCachedClusters()
	clusterJanitor:Cleanup()
	clusters = {}
end

local function onRichTerrainPointsLoaded(loadedClusters: {
	[number]: { [number]: {position: Vector3, radius: number} }
})
	cleanupCachedClusters()
	
	local newClusters = {}
	for _, cluster in loadedClusters do
		local container = clusterJanitor:Add(Instance.new("Model"))
		container.Name = "RichTerrain"
		container.Parent = workspace
		container:AddTag("Highlighted")

		local points = {}
		for _, point in cluster do
			local pos = point.position
			table.insert(points, {
				isGenerated = false,
				
				position = Vector3.new(pos.X, pos.Y, pos.Z),
				radius = point.radius,
			})
		end
		
		newClusters[container] = {
			points = points,
		}
	end
	clusters = newClusters
end

local function onCharacterAdded(char: Model)
	hum = char:FindFirstChildWhichIsA("Humanoid")
end

local function onHeartbeat()
	local char = player.Character
	if not char or not hum or hum.Health <= 0 then
		return
	end

	local takenPositions: { [Vector3]: Part } = {}
	for container, data in clusters do
		for _, point in data.points do
			local canRender = (point.position - char:GetPivot().Position).Magnitude < clusterRenderDistance
			local isGenerated = point.isGenerated
			if canRender and not isGenerated then
				point.isGenerated = true
				generateCluster(container, point.position, point.radius, takenPositions)
			elseif not canRender and isGenerated then
				point.isGenerated = false
				
				local part = takenPositions[point.position]
				if part then
					part:Destroy()
					takenPositions[point.position] = nil
				end
			end
		end
		--[[
		for _, point in points do
			local isWithinRange = (point.position - char:GetPivot().Position).Magnitude < renderClusterPointDistance
			local isGenerated = point.isGenerated
			if not isGenerated and isWithinRange then
				point.isGenerated = true
				
				generateCluster(container, point.position, point.radius, takenPositions)
			elseif isGenerated and not isWithinRange then
				point.isGenerated = false

				local part = takenPositions[point.position]
				if part then
					takenPositions[point.position] = nil
					part:Destroy()
				end
			end
		end
		]]
	end
end

-- Init --
RichTerrain.init = function()
	GroundService.RichTerrainPointsLoaded:Connect(onRichTerrainPointsLoaded)
	RunService.Heartbeat:Connect(onHeartbeat)

	player.CharacterAdded:Connect(onCharacterAdded)
	local char = player.Character
	if char then
		onCharacterAdded(char)
	end
end

return RichTerrain
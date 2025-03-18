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
local clusterRenderDistance = 50

local player = Players.LocalPlayer

local hum: Humanoid?

local pointContainers: { [Model]: Vector3 } = {}
local clusterJanitor = Janitor.new()
local clusters: {
	[Model]: {
		pointsGenerated: number,
		points: {
			[number]: {
				isGenerated: boolean,
				container: Model,
				
				position: Vector3,
				radius: number,
			}
		}
	}
} = {}

local clustersFolder = Instance.new("Folder")
clustersFolder.Name = "RichTerrainClusters"
clustersFolder.Parent = workspace

-- Functions --
local function cleanupCachedClusters()
	pointContainers = {}
	clusters = {}
	clusterJanitor:Cleanup()
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
		container:SetAttribute("IgnoreDistance", true)
		container.Parent = clustersFolder

		local points = {}
		for _, point in cluster do
			local posData = point.position
			local pos = Vector3.new(posData.X, posData.Y, posData.Z)

			local pointContainer = Instance.new("Model")
			pointContainer.Name = "Point"
			pointContainer:PivotTo(CFrame.new(pos))
			pointContainer.Parent = container
			pointContainers[pointContainer] = pos
			
			table.insert(points, {
				isGenerated = false,
				container = pointContainer,
				
				position = pos,
				radius = point.radius,
			})
		end
		
		newClusters[container] = {
			pointsGenerated = 0,
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
	
	for mainContainer, data in clusters do
		for _, point in data.points do
			local canRender = (point.container:GetPivot().Position - char:GetPivot().Position).Magnitude < clusterRenderDistance
			local isGenerated = point.isGenerated
			if canRender and not isGenerated then
				point.isGenerated = true
				data.pointsGenerated += 1
				generateCluster(point.container, point.position, point.radius, takenPositions)
			elseif not canRender and isGenerated then
				point.isGenerated = false
				data.pointsGenerated -= 1
				point.container:ClearAllChildren()
			end
		end
		
		local highlighted = mainContainer:GetAttribute("Highlighted")
		local canHighlight = data.pointsGenerated > 0
		if not highlighted and canHighlight then
			mainContainer:SetAttribute("Highlighted", true)
		elseif highlighted and not canHighlight then
			mainContainer:SetAttribute("Highlighted", false)
		end
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
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
local renderClusterPointDistance = 100

local player = Players.LocalPlayer

local hum: Humanoid?

local clusterJanitor = Janitor.new()
local clusterPoints: {
	[number]: {
		mainContainer: Model,

		isGenerated: boolean?,
		position: Vector3,
		radius: number,
	}
} = {}

-- Functions --
local function cleanupCachedClusters()
	clusterJanitor:Cleanup()
	clusterPoints = {}
end

local function onRichTerrainPointsLoaded(loadedClusters: {
	[number]: { [number]: {position: Vector3, radius: number} }
})
	cleanupCachedClusters()
	
	local newClusterPoints = {}
	for _, cluster in loadedClusters do
		local container = clusterJanitor:Add(Instance.new("Model"))
		container.Parent = workspace
		container:AddTag("Highlighted")

		clusterJanitor:Add(container.ChildAdded:Connect(function()
			container:SetAttribute("Highlighted", true)
		end))
		clusterJanitor:Add(container.ChildRemoved:Connect(function()
			if #container:GetChildren() > 0 then
				return
			end
			container:SetAttribute("Highlighted", false)
		end))

		for _, point in cluster do
			local pos = point.position
			table.insert(newClusterPoints, {
				position = Vector3.new(pos.X, pos.Y, pos.Z),
				radius = point.radius,

				mainContainer = container,
			})
		end
	end
	clusterPoints = newClusterPoints
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
	for _, point in clusterPoints do
		local isWithinRange = (point.position - char:GetPivot().Position).Magnitude < renderClusterPointDistance
		local isGenerated = point.isGenerated
		if not isGenerated and isWithinRange then
			point.isGenerated = true
			
			generateCluster(point.mainContainer, point.position, point.radius, takenPositions)
		elseif isGenerated and not isWithinRange then
			point.isGenerated = false

			local part = takenPositions[point.position]
			if part then
				takenPositions[point.position] = nil
				part:Destroy()
			end
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
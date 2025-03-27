-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MaterialService = game:GetService("MaterialService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Containers --
local WorldTerrainUtils = ReplicatedStorage.Source.Utils.WorldTerrain
local Packages = ReplicatedStorage.Packages

-- Packages --
local Streamable = require(Packages.Streamable).Streamable
local Knit = require(Packages.Knit)

-- Modules --
local WorldTerrainSpawning = require(ReplicatedStorage.Source.Data.Worlds.WorldTerrainSpawning)

local getWorldVariantFolder = require(WorldTerrainUtils.getWorldVariantFolder)
local getMaterialFromWorld = require(WorldTerrainUtils.getMaterialFromWorld)

-- Local --
local player = Players.LocalPlayer

local char: Model?, hum: Humanoid?

local streamingTerrainParts = {}
local loadedTerrainParts = {}
local digPoints: {
	[number]: {
		[number]: {
			position: { x: Vector3, y: Vector3, z: Vector3 },
			radius: number,
		}
	}
} = {}

-- Controller --
local WorldTerrainController = Knit.CreateController { Name = "WorldTerrainController" }
type Self = typeof(WorldTerrainController)

function WorldTerrainController:LoadTerrainPart(part: BasePart)
	if table.find(loadedTerrainParts, part) then
		return
	end
	table.insert(loadedTerrainParts, part)
	
	local partWorldIndex = part:GetAttribute("WorldIndex")
	
	workspace.Terrain:FillBlock(part.CFrame, part.Size, Enum.Material[getMaterialFromWorld(part.Name, partWorldIndex).Name])
	
	for worldIndex: number, points in digPoints do
		if worldIndex ~= partWorldIndex then
			continue
		end
		for _, point in points do
			local pos = point.position
			workspace.Terrain:FillBall(Vector3.new(pos.x, pos.y, pos.z), point.radius, Enum.Material.Air)
		end
	end
end

function WorldTerrainController:UnloadTerrainPart(part: BasePart)
	local index = table.find(loadedTerrainParts, part)
	if index then
		table.remove(loadedTerrainParts, index)
	end
end

function WorldTerrainController:ManageStreaming()
	for _, worldFold: Folder in workspace.Worlds:GetChildren() do
		Streamable.new(worldFold, "TerrainParts"):Observe(function(terrainParts: Model, trove)
			for _, part in terrainParts:GetChildren() do
				print(part)
				table.insert(streamingTerrainParts, part)
			end
			trove:Add(terrainParts.ChildAdded:Connect(function(part: BasePart)
				print(part)
				table.insert(streamingTerrainParts, part)
			end))
			trove:Add(terrainParts.ChildRemoved:Connect(function(part: BasePart)
				local index = table.find(streamingTerrainParts, part)
				if index then
					table.remove(streamingTerrainParts, index)
				end
			end))
		end)
	end
end

function WorldTerrainController:Heartbeat()
	if not char or not hum then
		return
	end
	
	for _, part: BasePart in streamingTerrainParts do
		local minSpawnDistnance = WorldTerrainSpawning.MIN_PART_LOAD_DISTANCE + part.Size.Y
		if (part:GetPivot().Position - char:GetPivot().Position).Magnitude > minSpawnDistnance then
			self:UnloadTerrainPart(part)
			continue
		end
		self:LoadTerrainPart(part)
	end
end

function WorldTerrainController:ResetVariantsForWorld(worldIndex: number)
	local worldVariantsFold: Folder? = getWorldVariantFolder(worldIndex)
	if not worldVariantsFold then
		return
	end
	for _, variant: MaterialVariant in worldVariantsFold:GetChildren() do
		MaterialService:SetBaseMaterialOverride(variant.BaseMaterial, variant.BaseMaterial.Name)
	end
end

function WorldTerrainController:SetVariantsForWorld(worldIndex: number)
	local worldVariantsFold: Folder? = getWorldVariantFolder(worldIndex)
	if not worldVariantsFold then
		return
	end
	for _, variant: MaterialVariant in worldVariantsFold:GetChildren() do
		MaterialService:SetBaseMaterialOverride(variant.BaseMaterial, variant.Name)
	end
end

function WorldTerrainController:ManageCurrentWorld(worldIndex: number)
	self:ResetVariantsForWorld(self.lastWorldIndex)
	self:SetVariantsForWorld(worldIndex)
end

function WorldTerrainController:ManageAddedCharacter(addedChar: Model?)
	if not addedChar then
		return
	end
	char = addedChar
	hum = addedChar:FindFirstChildWhichIsA("Humanoid")
end

function WorldTerrainController:KnitInit()
	local WorldTerrainService = Knit.GetService("WorldTerrainService")
	WorldTerrainService.DigPointsLoaded:Connect(function(loadedDigPoints)
		digPoints = loadedDigPoints
		loadedTerrainParts = {}
	end)
	
	self.worldPositions = nil :: { [string]: Vector3 }?
	WorldTerrainService.WorldSpawnPositionsLoaded:Connect(function(...)
		self.worldPositions = ...
	end)
	
	self:ManageStreaming()
	
	local ProfileStoreService = Knit.GetService("ProfileStoreService")
	ProfileStoreService.ProfileLoaded:Connect(function()
		local currentWorldVal: NumberValue = player.Data.CurrentWorld
		self.lastWorldIndex = currentWorldVal.Value
		
		currentWorldVal.Changed:Connect(function(worldIndex)
			self.lastWorldIndex = worldIndex
			task.delay(1, function()
				self:ManageCurrentWorld(worldIndex)
			end)
		end)
		self:ManageCurrentWorld(currentWorldVal.Value)
	end)
	
	player.CharacterAdded:Connect(function(addedChar)
		self:ManageAddedCharacter(addedChar)
	end)
	self:ManageAddedCharacter(player.Character)
	
	RunService.Heartbeat:Connect(function()
		self:Heartbeat()
	end)
end

return WorldTerrainController
-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MaterialService = game:GetService("MaterialService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Streamable = require(Packages.Streamable).Streamable
local Knit = require(Packages.Knit)

-- Modules --
local WorldTerrainSpawning = require(ReplicatedStorage.Source.Data.WorldTerrainSpawning)

-- Local --
local player = Players.LocalPlayer

local char: Model?, hum: Humanoid?

local streamingTerrainParts = {}
local loadedTerrainParts = {}

-- Controller --
local WorldTerrainController = Knit.CreateController { Name = "WorldTerrainController" }
type Self = typeof(WorldTerrainController)

function WorldTerrainController:GetWorldVariantFolder(worldIndex: number): Folder?
	return ReplicatedStorage.Assets.MaterialVariants.Worlds:FindFirstChild(tostring(worldIndex))
end

function WorldTerrainController:GetMaterialFromPart(part: BasePart)
	local worldVariantsFold: Folder? = self:GetWorldVariantFolder(part:GetAttribute("WorldIndex"))
	if not worldVariantsFold then
		return Enum.Material[part.Name]
	end
	local variant: MaterialVariant? = worldVariantsFold:FindFirstChild(part.Name)
	return variant
end

function WorldTerrainController:LoadTerrainPart(part: BasePart)
	if table.find(loadedTerrainParts, part) then
		return
	end
	table.insert(loadedTerrainParts, part)
	
	workspace.Terrain:FillBlock(part.CFrame, part.Size, self:GetMaterialFromPart(part))
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
			trove:Add(terrainParts.ChildAdded:Connect(function(part: BasePart)
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
	local worldVariantsFold: Folder? = self:GetWorldVariantFolder(worldIndex)
	if not worldVariantsFold then
		return
	end
	for _, variant: MaterialVariant in worldVariantsFold:GetChildren() do
		MaterialService:SetBaseMaterialOverride(variant.BaseMaterial, variant.BaseMaterial.Name)
	end
end

function WorldTerrainController:SetVariantsForWorld(worldIndex: number)
	local worldVariantsFold: Folder? = self:GetWorldVariantFolder(worldIndex)
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

function WorldTerrainController:KnitInit()
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
		char = addedChar
		hum = addedChar:FindFirstChildWhichIsA("Humanoid")
	end)
	
	RunService.Heartbeat:Connect(function()
		self:Heartbeat()
	end)
	self:ManageStreaming()
end

return WorldTerrainController
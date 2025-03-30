-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Containers --
local Packages = ReplicatedStorage.Packages
local Data = ReplicatedStorage.Source.Data

-- Modules --
local GroundSpawns = require(Data.Worlds.GroundSpawns)
local Digging = require(Data.Player.Digging)
local Types = require(Data.Types)

local Streamable = require(Packages.Streamable).Streamable
local Knit = require(Packages.Knit)

local isInBrick = require(ReplicatedStorage.Source.Utils.isInBrick)

-- Controller
local SpawningController = Knit.CreateController { Name = "SpawningController" }

-- Types --
type Self = typeof(SpawningController)
type ClientTerrainSpawn = Types.TerrainSpawn & { spawnedModel: Model? }

-- Local --
local player = Players.LocalPlayer

local char: Model?, hum: Humanoid?

local currentSpawns: { [number]: { [number]: { ClientTerrainSpawn } } } = {}
local streamingLevelParts: { [number]: { [number]: BasePart } } = {}

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local toolEquipped: NumberValue?

function SpawningController:SpawnPointAttempt(spawnData: ClientTerrainSpawn)
	if not char or not hum or hum.Health <= 0 then
		return
	end
	
	raycastParams.FilterDescendantsInstances = { char:GetDescendants() }
	
	local origin = char:GetPivot().Position
	local direction = spawnData.position - origin
	local result: RaycastResult? = workspace:Raycast(origin, direction * GroundSpawns.MAX_SPAWN_DISTANCE, raycastParams)
	if not result or (result.Position - spawnData.position).Magnitude > Digging.Tools[toolEquipped.Value].Radius + GroundSpawns.SPAWN_RADIUS_MARGIN then
		return
	end
	
	
	
	local newModel = spawnData.model:Clone()
	newModel.Parent = workspace.Terrain
	newModel:PivotTo(CFrame.new(spawnData.position))
	
	spawnData.spawnedModel = newModel
end

function SpawningController:DespawnPointAttempt(spawnData: ClientTerrainSpawn)
	local model = spawnData.spawnedModel
	if model then
		model:Destroy()
		spawnData.spawnedModel = nil
	end
end

function SpawningController:OnDig(_, digPosition: Vector3)
	if not char or not hum or hum.Health <= 0 then
		return
	end
	
	local playerDataFold: Folder? = player:FindFirstChild("Data")
	if not playerDataFold then
		return
	end
	local currentWorldIndex: number = playerDataFold.CurrentWorld.Value
	
	local worldLevelParts = streamingLevelParts[currentWorldIndex]
	for _, levelPart in worldLevelParts do
		if not isInBrick(digPosition, levelPart) then
			continue
		end
		local levelSpawns = currentSpawns[currentWorldIndex][tonumber(levelPart.Name)]
		for _, spawnData in levelSpawns do
			if (spawnData.position - char:GetPivot().Position).Magnitude > GroundSpawns.MAX_SPAWN_DISTANCE or spawnData.spawnedModel then
				if spawnData.spawned then
					self:DespawnPointAttempt(spawnData)
				end
				continue
			end
			self:SpawnPointAttempt(spawnData)
		end
	end
end

function SpawningController:KnitInit()
	local function checkChar()
		char = player.Character
		if not char  then
			return
		end
		hum = char:FindFirstChildWhichIsA("Humanoid")
	end
	player.CharacterAdded:Connect(checkChar)
	checkChar()
	
	local ProfileStoreService = Knit.GetService("ProfileStoreService")
	ProfileStoreService.ProfileLoaded:Connect(function()
		toolEquipped = player:FindFirstChild("Data").ToolEquipped
	end)
	
	local SpawningService = Knit.GetService("SpawningService")
	SpawningService.CurrentSpawns:Observe(function(newSpawns)
		currentSpawns = newSpawns
	end)
	
	local DiggingController = Knit.GetController("DiggingController")
	DiggingController.Dug:Connect(function(...)
		self:OnDig(...)
	end)
	
	for _, worldFold: Folder in workspace.Worlds:GetChildren() do
		local worldIndex = worldFold:GetAttribute("Index")
		streamingLevelParts[worldIndex] = {}
		
		Streamable.new(worldFold, "GroundLevels"):Observe(function(groundLevelsFold: Folder, trove)
			local function added(levelPart: BasePart)
				table.insert(streamingLevelParts[worldIndex], levelPart)
			end
			local function removed(levelPart: BasePart)
				local levelIndex = table.find(streamingLevelParts[worldIndex], levelPart)
				if levelIndex then
					table.remove(streamingLevelParts[worldIndex], levelIndex)
				end
			end
			
			trove:Add(groundLevelsFold.ChildAdded:Connect(added))
			trove:Add(groundLevelsFold.ChildRemoved:Connect(removed))
			for _, child in groundLevelsFold:GetChildren() do
				added(child)
			end
		end)
	end
end

return SpawningController
-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages
local Utils = ReplicatedStorage.Source.Utils
local Data = ReplicatedStorage.Source.Data

-- Modules --
local GroundSpawns = require(Data.Worlds.GroundSpawns)
local Types = require(Data.Types)

local Knit = require(Packages.Knit)

local getRandomPositionInPart = require(Utils.Random.getRandomPositionInPart)
local fromRandomWeight = require(Utils.Random.fromRandomWeight)

-- Service --
local SpawningService = Knit.CreateService {
	Name = "SpawningService",
	Client = {
		CurrentSpawns = Knit.CreateProperty({})
	},
}

-- Types --
type Self = typeof(SpawningService)

-- Local --
local playerGeneratedSpawns: { [Player]: { [number]: { [number]: { Types.TerrainSpawn } } } } = {}

function SpawningService:GetSpawnModelFromName(name: string, seed: number?)
	local rnd = Random.new(seed)
	
	local obj = self.spawnModels[name]
	if obj:IsA("Folder") then
		local possibleModels = obj:GetChildren()
		return possibleModels[rnd:NextInteger(1, #possibleModels)]
	elseif obj:IsA("Model") then
		return obj
	end
end

function SpawningService:GetSpawnsFromWorld(player: Player, worldIndex: number)
	local seed = player.Data.GroundResetCount.Value
	
	local worldGroundSpawns = GroundSpawns.Worlds[worldIndex]
	
	for _, worldFold: Folder in workspace.Worlds:GetChildren() do
		if worldFold:GetAttribute("Index") ~= worldIndex then
			continue
		end
		local groundLevelParts: { BasePart } = worldFold.GroundLevels:GetChildren()
		for _, groundLevelPart in groundLevelParts do
			local index = tonumber(groundLevelPart.Name)
			local possibleSpawns = worldGroundSpawns[index]
			
			local spawnChances = {}
			for spawnName, spawnData in possibleSpawns do
				spawnChances[spawnName] = spawnData.Chance
			end
			
			local selectedSpawns = {}
			for i=1, groundLevelPart:GetAttribute("SpawnAmount") do
				local spawnSeed = seed + i
				local name = fromRandomWeight(spawnChances, spawnSeed)
				
				table.insert(selectedSpawns, {
					model = self:GetSpawnModelFromName(name, spawnSeed),
					position = getRandomPositionInPart(groundLevelPart, spawnSeed)
				})
			end
			
			return index, selectedSpawns
		end
	end
end

function SpawningService:ManagePlayerLoaded(player: Player)
	local worldsUnlocked: NumberValue = player.Data.WorldsUnlocked
	
	local function checkWorlds(newWorlds: number)
		local newSpawns = {}
		for i=1, newWorlds do
			local levelPartIndex, selectedSpawns  = self:GetSpawnsFromWorld(player, i)
			newSpawns[i] = {}
			newSpawns[i][levelPartIndex] = selectedSpawns
		end
		playerGeneratedSpawns[player] = newSpawns
		self.Client.CurrentSpawns:SetFor(player, newSpawns)
	end
	
	worldsUnlocked.Changed:Connect(checkWorlds)
	checkWorlds(worldsUnlocked.Value)
	
	for _, world in playerGeneratedSpawns[player] do
		for _, spawns in world do
			for _, spawnData in spawns do
				local p = Instance.new("Part")
				p.Anchored = true
				
				p.Size = Vector3.one
				p.Position = spawnData.position
				
				p.Transparency = 0.8
				
				p.CanCollide = false
				p.CanQuery = false
				p.CastShadow = false
				
				p.Parent = workspace
			end
		end
	end
end

function SpawningService:KnitInit()
	self.spawnModels = {} :: { Model | Folder }
	for _, obj: Model | Folder in ReplicatedStorage.Assets.Models.Spawnables:GetChildren() do
		self.spawnModels[obj.Name] = obj
	end
	
	Players.PlayerAdded:Connect(function(player)
		playerGeneratedSpawns[player] = {}
	end)
	Players.PlayerRemoving:Connect(function(player)
		playerGeneratedSpawns[player] = nil
	end)
		
	local ProfileStoreService = Knit.GetService("ProfileStoreService")
	ProfileStoreService.PlayerProfileLoaded:Connect(function(...)
		self:ManagePlayerLoaded(...)
	end)
end

return SpawningService
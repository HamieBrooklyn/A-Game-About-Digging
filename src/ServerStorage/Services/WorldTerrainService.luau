-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

-- Service --
local WorldTerrainService = Knit.CreateService {
	Name = "WorldTerrainService",
	Client = {
		WorldSpawnPositionsLoaded = Knit.CreateSignal(),
		DigPointsLoaded = Knit.CreateSignal(),
	},
}

-- Types --
type Self = typeof(WorldTerrainService)

function WorldTerrainService:ManagePlayerReset(player: Player)
	local profile = self.ProfileStoreService.profiles[player]
	if not profile then
		return
	end
	
	profile.Data.DigPoints = {}
	self.Client.DigPointsLoaded:Fire(player, profile.Data.DigPoints)
end

local function getWorldSpawnPositions()
	local positions = {}
	for _, worldFold: Folder in workspace.Worlds:GetChildren() do
		local spawnLocation = worldFold:FindFirstChildWhichIsA("SpawnLocation")
		positions[worldFold.Name] = spawnLocation:GetPivot().Position
	end
	return positions
end

function WorldTerrainService:ManageAddedPlayer(player: Player)
	self.Client.WorldSpawnPositionsLoaded:Fire(player, getWorldSpawnPositions())
end

function WorldTerrainService:KnitInit()
	self.worldPositions = getWorldSpawnPositions() :: { [string]: Vector3 }
	
	self.ProfileStoreService = Knit.GetService("ProfileStoreService")
	self.ProfileStoreService.PlayerProfileLoaded:Connect(function(player: Player)
		self.Client.DigPointsLoaded:Fire(player, self.ProfileStoreService.profiles[player].Data.DigPoints)
	end)
	
	local ResettingService = Knit.GetService("ResettingService")
	ResettingService.PlayerReset:Connect(function(...)
		self:ManagePlayerReset(...)
	end)
	
	Players.PlayerAdded:Connect(function(player)
		self:ManageAddedPlayer(player)
	end)
	for _, player in Players:GetPlayers() do
		self:ManageAddedPlayer(player)
	end
end

return WorldTerrainService
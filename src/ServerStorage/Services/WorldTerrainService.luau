-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

-- Service --
local WorldTerrainService = Knit.CreateService {
	Name = "WorldTerrainService",
	Client = {
		DigPointsLoaded = Knit.CreateSignal(),
	},
}

-- Types --
type Self = typeof(WorldTerrainService)

function WorldTerrainService:KnitInit()
	local ProfileStoreService = Knit.GetService("ProfileStoreService")
	ProfileStoreService.PlayerProfileLoaded:Connect(function(player: Player)
		self.Client.DigPointsLoaded:Fire(player, ProfileStoreService.profiles[player].Data.DigPoints)
	end)
end

return WorldTerrainService
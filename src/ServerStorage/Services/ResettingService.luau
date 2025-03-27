-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Resetting = require(ReplicatedStorage.Source.Data.Worlds.Resetting)

local Signal = require(Packages.Signal)
local Knit = require(Packages.Knit)

-- Service --
local ResettingService = Knit.CreateService {
	Name = "ResettingService",
	Client = {
		TimeUntilReset = Knit.CreateProperty(Resetting.Terrain.COOLDOWN),
		Reset = Knit.CreateSignal(),
	},
}

ResettingService.PlayerReset = Signal.new()

-- Types --
type Self = typeof(ResettingService)

-- Local --
local playerTimes: { [Player]: number } = {}

function ResettingService:ManageLoadedPlayer(player: Player)
	local profile = self.ProfileStoreService.profiles[player]
	if not profile then
		return
	end
	local loadedTimeUntilReset = profile.Data.TimeUntilReset
	
	playerTimes[player] = loadedTimeUntilReset
end

function ResettingService:UpdatePlayerTimes()
	for player, timeUntilReset in playerTimes do
		local profile = self.ProfileStoreService.profiles[player]
		if not profile then
			continue
		end
		
		local newTime = math.clamp(timeUntilReset - 1, 0, Resetting.Terrain.COOLDOWN)
		profile.Data.TimeUntilReset = newTime
		playerTimes[player] = newTime
		
		self.Client.TimeUntilReset:SetFor(player, newTime)
		
		if newTime == 0 then
			playerTimes[player] = Resetting.Terrain.COOLDOWN
			
			self.PlayerService:TeleportPlayerToWorld(player, profile.Data.CurrentWorld)
			
			self.PlayerReset:Fire(player)
			self.Client.Reset:Fire(player)
		end
	end
end

function ResettingService:KnitInit()
	self.ProfileStoreService = Knit.GetService("ProfileStoreService")
	self.PlayerService = Knit.GetService("PlayerService")
	
	self.ProfileStoreService.PlayerProfileLoaded:Connect(function(...)
		self:ManageLoadedPlayer(...)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		playerTimes[player] = nil
	end)
	
	task.spawn(function()
		while task.wait(1) do
			self:UpdatePlayerTimes()
		end
	end)
end

return ResettingService
-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

-- Service --
local MusicService = Knit.CreateService { Name = "MusicService" }

-- Types --
type Self = typeof(MusicService)

function MusicService.Client:ToggleBackgroundMusic(player: Player)
	self.Server:ToggleBackgroundMusic(player)
end

function MusicService:ToggleBackgroundMusic(player: Player)
	local playerData: Folder? = player:FindFirstChild("Data")
	if not playerData then
		return
	end
	
	local bgMusicOnVal: NumberValue = playerData.BackgroundMusicOn
	bgMusicOnVal.Value = not bgMusicOnVal.Value
end

function MusicService:KnitInit()end

return MusicService
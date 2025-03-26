-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

local peek = Fusion.peek

-- Controller
local MusicController = Knit.CreateController { Name = "MusicController" }

-- Types --
type Self = typeof(MusicController)

function MusicController:SetSong(songName: string)
	
end

function MusicController:StartBackgroundMusic()
	local bgSongs = SoundService.Music.Background:GetChildren()
	task.spawn(function()
		local function selectSong()
			local song: Sound
			repeat
				song = bgSongs[math.random(1, #bgSongs)]
			until song and song ~= self.lastSong
			return song
		end
		local function newSong(song: Sound)
			song:Play()
			self.currentSong:set(song)
			self.lastSong = song
			
			self.loopConnection = song.Ended:Once(function()
				newSong(newSong)
			end)
		end
		newSong(selectSong())
	end)
end

function MusicController:CancelBackgroundMusic()
	if self.loopConnection then
		self.loopConnection:Disconnect()
		self.loopConnection = nil
	end
end

function MusicController:KnitInit()
	local ProfileStoreService = Knit.GetService("ProfileStoreService")
	local LoadingController = Knit.GetController("LoadingController")
	
	self.scope = Fusion:scoped() :: Fusion.Scope
	self.bgMusicPaused = self.scope:Value(false) :: Fusion.Value<boolean>
	self.currentSong = self.scope:Value(nil) :: Fusion.Value<Sound?>
	
	self.loopConnection = nil :: RBXScriptConnection?
	
	self.scope:Computed(function(use: Fusion.Use)
		local song = use(self.currentSong)
		if not song then
			return
		end
		if use(self.bgMusicPaused) and not song.Playing then
			song:Pause()
		end
	end)
	
	self.lastSong = nil :: Sound?
	self.canceled = false
	
	ProfileStoreService.ProfileLoaded:Connect(function()
		local bgMusicOnVal: BoolValue = Players.LocalPlayer.Data.BackgroundMusicOn
		bgMusicOnVal.Changed:Connect(function(on)
			self.bgMusicPaused:set(on)
		end)
		self.bgMusicPaused:set(bgMusicOnVal.Value)
		
		LoadingController.FinishedLoading:Connect(function()
			self:StartBackgroundMusic()
		end)
	end)
end

return MusicController
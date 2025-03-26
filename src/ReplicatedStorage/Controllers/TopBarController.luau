-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

local peek = Fusion.peek

-- Controller
local TopBarController = Knit.CreateController { Name = "TopBarController" }

-- Types --
type Self = typeof(TopBarController)

-- Local --
local player = Players.LocalPlayer

function TopBarController:ManageMusicIcon()
	local bgMusicOnVal: NumberValue = player.Data.BackgroundMusicOn
	
	local isOn = self.scope:Value(false)
	self.scope:Observer(isOn):onBind(function()
		self.musicIcon:setLabel(peek(isOn) and "🔊" or "🔇")
	end)
	
	local function checkIsOn(on)
		isOn:set(on)
	end
	bgMusicOnVal.Changed:Connect(checkIsOn)
	checkIsOn(bgMusicOnVal.Value)
	
	self.musicIcon:bindEvent("selected", function()
		self.MusicService:ToggleBackgroundMusic(player)
	end)
	self.musicIcon:bindEvent("deselected", function()
		self.MusicService:ToggleBackgroundMusic(player)
	end)
end

function TopBarController:KnitInit()
	self.MusicService = Knit.GetService("MusicService")
	
	self.scope = Fusion:scoped()
	
	local ProfileStoreService = Knit.GetService("ProfileStoreService")
	ProfileStoreService.ProfileLoaded:Connect(function()
		local Icon = require(Packages.TopbarPlus)
		
		self.musicIcon = Icon.new()
		self:ManageMusicIcon()
	end)
end

return TopBarController
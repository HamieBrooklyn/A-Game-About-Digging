-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local Resetting = require(ReplicatedStorage.Source.Data.Worlds.Resetting)

local ProfileTemplate = {}

ProfileTemplate.Coins = 0
ProfileTemplate.Dirt = 0
ProfileTemplate.Storage = 30

ProfileTemplate.WorldsUnlocked = 1
ProfileTemplate.CurrentWorld = 1

ProfileTemplate.ToolUpgrade = 1
ProfileTemplate.ToolEquipped = 1

ProfileTemplate.GroundResetCount = 0

ProfileTemplate.DigPoints = {} :: {
	[number]: { -- World Index
		[number]: { radius: number, position: { x: number, y: number, z: number } } -- Dig Point
	}
}

ProfileTemplate.TimeUntilReset = Resetting.Terrain.COOLDOWN

ProfileTemplate.BackgroundMusicOn = true

return ProfileTemplate
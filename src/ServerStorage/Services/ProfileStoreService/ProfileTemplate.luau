local ProfileTemplate = {}

ProfileTemplate.Coins = 0
ProfileTemplate.Dirt = 0
ProfileTemplate.Storage = 30

ProfileTemplate.CurrentWorld = 1

ProfileTemplate.ToolUpgrade = 1
ProfileTemplate.ToolEquipped = 1

ProfileTemplate.DigPoints = {} :: {
	[number]: { -- World Index
		[number]: { radius: number, position: { x: number, y: number, z: number } } -- Dig Point
	}
}

return ProfileTemplate
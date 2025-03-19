local ProfileTemplate = {}

ProfileTemplate.CurrentWorld = 1

ProfileTemplate.ToolUpgrade = 1
ProfileTemplate.ToolEquipped = 1

ProfileTemplate.DigPoints = {} :: {
	[number]: { -- World Index
		[number]: { radius: number, position: { x: number, y: number, z: number } } -- Dig Point
	}
}

return ProfileTemplate
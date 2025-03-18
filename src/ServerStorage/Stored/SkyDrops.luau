local SkyDrops = {}

SkyDrops.FALL_DURATION = 10

SkyDrops.Worlds = {
	[1] = {
		MinDrops = 5,
		MaxDrops = 10,
		Drops = {
			["Leaf"] = {
				Icon = "rbxassetid://104617292580855",
				CanvasSize = Vector2.new(3, 3),
				Give = 1,
			},
			["Berry"] = {
				Icon = "rbxassetid://104617292580855",
				CanvasSize = Vector2.new(3, 3),
				Give = 1,
			},
		},
	}
}

return SkyDrops
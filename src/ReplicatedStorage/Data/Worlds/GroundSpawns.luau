local GroundSpawns = {}

GroundSpawns.MAX_SPAWN_DISTANCE = 100
GroundSpawns.SPAWN_RADIUS_MARGIN = 5

GroundSpawns.Worlds = {
	[1] = {
		[1] = {
			["Rock"] = { Chance = 50 },
		},
		[2] = {
			["Rock"] = { Chance = 50 },
			["Coal"] = { Chance = 20 },
		},
		[3] = {
			["Rock"] = { Chance = 50 },
			["Coal"] = { Chance = 50 },
		},
	},
}

return GroundSpawns
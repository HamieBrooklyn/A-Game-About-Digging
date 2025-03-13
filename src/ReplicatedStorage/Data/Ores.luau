-- Data --
local Ores = {}

Ores.Worlds = {}

Ores.Worlds[1] = { -- [number] = World index
    [1] = { -- [number] = Ground level
        [1] = {
            Name = "Rock",
            Chance = 50,
        },
        [2] = {
            Name = "Coal",
            Chance = 50,
        },
        [3] = {
            Name = "Iron",
            Chance = 30,
        },
    }
}

return Ores
-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Utils --
local fromRandomWeight = require(ReplicatedStorage.Source.Utils.fromRandomWeight)

local function getSpawnsFromChance(possibleSpawns: {
    [number]: {
        Name: string,
        Chance: number,
    }
}, spawnAmount: number)
    local spawnChances = {}
    for _, data in possibleSpawns do
        spawnChances[data.Name] = data.Chance
    end

    local chosenSpawns = {}
    for _=1, spawnAmount do
        table.insert(chosenSpawns, fromRandomWeight(spawnChances))
    end
    
    return chosenSpawns
end
return getSpawnsFromChance
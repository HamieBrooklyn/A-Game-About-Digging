-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Utils --
local fromRandomWeight = require(ReplicatedStorage.Source.Utils.fromRandomWeight)

local function generatePointsFromPart(part: BasePart, possibleSpawns: {
    [number]: {
        Name: string,
        Chance: number,
    }
}, spawnAmount: number)
    local spawnChances = {}
    for _, data in possibleSpawns do
        spawnChances[data.Name] = data.Chance
    end

    for i=1, spawnAmount do
        print(fromRandomWeight(spawnChances))
    end
end
return generatePointsFromPart
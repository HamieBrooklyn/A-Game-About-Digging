-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Data --
local Ores = require(ReplicatedStorage.Source.Data.Ores)

-- Module --
local ObjectSpawning = require(script.Parent.Parent)

-- Utils --
local getRandomPositionInPart = require(ReplicatedStorage.Source.Utils.getRandomPositionInPart)
local getSpawnsFromChance = ObjectSpawning.getSpawnsFromChance

local function generateOrePoints(player: Player)
    local chosenOrePoints = {}
    
	for _, worldFold: Folder in workspace.Worlds:GetChildren() do
        for _, levelPart: Part in worldFold.GroundLevels:GetChildren() do
            local levelIndex = tonumber(levelPart.Name)
            
            local worldData = Ores.Worlds[worldFold:GetAttribute("Index")]
            if not worldData then
                continue
            end
            
            local levelData = worldData[levelIndex]
            if not levelData then
                continue
            end
            local levelOres = {}
            for _, oreData in levelData.Spawns do
                table.insert(levelOres, oreData)
            end

            local selectedOres = getSpawnsFromChance(levelOres, levelData.MaxSpawnAmount)

            local newLevelPoints = {}
            for _, oreName in selectedOres do
                table.insert(newLevelPoints, {
                    name = oreName,
                    position = getRandomPositionInPart(levelPart),
                    
                    levelPartIndex = levelIndex,
                })
            end
            chosenOrePoints[levelIndex] = newLevelPoints
        end
    end
    
    return chosenOrePoints
end

return generateOrePoints
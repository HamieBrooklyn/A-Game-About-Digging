-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Data --
local Ores = require(ReplicatedStorage.Source.Data.Ores)

-- Module --
local ObjectSpawning = require(script.Parent.Parent)

-- Utils --
local getRandomPositionInPart = require(ReplicatedStorage.Source.Utils.getRandomPositionInPart)
local generatePointsFromPart = ObjectSpawning.generatePointsFromPart

local function generateOrePoints(player: Player)
    local chosenOrePoints = {}
    
	for _, worldFold: Folder in workspace.Worlds:GetChildren() do
        for _, levelPart: Part in worldFold.GroundLevels:GetChildren() do
            for _, oreName in generatePointsFromPart(levelPart, ObjectSpawning.ores) do
                table.insert(chosenOrePoints, {
                    name = oreName,
                    position = getRandomPositionInPart(levelPart),
                    
                    levelPartIndex = tonumber(levelPart.Name),
                })
            end
        end
    end
    
    return chosenOrePoints
end

return generateOrePoints
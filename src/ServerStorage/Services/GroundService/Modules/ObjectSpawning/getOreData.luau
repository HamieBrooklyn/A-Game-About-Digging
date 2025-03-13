-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Data --
local Ores = require(ReplicatedStorage.Source.Data.Ores)

-- Utils --
local getWorldFromIndex = require(ReplicatedStorage.getWorldFromIndex)

local function getOreData()
    for worldIndex, groundLevels in Ores.Worlds do
        getWorldFromIndex(worldIndex):andThen(function(worldFold: Folder)
            local groundLevelsFold: Folder = worldFold.GroundLevels
            for _, groundLevelPart: Part in groundLevelsFold:GetChildren() do
                local levelData = groundLevels[tonumber(groundLevelPart.Name)]
                if not levelData then
                    continue
                end
                print(levelData)
            end
        end)
    end
end
return getOreData
-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Data --
local Ores = require(ReplicatedStorage.Source.Data.Ores)

-- Utils --
local getWorldFromIndex = require(ReplicatedStorage.getWorldFromIndex)

local function getOreData()
    local out = {}
    
    for worldIndex, groundLevels in Ores.Worlds do
        for _, worldFold: Folder in workspace.Worlds:GetChildren() do
            if worldFold:GetAttribute("Index") ~= worldIndex then
                continue
            end
            
            local groundLevelsFold: Folder = worldFold.GroundLevels
            for _, groundLevelPart: Part in groundLevelsFold:GetChildren() do
                local levelData = groundLevels[tonumber(groundLevelPart.Name)]
                if not levelData then
                    continue
                end
                
                for _, spawnData in levelData.Spawns do
                    table.insert(out, {
                        Name = spawnData.Name,
                        Chance = spawnData.Chance,
                        
                        GroundLevelIndex = tonumber(groundLevelPart.Name),
                    })
                end
            end
        end
    end
    
    return out
end
return getOreData
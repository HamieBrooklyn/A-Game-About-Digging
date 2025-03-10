-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Knit = require(Packages.Knit)

-- Controller --
local GroundController = Knit.CreateController { Name = "GroundController" }
type Self = typeof(GroundController)

function GroundController:KnitInit()
    self.RichTerrainService = Knit.GetService("RichTerrainService")
    require(script.RichTerrain).init()
end

return GroundController
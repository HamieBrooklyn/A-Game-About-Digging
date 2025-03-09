local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local GroundService = Knit.CreateService { Name = "GroundService" }
type Self = typeof(GroundService)

function GroundService:KnitInit()
    require(script.RichTerrain).init()
end

return GroundService
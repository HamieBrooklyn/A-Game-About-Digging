-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

-- Service --
local SpawningService = Knit.CreateService { Name = "SpawningService" }

-- Types --
type Self = typeof(SpawningService)



function SpawningService:KnitInit()end

return SpawningService
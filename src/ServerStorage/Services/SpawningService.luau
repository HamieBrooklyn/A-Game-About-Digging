-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Knit = require(Packages.Knit)

-- Service --
local SpawningService = Knit.CreateService { Name = "SpawningService" }
type Self = typeof(SpawningService)

function SpawningService:KnitInit()
	
end

return SpawningService
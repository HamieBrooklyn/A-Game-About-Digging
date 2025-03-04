local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local ControllerName = Knit.CreateController { Name = "ControllerName" }
type Self = typeof(ControllerName)

function ControllerName:KnitInit()end

return ControllerName
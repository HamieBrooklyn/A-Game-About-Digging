local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local ServiceName = Knit.CreateService { Name = "ServiceName" }
type Self = typeof(ServiceName)

function ServiceName:KnitInit()end

return ServiceName
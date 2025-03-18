-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages
local ControllerModules = script.Modules

-- Packages --
local Knit = require(Packages.Knit)

-- Variables --
local controllerModules: { ModuleScript } = ControllerModules:GetChildren()
local requiredModules: { ControllerModule } = {}

-- Service --
local GroundController = Knit.CreateController {
    Name = "GroundController",
    Client = {},
}
-- Types --
type Self = typeof(GroundController)
type ControllerModule = {
	init: (() -> nil)?,
}

local function callModuleFunction(functionKey: string, ...)
	for _, controllerMod in requiredModules do
		local func = controllerMod[functionKey]
		if func then
			func(...)
		end
	end
end

function GroundController:KnitInit()
	self.service = Knit.GetService("GroundService")

	for _, module in controllerModules do
		requiredModules[module.Name] = require(module)
	end
	callModuleFunction("init")
end

return GroundController
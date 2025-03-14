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
local MODULE_CONTROLLER_NAME = Knit.CreateController {
    Name = "MODULE_CONTROLLER_NAME",
    Client = {},
}
-- Types --
type Self = typeof(MODULE_CONTROLLER_NAME)
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

function MODULE_CONTROLLER_NAME:KnitInit()
	for _, module in controllerModules do
		requiredModules[module.Name] = require(module)
	end
	callModuleFunction("init")
end

return MODULE_CONTROLLER_NAME
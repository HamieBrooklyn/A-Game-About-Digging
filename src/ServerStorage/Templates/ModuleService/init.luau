-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Containers --
local Packages = ReplicatedStorage.Packages
local ServiceModules = script.Modules

-- Packages --
local Knit = require(Packages.Knit)

-- Variables --
local dataLoaded = ServerScriptService.Server.DataLoaded

local serviceModules: { ModuleScript } = ServiceModules:GetChildren()
local requiredModules: { ServiceModule } = {}

-- Service --
local MODULE_SERVICE_NAME = Knit.CreateService {
    Name = "MODULE_SERVICE_NAME",
    Client = {
        RichTerrainPointsLoaded = Knit.CreateSignal(),
    },
}
-- Types --
type Self = typeof(MODULE_SERVICE_NAME)
type ServiceModule = {
	init: (() -> nil)?,
	onPlayerAdded: ((Player) -> nil)?,
	onPlayerRemoving: ((Player) -> nil)?,
}

local function callModuleFunction(functionKey: string, ...)
	for _, serviceMod in requiredModules do
		local func = serviceMod[functionKey]
		if func then
			func(...)
		end
	end
end

local function onPlayerAdded(player: Player)
	callModuleFunction("onPlayerAdded", player)
end

local function onPlayerRemoving(player: Player)
	callModuleFunction("onPlayerRemoving", player)
end

local function onPlayerDataLoaded(player: Player)
	callModuleFunction("onPlayerDataLoaded", player)
end

function MODULE_SERVICE_NAME:KnitInit()
	for _, module in serviceModules do
		table.insert(requiredModules, require(module))
	end
	for _, serviceMod in requiredModules do
		if serviceMod.init then
			serviceMod.init()
		end
	end
	
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	
	dataLoaded.Event:Connect(onPlayerDataLoaded)
end

return MODULE_SERVICE_NAME
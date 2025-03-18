-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Knit = require(Packages.Knit)

-- Local --
local dataLoaded = ServerScriptService.Server.DataLoaded

local events: {ModuleScript} = script.Events:GetChildren()
local requiredEvents: {Event} = {}

-- Service --
local EventService = Knit.CreateService { Name = "EventService" }
type Self = typeof(EventService)
type Event = {
	init: (() -> nil)?,
	onPlayerAdded: ((Player) -> nil)?,
	onPlayerRemoving: ((Player) -> nil)?,
}

local function callEventFunction(functionKey: string, ...)
	for _, event in requiredEvents do
		local func = event[functionKey]
		if func then
			func(...)
		end
	end
end

local function onPlayerAdded(player: Player)
	callEventFunction("onPlayerAdded", player)
end

local function onPlayerRemoving(player: Player)
	callEventFunction("onPlayerRemoving", player)
end

local function onDataLoaded(player: Player)
	callEventFunction("onDataLoaded", player)
end

function EventService:KnitInit()
	for _, eventMod in events do
		table.insert(requiredEvents, require(eventMod))
	end
	for _, event in requiredEvents do
		if event.init then
			event.init()
		end
	end
	
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	
	dataLoaded.Event:Connect(onDataLoaded)
end

return EventService
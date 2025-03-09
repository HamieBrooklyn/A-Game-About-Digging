-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local --
local dug = ReplicatedStorage.Events.Bindable.Dug

local playersData = {}

-- Module --
local RichTerrain = {}

-- Functions --
local function onPlayerAdded(player: Player)
	playersData[player] = {}
end

local function onPlayerRemoving(player: Player)
	playersData[player] = nil
end

local function onDug(player: Player)
	
end

-- Init --
RichTerrain.init = function()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	dug.Event:Connect(onDug)
end

return RichTerrain
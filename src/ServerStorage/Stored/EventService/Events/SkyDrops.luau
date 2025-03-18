-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Container --
local Source = ReplicatedStorage.Source

-- Data --
local MainData = require(Source.Data.SkyDrops)

-- Utils --
local getRandomPositionInPart = require(Source.Utils.getRandomPositionInPart)

-- Variables --
local minEventCooldown = 1
local maxEventCooldown = 1

local cachedPlayers = {}
local playerDrops = {}

-- Module --
local SkyDrops = {}

local function onEvent(player: Player)
	local worldsUnlocked: NumberValue = player.Info.WorldsUnlocked
	for i=1, worldsUnlocked.Value do
		local worldDropsData = MainData.Worlds[i]
		if not worldDropsData then
			continue
		end
		
	end
end

SkyDrops.init = function()
	task.spawn(function()
		while task.wait(math.random(minEventCooldown, maxEventCooldown)) do
			for _, player: Player in Players:GetPlayers() do
				if not player:GetAttribute("DataLoaded") then
					table.insert(cachedPlayers, player)
					continue
				end
				onEvent(player)
			end
		end
	end)
end

SkyDrops.onPlayerDataLoaded = function(player: Player)
	local cachedPlayerIndex = table.find(cachedPlayers, player)
	if not cachedPlayerIndex then
		return
	end
	table.remove(cachedPlayers, cachedPlayerIndex)
	
	onEvent(player)
end

SkyDrops.onPlayerAdded = function(player: Player)
	playerDrops[player] = {}
end

SkyDrops.onPlayerRemoving = function(player: Player)
	playerDrops[player] = nil
	
	local cachedPlayerIndex = table.find(cachedPlayers, player)
	if cachedPlayerIndex then
		table.remove(cachedPlayers, cachedPlayerIndex)
	end
end

return SkyDrops
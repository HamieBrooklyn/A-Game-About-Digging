-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Worlds = require(ReplicatedStorage.Source.Data.Worlds.Worlds)

local provider;
if RunService:IsServer() then
	provider = require(ServerStorage.Source.Services.WorldTerrainService)
elseif RunService:IsClient() then
	provider = require(ReplicatedStorage.Source.Controllers.WorldTerrainController)
end

local function worldPosititonFromIndex(index: number)
	return provider.worldPositions[Worlds[index].Name]
end

return worldPosititonFromIndex
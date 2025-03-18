-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Streamable = require(Packages.Streamable).Streamable
local Knit = require(Packages.Knit)

-- Local --
local player = Players.LocalPlayer

local char: Model?, hum: Humanoid?

local streamingTerrainParts = {}

-- Controller --
local WorldTerrainController = Knit.CreateController { Name = "WorldTerrainController" }
type Self = typeof(WorldTerrainController)

function WorldTerrainController:LoadTerrainPart(part: BasePart)
	
end

function WorldTerrainController:UnloadTerrainPart(part: BasePart)
	
end

function WorldTerrainController:ManageStreaming()
	for _, worldFold: Folder in workspace.Worlds:GetChildren() do
		Streamable.new(worldFold, "TerrainParts"):Observe(function(terrainParts: Model, trove)
			trove:Add(terrainParts.ChildAdded:Connect(function(part: BasePart)
				table.insert(streamingTerrainParts, part)
			end))
			trove:Add(terrainParts.ChildRemoved:Connect(function(part: BasePart)
				local index = table.find(streamingTerrainParts, part)
				if index then
					table.remove(streamingTerrainParts, index)
				end
			end))
		end)
	end
end

function WorldTerrainController:Heartbeat()
	if not char or not hum then
		return
	end
	
	for _, part: BasePart in streamingTerrainParts do
		
	end
end

function WorldTerrainController:KnitInit()
	player.CharacterAdded:Connect(function(addedChar)
		char = addedChar
		hum = addedChar:FindFirstChildWhichIsA("Humanoid")
	end)
	
	RunService.Heartbeat:Connect(function()
		self:Heartbeat()
	end)
	self:ManageStreaming()
end

return WorldTerrainController
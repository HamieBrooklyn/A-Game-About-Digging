-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local DataFolders = require(ReplicatedStorage.Source.Data.Player.DataFolders)

local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

local Children = Fusion.Children
local peek = Fusion.peek

-- Controller
local ClientDataController = Knit.CreateController { Name = "ClientDataController" }

-- Types --
type Self = typeof(ClientDataController)

-- Local --
local player = Players.LocalPlayer

function ClientDataController:ReplicateValue(_use: Fusion.Use, scope: Fusion.Scope, valueObj: ValueBase)
	local value = self.scope:Value(valueObj.Value)
	scope:Hydrate(valueObj:Clone()) {
		Parent = self.clientDataFolder,
		Value = value
	}
	self.values[valueObj.Name] = value
end

function ClientDataController:KnitInit()
	self.scope = Fusion:scoped()
	
	self._clientValueObjects = self.scope:Value({}) :: Fusion.Value<{ [number]: ValueBase }>
	self.values = {} :: { [string]: Fusion.Value<number> }
	
	self.clientDataFolder = self.scope:New "Folder" {
		Name = "ClientData",
		Parent = player,
		[Children] = {
			self.scope:ForValues(self._clientValueObjects, function(...)
				return self:ReplicateValue(...)
			end)
		},
	}
	
	local function valueAdded(valueObj: ValueBase)
		local newValues = peek(self._clientValueObjects)
		table.insert(newValues, valueObj)
		self._clientValueObjects:set(newValues)
	end
	local function valueRemoved(valueObj: ValueBase)
		local newValues = peek(self._clientValueObjects)
		
		local objectIndex = table.find(newValues, valueObj)
		if objectIndex then
			table.remove(newValues, objectIndex)
			self._clientValueObjects:set(newValues)
		end
		
		local valueIndex = self.values[valueObj.Name]
		if valueIndex then
			self.values[valueObj.Name] = nil
		end
	end
	
	local ProfileStoreService = Knit.GetService("ProfileStoreService")
	ProfileStoreService.ProfileLoaded:Connect(function()
		for foldName, _ in DataFolders do
			local fold: Folder = player:FindFirstChild(foldName)
			fold.ChildAdded:Connect(valueAdded)
			fold.ChildRemoved:Connect(valueRemoved)
			for _, valueObj in fold:GetChildren() do
				valueAdded(valueObj)
			end
		end
	end)
end

return ClientDataController
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local Promise = require(ReplicatedStorage.Packages.Promise)

local worldFromIndex = require(ReplicatedStorage.Source.Utils.Worlds.worldFromIndex)

local function worldPosititonFromIndex(index: number)
	return Promise.new(function(resolve)
		worldFromIndex(index):andThen(function(worldFold: Folder)
			local con: RBXScriptConnection
			
			local function checkAdded(spawnLocation: SpawnLocation?)
				if not spawnLocation:IsA("SpawnLocation") then
					return
				end
				
				con:Disconnect()
				resolve(spawnLocation:GetPivot().Position)
			end
			
			con = worldFold.ChildAdded:Connect(function(...)
				checkAdded(...)
			end)
			for _, obj in worldFold:GetChildren() do
				checkAdded(obj)
			end
		end)
	end)
end

return worldPosititonFromIndex
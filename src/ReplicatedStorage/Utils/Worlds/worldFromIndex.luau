-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local Promise = require(ReplicatedStorage.Packages.Promise)

local function worldFromIndex(index: number)
	return Promise.new(function(resolve)
		local worlds = workspace.Worlds
		
		local con: RBXScriptConnection
		local function checkWorld(worldFold: Folder)
			if worldFold:GetAttribute("Index") ~= index then
				return
			end
			con:Disconnect()
			resolve(worldFold)
		end
		
		for _, worldFold in worlds:GetChildren() do
			checkWorld(worldFold)
		end
		con = worlds.ChildAdded:Connect(function(...)
			checkWorld(...)
		end)
	end)
end

return worldFromIndex
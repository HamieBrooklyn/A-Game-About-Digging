-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Janitor = require(Packages.Janitor)
local Signal = require(Packages.Signal)
local Knit = require(Packages.Knit)

-- Modules --
local DataFolders = require(ReplicatedStorage.Source.Data.DataFolders)
local ProfileTemplate = require(script.ProfileTemplate)

local ProfileStore = require(script.ProfileStore)

-- Local --
local playerProfileJanitors = {}

-- Service --
local ProfileStoreService = Knit.CreateService {
	Name = "ProfileStoreService",
	Client = {
		ProfileLoaded = Knit.CreateSignal()
	},
}

-- Signals --
ProfileStoreService.PlayerProfileLoaded = Signal.new()

-- Types --
type Self = typeof(ProfileStoreService)

function ProfileStoreService:SetupDataFolder(player: Player)
	local profile = self.profiles[player]
	
	local janitor = playerProfileJanitors[player]
	
	local dataFolders = {}
	for folderName, _ in DataFolders do
		local customFold = Instance.new("Folder")
		customFold.Name = folderName
		dataFolders[customFold.Name] = customFold 
	end
	
	for name, value in profile.Data do
		local customFold: Folder?
		for folderName, valueNames in DataFolders do
			if table.find(valueNames, name) then
				customFold = dataFolders[folderName]
			end
		end
		
		if typeof(value) == "number" then
			local val = Instance.new("NumberValue")
			val.Name = name
			val.Value = value
			janitor:Add(val.Changed:Connect(function(newValue)
				profile.Data[name] = newValue
			end))
			val.Parent = customFold
		end
	end
	
	for _, customFold: Folder in dataFolders do
		customFold.Parent = player
	end
end

function ProfileStoreService:ManageAddedPlayer(player: Player)
	local profile = self.playerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		
		profile.OnSessionEnd:Connect(function()
			self.profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			self.profiles[player] = profile
			self:SetupDataFolder(player)
			
			print(`Profile loaded for {player.DisplayName}!`)
			self.PlayerProfileLoaded:Fire(player)
			self.Client.ProfileLoaded:Fire(player)
		else
			profile:EndSession()
		end
	else
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function ProfileStoreService:KnitInit()
	self.playerStore = ProfileStore.New("PlayerStore", ProfileTemplate)
	self.profiles = {} :: {[Player]: typeof(self.playerStore:StartSessionAsync())}
	
	self.Client.customFolders = CustomFolders
	
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:ManageAddedPlayer(player)
		end)
	end
	
	Players.PlayerAdded:Connect(function(player)
		playerProfileJanitors[player] = Janitor.new()
		
		self:ManageAddedPlayer(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		playerProfileJanitors[player]:Cleanup()
		playerProfileJanitors[player]:Destroy()
		playerProfileJanitors[player] = nil
		
		local profile = self.profiles[player]
		if profile ~= nil then
			profile:EndSession()
		end
	end)
end

return ProfileStoreService
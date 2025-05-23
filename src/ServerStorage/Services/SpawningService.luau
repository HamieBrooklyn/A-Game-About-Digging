-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local ZonePlus = require(ReplicatedStorage.Packages.ZonePlus)
local Knit = require(Packages.Knit)

local Spawning = require(ServerStorage.Source.Data.Spawning)

-- Service --
local SpawningService = Knit.CreateService { Name = "SpawningService" }

-- Types --
type Self = typeof(SpawningService)

function SpawningService:GenerateGroundPoint(seed: number, groundPart: BasePart, possibleSpawns: { [string]: {} })
	print("Generating ground point")
end

function SpawningService:CreateGroundLoadHitboxes()
	local hitboxesFolder = Instance.new("Folder")
	hitboxesFolder.Name = "GroundLoadHitboxes"
	hitboxesFolder.Parent = workspace
	
	for _, world in workspace.Worlds:GetChildren() do
		local groundLevelsFold = world:FindFirstChild("GroundLevels")
		if not groundLevelsFold then
			continue
		end
		for _, groundPart: BasePart in groundLevelsFold:GetChildren() do
			local hitbox = groundPart:Clone()
			hitbox.Size += Vector3.one * Spawning.GROUND_SPAWNS_LOAD_DISTANCE
			hitbox.CanQuery = true
			hitbox:PivotTo(groundPart.CFrame)
			hitbox.Parent = hitboxesFolder
			
			local zone = ZonePlus.new(hitbox)
			zone.playerEntered:Connect(function(player: Player)
				task.spawn(function()
					local profile
					
					local searchCount = 0
					repeat
						searchCount += 1
						profile = self.ProfileStoreService.profiles[player]
						if profile then
							break
						end
						task.wait(1)
					until searchCount > 10 or profile ~= nil
					
					local groundSeed = profile.Data.GroundSeed
					for _, category in Spawning.Ground do
						local worldSpawnData = category[world.Name]
						if not worldSpawnData then
							continue
						end
						local possibleSpawns = worldSpawnData[tonumber(groundPart.Name)]
						if not possibleSpawns then
							continue
						end
						print(self:GenerateGroundPoint(groundSeed, groundPart, possibleSpawns))
					end
				end)
			end)
		end
	end
end

function SpawningService:ManagePlayerLoaded(player: Player)
	
end

function SpawningService:KnitInit()
	self:CreateGroundLoadHitboxes()
	
	self.ProfileStoreService = Knit.GetService("ProfileStoreService")
	self.ProfileStoreService.PlayerProfileLoaded:Connect(function(player)
		self:ManagePlayerLoaded(player)
	end)
end

return SpawningService
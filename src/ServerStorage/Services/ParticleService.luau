-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

-- Service --
local ParticleService = Knit.CreateService { Name = "ParticleService" }

-- Types --
type Self = typeof(ParticleService)

local playerParticles: { [Player]: { Attachment: { ParticleEmitter } } } = {}

function ParticleService:ManageAddedCharacter(char: Model)
	local particleParts = ReplicatedStorage.Assets.Particles:GetChildren()
	for _, particlePart: BasePart in particleParts do
		for _, att: Attachment in particlePart:GetChildren() do
			att = att:Clone()
			att.Name = particlePart.Name
			att.Parent = char.PrimaryPart
			playerParticles[Players:GetPlayerFromCharacter(char)][particlePart.Name] = att
		end
	end
end

function ParticleService:EmitPlayerParticle(player: Player, particleKey: string, emitCount: number?)
	local particles = playerParticles[player]
	if not particles then
		return
	end
	local att = particles[particleKey]
	if not att then
		return
	end
	for _, emitter: ParticleEmitter in att:GetChildren() do
		emitter:Emit(emitCount or 1)
	end
end

function ParticleService:KnitInit()
	Players.PlayerAdded:Connect(function(player)
		playerParticles[player] = {}
		player.CharacterAdded:Connect(function(char)
			self:ManageAddedCharacter(char)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		playerParticles[player] = nil
	end)
end

return ParticleService
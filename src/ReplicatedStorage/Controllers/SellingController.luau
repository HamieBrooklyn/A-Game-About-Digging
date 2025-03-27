-- Services --
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Moduoles --
local Currency = require(ReplicatedStorage.Source.Data.Stats.Currency)

local Sound = require(ReplicatedStorage.Source.Classes.Sound)

local Knit = require(Packages.Knit)

-- Controller
local SellingController = Knit.CreateController { Name = "SellingController" }

-- Types --
type Self = typeof(SellingController)

function SellingController:ManageOnSold(playerSold: Player, outputStatName: string, amount: number)
	if playerSold == Players.LocalPlayer then
		local coinsLabel = Players.LocalPlayer.PlayerGui:WaitForChild("Main").Sides.Left.Coins
		self.PopupController:SendIcons({
			[Currency.PopupIcons[outputStatName]] = math.clamp(amount, 1, math.random(15, 25)),
		}, coinsLabel.Position, function()
			self.GuiAnimationController:Bounce(coinsLabel)
			Sound.new(SoundService.SoundEffects.Gui.SoftPop)
		end)
	end
	
	local char = playerSold.Character
	if not char then
		return
	end
	local primary = char.PrimaryPart
	if not primary then
		return
	end
	
	Sound.new(SoundService.SoundEffects.Currency.Coins, nil, primary)
	
	local particlePart = ReplicatedStorage.Assets.Particles.Sell:Clone()
	particlePart.Parent = primary
	for _, emitter: ParticleEmitter in particlePart:GetChildren() do
		emitter:Emit()
	end
	Debris:AddItem(particlePart, 1)
end

function SellingController:KnitInit()
	self.GuiAnimationController = Knit.GetController("GuiAnimationController")
	self.PopupController = Knit.GetController("PopupController")
	
	local SellingService = Knit.GetService("SellingService")
	SellingService.Sold:Connect(function(...)
		self:ManageOnSold(...)
	end)
end

return SellingController
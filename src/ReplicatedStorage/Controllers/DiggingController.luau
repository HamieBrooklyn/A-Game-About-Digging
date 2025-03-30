-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Containers --
local Packages = ReplicatedStorage.Packages

local Utils = ReplicatedStorage.Source.Utils
local Data = ReplicatedStorage.Source.Data

-- Modules --
local Currency = require(ReplicatedStorage.Source.Data.Stats.Currency)

local Fusion = require(Packages.Fusion)
local Signal = require(Packages.Signal)
local Knit = require(Packages.Knit)

local peek = Fusion.peek

local Materials = require(Data.Worlds.Materials)
local Digging = require(Data.Player.Digging)

local Sound = require(ReplicatedStorage.Source.Classes.Sound)

local getMaterialFromWorld = require(Utils.WorldTerrain.getMaterialFromWorld)
local playerWorldDepth = require(Utils.Worlds.playerWorldDepth)

-- Controller --
local DiggingController = Knit.CreateController { Name = "DiggingController" }

DiggingController.Dug = Signal.new()

-- Types --
type Self = typeof(DiggingController)

-- Local --
local player = Players.LocalPlayer

local char: Model?, hum: Humanoid?

local camera = workspace.Camera
local mouse = player:GetMouse()

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local lastStorageWarning = 0
local lastDig = 0

function DiggingController:TriggerFullStorageEffect()
	if tick() - lastStorageWarning < Digging.FULL_STORAGE_WARNING_COOLDOWN then
		return
	end
	lastStorageWarning = tick()
	
	self.PopupController:AddMessage("FullStorage", "Large", "Max Storage", ColorSequence.new(
		Color3.fromHex("#FF0066"),
		Color3.fromHex("#9F2354")
	))
	task.delay(Digging.FULL_STORAGE_WARNING_COOLDOWN / 2, function()
		self.PopupController:RemoveMessage("FullStorage", "Large")
	end)
end

function DiggingController:Dig()
	if not char or not hum or hum.Health <= 0 then
		return
	end
	
	raycastParams.FilterDescendantsInstances = {char:GetDescendants()}
	
	local playerDataFold: Folder? = player:FindFirstChild("Data")
	if not playerDataFold then
		return
	end
	local equippedToolIndex = math.min(playerDataFold.ToolEquipped.Value, 1)
	local toolData = Digging.Tools[equippedToolIndex]
	if tick() - lastDig <= toolData.Cooldown then
		return
	end
	lastDig = tick()
	
	if playerDataFold.Dirt.Value >= playerDataFold.Storage.Value then
		self:TriggerFullStorageEffect()
		return
	end
	
	raycastParams.FilterDescendantsInstances = {char:GetDescendants()}
	
	local origin = char:GetPivot().Position
	local direction = mouse.Hit.Position - origin
	local result: RaycastResult = workspace:Raycast(origin, direction * Digging.MAX_DIGGING_DISTANCE, raycastParams)
	if not result or not result.Instance:IsA("Terrain") then
		return
	end
	
	local currentWorld = playerDataFold.CurrentWorld.Value
	local material = getMaterialFromWorld(result.Material.Name, currentWorld, true).Name
	
	if not string.find(toolData.Terrain, material) then
		return
	end
	
	local digPos = result.Position + camera.CFrame.LookVector * toolData.Radius / 2
	self.DiggingService:DigAttempt(digPos):andThen(function(digSuccess: boolean?)
		if not digSuccess then
			return
		end
		workspace.Terrain:FillBall(digPos, toolData.Radius, Enum.Material.Air)
		
		self.Dug:Fire(toolData, digPos)
		
		local dirtLabel = player.PlayerGui.Main.Sides.Left.Dirt
		self.PopupController:SendIcons({
			[Currency.PopupIcons.Dirt] = Materials[material].Give
		}, dirtLabel.Position, function()
			self.GuiAnimationController:Bounce(dirtLabel)
			Sound.new(SoundService.SoundEffects.Gui.SoftPop)
		end)
	end)
end

function DiggingController:ManageAddedCharacter(addedChar: Model)
	if not addedChar then
		return
	end
	char = addedChar
	hum = char:FindFirstChildWhichIsA("Humanoid")
end

function DiggingController:TriggerDigEffect(otherPlayer: Player, materialDugName: string, digPosition: Vector3)
	local otherChar: Model? = otherPlayer.Character
	if not otherChar then
		return
	end
	local primary = otherChar.PrimaryPart
	if not primary then
		return
	end
	local otherHum = otherChar:FindFirstChildWhichIsA("Humanoid")
	if not otherHum then
		return
	end
	local animator = otherHum:FindFirstChildWhichIsA("Animator")
	if not animator then
		return
	end
	
	local otherPlayerData: Folder? = otherPlayer:FindFirstChild("Data")
	if not otherPlayerData then
		return
	end
	local toolEquipped: number = otherPlayerData.ToolEquipped.Value
	local toolData = Digging.Tools[toolEquipped]
	
	local animation: Animation = ReplicatedStorage.Assets.Animations.Digging:FindFirstChild(toolData.DigAnimation)
	animator:LoadAnimation(animation):Play()
	
	local soundFold: Folder? = SoundService.SoundEffects.MaterialDigSounds:FindFirstChild(materialDugName)
	if soundFold then
		local possibleSounds = soundFold:GetChildren()
		local chosenSound: Sound = possibleSounds[math.random(1, #possibleSounds)]
		Sound.new(chosenSound, nil, primary)
	end
	
	local function rndRot()
		return math.rad(math.random(-360, 360))
	end
	local function rndPos()
		return math.random(-5, 10)
	end
	
	local materialColor = Materials[materialDugName] and Materials[materialDugName].Color or Color3.fromRGB(255, 255, 255)
	
	for _=1, math.random(10, 35) do
		local part = Instance.new("Part")
		part.Anchored = true
		
		part:PivotTo(CFrame.new(digPosition))
		part.Size = Vector3.one
		
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		
		part.Color = materialColor
		part.TopSurface = Enum.SurfaceType.Smooth
		
		local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		local targetCF = CFrame.new(part:GetPivot().Position + Vector3.new(rndPos(), rndPos(), rndPos())) * CFrame.Angles(rndRot(), rndRot(), rndRot())
		TweenService:Create(part, tweenInfo, {
			CFrame = targetCF
		}):Play()
		TweenService:Create(part, tweenInfo, {
			Size = Vector3.zero
		}):Play()
		TweenService:Create(part, tweenInfo, {
			Transparency = 1
		}):Play()
		
		part.Parent = workspace.Terrain
		
		Debris:AddItem(part, tweenInfo.Time)
	end
	
	local particlePart = ReplicatedStorage.Assets.Particles.DigHit:Clone()
	particlePart:PivotTo(CFrame.new(digPosition, char:GetPivot().Position))
	particlePart.Parent = workspace.Terrain
	
	local emitter = particlePart.MIDDLE.MAIN
	task.delay(0.1, function()
		emitter:Emit(math.random(1, 7))
		emitter.Color = ColorSequence.new(materialColor)
		Debris:AddItem(particlePart, emitter.Lifetime.Max)
	end)
end

function DiggingController:TapEffect()
	local frame = Instance.new("Frame")
	frame.Name = "Tap"
	
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	frame.Size = UDim2.fromScale(0, 0)
	
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 0.5
	
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.Parent = frame
	
	local corner = Instance.new("UICorner")
	corner.Parent = frame
	corner.CornerRadius = UDim.new(1, 0)
	
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(frame, tweenInfo, {
		Size = UDim2.fromScale(0.2, 0.2)
	}):Play()
	TweenService:Create(frame, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	
	Debris:AddItem(frame, tweenInfo.Time)
	
	frame.Parent = self.screenGui
end

function DiggingController:UpdateCooldownGui()
	local digCooldownCanvas = player.PlayerGui:WaitForChild("Main"):WaitForChild("DigCooldown")
	digCooldownCanvas.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	
	local playerDataFold: Folder? = player:FindFirstChild("Data")
	if not playerDataFold then
		return
	end
	local equippedToolIndex = math.min(playerDataFold.ToolEquipped.Value, 1)
	local toolData = Digging.Tools[equippedToolIndex]
	
	digCooldownCanvas.Container.Fill.Size = UDim2.fromScale(1 - math.clamp((tick() - lastDig) / toolData.Cooldown, 0, 1), 1)
	digCooldownCanvas.Visible = true
end

function DiggingController:ManageFullInventory()
	local dataFold: Folder = player:FindFirstChild("Data")
	local storage: NumberValue, dirt: NumberValue = dataFold.Storage, dataFold.Dirt
	
	local function checkFull()
		self.storageIsFull:set(dirt.Value >= storage.Value)
	end
	
	storage.Changed:Connect(checkFull)
	dirt.Changed:Connect(checkFull)
	checkFull()
end

function DiggingController:ManageTeleportButton()
	local teleportButtonCanvas = self.mainGui.Sides.Bottom.Middle.Upper.GoUp
	
	self.GuiAnimationController:ObserveTaggedObject(teleportButtonCanvas, function(animationValues)
		self.scope:Observer(self.teleportButtonShown):onBind(function()
			local shown = peek(self.teleportButtonShown)
			if shown then
				Sound.new(SoundService.SoundEffects.Gui.BigPop)
			end
			
			animationValues.size:set(shown and peek(animationValues.startSize) or UDim2.new())
		end)
		
		self.scope:Hydrate(teleportButtonCanvas) {
			GroupTransparency = self.scope:Tween(self.scope:Computed(function(use: Fusion.Use)
				return use(self.teleportButtonShown) and 0 or 1
			end), Digging.Gui.TeleportButton.TWEEN_INFO),
		}
		self.scope:Hydrate(teleportButtonCanvas.Message) {
			Text = self.scope:Computed(function(use: Fusion.Use)
				return use(self.storageIsFull) and "Go Up!" or "Go Up?"
			end)
		}
		
		teleportButtonCanvas.Interact.MouseButton1Click:Connect(function()
			local playerData: Folder? = player:FindFirstChild("Data")
			if not playerData then
				return
			end
			self.PlayerController:TeleportToTopAttempt(player, playerData.CurrentWorld.Value)
		end)
		
		local lastBounce = tick()
		RunService.Heartbeat:Connect(function()
			local depth: number? = playerWorldDepth(player)
			if not depth then
				return
			end
			self.teleportButtonShown:set(depth >= Digging.MIN_DEPTH_TELEPORT)
			
			if peek(self.teleportButtonShown) and peek(self.storageIsFull) and tick() - lastBounce > Digging.Gui.TeleportButton.BOUNCE_COOLDOWN then
				lastBounce = tick()
				animationValues.sizeSpring:addVelocity(UDim2.fromScale(0.3, 0.3))
			end
		end)
	end)
end

function DiggingController:KnitInit()
	self.WorldTerrainController = Knit.GetController("WorldTerrainController")
	self.GuiAnimationController = Knit.GetController("GuiAnimationController")
	self.PlayerController = Knit.GetController("PlayerController")
	self.PopupController = Knit.GetController("PopupController")
	
	self.ProfileStoreService = Knit.GetService("ProfileStoreService")
	self.DiggingService = Knit.GetService("DiggingService")
	
	self.ProfileStoreService.ProfileLoaded:Connect(function()
		self:ManageFullInventory()
	end)
	
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	
	self:ManageAddedCharacter(player.Character)
	player.CharacterAdded:Connect(function(addedChar)
		self:ManageAddedCharacter(addedChar)
	end)
	
	self.playerGui = player.PlayerGui
	self.mainGui = self.playerGui:WaitForChild("Main")
	
	self.scope = Fusion:scoped()
	self.screenGui = self.scope:New "ScreenGui" {
		Name = "DigEffects",
		Parent = Players.LocalPlayer.PlayerGui,
		ResetOnSpawn = false,
	}
	
	self.teleportButtonShown = self.scope:Value(false) :: Fusion.Value<boolean>
	self.storageIsFull = self.scope:Value(false) :: Fusion.Value<boolean>
	self:ManageTeleportButton()
	
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:TapEffect()
			self:Dig()
		end
	end)
	
	self.DiggingService.TriggerDigEffectsForPlayer:Connect(function(...)
		self:TriggerDigEffect(...)
	end)
	
	RunService.RenderStepped:Connect(function()
		self:UpdateCooldownGui()
	end)
end

return DiggingController
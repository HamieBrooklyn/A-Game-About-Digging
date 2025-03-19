-- Services --
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Containers --
local Packages = ReplicatedStorage.Packages
local Data = ReplicatedStorage.Source.Data

-- Modules --
local Knit = require(Packages.Knit)

local Materials = require(Data.Materials)
local Digging = require(Data.Digging)

local Sound = require(ReplicatedStorage.Source.Classes.Sound)

local getMaterialFromWorld = require(ReplicatedStorage.Source.Utils.WorldTerrain.getMaterialFromWorld)

-- Controller --
local DiggingController = Knit.CreateController { Name = "DiggingController" }

-- Types --
type Self = typeof(DiggingController)

-- Local --
local player = Players.LocalPlayer

local char: Model?, hum: Humanoid?

local camera = workspace.Camera
local mouse = player:GetMouse()

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local digDB = false

-- function DiggingController:GetToolFromIndex(toolIndex: number)
-- 	for _, tool: Tool in ReplicatedStorage.Assets.Tools.Digging:GetChildren() do
-- 		if tool:GetAttribute("Index") ~= toolIndex then
-- 			continue
-- 		end
-- 		return tool
-- 	end
-- end

function DiggingController:Dig()
	if not char or not hum or hum.Health <= 0 then
		return
	end
	if digDB then
		return
	end
	
	raycastParams.FilterDescendantsInstances = {char:GetDescendants()}
	
	local origin = char:GetPivot().Position
	local direction = mouse.Hit.Position - origin
	local result: RaycastResult = workspace:Raycast(origin, direction * Digging.MAX_DIGGING_DISTANCE, raycastParams)
	if not result or not result.Instance:IsA("Terrain") then
		return
	end
	
	local playerDataFold: Folder? = player:FindFirstChild("Data")
	if not playerDataFold then
		return
	end
	local equippedToolIndex = math.min(playerDataFold.ToolEquipped.Value, 1)
	local currentWorld = playerDataFold.CurrentWorld.Value
	local material = getMaterialFromWorld(result.Material.Name, currentWorld, true).Name
	
	local toolData = Digging.Tools[equippedToolIndex]
	
	if not string.find(toolData.Terrain, material) then
		return
	end
	
	digDB = true
	task.delay(toolData.Cooldown, function()
		digDB = false
	end)
	
	local digPos = result.Position + camera.CFrame.LookVector * toolData.Radius / 2
	self.DiggingService:DigAttempt(digPos):andThen(function(digSuccess: boolean?)
		if not digSuccess then
			return
		end
		workspace.Terrain:FillBall(digPos, toolData.Radius, Enum.Material.Air)
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
		
		local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		local targetCF = CFrame.new(part:GetPivot().Position + Vector3.new(rndPos(), rndPos(), rndPos())) * CFrame.Angles(rndRot(), rndRot(), rndRot())
		TweenService:Create(part, tweenInfo, {
			CFrame = targetCF
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

function DiggingController:KnitInit()
	self.WorldTerrainController = Knit.GetController("WorldTerrainController")
	self.DiggingService = Knit.GetService("DiggingService")
	
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	
	self:ManageAddedCharacter(player.Character)
	player.CharacterAdded:Connect(function(addedChar)
		self:ManageAddedCharacter(addedChar)
	end)
	
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:Dig()
		end
	end)
	
	self.DiggingService.TriggerDigEffectsForPlayer:Connect(function(...)
		self:TriggerDigEffect(...)
	end)
end

return DiggingController
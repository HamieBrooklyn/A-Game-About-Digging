-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

local Digging = require(ReplicatedStorage.Source.Data.Digging)

-- Controller --
local DiggingController = Knit.CreateController { Name = "DiggingController" }

-- Types --
type Self = typeof(DiggingController)

-- Local --
local player = Players.LocalPlayer

local char: Model?, hum: Humanoid?

local mouse = player:GetMouse()

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

function DiggingController:Dig()
	if not char or not hum or hum.Health <= 0 then
		return
	end
	
	local origin = char:GetPivot().Position
	local direction = mouse.Hit.Position - origin
	local result: RaycastResult = workspace:Raycast(origin, direction * Digging.MAX_DIGGING_DISTANCE, raycastParams)
	if not result or not result.Instance:IsA("Terrain") then
		return
	end
	
	
end

function DiggingController:ManageAddedCharacter(addedChar: Model)
	if not addedChar then
		return
	end
	char = addedChar
	hum = char:FindFirstChildWhichIsA("Humanoid")
end

function DiggingController:KnitInit()
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
end

return DiggingController
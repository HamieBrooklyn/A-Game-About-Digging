--[[

--// EXAMPLE CODE //--

PopupController:SendIcons({
	["rbxassetid://12345"] = math.random(10, 25)
}, Udim2.new(0, 100, 0, 100))

]]

-- Services --
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Popups = require(ReplicatedStorage.Source.Data.Popups)

local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

local Children = Fusion.Children
local peek = Fusion.peek

-- Controller
local PopupController = Knit.CreateController { Name = "PopupController" }

-- Types --
type Self = typeof(PopupController)
type IconData = { iconId: string, destination: UDim2, place: number }

-- Local --
local player = Players.LocalPlayer

local mouse = player:GetMouse()

local rnd = Random.new()

function PopupController:SendIcons(icons: { [string]: number }, destination: UDim2)
	local newIconPopups = peek(self.iconPopups)
	for iconId, amount in icons do
		for i=1, amount do
			newIconPopups[HttpService:GenerateGUID()] = {
				destination = destination,
				iconId = iconId,
				place = i,
			}
		end
	end
	self.iconPopups:set(newIconPopups)
end

local function newIconPopup(self: Self, scope: Fusion.Scope, id: string, iconData: IconData): Fusion.Child
	local rndSize = rnd:NextNumber(Popups.IconPopups.ICON_SCALE_MIN, Popups.IconPopups.ICON_SCALE_MAX)
	local pos: Fusion.Value<Udim2> = scope:Value(UDim2.fromOffset(mouse.X, mouse.Y))
	local rot: Fusion.Value<number> = scope:Value(0)
	local imageTrans: Fusion.Value<number> = scope:Value(1)
	
	local tweenInfo = Popups.IconPopups.TWEEN_INFO
	local iconPopup = scope:New "ImageLabel" {
		Name = "IconPopup",
		
		AnchorPoint = Vector2.one * 0.5,
		Position = scope:Tween(pos, tweenInfo),
		Size = UDim2.fromScale(rndSize, rndSize),
		Rotation = scope:Tween(rot, tweenInfo),
		
		ImageTransparency = scope:Tween(imageTrans, tweenInfo),
		Image = iconData.iconId,
		
		BackgroundTransparency = 1,
		
		[Children] = {
			scope:New "UIAspectRatioConstraint" {},
		},
	}
	
	local function randomPos()
		return rnd:NextNumber(Popups.IconPopups.DISTANCE_FROM_MOUSE_MIN, Popups.IconPopups.DISTANCE_FROM_MOUSE_MAX)
	end
	
	pos:set(iconPopup.Position + UDim2.fromScale(randomPos(), randomPos()))
	rot:set(rnd:NextInteger(-360, 360))
	imageTrans:set(0)
	
	task.delay(Popups.IconPopups.TWEEN_TO_DESTINATION_DELAY + iconData.place / 100, function()
		pos:set(iconData.destination)
		imageTrans:set(1)
		
		task.wait(tweenInfo.Time)
		
		local newPopups = peek(self.iconPopups)
		newPopups[id] = nil
		self.iconPopups:set(newPopups)
	end)
	
	return iconPopup
end

function PopupController:KnitInit()
	self.scope = Fusion:scoped()
	
	self.iconPopups = self.scope:Value({}) :: Fusion.Value< { [string]: number } >
	
	self.scope:New "ScreenGui" {
		Name = "Popups",
		Parent = player:WaitForChild("PlayerGui"),
		
		ResetOnSpawn = false,
		
		[Children] = {
			self.scope:New "Folder" {
				Name = "IconPopups",
				[Children] = {
					self.scope:ForPairs(self.iconPopups, function(_use: Fusion.Use, scope: Fusion.Scope, id: number, iconData: IconData)
						return id, newIconPopup(self, scope, id, iconData)
					end)
				},
			},
		},
	}
end

return PopupController
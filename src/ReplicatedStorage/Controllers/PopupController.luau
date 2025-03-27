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
local SoundService = game:GetService("SoundService")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Popups = require(ReplicatedStorage.Source.Data.Player.Popups)

local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

local Children = Fusion.Children
local peek = Fusion.peek

local Sound = require(ReplicatedStorage.Source.Classes.Sound)

-- Controller
local PopupController = Knit.CreateController { Name = "PopupController" }

-- Types --
type Self = typeof(PopupController)
type IconData = { iconId: string, destination: UDim2, place: number, callback: (() -> ())? }
type Message = { messageType: string, message: string, textGradient: ColorSequence? }

-- Local --
local player = Players.LocalPlayer

local mouse = player:GetMouse()

local rnd = Random.new()

local messagesShownToggles: { [string]: Fusion.Value<boolean> } = {}

function PopupController:AddMessage(id: string, messageType: string, message: string, textGradient: ColorSequence?)
	local messagesTable = messageType == "Large" and self.largeMessages or
						  messageType == "Small" and self.smallMessages
	local newMessages = peek(messagesTable)
	newMessages[id] = {
		messageType = "Large",
		message = message,
		
		textGradient = textGradient,
	}
	messagesTable:set(newMessages)
	
	Sound.new(SoundService.SoundEffects.Gui.BigPop)
end

function PopupController:SetMessageShown(id: string, shown: boolean)
	messagesShownToggles[id]:set(shown)
end

function PopupController:RemoveMessage(id: string, messageType: string, ignoreFadeout: boolean?)
	local messagesTable = messageType == "Large" and self.largeMessages or
						  messageType == "Small" and self.smallMessages
	local newMessages = peek(messagesTable)
	if newMessages[id] then
		messagesShownToggles[id]:set(false)
		
		messagesShownToggles[id] = nil
		
		self.largeMessageTexts[id] = nil
		self.smallMessageTexts[id] = nil
		
		if ignoreFadeout then
			newMessages[id] = nil
		else
			task.delay(Popups.Messages.TWEEN_INFO.Time, function()
				newMessages[id] = nil
			end)
		end
	end
	messagesTable:set(newMessages)
end

function PopupController:SendIcons(icons: { [string]: number }, destination: UDim2, reachedDestination: () -> ())
	local newIconPopups = peek(self.iconPopups)
	for iconId, amount in icons do
		for i=1, amount do
			newIconPopups[HttpService:GenerateGUID()] = {
				callback = reachedDestination,
				
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
	
	local addedTime =  iconData.place / 20
	local halfTweenTime = (tweenInfo.Time + addedTime) / 2
	task.delay(Popups.IconPopups.TWEEN_TO_DESTINATION_DELAY + addedTime, function()
		pos:set(iconData.destination)
		imageTrans:set(1)
		
		task.wait(halfTweenTime)
		if iconData.callback then
			iconData.callback()
		end
		task.wait(halfTweenTime)
		
		local newPopups = peek(self.iconPopups)
		newPopups[id] = nil
		self.iconPopups:set(newPopups)
	end)
	
	return iconPopup
end

local function newMessage(self: Self, scope: Fusion.Scope, id: string, messageData: Message)
	local text = scope:Value(messageData.message)
	self.largeMessageTexts[id] = text
	
	local shown: Fusion.Value<boolean> = scope:Value(false)
	messagesShownToggles[id] = shown
	
	local label: TextLabel
	if messageData.messageType == "Large" then
		label = scope:New "TextLabel" {
			Name = id,
			Parent = player.PlayerGui:WaitForChild("Main").Messages.Large,
			
			AnchorPoint = Vector2.xAxis * 0.5,
			Size = scope:Spring(scope:Computed(function(use: Fusion.Use)
				return use(shown) and UDim2.fromScale(1, 0.2) or UDim2.fromScale(0, 0)
			end), 25, 0.8),
			
			Text = text,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = scope:Tween(scope:Computed(function(use: Fusion.Use)
				return use(shown) and 0 or 1
			end), Popups.Messages.TWEEN_INFO),
			Font = Enum.Font.FredokaOne,
			
			BackgroundTransparency = 1,
			
			[Fusion.Children] = {
				scope:New "UIGradient" { Color = messageData.textGradient, Rotation = 90, },
				scope:New "UIStroke" {
					LineJoinMode = Enum.LineJoinMode.Miter,
					Thickness = 4,
					
					Color = Color3.new(0.3, 0.3, 0.3),
					
					Transparency = scope:Tween(scope:Computed(function(use: Fusion.Use)
						return use(shown) and 0 or 1
					end), Popups.Messages.TWEEN_INFO),
				},
			},
		}
	end
	
	shown:set(true)
	
	return label
end

function PopupController:KnitInit()
	self.scope = Fusion:scoped()
	
	self.iconPopups = self.scope:Value({}) :: Fusion.Value< { [string]: number } >
	
	self.largeMessages = self.scope:Value({}) :: Fusion.Value< { [string]: Message } >
	self.smallMessages = self.scope:Value({}) :: Fusion.Value< { [string]: Message } >
	
	self.largeMessageTexts = {} :: { [string]: Fusion.Value<string> }
	self.smallMessageTexts = {} :: { [string]: Fusion.Value<string> }
	
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
			self.scope:New "Folder" {
				Name = "Messages",
				[Children] = {
					self.scope:New "Frame" {
						Name = "LargeMessages",
						
						AnchorPoint = Vector2.xAxis * 0.5,
						Position = UDim2.fromScale(0.5, 0.1),
						Size = UDim2.fromScale(0.5, 0.3),
						
						BackgroundTransparency = 1,
						
						[Children] = {
							self.scope:New "UIListLayout" { HorizontalAlignment = Enum.HorizontalAlignment.Center },
							self.scope:ForPairs(self.largeMessages, function(_use: Fusion.Use, scope: Fusion.Scope, id: string, messageData: Message)
								return id, newMessage(self, scope, id, messageData)
							end),
						},
					},
				},
			}
		},
	}
	
	-- task.delay(3, function()
	-- 	self:AddMessage("Test", "Large", "TESTING", ColorSequence.new(Color3.new(), Color3.new(1, 1, 1)))
	-- 	task.wait(3)
	-- 	self:SetMessageShown("Test", false)
	-- end)
end

return PopupController
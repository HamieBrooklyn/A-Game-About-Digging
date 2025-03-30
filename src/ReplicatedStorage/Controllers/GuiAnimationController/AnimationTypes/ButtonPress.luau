-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local GuiAnimation = require(ReplicatedStorage.Source.Data.Gui.GuiAnimation)

local Fusion = require(Packages.Fusion)

-- Variables --
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

-- Class --
local ButtonPress = {}
ButtonPress.__index = ButtonPress
type UsedAs = Fusion.UsedAs
type Self = typeof(ButtonPress)
export type Props = {}

function ButtonPress.new(taggedObject: GuiObject)
	local self = setmetatable({}, ButtonPress)
	self:init(taggedObject)
	return self
end

function ButtonPress:init(taggedObject: GuiObject)
	self.GuiAnimationController = require(script.Parent.Parent)
	self.animationValues = self.GuiAnimationController.animatedObjects[taggedObject]
	
	self.scope = Fusion:scoped() :: Fusion.Scope
	
	local interactButton: GuiButton = taggedObject:FindFirstChild(GuiAnimation.INTERACT_BUTTON_NAME)
	self.scope:Hydrate(interactButton) {
		[OnEvent("MouseButton1Down")] = function()
			self.animationValues.size:set(peek(self.animationValues.startSize) - UDim2.fromOffset(10, 10))
		end,
		[OnEvent("MouseButton1Up")] = function()
			self.animationValues.size:set(peek(self.animationValues.startSize))
		end,
	}
end

function ButtonPress:Destroy()
	self.scope:doCleanup()
end

return ButtonPress
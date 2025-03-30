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
local ButtonSelect = {}
ButtonSelect.__index = ButtonSelect
type UsedAs = Fusion.UsedAs
type Self = typeof(ButtonSelect)
export type Props = {}

function ButtonSelect.new(taggedObject: GuiObject)
	local self = setmetatable({}, ButtonSelect)
	self:init(taggedObject)
	return self
end

function ButtonSelect:init(taggedObject: GuiObject)
	self.GuiAnimationController = require(script.Parent.Parent)
	self.animationValues = self.GuiAnimationController.animatedObjects[taggedObject]
	
	self.scope = Fusion:scoped() :: Fusion.Scope
	
	local interactButton: GuiButton = taggedObject:FindFirstChild(GuiAnimation.INTERACT_BUTTON_NAME)
	self.scope:Hydrate(interactButton) {
		[OnEvent("MouseEnter")] = function()
			self.animationValues.size:set(peek(self.animationValues.startSize) + UDim2.fromOffset(10, 10))
		end,
		[OnEvent("MouseLeave")] = function()
			self.animationValues.size:set(peek(self.animationValues.startSize))
		end,
	}
end

function ButtonSelect:Destroy()
	self.scope:doCleanup()
end

return ButtonSelect
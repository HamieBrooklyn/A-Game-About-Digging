-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Fusion = require(Packages.Fusion)

-- Variables --
local peek = Fusion.peek

-- Class --
local ANIMATION_TYPE_NAME = {}
ANIMATION_TYPE_NAME.__index = ANIMATION_TYPE_NAME
type UsedAs = Fusion.UsedAs
type Self = typeof(ANIMATION_TYPE_NAME)
export type Props = {}

function ANIMATION_TYPE_NAME.new(taggedObject: GuiObject)
	local self = setmetatable({}, ANIMATION_TYPE_NAME)
	self:init(taggedObject)
	return self
end

function ANIMATION_TYPE_NAME:init(taggedObject: GuiObject)
	self.GuiAnimationController = require(script.Parent.Parent)
	self.animationValues = self.GuiAnimationController.animatedObjects[taggedObject]
	
	self.scope = Fusion:scoped() :: Fusion.Scope
end

function ANIMATION_TYPE_NAME:Destroy()
	self.scope:doCleanup()
end

return ANIMATION_TYPE_NAME
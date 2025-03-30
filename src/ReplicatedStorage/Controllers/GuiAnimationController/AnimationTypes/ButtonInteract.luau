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
local ButtonInteract = {}
ButtonInteract.__index = ButtonInteract
type UsedAs = Fusion.UsedAs
type Self = typeof(ButtonInteract)
export type Props = {}

function ButtonInteract.new(taggedObject: GuiObject)
	local self = setmetatable({}, ButtonInteract)
	self:init(taggedObject)
	return self
end

function ButtonInteract:init(taggedObject: GuiObject)
	self.GuiAnimationController = require(script.Parent.Parent)
	self.animationValues = self.GuiAnimationController.animatedObjects[taggedObject]
	
	self.scope = Fusion:scoped() :: Fusion.Scope
	
	local hovering: Fusion.Value<boolean> = self.scope:Value(false)
	local holding: Fusion.Value<boolean> = self.scope:Value(false)
	
	self.scope:Computed(function(use: Fusion.Use)
		local startSize = peek(self.animationValues.startSize)
		
		local hov, hol = use(hovering), use(holding)
		self.animationValues.size:set(
			(hov and not hol) and startSize + UDim2.fromOffset(10, 10) or
			(hov and hol) and startSize - UDim2.fromOffset(10, 10) or
			startSize
		)
	end)
	
	local interactButton: GuiButton = taggedObject:FindFirstChild(GuiAnimation.INTERACT_BUTTON_NAME)
	self.scope:Hydrate(interactButton) {
		[OnEvent("MouseEnter")] = function()
			hovering:set(true)
		end,
		[OnEvent("MouseLeave")] = function()
			hovering:set(false)
		end,
		[OnEvent("MouseButton1Down")] = function()
			holding:set(true)
		end,
		[OnEvent("MouseButton1Up")] = function()
			holding:set(false)
		end,
	}
end

function ButtonInteract:Destroy()
	self.scope:doCleanup()
end

return ButtonInteract
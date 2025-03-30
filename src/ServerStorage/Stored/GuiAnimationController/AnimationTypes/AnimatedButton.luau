-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Fusion = require(Packages.Fusion)

-- Variables --
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

-- Class --
local AnimatedButton = {}
AnimatedButton.__index = AnimatedButton
type UsedAs = Fusion.UsedAs
type Self = typeof(AnimatedButton)
export type Props = {}

function AnimatedButton.new(...)
	local self = setmetatable({}, AnimatedButton)
	self:init(...)
	return self
end

function AnimatedButton:init(buttonParent: GuiObject)
	self.scope = Fusion:scoped() :: Fusion.Scope
	
	self.startSize = buttonParent.Size
	self.size = self.scope:Value(self.startSize) :: Fusion.Value<Udim2>
	self.sizeSpring = self.scope:Spring(self.size, 30, 0.8) :: Fusion.Spring
	
	self.scope:Hydrate(buttonParent) {
		Size = self.sizeSpring,
	}
	
	local button: GuiButton = buttonParent:FindFirstChild("Interact")
	self.scope:Hydrate(button) {
		[OnEvent("MouseEnter")] = function()
			self.size:set(self.startSize + UDim2.fromOffset(10, 10))
		end,
		[OnEvent("MouseLeave")] = function()
			self.size:set(self.startSize)
		end,
		[OnEvent("MouseButton1Down")] = function()
			self.size:set(self.startSize - UDim2.fromOffset(10, 10))
		end,
		[OnEvent("MouseButton1Up")] = function()
			self.size:set(self.startSize)
		end,
	}
end

function AnimatedButton:Destroy()
	self.scope:doCleanup()
end

return AnimatedButton
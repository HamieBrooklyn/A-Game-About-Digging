-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Fusion = require(Packages.Fusion)

local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

-- Class --
local CloseButton = {}
CloseButton.__index = CloseButton
type UsedAs = Fusion.UsedAs
type Self = typeof(CloseButton)
export type Props = {}

function CloseButton.new(button: GuiButton)
	local self = setmetatable({}, CloseButton)
	self:init(button)
	return self
end

function CloseButton:init(button: GuiButton)
	self.scope = Fusion:scoped() :: Fusion.Scope
	
	local menuTargetValue: ObjectValue = button:WaitForChild("Target")
	
	self.scope:Hydrate(button) {
		[OnEvent "MouseButton1Click"] = function()
			local menu: GuiObject? = menuTargetValue.Value
			if menu then
				menu.Visible = false
			end
		end
	}
end

function CloseButton:Destroy()
	self.scope:doCleanup()
end

return CloseButton
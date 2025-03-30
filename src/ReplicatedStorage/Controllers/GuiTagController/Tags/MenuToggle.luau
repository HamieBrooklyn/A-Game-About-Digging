-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Fusion = require(Packages.Fusion)

local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

-- Class --
local MenuToggle = {}
MenuToggle.__index = MenuToggle
type UsedAs = Fusion.UsedAs
type Self = typeof(MenuToggle)
export type Props = {}

function MenuToggle.new(button: GuiButton)
	local self = setmetatable({}, MenuToggle)
	self:init(button)
	return self
end

function MenuToggle:init(button: GuiButton)
	self.scope = Fusion:scoped() :: Fusion.Scope
	
	local menuTargetValue: ObjectValue = button:WaitForChild("Target")
	
	self.scope:Hydrate(button) {
		[OnEvent "MouseButton1Click"] = function()
			local menu: GuiObject? = menuTargetValue.Value
			if menu then
				menu.Visible = not menu.Visible
			end
		end
	}
end

function MenuToggle:Destroy()
	self.scope:doCleanup()
end

return MenuToggle
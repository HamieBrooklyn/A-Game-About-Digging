local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local OnEvent = Fusion.OnEvent

local function Animate(scope: Fusion.Scope, button: GuiButton)
	local parent = button.Parent
	
	local isEntered = false
	
	local startSize = parent.Size
	
	local size: Fusion.Value<boolean> = scope:Value(parent.Size)
	local sizeSpring = scope:Spring(size, 25, 0.9)
	scope:Hydrate(parent) {
		Size = sizeSpring,
	}
	scope:Hydrate(button) {
		[OnEvent("MouseButton1Down")] = function()
			size:set(startSize + UDim2.fromOffset(-10, -10))
		end,
		[OnEvent("MouseButton1Up")] = function()
			size:set(isEntered and startSize + UDim2.fromOffset(10, 10) or startSize)
		end,
		[OnEvent("MouseEnter")] = function()
			isEntered = true
			size:set(startSize + UDim2.fromOffset(10, 10))
		end,
		[OnEvent("MouseLeave")] = function()
			isEntered = false
			size:set(startSize)
		end,
	}
end
return Animate
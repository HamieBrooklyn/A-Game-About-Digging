-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Moduoles --
local abbreviateNumber = require(ReplicatedStorage.Source.Utils.Abbreviation.abbreviateNumber)

local Knit = require(Packages.Knit)

-- Controller
local GuiAnimationController = Knit.CreateController { Name = "GuiAnimationController" }

-- Types --
type Self = typeof(GuiAnimationController)

-- Local --
local startSizes: { [GuiObject]: UDim2 } = {}

function GuiAnimationController:CountLabelTo(label: TextLabel, from: number, to: number, ignoreAbbreviation: boolean?)
	local difference = to - from
	if difference == 0 then
		return to
	end
	
	local value = from
	task.spawn(function()
		while value ~= to do
			value += (difference > 0) and 1 or -1
			label.Text = not ignoreAbbreviation and abbreviateNumber(value) or value
			task.wait()
		end
	end)
end

function GuiAnimationController:Bounce(instance: GuiObject, tweenInfo: TweenInfo?, intensity: number?)
	local savedStartSize = startSizes[instance]
	local startSize = savedStartSize or instance.Size
	if not savedStartSize then
		startSizes[instance] = startSize
	end
	
	tweenInfo = tweenInfo or TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	intensity = intensity or 1
	
	local tween = TweenService:Create(instance, tweenInfo, {
		Size = startSize + UDim2.fromOffset(10 * intensity, 10 * intensity)
	})
	tween:Play()
	tween.Completed:Once(function()
		TweenService:Create(instance, tweenInfo, {
			Size = startSize
		}):Play()
	end)
end

function GuiAnimationController:KnitInit()end

return GuiAnimationController
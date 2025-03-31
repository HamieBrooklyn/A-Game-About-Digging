local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Knit = require(game.ReplicatedStorage:WaitForChild("Packages").Knit)

--[[

How to add new frames:
1. Add a tag to your frame called "Focus"
2. If you want to customize the frame settings then you can do that three ways:
-- Add their data to the "FRAME_SIDE_DATA" variable by typing out this: ["YOUR_FRAME_NAME"] = {"HIDDEN_SIDES"} (also shown as the examples)
-- Add some attributes to your frame. The following are implemented:
	IgnoreAnimation - If set to true, will not tween the frame in a popup animation.
	IgnoreZoom - If true will ignore the zoom effect given to the camera when the frame is focused on.
	IgnoreBlur - Same as zoom but for blur effect.
	IgnoreHiddenSides - if set to true, will ignore hiding any sides.
-- Changing the overall settings bellow starting and ending with "-- SETTINGS --"

Signals that can be accessed directly from the required module:
-- FrameFinishedFocusing: Gets fired when a frame is finished focusing and fully visible or invisible,
it also sends the frame that was finished focusing

Example on how to use signals from this module:
FrameHandler.FrameFinishedFocusing:Connect(function(frameFocused: Frame?)
	print(frameFocused.. " finished focusing")
end)

]]

-- SETTINGS --
local MAIN_SCREEN_GUI_NAME = "Main"
local DEFAULT_HIDDEN_SIDES = {"All"}
local HIDE_BY_DEFAULT = true
local SIDES_SPEED = 0.2
local FRAME_SIDE_DATA = {}
local SIDES_DATA = {
	{"Left", UDim2.fromScale(-1.5, 0)};
	{"Right", UDim2.fromScale(1.5, 0)};
	{"Top", UDim2.fromScale(0, -1.5)};
	{"Bottom", UDim2.fromScale(0, 1.5)};
}

local ANIMATE_BY_DEFAULT = true
local ANIMATION_SPEED = 0.2

local ZOOM_BY_DEFAULT = true
local ZOOMED_FOV = 85
local ZOOM_SPEED = 0.5

local BLUR_BY_DEFAULT = true
local BLUR_INTENSITY = 13
local BLUR_SPEED = 0.2
-- SETTINGS --

shared.Directions = {
	["Up"] = UDim2.fromScale(0, -1);
	["Down"] = UDim2.fromScale(0, 1);
	["Left"] = UDim2.fromScale(-1, 0);
	["Right"] = UDim2.fromScale(1, 0);
}

local regularFov = workspace.Camera.FieldOfView
local _blur: BlurEffect;
local _frameCounters = {}
local _focusFramesVisible = {}

local lockedFocus: Frame?;

local MenuFocusController = Knit.CreateController {
	Name = "MenuFocusController";
	CurrentFocus = nil;
	_Signals = {
		FrameFinishedFocusing = Instance.new("BindableEvent");
	};
}

function MenuFocusController:FocusFrame(frame: Frame?, prop: boolean)
	if lockedFocus and lockedFocus ~= frame and prop then
		_frameCounters[frame] = 1
		frame.Visible = false
		return
	end
	
	if frame:HasTag("LockFocus") then
		lockedFocus = if prop then frame else nil
	end
	
	-- Getting the player's camera
	local camera = workspace.CurrentCamera
	
	-- Saving the frame's start size
	if not frame:GetAttribute("StartSize") then 
		frame:SetAttribute("StartSize", frame.Size)
	end
	local startSize = frame:GetAttribute("StartSize")
	local hiddenSize = UDim2.fromScale(0, 0)
	local prevFocus = self.CurrentFocus
	
	-- Checking if there is a previous focus and if it isnt the current frame then un-focus the previous frame
	if prevFocus and prevFocus ~= frame and not prevFocus:HasTag("DontHide") then
		_frameCounters[prevFocus] = 1
		self:FocusFrame(prevFocus, false)
	end
	
	-- Setting the size and visibilitty according to the proposition sent in
	frame.Size = if prop then hiddenSize else frame.Size
	frame.Visible = not prop
	if not prop then
		for i, data in _focusFramesVisible do
			local oldFrame: Frame = data[1]
			if oldFrame ~= frame then continue end
			oldFrame.ZIndex = oldFrame:GetAttribute("StartZIndex")
			table.remove(_focusFramesVisible, i)
		end
	end
	
	-- Getting the current focus and checking if it is the same as the sent in frame
	local currentFocus = self.CurrentFocus
	local ignoreEffects = currentFocus and currentFocus ~= frame
	
	-- Checking if the frame wants to ignore the animations, if it doesnt then checking if it should be animated by default
	if not frame:GetAttribute("IgnoreAnimation") and ANIMATE_BY_DEFAULT then
		local tween = Tween(frame, "Size", if prop then startSize else hiddenSize, ANIMATION_SPEED).Completed:Once(function()
			if not prop then
				frame.Visible = false
			end
			self._Signals.FrameFinishedFocusing:Fire(frame)
		end)
	else
		self._Signals.FrameFinishedFocusing:Fire(frame)
	end
	
	-- Checking if there is a prioratized frame above this frame or if the frame itself is ignoring the effect. If so then ignore the effects
	local topFocus = _focusFramesVisible[1]
	local function ignoreEffect(ignoreKey: string)
		local topIgnore = (topFocus and topFocus[1] ~= frame and not topFocus[1]:GetAttribute("Ignore".. ignoreKey))
		return frame:GetAttribute("Ignore".. ignoreKey) or topIgnore
	end
	
	-- Doing the same as for the animation but now for the zoom effect
	if not ignoreEffect("Zoom") and ZOOM_BY_DEFAULT then
		Tween(camera, "FieldOfView", if prop then ZOOMED_FOV else regularFov, ZOOM_SPEED)
	end
	
	-- Doing the same as for the zoom but now for the blur effect
	if not ignoreEffect("Blur") and BLUR_BY_DEFAULT  then
		Tween(_blur, "Size", if prop then BLUR_INTENSITY else 0, BLUR_SPEED)
	end
	
	-- Doing the same as for the blur but now for the sides hiding
	if not ignoreEffect("HiddenSides") then
		local specifiedSides = FRAME_SIDE_DATA[frame.Name]
		if specifiedSides then
			self:HideSides(specifiedSides, frame.Visible)
		elseif not specifiedSides and HIDE_BY_DEFAULT then
			self:HideSides(DEFAULT_HIDDEN_SIDES, frame.Visible)
		end
	end
	
	-- If the should be shown then setting the frame visible to true
	if prop then
		frame.Visible = true
		local topIndex = frame.ZIndex
		for _, data in _focusFramesVisible do
			if data[2] < topIndex then continue end
			topIndex = data[2] + 1
		end
		if not frame:GetAttribute("StartZIndex") then
			frame:SetAttribute("StartZIndex", frame.ZIndex)
		end
		frame.ZIndex = topIndex
		table.insert(_focusFramesVisible, {frame, topIndex})
		table.sort(_focusFramesVisible, function(a, b)
			return a[2] > b[2]
		end)
	end
	
	-- Setting the current focus to the frame if it is shown else removing the current focus if it is hidden and the current focus is the same frame that was sent in
	self.CurrentFocus = if not prop and self.CurrentFocus == frame then nil else frame
end
shared.FocusFrame = MenuFocusController.FocusFrame

function MenuFocusController:HideSides(sides: {string}, prop: boolean)
	task.spawn(function()
		-- Getting the player and finding theur sides container
		local player = Players.LocalPlayer
		local playerGui = player:WaitForChild("PlayerGui")
		
		local main: ScreenGui = playerGui:WaitForChild(MAIN_SCREEN_GUI_NAME)
		local sidesContainer: Folder = main:WaitForChild("Sides")
		
		-- Tweening the sides to if they should be hidden or shown
		local function manageSide(sideName: string)
			local side: Frame? = sidesContainer:FindFirstChild(sideName)
			local sideData = GetSideData(sideName)
			if not side then return end
			if not sideData then warn(`No side data was found for {sideName} inside of SIDES_DATA`) return end
			local pos = UDim2.fromScale(sideData[2].X.Scale * side.Size.X.Scale, sideData[2].Y.Scale * side.Size.Y.Scale)
			if side:GetAttribute("Hidden") == nil then
				side:SetAttribute("HiddenPosition", side.Position + pos)
				side:SetAttribute("ShownPosition", side.Position)
			end
			local hidden = if side:GetAttribute("Hidden") then true else false
			local targetPos = if not hidden then side:GetAttribute("HiddenPosition") else side:GetAttribute("ShownPosition")
			Tween(side, "Position",	targetPos, SIDES_SPEED)
			side:SetAttribute("Hidden", not hidden)
		end
		
		-- Checking if the sides data wants to hide or show all of the sides
		if table.find(sides, "All") then
			for _, sideData in SIDES_DATA do
				manageSide(sideData[1])
			end
			return
		end
		
		-- Hiding ot showing the specified sides
		for _, sideName: string in sides do
			manageSide(sideName)
		end
	end)
end

function MenuFocusController:KnitInit()
	-- Setting up the signals so that they are accessible from the required module directly
	for name: string, signal: BindableEvent in self._Signals do
		self[name] = signal.Event
	end
	
	-- Managing the frame visibility and looking for when a frame becomes visible or invisible
	local function manageFrame(frame: Frame?)
		if not frame:IsDescendantOf(Players.LocalPlayer) then
			return
		end
		local success = pcall(function()
			if frame.Visible == nil then return end
		end)
		if not success then return end
		_frameCounters[frame] = 0
		frame.Changed:Connect(function(property)
			if property ~= "Visible" then return end
			if _frameCounters[frame] > 0 then _frameCounters[frame] -= 1 return end
			_frameCounters[frame] = 2
			self:FocusFrame(frame, frame.Visible)
		end)
		if frame.Visible then
			_frameCounters[frame] = 2
			self:FocusFrame(frame, true)
		end
	end
	
	-- Checking for added focus tags and setting up the frame screen blur
	CollectionService:GetInstanceAddedSignal("Focus"):Connect(manageFrame)
	for _, focusFrame: Frame? in CollectionService:GetTagged("Focus") do
		manageFrame(focusFrame)
	end
	SetupBlur()
end

function GetSideData(sideName: string)
	for _, sideData in SIDES_DATA do
		if sideData[1] ~= sideName then continue end
		return sideData
	end
end

function SetupBlur()
	local newBlur = Instance.new("BlurEffect")
	newBlur.Size = 0
	newBlur.Parent = game.Lighting
	newBlur.Name = "FocusBlur"
	_blur = newBlur
end

function Tween(object: GuiObject, property: string, value: any, speed: number, customtweenInfo: TweenInfo?)
	local tween = TweenService:Create(
		object,
		customtweenInfo or TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{[property] = value}
	)
	tween:Play()
	return tween
end

return MenuFocusController
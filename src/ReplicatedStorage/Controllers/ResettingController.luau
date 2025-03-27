-- Services --
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Resetting = require(ReplicatedStorage.Source.Data.Worlds.Resetting)

local Fusion = require(Packages.Fusion)
local Signal = require(Packages.Signal)
local Knit = require(Packages.Knit)

local formatTime = require(ReplicatedStorage.Source.Utils.Abbreviation.formatTime)

-- Controller
local ResettingController = Knit.CreateController { Name = "ResettingController" }

-- Types --
type Self = typeof(ResettingController)

-- Local --
local streamingResetLabels: { [number]: TextLabel } = {}

function ResettingController:ObserveResetTime(newTime: number)
	for _, label in streamingResetLabels do
		local text = `Ground reset in: {formatTime(newTime)}`
		label.Text = text
		
		local messageTextVal: Fusion.Value<string>? = self.PopupController.largeMessageTexts["Resetting"]
		if newTime > 10 then
			if messageTextVal then
				self.PopupController:RemoveMessage("Resetting", "Large")
			end
			continue
		end
		
		if not messageTextVal then
			self.PopupController:AddMessage("Resetting", "Large", text, ColorSequence.new(
				Color3.fromHex("#FF0066"),
				Color3.fromHex("#9F2354")
			))
		else
			messageTextVal:set(text)
		end
	end
end

function ResettingController:ManageReset()
	print("RESET!")
end

local function onBoardAdded(board: BillboardGui)
	table.insert(streamingResetLabels, board:FindFirstChildWhichIsA("TextLabel"))
end

local function onBoardRemoved(board: BillboardGui)
	local labelIndex = table.find(streamingResetLabels, board:FindFirstChildWhichIsA("TextLabel"))
	if labelIndex then
		table.remove(streamingResetLabels, labelIndex)
	end
end

function ResettingController:KnitInit()
	self.PopupController = Knit.GetController("PopupController")
	
	self.Reset = Signal.new()
	
	local ResettingService = Knit.GetService("ResettingService")
	ResettingService.TimeUntilReset:Observe(function(...)
		self:ObserveResetTime(...)
	end)
	ResettingService.Reset:Connect(function()
		self:ManageReset()
		self.Reset:Fire()
	end)
	
	local tag = Resetting.Terrain.BOARD_TAG
	CollectionService:GetInstanceAddedSignal(tag):Connect(onBoardAdded)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(onBoardRemoved)
	for _, board in CollectionService:GetTagged(tag) do
		onBoardAdded(board)
	end
end

return ResettingController
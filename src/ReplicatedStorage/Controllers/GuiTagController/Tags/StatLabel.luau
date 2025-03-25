-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

local abbreviateNumber = require(ReplicatedStorage.Source.Utils.abbreviateNumber)

-- Variables --
local peek = Fusion.peek

-- Class --
local StatLabel = {}
StatLabel.__index = StatLabel
type UsedAs = Fusion.UsedAs
type Self = typeof(StatLabel)
export type Props = {}

function StatLabel.new(label: GuiLabel)
	local self = setmetatable({}, StatLabel)
	Knit.GetService("ProfileStoreService").ProfileLoaded:Connect(function()
		self:init(label)
	end)
	return self
end

local function countToTarget(setVal: Fusion.Value<number>, startValue: number, endValue: number)
	local difference = endValue - startValue
	if difference == 0 then
		return endValue
	end
	
	local incrementTime = 0.01 / math.abs(difference)
	local value = startValue
	
	task.spawn(function()
		while value ~= endValue do
			value += (difference > 0) and 1 or -1
			setVal:set(value)
			task.wait()
		end
	end)
end

function StatLabel:init(label: GuiLabel)
	self.scope = Fusion:scoped() :: Fusion.Scope
	
	local statValsLast: { [NumberValue]: number } = {}
	local statVals: { [number]: NumberValue } = {}
	
	local pathsString = label:GetAttribute("StatPath")
	for _, path in string.split(pathsString, ",") do
		local waypointNames = string.split(path, "/")
		
		local waypoint: GuiLabel = Players.LocalPlayer
		for i, nextWaypointName in waypointNames do
			waypoint = waypoint:WaitForChild(nextWaypointName)
			if i == #waypointNames then
				break
			end
		end
		
		table.insert(statVals, waypoint)
		statValsLast[waypoint] = waypoint.Value
	end
	
	local checkScope: Fusion.Scope = Fusion:scoped()
	table.insert(self.scope, checkScope)
	
	local labelType = label:GetAttribute("Type")
	local function check(value: number)
		checkScope:doCleanup()
		
		task.delay(1.5, function()
			local values: { [number]: NumberValue } = {}
			for i, val in statVals do
				local lastValue = statValsLast[val] or val.Value
				local newValue = val.Value
				
				local counter: Fusion.Value<number> = checkScope:Value(lastValue)
				values[i] = checkScope:New "NumberValue" {
					Value = checkScope:Tween(counter, TweenInfo.new(0.2))
				}
				counter:set(newValue)
				
				statValsLast[val] = newValue
			end
			if labelType == "MinMax" then
				local minVal, maxVal = values[1], values[2]
				local function set()
					local min, max = abbreviateNumber(math.floor(minVal.Value)), abbreviateNumber(math.floor(maxVal.Value))
					label.Text = `{min} / {max}`
				end
				table.insert(checkScope, minVal.Changed:Connect(set))
				table.insert(checkScope, maxVal.Changed:Connect(set))
				set()
			elseif labelType == "Single" then
				local val = values[1]
				local function set()
					label.Text = abbreviateNumber(math.floor(val.Value))
				end
				table.insert(checkScope, val.Changed:Connect(set))
				set()
			end
		end)
	end
	
	for _, statVal in statVals do
		table.insert(self.scope, statVal.Changed:Connect(check))
		check(statVal.Value)
	end
end

function StatLabel:Destroy()
	self.scope:doCleanup()
end

return StatLabel
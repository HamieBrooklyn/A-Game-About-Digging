local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.Signal)
local Fusion = require(Packages.Fusion)
local _peek = Fusion.peek

local Sound = {}
Sound.__index = Sound

type Self = typeof(Sound)
export type Props = {}

function Sound.new(
	sound: Instance | string,
	props: Props?,
	parent: Instance?,
	playOnAwake: boolean?,
	deleteOnEnd: boolean?,
	minSpeed: number?,
	maxSpeed: number?
)
	local self = setmetatable({}, Sound)
	self:init(sound, props, parent, playOnAwake, deleteOnEnd, minSpeed, maxSpeed)
	return self
end

local function getSound(self: Self, sound: Instance | string, props: Props?): Sound
	local out: Sound;
	if sound:IsA("Sound") then
		out = sound:Clone()
		table.insert(self.scope, out)
	elseif sound:IsA("string") then
		out = self.scope:New "Sound" { SoundId = sound }
	end
	if props then
		for key, value in props do
			out[key] = value
		end
	end
	return out
end

function Sound:init(
	sound: Instance | string,
	props: Props,
	parent: Instance?,
	playOnAwake: boolean?,
	deleteOnEnd: boolean?,
	minSpeed: number?,
	maxSpeed: number?
)
	local rnd = Random.new()
	
	self.scope = Fusion:scoped() :: Fusion.Scope
	self.ended = Signal.new()
	
	self.instance = getSound(self, sound, props)
	if minSpeed and maxSpeed then
		self.instance.PlaybackSpeed = rnd:NextNumber(minSpeed, maxSpeed)
	end
	self.instance.Parent = parent or workspace
	
	if playOnAwake == nil or playOnAwake then
		self:Play()
	end
	self.instance.Ended:Once(function()
		self.ended:Fire()
		if deleteOnEnd == nil or deleteOnEnd then
			self:Destroy()
		end
	end)
end

function Sound:Play()
	self.instance:Play()
end
function Sound:Stop()
	self.instance:Stop()
end
function Sound:Pause()
	self.instance:Pause()
end
function Sound:Resume()
	self.instance:Resume()
end

function Sound:Destroy()
	self.scope:doCleanup()
	self.ended:Destroy()
end

return Sound
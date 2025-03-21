-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Fusion = require(Packages.Fusion)

-- Variables --
local peek = Fusion.peek

-- Class --
local TAG_NAME = {}
TAG_NAME.__index = TAG_NAME
type UsedAs = Fusion.UsedAs
type Self = typeof(TAG_NAME)
export type Props = {}

function TAG_NAME.new(instance: Instance)
	local self = setmetatable({}, TAG_NAME)
	self:init(instance)
	return self
end

function TAG_NAME:init(instance: Instance)
	self.scope = Fusion:scoped() :: Fusion.Scope
end

function TAG_NAME:Destroy()
	self.scope:doCleanup()
end

return TAG_NAME
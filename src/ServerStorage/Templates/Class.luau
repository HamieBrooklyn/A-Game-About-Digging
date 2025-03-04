local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)
local peek = Fusion.peek

local Class = {}
Class.__index = Class

type UsedAs = Fusion.UsedAs
type Self = typeof(Class)
export type Props = {}

function Class.new(props: Props)
	local self = setmetatable({}, Class)
	self:init(props)
	return self
end

function Class:init(props: Props)
	self.scope = Fusion:scoped() :: Fusion.Scope
end

function Class:Destroy()
	self.scope:doCleanup()
end

return Class
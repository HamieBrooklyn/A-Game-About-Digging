-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Packages --
local Fusion = require(Packages.Fusion)

-- Variables --
local peek = Fusion.peek

-- Class --
local PhysicalItemDrop = {}
PhysicalItemDrop.__index = PhysicalItemDrop
type UsedAs = Fusion.UsedAs
type Self = typeof(PhysicalItemDrop)
export type Props = {}

function PhysicalItemDrop.new(icon: string, start: Vector3, customRadius: number?)
	local self = setmetatable({}, PhysicalItemDrop)
	self:init(icon)
	return self
end

function PhysicalItemDrop:init(icon: string, start: Vector3, customRadius: number?)
	self.scope = Fusion:scoped() :: Fusion.Scope
	
end

function PhysicalItemDrop:Destroy()
	self.scope:doCleanup()
end

return PhysicalItemDrop
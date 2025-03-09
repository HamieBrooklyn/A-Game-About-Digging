local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)
local peek = Fusion.peek

local RichTerrain = {}
RichTerrain.__index = RichTerrain

type UsedAs = Fusion.UsedAs
type Self = typeof(RichTerrain)
export type Props = {}

function RichTerrain.new(props: Props)
	local self = setmetatable({}, RichTerrain)
	self:init(props)
	return self
end

function RichTerrain:init(props: Props)
	self.scope = Fusion:scoped() :: Fusion.Scope
end

function RichTerrain:Destroy()
	self.scope:doCleanup()
end

return RichTerrain
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)

local scope = Fusion:scoped()
local controls = {}

type Props = {
	controls: typeof(controls)
}
return {
	controls = controls,
	story = function(_props: Props)
		return 
	end,
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Types = {}

export type ItemData = {
	name: string,
	amount: number,
}
export type ItemDataState = {
	name: string,
	amount: Fusion.Value<number>,
}

return Types
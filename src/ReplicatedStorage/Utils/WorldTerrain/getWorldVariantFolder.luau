local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getWorldVariantFolder(worldIndex: number): Folder?
	return ReplicatedStorage.Assets.MaterialVariants.Worlds:FindFirstChild(tostring(worldIndex))
end

return getWorldVariantFolder
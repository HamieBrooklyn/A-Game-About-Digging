local getWorldVariantFolder = require(script.Parent.getWorldVariantFolder)

local function getMaterialFromWorld(materialName: string, worldIndex: number, getVariant: boolean?): Enum.Material | MaterialVariant
	local worldVariantsFold: Folder? = getWorldVariantFolder(worldIndex)
	if not worldVariantsFold then
		return Enum.Material[materialName]
	end
	local variant: MaterialVariant? = worldVariantsFold:FindFirstChild(materialName)
	return if getVariant then variant else variant.BaseMaterial
end

return getMaterialFromWorld
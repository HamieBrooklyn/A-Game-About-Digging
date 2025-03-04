local function utilityName(items: {string: number}): string
	local totalWeight = 0
	for _, weight in pairs(items) do
		totalWeight += weight
	end
	local randomWeight = math.random(1, totalWeight)
	local currentWeight = 0
	for item, weight in pairs(items) do
		currentWeight += weight
		if randomWeight <= currentWeight then
			return item
		end
	end
end
return utilityName
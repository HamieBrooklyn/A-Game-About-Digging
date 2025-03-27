local function fromRandomWeight(items: {string: number}, seed: number?): string
	local rnd = seed and Random.new(seed) or Random.new()
	local totalWeight = 0
	for _, weight in pairs(items) do
		totalWeight += weight
	end
	local randomWeight = rnd:NextInteger(1, totalWeight)
	local currentWeight = 0
	for item, weight in pairs(items) do
		currentWeight += weight
		if randomWeight <= currentWeight then
			return item
		end
	end
end
return fromRandomWeight
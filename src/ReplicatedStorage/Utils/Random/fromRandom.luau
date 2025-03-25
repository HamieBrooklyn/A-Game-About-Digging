local function fromRandom(items: { [number]: any }, seed: number?)
	return items[Random.new(seed or tick()):NextInteger(1, #items)]
end
return fromRandom
local function getRandomPositionInPart(part: Part, seed: number?)
	local rnd = seed and Random.new(seed) or Random.new()
	local x = part.Position.X + rnd:NextNumber(-part.Size.X/2,part.Size.X/2)
	local y = part.Position.Y + rnd:NextNumber(-part.Size.Y/2,part.Size.Y/2)
	local z = part.Position.Z + rnd:NextNumber(-part.Size.Z/2,part.Size.Z/2)
	return Vector3.new(x, y, z)
end
return getRandomPositionInPart
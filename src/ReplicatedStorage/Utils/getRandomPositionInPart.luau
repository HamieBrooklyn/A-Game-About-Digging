local function getRandomPositionInPart(part: Part)
	local x = part.Position.X + math.random(-part.Size.X/2,part.Size.X/2)
	local y = part.Position.Y + math.random(-part.Size.Y/2,part.Size.Y/2)
	local z = part.Position.Z + math.random(-part.Size.Z/2,part.Size.Z/2)
	return Vector3.new(x, y, z)
end
return getRandomPositionInPart
local function isInBrick(position: Vector3, brick: BasePart)
    local v3 = brick.CFrame:PointToObjectSpace(position)
	return (math.abs(v3.X) <= brick.Size.X / 2)
		and (math.abs(v3.Y) <= brick.Size.Y / 2)
		and (math.abs(v3.Z) <= brick.Size.Z / 2)
end
return isInBrick
local function generateStudClusters(
	container: Instance?,
	position: Vector3,
	radius: number,
	takenPositions: { [Vector3]: Part }
)
	local tempPart = Instance.new("Part")
	tempPart.Size = Vector3.one
	tempPart.Anchored = true
	tempPart.CanCollide = false
	tempPart.CanQuery = false
	tempPart.CastShadow = false

	tempPart.Material = Enum.Material.Glass
	tempPart.Transparency = 1
	tempPart.Reflectance = -math.huge

	tempPart.Parent = container

	for x = 1, radius*2 do
		for y = 1, radius*2 do
			for z = 1, radius*2 do
				local worldSpace = Vector3.new(-x+position.X,-y+position.Y,-z+position.Z)

				if takenPositions[worldSpace] then
					continue
				end
				if Vector3.new(x-radius,y-radius,z-radius).Magnitude <= radius then
					local new = tempPart:Clone()
					new.CastShadow = false
					new.Parent = container
					new.Position = worldSpace
					
					task.spawn(function()
						for i=0.1, 2, 0.1 do
							new.Size = Vector3.one * i
							task.wait()
						end
					end)

					takenPositions[worldSpace] = new
				end
			end
		end
	end
	
	tempPart:Destroy()
end

return generateStudClusters
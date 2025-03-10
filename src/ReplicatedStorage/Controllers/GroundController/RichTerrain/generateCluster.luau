local function generateStudClusters(container: Instance?, position: Vector3, radius: number)
   local tempPart = Instance.new("Part")
	tempPart.Size = Vector3.one
	tempPart.Anchored = true
	tempPart.Parent = container
	
	for x = 1, radius*2 do
		for y = 1, radius*2 do
			for z = 1, radius*2 do
				local worldSpace = Vector3.new(-x+position.X,-y+position.Y,-z+position.Z)
				if Vector3.new(x-radius,y-radius,z-radius).Magnitude <= radius then
					local new = tempPart:Clone()
					new.CastShadow = false
					new.Parent = container
					new.Position = worldSpace
				end
			end
		end
	end
	
	tempPart:Destroy()
end

return generateStudClusters
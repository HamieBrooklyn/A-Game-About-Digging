local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Children = Fusion.Children

local function InfoWindow(
	scope: Fusion.Scope,
	texts: Fusion.Value<{String}>,
	gradients: Fusion.Value<{String}>,
	position: Fusion.Value<Udim2>
)
	return scope:New "Frame" {
		AnchorPoint = Vector2.yAxis,
		Size = UDim2.fromScale(0.2, 0.2),
		Position = position,
		
		BackgroundTransparency = 1,
		
		[Children] = {
			scope:ForPairs(texts, function(use: Fusion.Use, tempScope: Fusion.Scope, index: number, text: string)
				local length = #use(texts)
				local shown = tempScope:Value(false) :: Fusion.Value<boolean>
				task.delay(index / (length * 10), function()
					shown:set(true)
				end)
				
				return index, tempScope:New "Frame" {
					Name = index,
					LayoutOrder = length - index,
					
					Size = UDim2.fromScale(1, 0.2),
					
					BackgroundTransparency = 1,
					[Children] = {
						tempScope:New "TextLabel" {
							Size = UDim2.fromScale(1, 1),
							Position = tempScope:Spring(tempScope:Computed(function(useB)
								return useB(shown) and UDim2.fromScale(0, 0) or UDim2.fromScale(-0.5, 0)
							end), 45, 0.6),
							
							Font = Enum.Font.FredokaOne,
							
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTransparency = tempScope:Tween(tempScope:Computed(function(useB)
								return useB(shown) and 0 or 1
							end), TweenInfo.new(0.3)),
							TextColor3 = Color3.new(1, 1, 1),
							TextScaled = true,
							Text = text,
							
							BackgroundTransparency = 1,
							
							[Children] = {
								tempScope:New "UIStroke" {
									Thickness = 3,
									Color = Color3.fromRGB(95, 95, 95),
									LineJoinMode = Enum.LineJoinMode.Miter,
									Transparency = tempScope:Tween(tempScope:Computed(function(useB)
										return useB(shown) and 0 or 1
									end), TweenInfo.new(0.3)),
								},
								tempScope:New "UIGradient" {
									Rotation = 90,
									Color = tempScope:Computed(function(useB)
										local color = ColorSequence.new(Color3.new(1, 1, 1))
										
										if useB(gradients) then
											local gradientName = useB(gradients)[index]
											if gradientName then
												local gradient: UIGradient? = ReplicatedStorage.Gradients:FindFirstChild(gradientName)
												if gradient then
													color = gradient.Color
												end
											end
										end
										
										return color
									end),
								},
							},
						},
					},
				}
			end),
			scope:New "UIListLayout" {
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
		},
	}
end

return InfoWindow
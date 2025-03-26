-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Container --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Loading = require(ReplicatedStorage.Source.Data.Loading)

local TableUtil = require(Packages.TableUtil)
local Fusion = require(Packages.Fusion)

local Children = Fusion.Children
local peek = Fusion.peek

-- Child --
local function LoadingGui(
	scope: Fusion.Scope,
	shown: Fusion.Value<boolean>,
	progress: Fusion.Value<number>
): Fusion.Child
	local dots = scope:Value({}) :: Fusion.Value<{ [number]: Fusion.Value<boolean> }>
	local newDots = peek(dots)
	for _=1, 3 do
		table.insert(newDots, { trigger = scope:Value(false), done = scope:Value(false) })
	end
	dots:set(newDots)
	
	scope:Observer(progress):onChange(function()
		for i, data in TableUtil.Reverse(peek(dots)) do
			data.done:set(1 / i <= peek(progress))
		end
	end)
	
	local logoShown: Fusion.Value<boolean> = scope:Value(false)
	scope:Observer(shown):onBind(function()
		if not peek(shown) then
			logoShown:set(false)
			return
		end
		task.delay(Loading.Gui.TWEEN_INFO.Time, function()
			logoShown:set(true)
		end)
		task.spawn(function()
			task.wait(1)
			while peek(shown) do
				for _, data in peek(dots) do
					data.trigger:set(not peek(data.trigger))
					task.wait(Loading.Gui.Dots.JUMP_COOLDOWN)
				end
			end
		end)
	end)
	
	local function Dot(
		_use: Fusion.Use,
		dotScope: Fusion.Scope,
		index: number,
		data:Fusion.Value<{ trigger: Fusion.Value<boolean>, done: Fusion.Value<boolean> }>
	)
		local position: Fusion.Value<Udim2> = dotScope:Value(UDim2.new())
		local posSpring: Fusion.Spring = dotScope:Spring(position, 25, 0.8)
		dotScope:Observer(data.trigger):onChange(function()
			posSpring:addVelocity(UDim2.fromScale(0, -0.5))
		end)
		
		return dotScope:New "Frame" {
			Name = tostring(index),
			LayoutOrder = index,
			
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			
			[Children] = {
				dotScope:New "UIAspectRatioConstraint" {},
				dotScope:New "Frame" {
					Name = "Dot",
					
					AnchorPoint = Vector2.one * 0.5,
					Position = posSpring,
					Size = UDim2.fromScale(1, 1),
					
					BackgroundColor3 = dotScope:Tween(dotScope:Computed(function(use: Fusion.Use)
						return use(data.done) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
					end), Loading.Gui.TWEEN_INFO),
					BackgroundTransparency = 1,
					
					[Children] = {
						dotScope:New "UICorner" {
							CornerRadius = UDim.new(1, 0),
						},
						dotScope:New "UIStroke" {
							Transparency = 0.8,
							Color = dotScope:Tween(dotScope:Computed(function(use: Fusion.Use)
								return use(data.done) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
							end), Loading.Gui.TWEEN_INFO),
							Thickness = 6,
						}
					},
				}
			},
		}
	end
	
	
	return scope:New "CanvasGroup" {
		Name = "Main",
		
		AnchorPoint = Vector2.one * 0.5,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		
		BackgroundTransparency = 1,
		GroupTransparency = scope:Tween(scope:Computed(function(use: Fusion.Use)
			return use(shown) and 0 or 1
		end), Loading.Gui.TWEEN_INFO),
		
		[Children] = {
			scope:New "Frame" {
				Name = "Backdrop",
				Size = UDim2.fromScale(1, 1),
				[Children] = {
					scope:New "UIGradient" {
						Color = ColorSequence.new(
							Color3.fromHex("#73e49e"),
							Color3.fromHex("#0f68a9")
						),
						Rotation = 90,
					}
				},
			},
			scope:New "ImageLabel" {
				Name = "Logo",
				
				AnchorPoint = Vector2.one * 0.5,
				Position = scope:Spring(scope:Computed(function(use: Fusion.Use)
					return use(logoShown) and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.5, 0.6)
				end), 15, 0.8),
				Size = UDim2.fromScale(0.7, 0.4),
				
				Image = Loading.Gui.LOGO_ICON,
				ImageTransparency = scope:Tween(scope:Computed(function(use: Fusion.Use)
					return use(logoShown) and 0 or 1
				end), Loading.Gui.TWEEN_INFO),
				ScaleType = Enum.ScaleType.Fit,
				
				BackgroundTransparency = 1,
			},
			scope:New "Frame" {
				Name = "Dots",
				
				AnchorPoint = Vector2.one * 0.5,
				Position = UDim2.fromScale(0.5, 0.7),
				Size = UDim2.fromScale(0.2, 0.03),
				
				BackgroundTransparency = 1,
				
				[Children] = {
					scope:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						
						Padding = UDim.new(0.2, 0),
					},
					scope:ForPairs(dots, function(use, dotScope, index, data)
						return index, Dot(use, dotScope, index, data)
					end),
				},
			}
		},
	}
end

return LoadingGui
local Popups = {}

Popups.IconPopups = {
	TWEEN_INFO = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
	
	ICON_SCALE_MIN = 0.03,
	ICON_SCALE_MAX = 0.06,
	
	DISTANCE_FROM_MOUSE_MIN = -0.1,
	DISTANCE_FROM_MOUSE_MAX = 0.1,
	
	TWEEN_TO_DESTINATION_DELAY = 1,
}

Popups.Messages = {
	TWEEN_INFO = TweenInfo.new(0.2)
}

return Popups
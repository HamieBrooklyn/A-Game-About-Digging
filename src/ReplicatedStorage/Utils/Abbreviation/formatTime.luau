local function formatTime(seconds: number)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local remainingSeconds = seconds % 60
	
	-- Build the shortened string
	local result = ""
	if hours > 0 then
		result = result .. hours .. "h "
	end
	if minutes > 0 or hours > 0 then
		result = result .. minutes .. "m "
	end
	result = result .. remainingSeconds .. "s"
	
	-- Trim any trailing space
	return result:match("^%s*(.-)%s*$")
end
return formatTime

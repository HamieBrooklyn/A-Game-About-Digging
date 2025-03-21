local function abbreviateNumber(number)
	if number >= 1e9 then
		return string.format("%.1fb", number / 1e9)
	elseif number >= 1e6 then
		return string.format("%.1fm", number / 1e6)
	elseif number >= 1e3 then
		-- Add commas for numbers between 1,000 and 999,999
		local formatted = tostring(number)
		formatted = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse()
		if formatted:sub(1, 1) == "," then
			formatted = formatted:sub(2)
		end
		return formatted
	else
		-- No formatting needed for numbers below 1,000
		return tostring(number)
	end
end

return abbreviateNumber
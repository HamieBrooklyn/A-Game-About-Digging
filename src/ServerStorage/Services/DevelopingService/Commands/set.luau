local Command = {
	Key = "set";
	
	WordsAccepted = 3;
}

function Command.Trigger(player: Player, words: {string})
	-- Getting the stat Value
	local statVal: ValueBase;
	for _, setStatVal: ValueBase? in player:GetDescendants() do
		if string.lower(setStatVal.Name) ~= string.lower(words[1]) then continue end
		statVal = setStatVal
	end
	if not statVal then warn(`{words[1]} was not a stat found anywhere inside of {player}`) return end
	
	-- Setting the value
	local success, errMess = pcall(function()
		statVal.Value = words[2]
	end)
	if not success then warn(errMess) return end
	
	-- Returning true if everything worked
	return true
end

return Command

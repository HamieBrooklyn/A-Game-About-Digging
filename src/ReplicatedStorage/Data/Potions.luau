local Potions = {}

Potions["OrePotion"] = {
	Icon = "rbxassetid://94517821571661",
	Duration = 30,
	
	UseText = "Used ore potion!",
	UseGradient = "Blue",
	
	RunOutText = "Ore potion ran out",
	RunOutGradient = "Red",
	
	InfoWindow = {
		{ text = "2X Ores", gradient = "Blue" },
		{ text = "Not Stackable", gradient = "Red" },
	},
}

return Potions
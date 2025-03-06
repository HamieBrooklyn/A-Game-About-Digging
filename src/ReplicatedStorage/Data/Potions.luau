local Potions = {}

Potions["OrePotion"] = {
	FormattedName = "Ore Potion",
	
	Icon = "rbxassetid://94517821571661",
	Duration = 60,
	
	UseText = "Used Ore potion!",
	UseGradient = "Blue",
	
	RunOutText = "Ore Potion ran out",
	RunOutGradient = "Red",
	
	InfoWindow = {
		{ text = "More Ores", gradient = "Blue" },
		{ text = "Not Stackable", gradient = "Red" },
	},
}

Potions["DigPotion"] = {
	FormattedName = "Dig Potion",
	
	Icon = "rbxassetid://101899553050288",
	Duration = 60,
	
	UseText = "Used Dig potion!",
	UseGradient = "Green",
	
	RunOutText = "Dig Potion ran out",
	RunOutGradient = "Red",
	
	InfoWindow = {
		{ text = "Faster Digging", gradient = "Green" },
		{ text = "Not Stackable", gradient = "Red" },
	},
}

Potions["CoinPotion"] = {
	FormattedName = "Coin Potion",
	
	Icon = "rbxassetid://86378544094933",
	Duration = 60,
	
	UseText = "Used Coin potion!",
	UseGradient = "Gold",
	
	RunOutText = "Coin Potion ran out",
	RunOutGradient = "Red",
	
	InfoWindow = {
		{ text = "Coins from digging", gradient = "Gold" },
		{ text = "Not Stackable", gradient = "Red" },
	},
}

return Potions
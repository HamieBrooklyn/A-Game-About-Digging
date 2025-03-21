local Digging = {}

Digging.MAX_DIGGING_DISTANCE = 30

Digging.Tools = {
	[1] = {
		Name = "Hand Trowel",
		
		Cooldown = 0.5,
		Give = 1,
		Radius = 3,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Snow",
		DigType = "Click",
	},
	[2] = {
		Name = "Basic Shovel",
		
		Cooldown = 0.6,
		Give = 5,
		Radius = 4,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Snow",
		DigType = "Click",
	},
	[3] = {
		Name = "Wide Shovel",
		
		Cooldown = 0.65,
		Give = 10,
		Radius = 5,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Snow",
		DigType = "Click",
	},
	[4] = {
		Name = "Quick Shovel",
		
		Cooldown = 0.4,
		Give = 15,
		Radius = 6,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Snow",
		DigType = "Click",
	},
	[5] = {
		Name = "Drill",
		
		Cooldown = 0.5,
		Give = 20,
		Radius = 6,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Rock,Snow",
		DigType = "Hold",
	},
	[6] = {
		Name = "Snow Shovel",
		
		Cooldown = 0.5,
		Give = 25,
		Radius = 7.5,
		
		Terrain = "Grass,Snow",
		DigType = "Click",
	},
	[7] = {
		Name = "Deep Pickaxe",
		
		Cooldown = 0.4,
		Give = 30,
		Radius = 5,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Rock,Snow,Ice",
		DigType = "Click",
	},
	[8] = {
		Name = "Glacier Drill",
		
		Cooldown = 0.3,
		Give = 35,
		Radius = 7,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Rock,Snow,Ice,Glacier,CandyFloss",
		DigType = "Hold",
	},
	[9] = {
		Name = "Large Spoon",
		
		Cooldown = 0.5,
		Give = 40,
		Radius = 8,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Snow,Sand,CandyFloss",
		DigType = "Click",
	},
	[10] = {
		Name = "Candy Cane",
		
		Cooldown = 0.3,
		Give = 45,
		Radius = 6.5,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Rock,Snow,Ice,Glacier,CandyFloss,Chocolate",
		DigType = "Click",
	},
	[11] = {
		Name = "Jawbreaker Hammer",
		
		Cooldown = 0.35,
		Give = 50,
		Radius = 7.5,
		
		DigAnimation = "Shovel",
		Terrain = "Grass,Rock,Snow,Ice,Glacier,CandyFloss,Chocolate,CandyCorn",
		DigType = "Hold",
	},
	[12] = {
		Name = "Big Straw",
		
		Cooldown = 0.2,
		Give = 55,
		Radius = 7.5,
		
		DigAnimation = "Shovel",
		Terrain = "CandyFloss,Chocolate,CandyCorn,Lollipop",
		DigType = "Hold",
	},
}

return Digging
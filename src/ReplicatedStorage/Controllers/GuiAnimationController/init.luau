-- Services --
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local AnimationTypes = script.AnimationTypes
local Packages = ReplicatedStorage.Packages

-- Modules --
local GuiAnimation = require(ReplicatedStorage.Source.Data.Gui.GuiAnimation)

local Fusion = require(Packages.Fusion)
local Signal = require(Packages.Signal)
local Knit = require(Packages.Knit)

local peek = Fusion.peek

local AnimationType = require(AnimationTypes.AnimationType)

-- Controller
local GuiAnimationController = Knit.CreateController { Name = "GuiAnimationController" }
GuiAnimationController.TaggedObjectAnimated = Signal.new()

-- Types --
type Self = typeof(GuiAnimationController)
type AnimatedObject = {
	scope: Fusion.Scope,
	
	startSize: Fusion.Value<Udim2>,
	size: Fusion.Value<Udim2>,
	sizeSpring: Fusion.Spring,
}
type AnimationTypeClass = typeof(AnimationType)

-- Local --
local animationTypeClasses: { [string]: AnimationTypeClass } = {}
local activeTypeClasses: { [GuiObject]: AnimationTypeClass } = {}

function GuiAnimationController:ObserveTaggedObject(taggedOject: GuiObject, handler: (animationValues: AnimatedObject) -> ())
	local con: RBXScriptConnection
	con = self.TaggedObjectAnimated:Connect(function(objectAnimated: GuiObject)
		if objectAnimated ~= taggedOject then
			return
		end
		handler(self.animatedObjects[objectAnimated])
		con:Disconnect()
	end)
end

function GuiAnimationController:Bounce(taggedObject: GuiObject, intensity: number?, useScale: boolean?)
	intensity = intensity or 1
	local o, s = 10 * intensity, 0.1  * intensity
	local addedSize = useScale and UDim2.fromScale(s, s) or UDim2.fromOffset(o, o)
	
	self.animatedObjects[taggedObject].sizeSpring:addVelocity(addedSize)
end

local function manageTaggedObjectTypes(taggedObject: GuiObject)
	local types = taggedObject:GetAttribute(GuiAnimation.ANIMATION_TYPES_ATTRIBUTE_NAME)
	if not types then
		return
	end
	
	for _, animTypeName in string.split(types, ",") do
		local class = animationTypeClasses[animTypeName]
		if not class then
			warn(animTypeName, " was not found as an animation type class.")
		end
		activeTypeClasses[taggedObject] = class.new(taggedObject)
	end
end

local function onTaggedObjectAdded(self: Self, taggedObject: GuiObject)
	local scope: Fusion.Scope = Fusion:scoped()
	
	local startSize: Fusion.Value<Udim2> = scope:Value(taggedObject.Size)
	local size: Fusion.Value<Udim2> = scope:Value(peek(startSize))
	local sizeSpring: Fusion.Spring = scope:Spring(size, 25, 0.8)
	
	scope:Hydrate(taggedObject) {
		Size = sizeSpring,
	}
	
	self.animatedObjects[taggedObject] = {
		scope = scope,
		
		startSize = startSize,
		size = size,
		sizeSpring = sizeSpring,
	}
	
	manageTaggedObjectTypes(taggedObject)
	
	self.TaggedObjectAnimated:Fire(taggedObject)
end

local function onTaggedObjectRemoved(self: Self, taggedObject: GuiObject)
	local activeClass = activeTypeClasses[taggedObject]
	if activeClass then
		activeClass:Destroy()
		activeTypeClasses[taggedObject] = nil
	end
	
	local data = self.animatedObjects[taggedObject]
	if data then
		data.scope:doCleanup()
		self.animatedObjects[taggedObject] = nil
	end
end

function GuiAnimationController:KnitInit()
	for _, animationTypeModule: ModuleScript in AnimationTypes:GetChildren() do
		animationTypeClasses[animationTypeModule.Name] = require(animationTypeModule)
	end
	
	self.animatedObjects = {} :: { [GuiObject]: AnimatedObject }
	
	local tag = GuiAnimation.ANIMATED_TAG
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(obj)
		onTaggedObjectAdded(self, obj)
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(obj)
		onTaggedObjectRemoved(self, obj)
	end)
	for _, obj in CollectionService:GetTagged(tag) do
		onTaggedObjectAdded(self, obj)
	end
end

return GuiAnimationController
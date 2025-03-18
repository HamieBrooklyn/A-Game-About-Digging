local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tags = script.Tags

local Packages = ReplicatedStorage.Packages
local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

local TagController = Knit.CreateController { Name = "TagController" }
type Self = typeof(TagController)
type TagConstructor = typeof(require(script.Tags.Tag))

function TagController:OnTagAdded(tagObject: GuiObject, tag: string)
	local tagConstructor: TagConstructor = require(Tags:FindFirstChild(tag))
	tagConstructor(self.scope, tagObject)
end

function TagController:KnitInit()
	self.scope = Fusion:scoped()
	for _, tagModule: ModuleScript in Tags:GetChildren() do
		CollectionService:GetInstanceAddedSignal(tagModule.Name):Connect(function(tagObject: GuiObject)
			self:OnTagAdded(tagObject, tagModule.Name)
		end)
		for _, tagObject: GuiObject in CollectionService:GetTagged(tagModule.Name) do
			self:OnTagAdded(tagObject, tagModule.Name)
		end
	end
end

return TagController
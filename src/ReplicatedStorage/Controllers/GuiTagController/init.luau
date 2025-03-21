-- Services --
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Knit = require(Packages.Knit)

local TagClass = require(script.Tags.Tag)

-- Controller
local GuiTagController = Knit.CreateController { Name = "GuiTagController" }

-- Types --
type Self = typeof(GuiTagController)
type Tag = typeof(TagClass)

-- Local --
local activeClasses: { [Instance]: Tag } = {}
local tagClasses: { [string]: { Tag } } = {}

function GuiTagController:ManageAddedTag(instance: Instance, tag: string)
	if not instance:IsDescendantOf(Players.LocalPlayer) then
		return
	end
	local class: Tag = tagClasses[tag]
	activeClasses[instance] = class.new(instance)
end

function GuiTagController:ManageRemovedTag(instance: Instance, tag: string)
	local class = activeClasses[instance]
	if not class then
		return
	end
	class:Destroy()
end

function GuiTagController:KnitInit()
	for _, tagMod in script.Tags:GetChildren() do
		tagClasses[tagMod.Name] = require(tagMod)
	end
	
	for tag, _ in tagClasses do
		CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
			self:ManageAddedTag(instance, tag)
		end)
		CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
			self:ManageRemovedTag(instance, tag)
		end)
		for _, instance in CollectionService:GetTagged(tag) do
			self:ManageAddedTag(instance, tag)
		end
	end
end

return GuiTagController
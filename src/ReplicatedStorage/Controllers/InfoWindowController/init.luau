local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local InfoWindowData = require(ReplicatedStorage.Source.Data.InfoWindow)

local InfoWindow = require(script.InfoWindow)

local Packages = ReplicatedStorage.Packages
local Janitor = require(Packages.Janitor)
local Fusion = require(Packages.Fusion)
local Knit = require(Packages.Knit)

local Children = Fusion.Children
local peek = Fusion.peek

local InfoWindowController = Knit.CreateController { Name = "InfoWindowController" }
type Self = typeof(InfoWindowController)

function InfoWindowController:ManageInfoWindow()
	self.scope:Observer(self.textStrings):onChange(function()
		self.gradientNames:set(peek(self.gradientNameStrings) and string.split(peek(self.gradientNameStrings), ",") or nil)
		self.texts:set(peek(self.textStrings) and string.split(peek(self.textStrings), ",") or nil)
	end)
end

function InfoWindowController:OnInfoObjectAdded(object: GuiObject)
	local janitor = Janitor.new()
	janitor:Add(object.MouseEnter:Connect(function()
		self.lastSelectedObject:set(object)
		
		self.gradientNameStrings:set(object:GetAttribute("Gradients") or nil)
		self.textStrings:set(object:GetAttribute("Texts") or nil)
	end))
	
	local function resetAttempt()
		if peek(self.lastSelectedObject) ~= object then
			return
		end
		self.gradientNameStrings:set(nil)
		self.textStrings:set(nil)
	end
	janitor:Add(object.MouseLeave:Connect(resetAttempt))
	object.Destroying:Once(function()
		resetAttempt()
		janitor:Cleanup()
		janitor:Destroy()
	end)
end

function InfoWindowController:FollowMouse()
	local mouse = self.player:GetMouse()
	RunService.RenderStepped:Connect(function()
		self.position:set(UDim2.fromOffset(mouse.X, mouse.Y))
	end)
end

function InfoWindowController:KnitInit()
	CollectionService:GetInstanceAddedSignal(InfoWindowData.TAG):Connect(function(object)
		self:OnInfoObjectAdded(object)
	end)
	for _, object in CollectionService:GetTagged(InfoWindowData.TAG) do
		self:OnInfoObjectAdded(object)
	end
	
	self.player = Players.LocalPlayer
	
	self.scope = Fusion:scoped() :: Fusion.Scope
	
	self.lastSelectedObject = self.scope:Value(nil) :: Fusion.Value<GuiObject?>
	
	self.textStrings = self.scope:Value("") :: Fusion.Value<String?>
	self.gradientNameStrings = self.scope:Value("") :: Fusion.Value<String?>
	
	self.texts = self.scope:Value({}) :: Fusion.Value<{string}>
	self.gradientNames = self.scope:Value({}) :: Fusion.Value<{string}>
	
	self.position = self.scope:Value(UDim2.new()) :: Fusion.Value<Udim2>
	self.screenGui = self.scope:New "ScreenGui" {
		Name = "InfoWindow",
		Parent = self.player:WaitForChild("PlayerGui"),
		DisplayOrder = 1,
		[Children] = {
			InfoWindow(self.scope, self.texts, self.gradientNames, self.position)
		}
	}
	
	self:ManageInfoWindow()
	self:FollowMouse()
end

return InfoWindowController
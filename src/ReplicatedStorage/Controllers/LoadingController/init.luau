-- Services --
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Containers --
local Packages = ReplicatedStorage.Packages

-- Modules --
local Loading = require(ReplicatedStorage.Source.Data.Player.Loading)

local LoadingGui = require(script.LoadingGui)

local Fusion = require(Packages.Fusion)
local Signal = require(Packages.Signal)
local Knit = require(Packages.Knit)

local Children = Fusion.Children
local peek = Fusion.peek

-- Controller
local LoadingController = Knit.CreateController { Name = "LoadingController" }

LoadingController.FinishedLoading = Signal.new()

-- Types --
type Self = typeof(LoadingController)

function LoadingController:StartLoad(assets: { any })
	if peek(self.loading) then
		return
	end
	self.assets:set(assets)
	self.loading:set(true)
end

function LoadingController:CancelCurrentLoad()
	if not peek(self.loading) then
		return
	end
	self.assets:set({})
	self.loading:set(false)
end

function LoadingController:KnitInit()
	self.scope = Fusion:scoped() :: Fusion.Scope
	self.loading = self.scope:Value(false) :: Fusion.Value<boolean>
	self.assets = self.scope:Value({}) :: Fusion.Value<{ any }>
	self.progress = self.scope:Value(0) :: Fusion.Value<number>
	
	local playerGui = Players.LocalPlayer.PlayerGui
	self.scope:New "ScreenGui" {
		Name = "Loading",
		Parent = playerGui,
		
		DisplayOrder = 3,
		
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		
		[Children] = {
			LoadingGui(self.scope, self.loading, self.progress)
		},
	}
	
	self.scope:Observer(self.assets):onChange(function()
		if #peek(self.assets) == 0 then
			return
		end
		for i, assets in peek(self.assets) do
			for _, asset in assets do
				ContentProvider:PreloadAsync({ asset })
				self.progress:set(i / #peek(self.assets))
				task.wait(Loading.MIN_LOAD_TIME)
			end
		end
		self:CancelCurrentLoad()
		self.FinishedLoading:Fire()
	end)
	
	self:StartLoad({
		[1] = workspace:GetChildren(),
		[2] = playerGui:GetChildren(),
		[3] = ReplicatedStorage.Assets.Animations:GetDescendants(),
	})
end

return LoadingController
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Vide = require(ReplicatedStorage.Packages.Vide)
local RootUI = require(ReplicatedStorage.Source.Features.App.UI.RootUI)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Mounts RootUI into a ScreenGui and returns the unmount function.
return function(): () -> ()
	local container = Instance.new("ScreenGui")
	container.Name = "UI"
	container.IgnoreGuiInset = true
	container.ResetOnSpawn = false
	container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	container.ClipToDeviceSafeArea = false
	container.Parent = playerGui

	local unmount = Vide.mount(RootUI, container)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	return function()
		unmount()
		container:Destroy()
	end
end

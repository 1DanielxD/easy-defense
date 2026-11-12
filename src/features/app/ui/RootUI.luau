--[[
	Top-level UI. Mounts every `*Root` module under Source.Features (e.g. HudRoot, MenuRoot,
	ScreenRoot, or a feature's own InventoryRoot), plus the global message layers.

	To add UI for a feature: create `features/<feature>/ui/<Feature>Root.luau` returning a Vide
	component, then regenerate the Rojo tree (npm run build:rojo).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local ErrorMessage = require(ReplicatedStorage.Source.Core.UI.Components.ErrorMessage)
local NotificationMessage = require(ReplicatedStorage.Source.Core.UI.Components.NotificationMessage)
local Notifications = require(ReplicatedStorage.Source.Features.Notifications.UI.Notifications)
local create = Vide.create

local capturedRoots: { [string]: () -> any } = {}
for _, module in ReplicatedStorage.Source.Features:GetDescendants() do
	if module:IsA("ModuleScript") and module.Name:match("Root$") and module ~= script then
		capturedRoots[module.Name] = require(module) :: any
	end
end

local function RootUI()
	local children = {}
	for name, root in capturedRoots do
		local instance = root()
		if typeof(instance) == "Instance" then
			instance.Name = name
		end
		table.insert(children, instance)
	end

	table.insert(children, ErrorMessage.Component())
	table.insert(children, NotificationMessage.Component())
	table.insert(children, Notifications.Screen())

	return create "Folder" {
		Name = "Root",
		children,
	}
end

return RootUI

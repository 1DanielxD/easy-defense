-- Mounts every menu module in this folder (each returns a Vide component; see Menu.luau).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create

local capturedMenus: { [string]: () -> any } = {}
for _, module in script.Parent:GetChildren() do
	if module:IsA("ModuleScript") and module.Name ~= "Menu" and module ~= script then
		capturedMenus[module.Name] = require(module) :: any
	end
end

return function()
	local children = {}
	for _, menu in capturedMenus do
		table.insert(children, menu())
	end

	return create "Folder" {
		Name = "Menus",
		children,
	}
end

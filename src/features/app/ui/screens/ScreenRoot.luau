-- Mounts every screen module in this folder (each returns a Vide component; see Screen.luau).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create

local capturedScreens: { [string]: () -> any } = {}
for _, module in script.Parent:GetChildren() do
	if module:IsA("ModuleScript") and module.Name ~= "Screen" and module ~= script then
		capturedScreens[module.Name] = require(module) :: any
	end
end

return function()
	local children = {}
	for _, screen in capturedScreens do
		table.insert(children, screen())
	end

	return create "Folder" {
		Name = "Screens",
		children,
	}
end

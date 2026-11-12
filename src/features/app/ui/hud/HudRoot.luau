-- Always-visible HUD (currency, side buttons, ...). Add HUD component modules next to this file
-- and list them below.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create

return function()
	return create "Folder" {
		Name = "Hud",
		-- BottomBar(),
	}
end

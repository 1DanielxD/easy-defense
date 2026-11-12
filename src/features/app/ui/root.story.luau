-- UI Labs / Hoarcekat story for the whole UI tree. Outside of play mode, Data.client loads the template.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local MonetizationServiceClient = require(ReplicatedStorage.Source.Features.Monetization.MonetizationServiceClient)
local RootUI = require(script.Parent.RootUI)

return function(parent: Instance)
	MonetizationServiceClient:init(Products)
	local unmount = Vide.mount(RootUI, parent)

	return function()
		unmount()
	end
end

--[[
	Turns a DataServiceTyped Value into a Vide source that updates whenever the value
	(or anything nested under it) changes. Must be called inside a Vide scope (a component);
	the subscription is cleaned up with that scope.

	local PlayerData = require(ReplicatedStorage.Source.Game.Data).client
	local currency = useDataState(PlayerData.currency)
	create "TextLabel" { Text = function() return FormatCurrency(currency()) end }
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)

type DataValue<T> = (() -> T) & { Changed: ((T) -> ()) -> () -> () }

return function<T>(value: DataValue<T>): () -> T
	local state = Vide.source(value())

	Vide.cleanup(value.Changed(function(new: T)
		state(new)
	end))

	return state
end

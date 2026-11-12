--[[
	Single shared DataServiceTyped instance for player save data.

	Server:
		local PlayerData = Data.server
		local data = PlayerData[player] -- Value<DataTemplate.PlayerData>? (nil until loaded / after leaving)
		data.currency()                          -- read
		data.currency(100)                       -- set (replicates)
		data.currency(function(n) return n + 1 end) -- update, returns new value
		data.inventory[uniqueId].fav(true, false)   -- set without replicating
		local disconnect = data.rebirths.Changed(function(new, old) end)
		PlayerData.Service:waitForData(player)

	Client (requiring this yields until the player's data has loaded):
		Data.client.currency()
		Data.client.currency.Changed(function(new) end)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataServiceTyped = require(ReplicatedStorage.Packages.DataServiceTyped)
local DataTemplate = require(ReplicatedStorage.Source.Game.Items.DataTemplate)

export type PlayerData = DataTemplate.PlayerData
export type Value<T> = DataServiceTyped.Value<T>

return DataServiceTyped({
	template = DataTemplate,
	-- Must stay "OFFICIAL" with the default "PLAYER_" key prefix to keep existing saves.
	profileStoreIndex = "OFFICIAL",
	useMock = false,
	resetData = false,
	dontSave = false,
})

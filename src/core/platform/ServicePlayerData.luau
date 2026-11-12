--[[
	Per-player, per-session (non-saved) state for a service.

	local playerData = ServicePlayerData.new(TEMPLATE, service)
	playerData:get(player) -- deep copy of TEMPLATE for that player, or nil if not in game

	If `service` defines `playerAdded(self, player, data)` / `playerRemoving(self, player, data)`
	they are called when a player's entry is created / right before it is removed.
	playerAdded runs in its own thread, so it may yield.
]]

local Players = game:GetService("Players")

local ServicePlayerData = {}
ServicePlayerData.__index = ServicePlayerData

export type ServicePlayerData<T> = {
	get: (self: ServicePlayerData<T>, player: Player) -> T,
	destroy: (self: ServicePlayerData<T>) -> (),
}

local function deepCopy<T>(value: T): T
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for k, v in value :: any do
		copy[k] = deepCopy(v)
	end
	return copy :: any
end

function ServicePlayerData.new<T>(template: T, service: any?): ServicePlayerData<T>
	local self = setmetatable({
		_template = template,
		_service = service,
		_data = {} :: { [Player]: T },
		_connections = {} :: { RBXScriptConnection },
	}, ServicePlayerData)

	local function added(player: Player)
		if self._data[player] then
			return
		end

		local data = deepCopy(template)
		self._data[player] = data
		if service and service.playerAdded then
			task.spawn(service.playerAdded, service, player, data)
		end
	end

	table.insert(self._connections, Players.PlayerAdded:Connect(added))
	table.insert(
		self._connections,
		Players.PlayerRemoving:Connect(function(player: Player)
			local data = self._data[player]
			if not data then
				return
			end

			if service and service.playerRemoving then
				local ok, err = pcall(service.playerRemoving, service, player, data)
				if not ok then
					warn(err)
				end
			end
			self._data[player] = nil
		end)
	)

	for _, player in Players:GetPlayers() do
		added(player)
	end

	return self :: any
end

function ServicePlayerData.get<T>(self: any, player: Player): T
	return self._data[player]
end

function ServicePlayerData.destroy(self: any)
	for _, connection in self._connections do
		connection:Disconnect()
	end
	table.clear(self._connections)
	table.clear(self._data)
end

return ServicePlayerData

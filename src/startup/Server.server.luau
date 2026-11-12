local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CodeRewardCallbacks = require(ReplicatedStorage.Source.Features.Codes.CodeRewardCallbacks)
local Products = require(ReplicatedStorage.Source.Features.Monetization.Modules.Products)
local _ProductServerCallbacks = require(ServerScriptService.Features.Monetization.Modules.ProductServerCallbacks)
local AutoRejoinServiceServer = require(ServerScriptService.Features.AutoRejoin.AutoRejoinServiceServer)
local BaseServiceServer = require(ServerScriptService.Features.Bases.BaseServiceServer)
local CodeServiceServer = require(ServerScriptService.Features.Codes.CodeServiceServer)
local FriendServiceServer = require(ServerScriptService.Features.Friends.FriendServiceServer)
local InventoryServiceServer = require(ServerScriptService.Features.Inventory.InventoryServiceServer)
local LeaderboardServiceServer = require(ServerScriptService.Features.Leaderboards.LeaderboardServiceServer)
local MonetizationServiceServer = require(ServerScriptService.Features.Monetization.MonetizationServiceServer)
local MutationServiceServer = require(ServerScriptService.Features.Mutations.MutationServiceServer)
local NotificationServiceServer = require(ServerScriptService.Features.Notifications.NotificationServiceServer)
local PlotServiceServer = require(ServerScriptService.Features.Plots.PlotServiceServer)
local Data = require(ReplicatedStorage.Source.Game.Data)

local DataService = Data.server.Service

function DataService:onPlayerInit(_player: Player, data: Data.PlayerData)
	print(data)
	data.sessionStart = os.time()
end

DataService:addPlayerRemovingCallback(function(_player: Player, data: Data.PlayerData)
	local playTime = os.time() - (data.sessionStart or os.time())
	data.stats.timePlayed += playTime
	print(data)
end)

DataService:init() -- options live in Source.Game.Data
BaseServiceServer:init()

MonetizationServiceServer:init({
	products = Products,
	canAwardGamepasses = true,
	freePassesGroupRank = 255,
	groupId = 15794692,
})

CodeServiceServer:init(CodeRewardCallbacks :: any)
PlotServiceServer:init()
InventoryServiceServer:init()
MutationServiceServer:init()
LeaderboardServiceServer:init()
AutoRejoinServiceServer:init()
NotificationServiceServer:init()
FriendServiceServer:init()

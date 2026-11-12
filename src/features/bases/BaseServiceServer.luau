--[[
	Gives every player their own base.

	On join: claims the first free slot in Workspace.BasesRoot (Claimed = true, OwnerUserId = id),
	clones ReplicatedStorage.Assets.BaseTemplate onto that slot into Workspace.Bases, and from then
	on spawns the player's character on the base's PrimaryPart (Root) every time it loads:
	first spawn, death, reset, LoadCharacter, etc.
	On leave: destroys the base and frees the slot for the next player.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServicePlayerData = require(ReplicatedStorage.Source.Core.Platform.ServicePlayerData)
local BaseServiceUtils = require(ReplicatedStorage.Source.Features.Bases.BaseServiceUtils)

local ATTRIBUTES = BaseServiceUtils.attributes
-- HumanoidRootPart sits about this far above the floor for a default character.
local SPAWN_OFFSET = CFrame.new(0, 3.5, 0)

type PlayerData = {
	base: Model?,
	root: BasePart?,
	characterConnection: RBXScriptConnection?,
}

local PLAYER_DATA_TEMPLATE: PlayerData = {
	base = nil,
	root = nil,
	characterConnection = nil,
}

local BaseServiceServer = {}

function BaseServiceServer.init(self: BaseServiceServer)
	self.template = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("BaseTemplate") :: Model
	assert(self.template.PrimaryPart, "BaseTemplate needs a PrimaryPart (Root) to spawn players on")

	-- Every slot starts free.
	for _, root in BaseServiceUtils.getSortedRoots() do
		root:SetAttribute(ATTRIBUTES.claimed, false)
		root:SetAttribute(ATTRIBUTES.ownerUserId, nil)
	end

	self.playerData = ServicePlayerData.new(PLAYER_DATA_TEMPLATE, self)
end

function BaseServiceServer.claimRoot(_self: BaseServiceServer, player: Player): BasePart?
	for _, root in BaseServiceUtils.getSortedRoots() do
		if not BaseServiceUtils.isRootClaimed(root) then
			-- Set before anything yields so two joining players can never get the same slot.
			root:SetAttribute(ATTRIBUTES.claimed, true)
			root:SetAttribute(ATTRIBUTES.ownerUserId, player.UserId)
			return root
		end
	end
	return nil
end

function BaseServiceServer.releaseRoot(_self: BaseServiceServer, root: BasePart)
	root:SetAttribute(ATTRIBUTES.claimed, false)
	root:SetAttribute(ATTRIBUTES.ownerUserId, nil)
end

function BaseServiceServer.createBase(self: BaseServiceServer, player: Player, root: BasePart): Model
	local base = self.template:Clone()
	base.Name = player.Name .. "_Base"
	base:SetAttribute(ATTRIBUTES.ownerUserId, player.UserId)

	-- The template's parts aren't anchored or welded, so a clone would fall apart.
	for _, descendant in base:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
		end
	end

	local primary = base.PrimaryPart :: BasePart
	primary.CanCollide = false
	primary.CanTouch = false
	primary.CanQuery = false

	base:PivotTo(root.CFrame)
	base.Parent = BaseServiceUtils.getBasesFolder()
	return base
end

function BaseServiceServer.spawnCharacter(_self: BaseServiceServer, character: Model, base: Model)
	-- CharacterAdded can fire before the character is in the workspace; wait so Roblox's own
	-- spawn positioning doesn't overwrite ours.
	character:WaitForChild("HumanoidRootPart", 10)
	if not character:IsDescendantOf(workspace) then
		character.AncestryChanged:Wait()
	end

	task.defer(function()
		local primary = base.PrimaryPart
		if primary and character.Parent and base.Parent then
			character:PivotTo(primary.CFrame * SPAWN_OFFSET)
		end
	end)
end

function BaseServiceServer.playerAdded(self: BaseServiceServer, player: Player, playerData: PlayerData)
	local root = self:claimRoot(player)
	if not root then
		warn(`No free base for {player.Name}; all {#BaseServiceUtils.getSortedRoots()} slots are claimed`)
		return
	end

	local base = self:createBase(player, root)
	playerData.root = root
	playerData.base = base

	playerData.characterConnection = player.CharacterAdded:Connect(function(character: Model)
		self:spawnCharacter(character, base)
	end)

	-- The character may have loaded before the base was ready.
	if player.Character then
		task.spawn(self.spawnCharacter, self, player.Character, base)
	end
end

function BaseServiceServer.playerRemoving(self: BaseServiceServer, _player: Player, playerData: PlayerData)
	if playerData.characterConnection then
		playerData.characterConnection:Disconnect()
	end
	if playerData.base then
		playerData.base:Destroy()
	end
	if playerData.root then
		self:releaseRoot(playerData.root)
	end
end

function BaseServiceServer.getPlayerBase(self: BaseServiceServer, player: Player): Model?
	local playerData = self.playerData:get(player)
	return playerData and playerData.base
end

type BaseServiceServer = typeof(BaseServiceServer) & {
	template: Model,
	playerData: ServicePlayerData.ServicePlayerData<PlayerData>,
}

return BaseServiceServer :: BaseServiceServer

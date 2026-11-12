--[[
	Shared helpers for player bases.

	Workspace.BasesRoot holds the base slots (Root1, Root2, ...). When a player joins, the server
	claims a free slot (attributes below) and clones ReplicatedStorage.Assets.BaseTemplate onto it
	into Workspace.Bases.
]]

local Players = game:GetService("Players")

local BaseServiceUtils = {}

BaseServiceUtils.attributes = {
	claimed = "Claimed", -- on slot roots: boolean
	ownerUserId = "OwnerUserId", -- on slot roots and base models: number?
}

function BaseServiceUtils.getRootsFolder(): Folder
	return workspace:WaitForChild("BasesRoot") :: Folder
end

function BaseServiceUtils.getBasesFolder(): Folder
	return workspace:WaitForChild("Bases") :: Folder
end

-- Slot roots sorted by the number in their name (Root1, Root2, ...), so bases fill in order.
function BaseServiceUtils.getSortedRoots(): { BasePart }
	local roots: { BasePart } = {}
	for _, child in BaseServiceUtils.getRootsFolder():GetChildren() do
		if child:IsA("BasePart") then
			table.insert(roots, child)
		end
	end

	table.sort(roots, function(a: BasePart, b: BasePart): boolean
		local na = tonumber(a.Name:match("%d+")) or math.huge
		local nb = tonumber(b.Name:match("%d+")) or math.huge
		if na == nb then
			return a.Name < b.Name
		end
		return na < nb
	end)

	return roots
end

function BaseServiceUtils.isRootClaimed(root: BasePart): boolean
	return root:GetAttribute(BaseServiceUtils.attributes.claimed) == true
end

-- The base model owned by `player`, if they have one. Works on server and client.
function BaseServiceUtils.getPlayerBase(player: Player?): Model?
	player = player or Players.LocalPlayer
	assert(player, "No player given")

	for _, base in BaseServiceUtils.getBasesFolder():GetChildren() do
		if base:IsA("Model") and base:GetAttribute(BaseServiceUtils.attributes.ownerUserId) == player.UserId then
			return base
		end
	end
	return nil
end

return BaseServiceUtils

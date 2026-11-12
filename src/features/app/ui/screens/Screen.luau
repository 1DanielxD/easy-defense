--[[
	Full-screen takeovers (reward reveals, cutscenes...). Only one screen is open at a time,
	and while one is open, menus are hidden.

	Gameplay code:  Screen.setOpenedScreen("RebirthReward") / Screen.setOpenedScreen(nil)

	A screen module in this folder (picked up by ScreenRoot) returns a component:

		return function()
			return Screen.Component({
				screenName = "RebirthReward",
				children = { create "Frame" { ... } },
			})
		end
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local create = Vide.create

local openedScreen = Charm.atom(nil :: string?)

local function setOpenedScreen(screenName: string?)
	openedScreen(screenName)
end

-- Vide source that is true while `screenName` is the open screen.
local function useIsOpen(screenName: string): () -> boolean
	return VideCharm.useAtom(function()
		return openedScreen() == screenName
	end)
end

type ScreenProps = {
	screenName: string,
	children: UITypes.Children?,
}

local function Component(props: ScreenProps)
	local isOpen = useIsOpen(props.screenName)

	return create "Frame" {
		Name = props.screenName,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = isOpen,

		props.children,
	}
end

return {
	openedScreen = openedScreen,
	setOpenedScreen = setOpenedScreen,
	useIsOpen = useIsOpen,
	Component = Component,
}

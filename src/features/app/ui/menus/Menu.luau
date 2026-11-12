--[[
	Popup menus. Only one menu is open at a time; opening a menu blurs the world and narrows the FOV.

	Gameplay code:  Menu.setOpenedMenu("SellMenu")  -- toggles; pass nil to close

	A menu module in this folder (picked up by MenuRoot) returns a component:

		return function()
			return Menu.Component({
				menuName = "SellMenu",
				Title = "Sell",
				children = { create "Frame" { ... } },
			})
		end
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Charm = require(ReplicatedStorage.Packages.Charm)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideCharm = require(ReplicatedStorage.Packages.VideCharm)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local Screen = require(ReplicatedStorage.Source.Features.App.UI.Screens.Screen)
local create = Vide.create

local openedMenu = Charm.atom(nil :: string?)
local hasInitialized = false

-- Blur + FOV effect while any menu or screen is open.
local function init(): () -> ()
	if hasInitialized then
		warn("Menu module has already been initialized!")
		return function() end
	end
	hasInitialized = true

	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Name = "MenuBlur"
	blur.Parent = Lighting
	local camera = workspace.CurrentCamera
	local spring = Ripple.createSpring(0, { frequency = 3, dampingRatio = 0.8, start = true })
	spring:onChange(function(value)
		blur.Size = value * 16
		camera.FieldOfView = 70 - value * 10
	end)

	local disconnect = Charm.subscribe(function()
		return openedMenu() or Screen.openedScreen()
	end, function(name)
		spring:setGoal(if name then 1 else 0)
	end)

	return function()
		disconnect()
		blur:Destroy()
		spring:destroy()
		hasInitialized = false
	end
end

local function setOpenedMenu(menuName: string?)
	if openedMenu() == menuName then
		openedMenu(nil)
	else
		openedMenu(menuName)
	end
end

-- Vide source that is true while `menuName` is open (and no screen is covering it).
local function useIsOpen(menuName: string): () -> boolean
	return VideCharm.useAtom(function()
		return openedMenu() == menuName and Screen.openedScreen() == nil
	end)
end

type MenuProps = {
	menuName: string,
	Title: string?,
	Size: UDim2?,
	OpenPosition: UDim2?,
	ClosedPosition: UDim2?,
	OnOpen: (() -> ())?,
	OnClose: (() -> ())?,
	children: UITypes.Children?,
}

local function Component(props: MenuProps)
	local isOpen = useIsOpen(props.menuName)
	local openPosition = props.OpenPosition or UDim2.fromScale(0.5, 0.5)
	local closedPosition = props.ClosedPosition or UDim2.fromScale(0.5, -0.5)

	local position = Vide.spring(function()
		return if isOpen() then openPosition else closedPosition
	end, 0.35, 0.8)

	if props.OnOpen or props.OnClose then
		-- Charm.subscribe only fires on changes (not on mount, and not twice under Vide strict mode).
		Vide.cleanup(Charm.subscribe(function()
			return openedMenu() == props.menuName and Screen.openedScreen() == nil
		end, function(open: boolean)
			if open and props.OnOpen then
				props.OnOpen()
			elseif not open and props.OnClose then
				props.OnClose()
			end
		end))
	end

	return create "Frame" {
		Name = props.menuName,
		Size = props.Size or UDim2.fromOffset(600, 400),
		Position = position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 0.5,

		create "UIStroke" { Thickness = 3, Color = Color3.fromRGB(20, 20, 20) },

		create "TextLabel" {
			Name = "Title",
			Text = props.Title or props.menuName,
			Size = UDim2.new(1, -60, 0, 50),
			Position = UDim2.fromOffset(10, 0),
			BackgroundTransparency = 1,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
			TextColor3 = Color3.new(1, 1, 1),

			create "UIStroke" { Thickness = 3, Color = Color3.fromRGB(20, 20, 20) },
		},

		create "TextButton" {
			Name = "Close",
			Text = "X",
			Size = UDim2.fromOffset(50, 50),
			Position = UDim2.fromScale(1, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 10, 10),
			TextScaled = true,
			FontFace = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
			TextColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,

			Activated = function()
				if openedMenu() == props.menuName then
					openedMenu(nil)
				end
			end,

			create "UIStroke" {
				Thickness = 3,
				Color = Color3.fromRGB(117, 4, 4),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			},
		},

		create "Frame" {
			Name = "Content",
			Size = UDim2.new(1, 0, 1, -50),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,

			props.children,
		},
	}
end

if RunService:IsRunning() and RunService:IsClient() then
	init()
end

return {
	init = init,
	openedMenu = openedMenu,
	setOpenedMenu = setOpenedMenu,
	useIsOpen = useIsOpen,
	Component = Component,
}

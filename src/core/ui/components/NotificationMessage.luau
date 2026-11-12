--[[
	Banner messages at the top of the screen.
	NotificationMessage.add({ Text = "...", TextColor3 = ..., Stroke = {...}, Gradient = {...}, Prefix = { Image = ... } })
	RootUI mounts NotificationMessage.Component.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local UITypes = require(ReplicatedStorage.Source.Core.UI.UITypes)
local create = Vide.create

type MessageProps = UITypes.TextProps

local LIFETIME = 6

local messages = Vide.source({} :: { [number]: MessageProps })
local id = 0

local function add(props: MessageProps)
	id += 1
	local current = table.clone(messages())
	current[id] = props
	messages(current)
end

local function remove(i: number)
	local current = table.clone(messages())
	current[i] = nil
	messages(current)
end

local function Message(props: () -> MessageProps, i: number)
	local shown = Vide.source(false)
	local size = Vide.spring(function()
		return if shown() then UDim2.fromScale(1, 1) else UDim2.fromScale(0, 0)
	end, 0.4, 1)

	shown(true)
	Vide.cleanup(task.delay(LIFETIME, function()
		shown(false)
		task.wait(0.4)
		-- Deferred: removing destroys this scope, which would cancel the running thread.
		task.defer(remove, i)
	end))

	local p = Vide.untrack(props)

	return create "Frame" {
		LayoutOrder = -i,
		Size = size,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.25,

		create "UIGradient" {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.33, 0.5),
				NumberSequenceKeypoint.new(0.66, 0.5),
				NumberSequenceKeypoint.new(1, 1),
			}),
		},

		create "UIListLayout" {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		},

		if p.Prefix
			then create "ImageLabel" {
				LayoutOrder = 1,
				Image = p.Prefix.Image,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
			}
			else nil,

		create "TextLabel" {
			LayoutOrder = 2,
			Text = p.Text or "",
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextScaled = true,
			FontFace = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
			TextColor3 = p.TextColor3 or Color3.new(1, 1, 1),

			if p.Stroke
				then create "UIStroke" {
					Thickness = p.Stroke.Thickness or 2,
					Color = p.Stroke.Color or Color3.new(0, 0, 0),
				}
				else nil,

			if p.Gradient
				then create "UIGradient" {
					Rotation = p.Gradient.Rotation or 0,
					Color = p.Gradient.Color,
				}
				else nil,
		},
	}
end

local function Component()
	return create "Frame" {
		Name = "NotificationMessages",
		Size = UDim2.new(0.55, 0, 0, 42),
		Position = UDim2.fromScale(0.5, 0.25),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 2 ^ 31 - 1,

		create "UIListLayout" {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.1, 0),
		},

		Vide.indexes(messages, Message),
	}
end

return {
	Component = Component,
	add = add,
}

--[[
	Short-lived red error toasts.
	ErrorMessage.add("Not enough money") from anywhere on the client; RootUI mounts ErrorMessage.Component.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create

local LIFETIME = 3

local errors = Vide.source({} :: { [number]: string })
local id = 0

local function add(message: string)
	id += 1
	local current = table.clone(errors())
	current[id] = message
	errors(current)
end

local function remove(i: number)
	local current = table.clone(errors())
	current[i] = nil
	errors(current)
end

local function Message(message: () -> string, i: number)
	local shown = Vide.source(false)
	local size = Vide.spring(function()
		return if shown() then UDim2.fromScale(1, 1) else UDim2.fromScale(0, 0)
	end, 0.4, 1)

	shown(true)
	local hideThread = task.delay(LIFETIME, function()
		shown(false)
		task.wait(0.4)
		-- Deferred: removing destroys this scope, which would cancel the running thread.
		task.defer(remove, i)
	end)
	Vide.cleanup(hideThread)

	return create "Frame" {
		LayoutOrder = i,
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

		create "TextLabel" {
			Text = message,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			TextScaled = true,
			FontFace = Font.fromEnum(Enum.Font.BuilderSansExtraBold),
			TextColor3 = Color3.fromRGB(255, 0, 0),

			create "UIStroke" {
				Color = Color3.fromRGB(87, 0, 0),
				Thickness = 2,
			},
		},
	}
end

local function Component()
	return create "Frame" {
		Name = "ErrorMessages",
		Size = UDim2.new(0.55, 0, 0, 30),
		Position = UDim2.fromScale(0.5, 0.7),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		ZIndex = 2 ^ 31 - 1,

		create "UIListLayout" {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.1, 0),
		},

		Vide.indexes(errors, Message),
	}
end

return {
	Component = Component,
	add = add,
}

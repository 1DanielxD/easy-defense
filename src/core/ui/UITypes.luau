-- Shared Vide prop types.
-- Any prop typed `Derivable<T>` accepts either a plain value or a source/derived getter;
-- Vide binds getters reactively when they're passed as instance properties.

export type Derivable<T> = T | () -> T

-- Anything Vide accepts as a child: an Instance, an array of them, or a source returning them.
export type Children = { any } | Instance | () -> any

export type GenericUIProps = {
	Active: Derivable<boolean>?,
	BackgroundTransparency: Derivable<number>?,
	Size: Derivable<UDim2>?,
	Position: Derivable<UDim2>?,
	AnchorPoint: Derivable<Vector2>?,
	BackgroundColor3: Derivable<Color3>?,
	ClipsDescendants: Derivable<boolean>?,
	LayoutOrder: Derivable<number>?,
	ZIndex: Derivable<number>?,
	Visible: Derivable<boolean>?,
	Rotation: Derivable<number>?,
	SizeConstraint: Derivable<Enum.SizeConstraint>?,
	AutomaticSize: Derivable<Enum.AutomaticSize>?,
}

export type TextProps = {
	Text: Derivable<string>?,
	TextColor3: Derivable<Color3>?,
	Stroke: { Thickness: number?, Color: Color3? }?,
	Gradient: { Rotation: number?, Color: ColorSequence? }?,
	Prefix: { Image: string }?,
}

return nil

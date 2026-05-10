-- [[
-- 	Rayfield Enhanced — Design Tokens
-- 	Sistema global de design para consistência visual absoluta
-- ]]

local Tokens = {}

-- ============================================================
-- 	SPACING
-- ============================================================

Tokens.Spacing = {
	XXS = 2,
	XS = 4,
	SM = 8,
	MD = 12,
	LG = 16,
	XL = 24,
	XXL = 32,
	Section = 20,
	Element = 10,
	Padding = 12,
	Content = 14,
}

-- ============================================================
-- 	RADIUS
-- ============================================================

Tokens.Radius = {
	None = UDim.new(0, 0),
	SM = UDim.new(0, 4),
	MD = UDim.new(0, 8),
	LG = UDim.new(0, 12),
	XL = UDim.new(0, 16),
	Full = UDim.new(1, 0),
	Toggle = UDim.new(0, 12),
	Card = UDim.new(0, 10),
	Button = UDim.new(0, 8),
	Input = UDim.new(0, 6),
	Modal = UDim.new(0, 14),
}

-- ============================================================
-- 	SHADOWS
-- ============================================================

Tokens.Shadow = {
	Level1 = 0.85,
	Level2 = 0.75,
	Level3 = 0.6,
	Level4 = 0.4,
	Card = 0.8,
	Modal = 0.6,
	Dropdown = 0.75,
	Toast = 0.8,
	Asset = "rbxassetid://5587865193",
}

-- ============================================================
-- 	BLUR
-- ============================================================

Tokens.Blur = {
	Subtle = 12,
	Normal = 24,
	Heavy = 48,
	Max = 72,
	Asset = "rbxassetid://3570695787",
}

-- ============================================================
-- 	TYPOGRAPHY
-- ============================================================

Tokens.Typography = {
	Title = Enum.Font.GothamSemibold,
	Body = Enum.Font.Gotham,
	Mono = Enum.Font.Code,
	Bold = Enum.Font.GothamBlack,
	SizeXS = 11,
	SizeSM = 13,
	SizeMD = 14,
	SizeLG = 16,
	SizeXL = 20,
	SizeXXL = 24,
}

-- ============================================================
-- 	TRANSITIONS
-- ============================================================

Tokens.Transition = {
	Fast = 0.15,
	Normal = 0.25,
	Slow = 0.4,
	Spring = 0.5,
	Expo = 0.6,
	Ease = Enum.EasingStyle.Quad,
	Smooth = Enum.EasingStyle.Exponential,
	SpringEase = Enum.EasingStyle.Back,
}

-- ============================================================
-- 	GLOW
-- ============================================================

Tokens.Glow = {
	Subtle = 0.85,
	Normal = 0.7,
	Strong = 0.4,
	Max = 0.15,
}

-- ============================================================
-- 	ELEMENT SIZES
-- ============================================================

Tokens.Size = {
	Button = 38,
	Toggle = 42,
	Slider = 50,
	Input = 42,
	DropdownItem = 36,
	TabButton = 30,
	SectionTitle = 20,
	Divider = 1,
	Icon = 20,
	IconLarge = 28,
	Handle = 16,
	Track = 6,
	Switch = {Width = 44, Height = 24, Knob = 18},
}

-- ============================================================
-- 	GRADIENTS (premade)
-- ============================================================

function Tokens.Gradient(fromColor, toColor, steps)
	steps = steps or 10
	local seq = {}
	for i = 0, steps do
		local t = i / steps
		table.insert(seq, ColorSequenceKeypoint.new(t, Color3.new(
			fromColor.R + (toColor.R - fromColor.R) * t,
			fromColor.G + (toColor.G - fromColor.G) * t,
			fromColor.B + (toColor.B - fromColor.B) * t
		)))
	end
	return ColorSequence.new(seq)
end

return Tokens
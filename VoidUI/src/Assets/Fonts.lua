-- [[
-- 	Rayfield Enhanced — Fonts.lua
-- 	Font system with presets, weights, custom loader, fallbacks
-- ]]

local Fonts = {}

local fontRegistry = {
	gotham = Enum.Font.Gotham,
	gothamMedium = Enum.Font.GothamMedium,
	gothamBold = Enum.Font.GothamBold,
	gothamBlack = Enum.Font.GothamBlack,
	arial = Enum.Font.Arial,
	arialBold = Enum.Font.ArialBold,
	code = Enum.Font.Code,
	cartoon = Enum.Font.Cartoon,
	fantasy = Enum.Font.Fantasy,
	antique = Enum.Font.Antique,
}

local fontCache = {}

function Fonts:Get(name)
	if fontCache[name] then return fontCache[name] end
	local font = fontRegistry[name:lower()] or Enum.Font.Gotham
	fontCache[name] = font
	return font
end

function Fonts:Register(name, fontEnum)
	fontRegistry[name:lower()] = fontEnum
end

-- Presets
function Fonts.Title()
	return fontRegistry.gothamBold, 16
end

function Fonts.Body()
	return fontRegistry.gotham, 14
end

function Fonts.Small()
	return fontRegistry.gotham, 12
end

function Fonts.Caption()
	return fontRegistry.gotham, 11
end

function Fonts.Mono()
	return fontRegistry.code, 13
end

-- Font sizes
Fonts.Size = {
	H1 = 24,
	H2 = 20,
	H3 = 18,
	H4 = 16,
	Body = 14,
	Small = 12,
	XS = 11,
	Caption = 10,
}

return Fonts
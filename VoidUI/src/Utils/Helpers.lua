-- [[
-- 	Rayfield Enhanced — Helpers.lua
-- 	Utility functions for the enhanced UI library
-- ]]

local Helpers = {}

-- Safely call a function
function Helpers.CallSafe(func, ...)
	if not func then return end
	local success, result = pcall(func, ...)
	if not success then
		warn("RayfieldEnhanced | CallSafe Error:", result)
	end
	return result
end

-- Deep table copy
function Helpers.DeepCopy(tbl)
	if type(tbl) ~= "table" then return tbl end
	local copy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = Helpers.DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- Check if a table has values
function Helpers.TableHas(tbl, value)
	for _, v in pairs(tbl) do
		if v == value then return true end
	end
	return false
end

-- Clamp value between min and max
function Helpers.Clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

-- Round to nearest increment
function Helpers.Round(value, increment)
	if increment <= 0 then return value end
	return math.floor(value / increment + 0.5) * increment
end

-- Generate unique ID
local idCounter = 0
function Helpers.UniqueId(prefix)
	idCounter = idCounter + 1
	return (prefix or "rf") .. "_" .. idCounter .. "_" .. tick()
end

-- Merge two tables (dest overwrites src)
function Helpers.Merge(src, dest)
	local result = {}
	for k, v in pairs(src) do result[k] = v end
	for k, v in pairs(dest) do result[k] = v end
	return result
end

-- Convert hex color to Color3
function Helpers.HexToColor3(hex)
	hex = hex:gsub("#", "")
	local r, g, b = string.match(hex, "^(%w%w)(%w%w)(%w%w)$")
	if not r then return Color3.fromRGB(255, 255, 255) end
	return Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
end

-- Convert Color3 to hex
function Helpers.Color3ToHex(color)
	return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end

-- Get executor name
function Helpers.GetExecutor()
	local success, name = pcall(identifyexecutor)
	if success and name then return name end
	return "Unknown"
end

-- Check if filesystem is available
function Helpers.HasFilesystem()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

-- Create gradient ColorSequence
function Helpers.Gradient(fromColor, toColor, steps)
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

-- Check if mobile
function Helpers.IsMobile()
	return UserInputService.TouchEnabled
end

return Helpers
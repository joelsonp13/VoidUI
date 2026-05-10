-- [[
-- 	Rayfield Enhanced — Acrylic.lua
-- 	Fake acrylic/blur effect using ImageConvolve and transparency layering
-- ]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Acrylic = {}

local activeAcrylics = {}

-- ============================================================
-- 	FAKE ACRYLIC (glassmorphism effect)
-- ============================================================

function Acrylic:Apply(frame, config)
	config = config or {}
	local blurAmount = config.Blur or 24
	local tint = config.Tint or Color3.fromRGB(18, 18, 22)
	local tintTransparency = config.TintTransparency or 0.4
	local saturation = config.Saturation or 1.2

	-- Ensure frame has background transparency for layering
	frame.BackgroundTransparency = tintTransparency

	-- Add inner glow/shine
	local shine = Instance.new("ImageLabel")
	shine.Name = "AcrylicShine"
	shine.Size = UDim2.new(1, 0, 1, 0)
	shine.Position = UDim2.new(0, 0, 0, 0)
	shine.BackgroundTransparency = 1
	shine.Image = "rbxassetid://3570695787"
	shine.ImageColor3 = Color3.fromRGB(255, 255, 255)
	shine.ImageTransparency = 0.92
	shine.ZIndex = frame.ZIndex + 1
	shine.Parent = frame

	-- Add bottom border glow
	local borderGlow = Instance.new("Frame")
	borderGlow.Name = "AcrylicBorder"
	borderGlow.Size = UDim2.new(1, 0, 0, 1)
	borderGlow.Position = UDim2.new(0, 0, 1, 0)
	borderGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	borderGlow.BackgroundTransparency = 0.85
	borderGlow.BorderSizePixel = 0
	borderGlow.ZIndex = frame.ZIndex + 1
	borderGlow.Parent = frame

	-- Store for cleanup
	table.insert(activeAcrylics, {
		Frame = frame,
		Shine = shine,
		Border = borderGlow,
	})

	return frame
end

function Acrylic:Remove(frame)
	for i, data in ipairs(activeAcrylics) do
		if data.Frame == frame then
			pcall(function() data.Shine:Destroy() end)
			pcall(function() data.Border:Destroy() end)
			table.remove(activeAcrylics, i)
			return
		end
	end
end

function Acrylic:ClearAll()
	for _, data in ipairs(activeAcrylics) do
		pcall(function() data.Shine:Destroy() end)
		pcall(function() data.Border:Destroy() end)
	end
	table.clear(activeAcrylics)
end

-- ============================================================
-- 	REAL ACRYLIC (Lighting Blur + Background transparency)
-- ============================================================

function Acrylic:ApplyReal(frame, intensity)
	intensity = intensity or 24

	-- Try to add BlurEffect to Lighting
	local success, blur = pcall(function()
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = intensity
		blurEffect.Parent = game:GetService("Lighting")
		return blurEffect
	end)

	if success then
		frame.BackgroundTransparency = 0.3
		return blur
	end

	return nil
end

return Acrylic
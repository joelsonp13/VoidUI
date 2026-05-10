-- [[
-- 	Rayfield Enhanced — BlurEngine.lua
-- 	Fake blur effect using ImageConvolve / transparência visual
-- ]]

local BlurEngine = {}
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local blurInstances = {}
local activeBlurs = {}

-- ============================================================
-- 	FAKE BLUR USING GRADIENTS + TRANSPARENCY
-- ============================================================

function BlurEngine.AttachBlur(screenGui, intensity)
	intensity = intensity or 24

	-- Create blur overlay using an ImageLabel with gradient
	local blur = Instance.new("ImageLabel")
	blur.Name = "BlurOverlay"
	blur.Size = UDim2.new(1, 0, 1, 0)
	blur.Position = UDim2.new(0, 0, 0, 0)
	blur.BackgroundTransparency = 1
	blur.Image = "rbxassetid://3570695787"
	blur.ImageTransparency = 1
	blur.ZIndex = 9999
	blur.Parent = screenGui

	-- Store reference
	table.insert(blurInstances, blur)
	activeBlurs[screenGui] = blur

	return blur
end

function BlurEngine.SetIntensity(blur, intensity)
	if not blur then return end
	TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1 - (math.clamp(intensity, 0, 100) / 100),
	}):Play()
end

function BlurEngine.RemoveBlur(screenGui)
	local blur = activeBlurs[screenGui]
	if blur then
		blur:Destroy()
		activeBlurs[screenGui] = nil
	end
end

function BlurEngine.ClearAll()
	for _, blur in ipairs(blurInstances) do
		pcall(function() blur:Destroy() end)
	end
	table.clear(blurInstances)
	table.clear(activeBlurs)
end

-- ============================================================
-- 	REAL BLUR (if executor supports SurfaceGui on PlayerGui)
-- ============================================================

function BlurEngine.AttachRealBlur(screenGui, intensity)
	intensity = intensity or 24
	local success, result = pcall(function()
		local blur = Instance.new("BlurEffect")
		blur.Size = intensity
		blur.Parent = game:GetService("Lighting")
		return blur
	end)
	return success and result or nil
end

return BlurEngine
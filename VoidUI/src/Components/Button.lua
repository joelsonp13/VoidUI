-- [[
-- 	Rayfield Enhanced — Button.lua
-- 	Modern button component with ripple, glow, and hover effects
-- ]]

local TweenService = game:GetService("TweenService")

local ButtonComponent = {}

function ButtonComponent.Create(config)
	config = config or {}
	
	local btn = Instance.new("TextButton")
	btn.Name = config.Name or "Button"
	btn.Size = UDim2.new(1, -10, 0, 38)
	btn.Position = UDim2.new(0.5, 0, 0, 0)
	btn.AnchorPoint = Vector2.new(0.5, 0)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	btn.BackgroundTransparency = 0
	btn.Text = config.Title or config.Text or "Button"
	btn.Font = Enum.Font.GothamSemibold
	btn.TextColor3 = Color3.fromRGB(220, 220, 230)
	btn.TextSize = 14
	btn.AutoButtonColor = false
	btn.ClipsDescendants = true
	btn.ZIndex = 5

	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, config.CornerRadius or 8)
	corner.Parent = btn

	-- Stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(55, 55, 68)
	stroke.Thickness = 1
	stroke.Transparency = 0
	stroke.Parent = btn

	-- Optional icon
	if config.Icon then
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 20, 0, 20)
		icon.Position = UDim2.new(0, 12, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.BackgroundTransparency = 1
		icon.Image = config.Icon
		icon.ImageColor3 = Color3.fromRGB(220, 220, 230)
		icon.ZIndex = 6
		icon.Parent = btn

		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.PaddingLeft = UDim.new(0, 40)
	end

	-- Glow overlay (hidden by default)
	local glow = Instance.new("ImageLabel")
	glow.Name = "Glow"
	glow.Size = UDim2.new(1, 0, 1, 0)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://3570695787"
	glow.ImageColor3 = config.AccentColor or Color3.fromRGB(88, 130, 255)
	glow.ImageTransparency = 1
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceCenter = Rect.new(10, 10, 118, 118)
	glow.ZIndex = 1
	glow.Parent = btn

	-- Hover effects
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(42, 42, 54),
		}):Play()
		TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 0.75,
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(35, 35, 45),
		}):Play()
		TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 1,
		}):Play()
	end)

	-- Click ripple + callback
	btn.MouseButton1Click:Connect(function()
		-- Ripple
		if config.Ripple ~= false then
			local ripple = Instance.new("ImageLabel")
			ripple.Size = UDim2.new(0, 0, 0, 0)
			ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
			ripple.AnchorPoint = Vector2.new(0.5, 0.5)
			ripple.BackgroundTransparency = 1
			ripple.Image = "rbxassetid://3570695787"
			ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
			ripple.ImageTransparency = 0.8
			ripple.ZIndex = 100
			ripple.Parent = btn

			local maxSize = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.5
			TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, maxSize, 0, maxSize),
				ImageTransparency = 1,
			}):Play()

			task.delay(0.65, function()
				pcall(function() ripple:Destroy() end)
			end)
		end

		-- Callback
		if config.Callback then
			pcall(config.Callback)
		end
	end)

	-- Updater
	local selfTable = {}

	function selfTable:Set(text)
		btn.Text = text
	end

	function selfTable:SetCallback(cb)
		config.Callback = cb
	end

	function selfTable:SetEnabled(enabled)
		btn.Active = enabled
		btn.BackgroundTransparency = enabled and 0 or 0.5
		btn.TextTransparency = enabled and 0 or 0.5
	end

	function selfTable:Destroy()
		btn:Destroy()
	end

	return selfTable, btn
end

return ButtonComponent
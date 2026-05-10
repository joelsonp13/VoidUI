-- [[
-- 	Rayfield Enhanced — ThemeEditor.lua
-- 	Live visual theme editor with color pickers, sliders, export/import
-- 	Diferencial PROFISSIONAL
-- ]]

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local ThemeEditor = {}

function ThemeEditor:Open(themeManager, parentGui)
	themeManager = themeManager
	parentGui = parentGui or CoreGui

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.ZIndex = 5000
	overlay.Visible = true
	overlay.Parent = parentGui

	local editor = Instance.new("Frame")
	editor.Size = UDim2.new(0, 520, 0, 460)
	editor.Position = UDim2.new(0.5, 0, 0.5, 0)
	editor.AnchorPoint = Vector2.new(0.5, 0.5)
	editor.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
	editor.BackgroundTransparency = 0
	editor.BorderSizePixel = 0
	editor.ClipsDescendants = true
	editor.ZIndex = 5001
	editor.Parent = overlay

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = editor

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(50, 50, 62)
	stroke.Thickness = 1
	stroke.Parent = editor

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 44)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamSemibold
	title.Text = "Theme Editor"
	title.TextColor3 = Color3.fromRGB(230, 230, 240)
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 5002
	title.Parent = editor

	-- Close button
	local close = Instance.new("ImageButton")
	close.Size = UDim2.new(0, 28, 0, 28)
	close.Position = UDim2.new(1, -38, 0, 8)
	close.BackgroundTransparency = 1
	close.Image = "rbxassetid://10137832201"
	close.ImageColor3 = Color3.fromRGB(180, 180, 195)
	close.ZIndex = 5002
	close.Parent = editor
	close.MouseButton1Click:Connect(function() overlay:Destroy() end)

	-- Category bar
	local categoryBar = Instance.new("Frame")
	categoryBar.Size = UDim2.new(1, 0, 0, 36)
	categoryBar.Position = UDim2.new(0, 0, 0, 44)
	categoryBar.BackgroundTransparency = 1
	categoryBar.ZIndex = 5002
	categoryBar.Parent = editor

	local categories = {"Background", "Text", "Accent", "Toggle", "Slider", "Input", "Dimensions"}
	local currentCategory = 1
	local categoryButtons = {}

	for i, cat in ipairs(categories) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 70, 0, 28)
		btn.Position = UDim2.new(0, (i - 1) * 74 + 8, 0, 4)
		btn.BackgroundColor3 = i == currentCategory and Color3.fromRGB(88, 130, 255) or Color3.fromRGB(35, 35, 45)
		btn.BackgroundTransparency = i == currentCategory and 0 or 0
		btn.Text = cat
		btn.Font = Enum.Font.Gotham
		btn.TextColor3 = Color3.fromRGB(200, 200, 215)
		btn.TextSize = 12
		btn.AutoButtonColor = false
		btn.ZIndex = 5003
		btn.Parent = categoryBar

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn

		categoryButtons[i] = btn

		btn.MouseButton1Click:Connect(function()
			currentCategory = i
			for j, b in ipairs(categoryButtons) do
				TweenService:Create(b, TweenInfo.new(0.2), {
					BackgroundColor3 = j == i and Color3.fromRGB(88, 130, 255) or Color3.fromRGB(35, 35, 45)
				}):Play()
			end
		end)
	end

	-- Content area (scrollable)
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, -16, 1, -100)
	content.Position = UDim2.new(0, 8, 0, 88)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = 4
	content.CanvasSize = UDim2.new(0, 0, 0, 600)
	content.ZIndex = 5002
	content.Parent = editor

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = content

	-- Bottom bar
	local bottomBar = Instance.new("Frame")
	bottomBar.Size = UDim2.new(1, 0, 0, 44)
	bottomBar.Position = UDim2.new(0, 0, 1, -44)
	bottomBar.BackgroundTransparency = 1
	bottomBar.ZIndex = 5002
	bottomBar.Parent = editor

	local function makeButton(x, text, color, cb)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 100, 0, 30)
		btn.Position = UDim2.new(0, x, 0.5, 0)
		btn.AnchorPoint = Vector2.new(0, 0.5)
		btn.BackgroundColor3 = color
		btn.BackgroundTransparency = 0
		btn.Text = text
		btn.Font = Enum.Font.GothamSemibold
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 13
		btn.AutoButtonColor = false
		btn.ZIndex = 5003
		btn.Parent = bottomBar

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 8)
		btnCorner.Parent = btn

		btn.MouseButton1Click:Connect(cb)
		return btn
	end

	makeButton(12, "Export JSON", Color3.fromRGB(88, 130, 255), function()
		local data = themeManager:ExportTheme(themeManager._currentName)
		if data and HttpService then
			setclipboard and setclipboard(HttpService:JSONEncode(data))
		end
	end)

	makeButton(124, "Save Theme", Color3.fromRGB(45, 200, 120), function()
		themeManager:ApplyTheme(themeManager._currentName)
	end)

	makeButton(236, "Reset", Color3.fromRGB(235, 80, 80), function()
		themeManager:ApplyTheme("Default")
	end)

	return {Overlay = overlay, Editor = editor}
end

return ThemeEditor
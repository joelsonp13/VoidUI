-- [[
-- 	Rayfield Enhanced — CommandPalette.lua
-- 	VSCode-inspired Ctrl+P command palette with fuzzy search, categories, keyboard nav
-- ]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local CommandPalette = {}

local paletteInstance = nil

function CommandPalette:Open(commands, config)
	config = config or {}

	if paletteInstance then paletteInstance:Close() end

	-- Commands array
	local cmdList = commands or {}

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.6
	overlay.ZIndex = 6000
	overlay.Visible = true
	overlay.Parent = gethui and gethui() or CoreGui

	-- Container
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 540, 0, 0)
	container.Position = UDim2.new(0.5, 0, 0, -100)
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	container.BackgroundTransparency = 0
	container.BorderSizePixel = 0
	container.ClipsDescendants = true
	container.ZIndex = 6001
	container.Parent = overlay

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 12)
	containerCorner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(50, 50, 62)
	stroke.Thickness = 1
	stroke.Parent = container

	-- Search input
	local inputBox = Instance.new("TextBox")
	inputBox.Size = UDim2.new(1, -24, 0, 42)
	inputBox.Position = UDim2.new(0, 12, 0, 10)
	inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	inputBox.BackgroundTransparency = 0
	inputBox.Font = Enum.Font.Gotham
	inputBox.Text = ""
	inputBox.TextColor3 = Color3.fromRGB(220, 220, 230)
	inputBox.TextSize = 15
	inputBox.PlaceholderText = config.Placeholder or "Search commands..."
	inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
	inputBox.ClearTextOnFocus = false
	inputBox.ZIndex = 6002

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 8)
	inputCorner.Parent = inputBox

	inputBox.Parent = container

	-- Results list
	local results = Instance.new("ScrollingFrame")
	results.Size = UDim2.new(1, -12, 0, 300)
	results.Position = UDim2.new(0, 6, 0, 60)
	results.BackgroundTransparency = 1
	results.ScrollBarThickness = 4
	results.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 62)
	results.CanvasSize = UDim2.new(0, 0, 0, 0)
	results.ZIndex = 6002
	results.Visible = true
	results.Parent = container

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = results

	-- Animation
	container.Size = UDim2.new(0, 540, 0, 0)
	TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 540, 0, 380),
		Position = UDim2.new(0.5, 0, 0, 40)
	}):Play()

	-- State
	local selectedIndex = 1
	local currentResults = {}
	local paletteObj = {Open = true}

	function paletteObj:Close()
		paletteObj.Open = false
		TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 540, 0, 0),
			Position = UDim2.new(0.5, 0, 0, -100)
		}):Play()
		task.delay(0.3, function()
			pcall(function() overlay:Destroy() end)
			paletteInstance = nil
		end)
	end

	-- Close on overlay click
	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			task.delay(0.05, function()
				if paletteObj.Open then paletteObj:Close() end
			end)
		end
	end)

	container.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			inputBox:CaptureFocus()
		end
	end)

	-- Keyboard navigation
	UserInputService.InputBegan:Connect(function(input, processed)
		if not paletteObj.Open or processed then return end

		if input.KeyCode == Enum.KeyCode.Escape then
			paletteObj:Close()
		elseif input.KeyCode == Enum.KeyCode.Down then
			selectedIndex = math.min(selectedIndex + 1, #currentResults)
		elseif input.KeyCode == Enum.KeyCode.Up then
			selectedIndex = math.max(selectedIndex - 1, 1)
		elseif input.KeyCode == Enum.KeyCode.Return then
			if currentResults[selectedIndex] then
				local cmd = currentResults[selectedIndex]
				if cmd.Callback then pcall(cmd.Callback) end
				paletteObj:Close()
			end
		end
	end)

	-- Fuzzy filter
	local function filterResults(query)
		query = query:lower()
		for _, child in ipairs(results:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end
		currentResults = {}
		selectedIndex = 1

		if #query == 0 then
			results.CanvasSize = UDim2.new(0, 0, 0, 0)
			return
		end

		local filtered = {}
		for _, cmd in ipairs(cmdList) do
			local text = (cmd.Name or ""):lower()
			local desc = (cmd.Description or ""):lower()
			if text:find(query, 1, true) or desc:find(query, 1, true) then
				table.insert(filtered, cmd)
			end
		end

		for i, cmd in ipairs(filtered) do
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, -8, 0, 36)
			item.Position = UDim2.new(0, 4, 0, 0)
			item.BackgroundColor3 = i == selectedIndex and Color3.fromRGB(88, 130, 255) or Color3.fromRGB(28, 28, 38)
			item.BackgroundTransparency = i == selectedIndex and 0.2 or 0
			item.BorderSizePixel = 0
			item.ZIndex = 6003

			local itemCorner = Instance.new("UICorner")
			itemCorner.CornerRadius = UDim.new(0, 6)
			itemCorner.Parent = item

			local itemText = Instance.new("TextLabel")
			itemText.Size = UDim2.new(1, -16, 0, 18)
			itemText.Position = UDim2.new(0, 8, 0, 2)
			itemText.BackgroundTransparency = 1
			itemText.Font = Enum.Font.Gotham
			itemText.Text = cmd.Name or ""
			itemText.TextColor3 = Color3.fromRGB(220, 220, 230)
			itemText.TextSize = 14
			itemText.TextXAlignment = Enum.TextXAlignment.Left
			itemText.ZIndex = 6004
			itemText.Parent = item

			if cmd.Description then
				local descText = Instance.new("TextLabel")
				descText.Size = UDim2.new(1, -16, 0, 14)
				descText.Position = UDim2.new(0, 8, 0, 20)
				descText.BackgroundTransparency = 1
				descText.Font = Enum.Font.Gotham
				descText.Text = cmd.Description
				descText.TextColor3 = Color3.fromRGB(140, 140, 155)
				descText.TextSize = 11
				descText.TextXAlignment = Enum.TextXAlignment.Left
				descText.ZIndex = 6004
				descText.Parent = item
			end

			item.Parent = results

			item.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					selectedIndex = i
					if cmd.Callback then pcall(cmd.Callback) end
					paletteObj:Close()
				end
			end)

			table.insert(currentResults, cmd)
		end

		results.CanvasSize = UDim2.new(0, 0, 0, #filtered * 38)
	end

	inputBox:GetPropertyChangedSignal("Text"):Connect(function()
		filterResults(inputBox.Text)
	end)

	inputBox:CaptureFocus()

	paletteInstance = paletteObj
	return paletteObj
end

function CommandPalette:Close()
	if paletteInstance then
		paletteInstance:Close()
	end
end

return CommandPalette
-- [[
-- 	VoidUI — WindowCore.lua
-- 	Core UI engine: creates windows, tabs, and all UI elements
-- 	No external dependencies — generates everything from scratch
-- ]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local WindowCore = {}

-- ============================================================
-- 	WINDOW MANAGER
-- ============================================================

local windowInstances = {}
local windowCounter = 0

function WindowCore:CreateWindow(config)
	config = config or {}
	windowCounter = windowCounter + 1

	local windowId = "VoidUI_Window_" .. windowCounter
	local windowTitle = config.Title or config.Name or "VoidUI"
	local windowWidth = config.Width or 500
	local windowHeight = config.Height or 475
	local toggleKey = config.ToggleUIKeybind or config.ToggleKeybind or "K"

	-- Main GUI Container
	local gui = Instance.new("ScreenGui")
	gui.Name = windowId
	gui.DisplayOrder = 100
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ResetOnSpawn = false
	gui.Parent = gethui and gethui() or CoreGui

	-- Main Frame
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, windowWidth, 0, windowHeight)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	main.BackgroundTransparency = 0
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Parent = gui

	-- Corner
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = main

	-- Stroke
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(40, 40, 52)
	mainStroke.Thickness = 1
	mainStroke.Parent = main

	-- Shadow
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 40, 1, 40)
	shadow.Position = UDim2.new(0, -20, 0, -20)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5587865193"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.6
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.ZIndex = -1
	shadow.Parent = main

	-- Topbar
	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Size = UDim2.new(1, 0, 0, 40)
	topbar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	topbar.BackgroundTransparency = 0
	topbar.BorderSizePixel = 0
	topbar.ZIndex = 10
	topbar.Parent = main

	local topbarCorner = Instance.new("UICorner")
	topbarCorner.CornerRadius = UDim.new(0, 12, 0, 12, 0, 0)
	topbarCorner.Parent = topbar

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 1, 0)
	title.Position = UDim2.new(0, 14, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamSemibold
	title.Text = windowTitle
	title.TextColor3 = Color3.fromRGB(225, 225, 230)
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 11
	title.Parent = topbar

	-- Close button
	local closeBtn = Instance.new("ImageButton")
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -36, 0.5, 0)
	closeBtn.AnchorPoint = Vector2.new(0, 0.5)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Image = "rbxassetid://10137832201"
	closeBtn.ImageColor3 = Color3.fromRGB(180, 180, 195)
	closeBtn.ZIndex = 12
	closeBtn.Parent = topbar

	-- Divider
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.new(0, 0, 1, 0)
	divider.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
	divider.BackgroundTransparency = 0
	divider.BorderSizePixel = 0
	divider.Parent = topbar

	-- Tab List
	local tabList = Instance.new("Frame")
	tabList.Name = "TabList"
	tabList.Size = UDim2.new(1, 0, 0, 34)
	tabList.Position = UDim2.new(0, 0, 0, 40)
	tabList.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
	tabList.BackgroundTransparency = 0
	tabList.BorderSizePixel = 0
	tabList.ZIndex = 5
	tabList.Parent = main

	local tabListPadding = Instance.new("UIPadding")
	tabListPadding.PaddingLeft = UDim.new(0, 6)
	tabListPadding.PaddingRight = UDim.new(0, 6)
	tabListPadding.Parent = tabList

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.FillDirection = Enum.FillDirection.Horizontal
	tabListLayout.Padding = UDim.new(0, 4)
	tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Parent = tabList

	-- Content Area
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, 0, 1, -74)
	content.Position = UDim2.new(0, 0, 0, 74)
	content.BackgroundTransparency = 1
	content.ClipsDescendants = true
	content.Parent = main

	-- Page Layout (for tab switching)
	local pageLayout = Instance.new("Frame")
	pageLayout.Size = UDim2.new(1, 0, 1, 0)
	pageLayout.BackgroundTransparency = 1
	pageLayout.Parent = content

	-- Draggable
	local dragging = false
	local dragOffset
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragOffset = input.Position - main.AbsolutePosition
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	RunService.RenderStepped:Connect(function()
		if dragging then
			local mousePos = UserInputService:GetMouseLocation()
			main.Position = UDim2.fromOffset(mousePos.X - dragOffset.X, mousePos.Y - dragOffset.Y)
		end
	end)

	-- Hide/Show logic
	local hidden = false
	closeBtn.MouseButton1Click:Connect(function()
		hidden = not hidden
		main.Visible = not hidden
	end)

	-- Toggle keybind
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode[toggleKey] then
			hidden = not hidden
			main.Visible = not hidden
		end
	end)

	-- ============================================================
	-- 	WINDOW OBJECT
	-- ============================================================

	local window = {
		Id = windowId,
		Gui = gui,
		Main = main,
		Topbar = topbar,
		TabList = tabList,
		Content = pageLayout,
		Tabs = {},
		ActiveTab = nil,
	}

	local currentTabIndex = 0

	function window:CreateTab(name, icon)
		currentTabIndex = currentTabIndex + 1
		local tabId = "tab_" .. currentTabIndex

		-- Tab Button
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "TabBtn_" .. name
		tabBtn.Size = UDim2.new(0, 80, 0, 26)
		tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		tabBtn.BackgroundTransparency = 0.3
		tabBtn.Text = "  " .. name
		tabBtn.Font = Enum.Font.Gotham
		tabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
		tabBtn.TextSize = 12
		tabBtn.AutoButtonColor = false
		tabBtn.ZIndex = 6
		tabBtn.Parent = self.TabList

		local tabBtnCorner = Instance.new("UICorner")
		tabBtnCorner.CornerRadius = UDim.new(0, 6)
		tabBtnCorner.Parent = tabBtn

		-- Tab Page
		local tabPage = Instance.new("ScrollingFrame")
		tabPage.Name = "Page_" .. name
		tabPage.Size = UDim2.new(1, 0, 1, 0)
		tabPage.BackgroundTransparency = 1
		tabPage.ScrollBarThickness = 4
		tabPage.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 52)
		tabPage.BorderSizePixel = 0
		tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabPage.Visible = currentTabIndex == 1
		tabPage.Parent = self.Content

		local pageListLayout = Instance.new("UIListLayout")
		pageListLayout.Padding = UDim.new(0, 4)
		pageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageListLayout.Parent = tabPage

		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingTop = UDim.new(0, 8)
		pagePadding.PaddingLeft = UDim.new(0, 5)
		pagePadding.PaddingRight = UDim.new(0, 5)
		pagePadding.PaddingBottom = UDim.new(0, 8)
		pagePadding.Parent = tabPage

		-- Set first tab as active
		if currentTabIndex == 1 then
			self.ActiveTab = tabPage
			tabBtn.BackgroundTransparency = 0
			tabBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
			tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		-- Tab switching
		tabBtn.MouseButton1Click:Connect(function()
			-- Deactivate all
			for _, otherBtn in ipairs(self.TabList:GetChildren()) do
				if otherBtn:IsA("TextButton") then
					otherBtn.BackgroundTransparency = 0.3
					otherBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
					otherBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
				end
			end
			for _, otherPage in ipairs(self.Content:GetChildren()) do
				if otherPage:IsA("ScrollingFrame") then
					otherPage.Visible = false
				end
			end

			-- Activate this
			tabBtn.BackgroundTransparency = 0
			tabBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
			tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			tabPage.Visible = true
			self.ActiveTab = tabPage
		end)

		-- ============================================================
		-- 	TAB OBJECT
		-- ============================================================

		local tab = {
			Id = tabId,
			Name = name,
			Button = tabBtn,
			Page = tabPage,
			ListLayout = pageListLayout,
			ElementIndex = 0,
		}

		-- Placeholder for CanvasSize update
		local function updateCanvas()
			local totalHeight = 0
			for _, child in ipairs(tabPage:GetChildren()) do
				if child:IsA("Frame") or child:IsA("TextButton") then
					totalHeight = totalHeight + child.AbsoluteSize.Y + 4
				end
			end
			tabPage.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
		end

		-- Create Section
		function tab:CreateSection(name)
			self.ElementIndex = self.ElementIndex + 1

			local section = Instance.new("Frame")
			section.Name = "Section_" .. name
			section.Size = UDim2.new(1, 0, 0, 22)
			section.BackgroundTransparency = 1
			section.BorderSizePixel = 0
			section.LayoutOrder = self.ElementIndex
			section.Parent = self.Page

			local sectionLabel = Instance.new("TextLabel")
			sectionLabel.Size = UDim2.new(1, -10, 1, 0)
			sectionLabel.BackgroundTransparency = 1
			sectionLabel.Font = Enum.Font.GothamSemibold
			sectionLabel.Text = name:upper()
			sectionLabel.TextColor3 = Color3.fromRGB(110, 110, 125)
			sectionLabel.TextSize = 11
			sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			sectionLabel.Parent = section

			updateCanvas()
			return { Set = function(_, newName) sectionLabel.Text = newName:upper() end }
		end

		-- Create Toggle
		function tab:CreateToggle(config)
			config = config or {}
			self.ElementIndex = self.ElementIndex + 1

			local frame = Instance.new("Frame")
			frame.Name = "Toggle_" .. (config.Name or "Toggle")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.LayoutOrder = self.ElementIndex
			frame.Parent = self.Page

			local frameCorner = Instance.new("UICorner")
			frameCorner.CornerRadius = UDim.new(0, 8)
			frameCorner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(48, 48, 58)
			stroke.Thickness = 1
			stroke.Parent = frame

			-- Label
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -70, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham
			label.Text = config.Name or "Toggle"
			label.TextColor3 = Color3.fromRGB(220, 220, 230)
			label.TextSize = 14
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = frame

			-- Switch Track
			local track = Instance.new("Frame")
			track.Size = UDim2.new(0, 44, 0, 24)
			track.Position = UDim2.new(1, -58, 0.5, 0)
			track.AnchorPoint = Vector2.new(0, 0.5)
			track.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
			track.BorderSizePixel = 0
			track.Parent = frame

			local trackCorner = Instance.new("UICorner")
			trackCorner.CornerRadius = UDim.new(0, 12)
			trackCorner.Parent = track

			-- Switch Knob
			local knob = Instance.new("Frame")
			knob.Size = UDim2.new(0, 18, 0, 18)
			knob.Position = UDim2.new(0, 3, 0.5, 0)
			knob.AnchorPoint = Vector2.new(0, 0.5)
			knob.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
			knob.BorderSizePixel = 0
			knob.ZIndex = 2
			knob.Parent = track

			local knobCorner = Instance.new("UICorner")
			knobCorner.CornerRadius = UDim.new(0, 9)
			knobCorner.Parent = knob

			-- Interact
			local interact = Instance.new("TextButton")
			interact.Size = UDim2.new(1, 0, 1, 0)
			interact.BackgroundTransparency = 1
			interact.Text = ""
			interact.ZIndex = 10
			interact.Parent = frame

			local state = config.CurrentValue or config.Default or false
			local callback = config.Callback or function() end

			local function updateState(newState)
				state = newState
				if state then
					track.BackgroundColor3 = Color3.fromRGB(88, 130, 255)
					TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(1, -21, 0.5, 0)
					}):Play()
				else
					track.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
					TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(0, 3, 0.5, 0)
					}):Play()
				end
				callback(state)
			end

			interact.MouseButton1Click:Connect(function()
				updateState(not state)
			end)

			-- Set initial
			if state then
				knob.Position = UDim2.new(1, -21, 0.5, 0)
				track.BackgroundColor3 = Color3.fromRGB(88, 130, 255)
			end

			updateCanvas()

			local selfObj = {}
			function selfObj:Set(v) updateState(v) end
			function selfObj:Get() return state end
			function selfObj:Toggle() updateState(not state) end
			return selfObj
		end

		-- Create Button
		function tab:CreateButton(config)
			config = config or {}
			self.ElementIndex = self.ElementIndex + 1

			local btn = Instance.new("TextButton")
			btn.Name = "Button_" .. (config.Name or "Button")
			btn.Size = UDim2.new(1, 0, 0, 38)
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
			btn.BackgroundTransparency = 0
			btn.Text = config.Name or "Button"
			btn.Font = Enum.Font.GothamSemibold
			btn.TextColor3 = Color3.fromRGB(220, 220, 230)
			btn.TextSize = 14
			btn.AutoButtonColor = false
			btn.LayoutOrder = self.ElementIndex
			btn.Parent = self.Page

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 8)
			btnCorner.Parent = btn

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(50, 50, 62)
			stroke.Thickness = 1
			stroke.Parent = btn

			btn.MouseEnter:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 42, 54)}):Play()
			end)
			btn.MouseLeave:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
			end)

			if config.Callback then
				btn.MouseButton1Click:Connect(function()
					pcall(config.Callback)
				end)
			end

			updateCanvas()
			return { Set = function(_, text) btn.Text = text end }
		end

		-- Create Slider
		function tab:CreateSlider(config)
			config = config or {}
			self.ElementIndex = self.ElementIndex + 1

			local min = config.Range and config.Range[1] or 0
			local max = config.Range and config.Range[2] or 100
			local inc = config.Increment or 1
			local suffix = config.Suffix or ""
			local value = config.CurrentValue or config.Default or min
			local callback = config.Callback or function() end

			local frame = Instance.new("Frame")
			frame.Name = "Slider_" .. (config.Name or "Slider")
			frame.Size = UDim2.new(1, 0, 0, 50)
			frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.LayoutOrder = self.ElementIndex
			frame.Parent = self.Page

			local frameCorner = Instance.new("UICorner")
			frameCorner.CornerRadius = UDim.new(0, 8)
			frameCorner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(48, 48, 58)
			stroke.Thickness = 1
			stroke.Parent = frame

			-- Label
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -80, 0, 18)
			label.Position = UDim2.new(0, 14, 0, 8)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham
			label.Text = config.Name or "Slider"
			label.TextColor3 = Color3.fromRGB(220, 220, 230)
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = frame

			-- Value
			local valueLabel = Instance.new("TextLabel")
			valueLabel.Size = UDim2.new(0, 60, 0, 18)
			valueLabel.Position = UDim2.new(1, -74, 0, 8)
			valueLabel.BackgroundTransparency = 1
			valueLabel.Font = Enum.Font.GothamSemibold
			valueLabel.Text = tostring(value) .. " " .. suffix
			valueLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
			valueLabel.TextSize = 12
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.Parent = frame

			-- Track
			local track = Instance.new("Frame")
			track.Size = UDim2.new(1, -28, 0, 6)
			track.Position = UDim2.new(0, 14, 0, 34)
			track.BackgroundColor3 = Color3.fromRGB(42, 42, 54)
			track.BorderSizePixel = 0
			track.Parent = frame

			local trackCorner = Instance.new("UICorner")
			trackCorner.CornerRadius = UDim.new(0, 3)
			trackCorner.Parent = track

			-- Progress
			local progress = Instance.new("Frame")
			progress.Size = UDim2.new(0, 0, 1, 0)
			progress.BackgroundColor3 = Color3.fromRGB(88, 130, 255)
			progress.BorderSizePixel = 0
			progress.Parent = track

			local progressCorner = Instance.new("UICorner")
			progressCorner.CornerRadius = UDim.new(0, 3)
			progressCorner.Parent = progress

			updateCanvas()
			return { Set = function(_, v) value = v; valueLabel.Text = tostring(v) .. " " .. suffix end }
		end

		-- Create Dropdown
		function tab:CreateDropdown(config)
			config = config or {}
			self.ElementIndex = self.ElementIndex + 1

			local frame = Instance.new("Frame")
			frame.Name = "Dropdown_" .. (config.Name or "Dropdown")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = true
			frame.LayoutOrder = self.ElementIndex
			frame.Parent = self.Page

			local frameCorner = Instance.new("UICorner")
			frameCorner.CornerRadius = UDim.new(0, 8)
			frameCorner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(48, 48, 58)
			stroke.Thickness = 1
			stroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -40, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham
			label.Text = config.Name or "Dropdown"
			label.TextColor3 = Color3.fromRGB(220, 220, 230)
			label.TextSize = 14
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = frame

			updateCanvas()
			return { Set = function(_, opts) end }
		end

		-- Create Input
		function tab:CreateInput(config)
			config = config or {}
			self.ElementIndex = self.ElementIndex + 1

			local frame = Instance.new("Frame")
			frame.Name = "Input_" .. (config.Name or "Input")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.LayoutOrder = self.ElementIndex
			frame.Parent = self.Page

			local frameCorner = Instance.new("UICorner")
			frameCorner.CornerRadius = UDim.new(0, 8)
			frameCorner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(48, 48, 58)
			stroke.Thickness = 1
			stroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0, 120, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham
			label.Text = config.Name or "Input"
			label.TextColor3 = Color3.fromRGB(220, 220, 230)
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = frame

			local inputBox = Instance.new("TextBox")
			inputBox.Size = UDim2.new(0, 140, 0, 28)
			inputBox.Position = UDim2.new(1, -154, 0.5, 0)
			inputBox.AnchorPoint = Vector2.new(0, 0.5)
			inputBox.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
			inputBox.BackgroundTransparency = 0
			inputBox.Font = Enum.Font.Gotham
			inputBox.Text = config.CurrentValue or config.Default or ""
			inputBox.TextColor3 = Color3.fromRGB(220, 220, 230)
			inputBox.TextSize = 13
			inputBox.PlaceholderText = config.Placeholder or "Type..."
			inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
			inputBox.ZIndex = 2
			inputBox.Parent = frame

			local inputCorner = Instance.new("UICorner")
			inputCorner.CornerRadius = UDim.new(0, 6)
			inputCorner.Parent = inputBox

			updateCanvas()

			local selfObj = { CurrentValue = config.CurrentValue or config.Default or "" }
			local callback = config.Callback or function() end
			inputBox.FocusLost:Connect(function()
				selfObj.CurrentValue = inputBox.Text
				callback(inputBox.Text)
			end)
			function selfObj:Set(text) inputBox.Text = text; selfObj.CurrentValue = text end
			return selfObj
		end

		-- Create Keybind
		function tab:CreateKeybind(config)
			config = config or {}
			self.ElementIndex = self.ElementIndex + 1

			local frame = Instance.new("Frame")
			frame.Name = "Keybind_" .. (config.Name or "Keybind")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.LayoutOrder = self.ElementIndex
			frame.Parent = self.Page

			local frameCorner = Instance.new("UICorner")
			frameCorner.CornerRadius = UDim.new(0, 8)
			frameCorner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(48, 48, 58)
			stroke.Thickness = 1
			stroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -60, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham
			label.Text = config.Name or "Keybind"
			label.TextColor3 = Color3.fromRGB(220, 220, 230)
			label.TextSize = 14
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = frame

			updateCanvas()

			local currentKey = config.CurrentKeybind or config.Default or "F"
			local callback = config.Callback or function() end
			local selfObj = { CurrentKeybind = currentKey }
			function selfObj:Set(key) currentKey = key end
			return selfObj
		end

		-- Create ColorPicker
		function tab:CreateColorPicker(config)
			config = config or {}
			self.ElementIndex = self.ElementIndex + 1

			local frame = Instance.new("Frame")
			frame.Name = "CP_" .. (config.Name or "Color")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.LayoutOrder = self.ElementIndex
			frame.Parent = self.Page

			local frameCorner = Instance.new("UICorner")
			frameCorner.CornerRadius = UDim.new(0, 8)
			frameCorner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(48, 48, 58)
			stroke.Thickness = 1
			stroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -60, 1, 0)
			label.Position = UDim2.new(0, 14, 0, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham
			label.Text = config.Name or "Color"
			label.TextColor3 = Color3.fromRGB(220, 220, 230)
			label.TextSize = 14
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = frame

			updateCanvas()

			local color = config.Color or config.Default or Color3.fromRGB(255, 255, 255)
			local callback = config.Callback or function() end
			return { Color = color, Set = function(_, c) color = c end }
		end

		-- Create Label
		function tab:CreateLabel(text, icon, color)
			self.ElementIndex = self.ElementIndex + 1

			local frame = Instance.new("Frame")
			frame.Name = "Label_" .. (text or "Label")
			frame.Size = UDim2.new(1, 0, 0, 32)
			frame.BackgroundColor3 = color or Color3.fromRGB(25, 25, 32)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.LayoutOrder = self.ElementIndex
			frame.Parent = self.Page

			local frameCorner = Instance.new("UICorner")
			frameCorner.CornerRadius = UDim.new(0, 6)
			frameCorner.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -14, 1, 0)
			label.Position = UDim2.new(0, 7, 0, 0)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham
			label.Text = text or ""
			label.TextColor3 = Color3.fromRGB(200, 200, 215)
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = frame

			updateCanvas()
			return { Set = function(_, t) label.Text = t end }
		end

		-- Create Paragraph
		function tab:CreateParagraph(config)
			config = config or {}
			self.ElementIndex = self.ElementIndex + 1

			local frame = Instance.new("Frame")
			frame.Name = "Para_" .. (config.Title or "Para")
			frame.Size = UDim2.new(1, 0, 0, 60)
			frame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.LayoutOrder = self.ElementIndex
			frame.Parent = self.Page

			local frameCorner = Instance.new("UICorner")
			frameCorner.CornerRadius = UDim.new(0, 6)
			frameCorner.Parent = frame

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, -14, 0, 18)
			title.Position = UDim2.new(0, 7, 0, 6)
			title.BackgroundTransparency = 1
			title.Font = Enum.Font.GothamSemibold
			title.Text = config.Title or ""
			title.TextColor3 = Color3.fromRGB(220, 220, 230)
			title.TextSize = 14
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = frame

			local contentText = Instance.new("TextLabel")
			contentText.Size = UDim2.new(1, -14, 0, 30)
			contentText.Position = UDim2.new(0, 7, 0, 26)
			contentText.BackgroundTransparency = 1
			contentText.Font = Enum.Font.Gotham
			contentText.Text = config.Content or ""
			contentText.TextColor3 = Color3.fromRGB(160, 160, 175)
			contentText.TextSize = 12
			contentText.TextXAlignment = Enum.TextXAlignment.Left
			contentText.TextWrapped = true
			contentText.Parent = frame

			updateCanvas()
			return { Set = function(_, c) contentText.Text = c.Content end }
		end

		-- Create Divider
		function tab:CreateDivider()
			self.ElementIndex = self.ElementIndex + 1

			local frame = Instance.new("Frame")
			frame.Name = "Divider"
			frame.Size = UDim2.new(1, -10, 0, 1)
			frame.Position = UDim2.new(0, 5, 0, 0)
			frame.BackgroundColor3 = Color3.fromRGB(50, 50, 62)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.LayoutOrder = self.ElementIndex
			frame.Parent = self.Page

			updateCanvas()
			return { Set = function(_, visible) frame.Visible = visible end }
		end

		table.insert(self.Tabs, tab)
		return tab
	end

	-- ModifyTheme (compatibility)
	function window:ModifyTheme(name)
		-- Theme is handled by ThemeManager
		print("Theme:", name)
	end

	table.insert(windowInstances, window)
	return window
end

-- Notify (basic implementation)
function WindowCore:Notify(data)
	data = data or {}
	warn("[Notify]", data.Title, data.Content)
end

function WindowCore:LoadConfiguration()
	-- Config is handled by ConfigManager
end

function WindowCore:SetVisibility(visible)
	for _, w in ipairs(windowInstances) do
		w.Main.Visible = visible
	end
end

function WindowCore:IsVisible()
	for _, w in ipairs(windowInstances) do
		if w.Main.Visible then return true end
	end
	return false
end

function WindowCore:Destroy()
	for _, w in ipairs(windowInstances) do
		pcall(function() w.Gui:Destroy() end)
	end
	table.clear(windowInstances)
end

return WindowCore
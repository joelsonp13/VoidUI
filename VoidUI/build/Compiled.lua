-- ============================================================
-- 	VOIDUI v2.0.0 — Premium Roblox UI Library
-- 	100% self-contained, zero external dependencies
-- ============================================================
-- 	Usage: loadstring(game:HttpGet("url"))()
-- 	GitHub: https://github.com/joelsonp13/VoidUI
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- 	SERVICES
-- ═══════════════════════════════════════════════════════════════

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════════
-- 	WINDOW CORE (self-contained UI engine)
-- ═══════════════════════════════════════════════════════════════

local WindowCore = {}
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

	local gui = Instance.new("ScreenGui")
	gui.Name = windowId; gui.DisplayOrder = 100; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.ResetOnSpawn = false
	gui.Parent = gethui and gethui() or CoreGui

	local main = Instance.new("Frame")
	main.Name = "Main"; main.Size = UDim2.new(0, windowWidth, 0, windowHeight); main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5); main.BackgroundColor3 = Color3.fromRGB(18, 18, 22); main.BorderSizePixel = 0; main.ClipsDescendants = true; main.Parent = gui

	local mainCorner = Instance.new("UICorner"); mainCorner.CornerRadius = UDim.new(0, 12); mainCorner.Parent = main
	local mainStroke = Instance.new("UIStroke"); mainStroke.Color = Color3.fromRGB(40, 40, 52); mainStroke.Thickness = 1; mainStroke.Parent = main

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"; shadow.Size = UDim2.new(1, 40, 1, 40); shadow.Position = UDim2.new(0, -20, 0, -20)
	shadow.BackgroundTransparency = 1; shadow.Image = "rbxassetid://5587865193"; shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.6; shadow.ScaleType = Enum.ScaleType.Slice; shadow.SliceCenter = Rect.new(10, 10, 118, 118); shadow.ZIndex = -1; shadow.Parent = main

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"; topbar.Size = UDim2.new(1, 0, 0, 40); topbar.BackgroundColor3 = Color3.fromRGB(22, 22, 28); topbar.BorderSizePixel = 0; topbar.ZIndex = 10; topbar.Parent = main

	local topbarCorner = Instance.new("UICorner"); topbarCorner.CornerRadius = UDim.new(0, 12, 0, 12, 0, 0); topbarCorner.Parent = topbar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 1, 0); title.Position = UDim2.new(0, 14, 0, 0); title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamSemibold; title.Text = windowTitle; title.TextColor3 = Color3.fromRGB(225, 225, 230)
	title.TextSize = 15; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 11; title.Parent = topbar

	local closeBtn = Instance.new("ImageButton")
	closeBtn.Size = UDim2.new(0, 28, 0, 28); closeBtn.Position = UDim2.new(1, -36, 0.5, 0); closeBtn.AnchorPoint = Vector2.new(0, 0.5)
	closeBtn.BackgroundTransparency = 1; closeBtn.Image = "rbxassetid://10137832201"; closeBtn.ImageColor3 = Color3.fromRGB(180, 180, 195); closeBtn.ZIndex = 12; closeBtn.Parent = topbar

	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, 0, 0, 1); divider.Position = UDim2.new(0, 0, 1, 0); divider.BackgroundColor3 = Color3.fromRGB(40, 40, 52); divider.BorderSizePixel = 0; divider.Parent = topbar

	local tabList = Instance.new("Frame")
	tabList.Name = "TabList"; tabList.Size = UDim2.new(1, 0, 0, 34); tabList.Position = UDim2.new(0, 0, 0, 40)
	tabList.BackgroundColor3 = Color3.fromRGB(14, 14, 18); tabList.BorderSizePixel = 0; tabList.ZIndex = 5; tabList.Parent = main

	local tabListPadding = Instance.new("UIPadding"); tabListPadding.PaddingLeft = UDim.new(0, 6); tabListPadding.Parent = tabList
	local tabListLayout = Instance.new("UIListLayout"); tabListLayout.FillDirection = Enum.FillDirection.Horizontal; tabListLayout.Padding = UDim.new(0, 4); tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center; tabListLayout.Parent = tabList

	local content = Instance.new("Frame")
	content.Name = "Content"; content.Size = UDim2.new(1, 0, 1, -74); content.Position = UDim2.new(0, 0, 0, 74)
	content.BackgroundTransparency = 1; content.ClipsDescendants = true; content.Parent = main

	local pageLayout = Instance.new("Frame"); pageLayout.Size = UDim2.new(1, 0, 1, 0); pageLayout.BackgroundTransparency = 1; pageLayout.Parent = content

	-- Draggable
	local dragging = false; local dragOffset
	topbar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragOffset = i.Position - main.AbsolutePosition end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	RunService.RenderStepped:Connect(function() if dragging then local m = UserInputService:GetMouseLocation(); main.Position = UDim2.fromOffset(m.X - dragOffset.X, m.Y - dragOffset.Y) end end)

	-- Toggle visibility
	local hidden = false
	closeBtn.MouseButton1Click:Connect(function() hidden = not hidden; main.Visible = not hidden end)
	UserInputService.InputBegan:Connect(function(i, p) if p then return end; if i.KeyCode == Enum.KeyCode[toggleKey] then hidden = not hidden; main.Visible = not hidden end end)

	local window = { Id = windowId, Gui = gui, Main = main, Topbar = topbar, TabList = tabList, Content = pageLayout, Tabs = {}, ActiveTab = nil }
	local tabIdx = 0

	function window:CreateTab(name)
		tabIdx = tabIdx + 1
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "TabBtn_" .. name; tabBtn.Size = UDim2.new(0, 80, 0, 26)
		tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45); tabBtn.BackgroundTransparency = 0.3; tabBtn.Text = "  " .. name
		tabBtn.Font = Enum.Font.Gotham; tabBtn.TextColor3 = Color3.fromRGB(180, 180, 190); tabBtn.TextSize = 12; tabBtn.AutoButtonColor = false; tabBtn.ZIndex = 6; tabBtn.Parent = self.TabList
		local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = tabBtn

		local tabPage = Instance.new("ScrollingFrame")
		tabPage.Name = "Page_" .. name; tabPage.Size = UDim2.new(1, 0, 1, 0); tabPage.BackgroundTransparency = 1
		tabPage.ScrollBarThickness = 4; tabPage.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 52); tabPage.BorderSizePixel = 0; tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabPage.Visible = tabIdx == 1; tabPage.Parent = self.Content

		local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, 4); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = tabPage
		local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0, 8); pad.PaddingLeft = UDim.new(0, 5); pad.PaddingRight = UDim.new(0, 5); pad.Parent = tabPage

		if tabIdx == 1 then tabBtn.BackgroundTransparency = 0; tabBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70); tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) end

		tabBtn.MouseButton1Click:Connect(function()
			for _, b in ipairs(self.TabList:GetChildren()) do if b:IsA("TextButton") then b.BackgroundTransparency = 0.3; b.BackgroundColor3 = Color3.fromRGB(35, 35, 45); b.TextColor3 = Color3.fromRGB(180, 180, 190) end end
			for _, p in ipairs(self.Content:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
			tabBtn.BackgroundTransparency = 0; tabBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70); tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); tabPage.Visible = true
		end)

		local function updateCanvas()
			local h = 0
			for _, c in ipairs(tabPage:GetChildren()) do if c:IsA("Frame") or c:IsA("TextButton") then h = h + c.AbsoluteSize.Y + 4 end end
			tabPage.CanvasSize = UDim2.new(0, 0, 0, h + 20)
		end

		local tab = { Button = tabBtn, Page = tabPage, el = 0 }

		function tab:Section(name)
			self.el = self.el + 1
			local s = Instance.new("Frame"); s.Size = UDim2.new(1, 0, 0, 22); s.BackgroundTransparency = 1; s.BorderSizePixel = 0; s.LayoutOrder = self.el; s.Parent = self.Page
			local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -10, 1, 0); l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamSemibold; l.Text = name:upper(); l.TextColor3 = Color3.fromRGB(110, 110, 125); l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = s
			updateCanvas(); return { Set = function(_, n) l.Text = n:upper() end }
		end

		function tab:Toggle(c)
			c = c or {}; self.el = self.el + 1
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 42); f.BackgroundColor3 = Color3.fromRGB(28, 28, 36); f.BorderSizePixel = 0; f.LayoutOrder = self.el; f.Parent = self.Page
			local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 8); fc.Parent = f
			local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(48, 48, 58); fs.Thickness = 1; fs.Parent = f
			local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -70, 1, 0); l.Position = UDim2.new(0, 14, 0, 0); l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.Text = c.Name or "Toggle"; l.TextColor3 = Color3.fromRGB(220, 220, 230); l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
			local tr = Instance.new("Frame"); tr.Size = UDim2.new(0, 44, 0, 24); tr.Position = UDim2.new(1, -58, 0.5, 0); tr.AnchorPoint = Vector2.new(0, 0.5); tr.BackgroundColor3 = Color3.fromRGB(55, 55, 68); tr.BorderSizePixel = 0; tr.Parent = f
			local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 12); tc.Parent = tr
			local kn = Instance.new("Frame"); kn.Size = UDim2.new(0, 18, 0, 18); kn.Position = UDim2.new(0, 3, 0.5, 0); kn.AnchorPoint = Vector2.new(0, 0.5); kn.BackgroundColor3 = Color3.fromRGB(200, 200, 210); kn.BorderSizePixel = 0; kn.ZIndex = 2; kn.Parent = tr
			local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(0, 9); kc.Parent = kn
			local ib = Instance.new("TextButton"); ib.Size = UDim2.new(1, 0, 1, 0); ib.BackgroundTransparency = 1; ib.Text = ""; ib.ZIndex = 10; ib.Parent = f
			local state = c.CurrentValue or c.Default or false; local cb = c.Callback or function() end
			local function us(s) state = s; if s then tr.BackgroundColor3 = Color3.fromRGB(88, 130, 255); TweenService:Create(kn, TweenInfo.new(0.25), {Position = UDim2.new(1, -21, 0.5, 0)}):Play() else tr.BackgroundColor3 = Color3.fromRGB(55, 55, 68); TweenService:Create(kn, TweenInfo.new(0.25), {Position = UDim2.new(0, 3, 0.5, 0)}):Play() end; cb(state) end
			ib.MouseButton1Click:Connect(function() us(not state) end)
			if state then kn.Position = UDim2.new(1, -21, 0.5, 0); tr.BackgroundColor3 = Color3.fromRGB(88, 130, 255) end
			updateCanvas()
			local o = {}; function o:Set(v) us(v) end; function o:Get() return state end; function o:Toggle() us(not state) end; return o
		end

		function tab:Button(c)
			c = c or {}; self.el = self.el + 1
			local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 38); b.BackgroundColor3 = Color3.fromRGB(35, 35, 45); b.Text = c.Name or "Button"; b.Font = Enum.Font.GothamSemibold; b.TextColor3 = Color3.fromRGB(220, 220, 230); b.TextSize = 14; b.AutoButtonColor = false; b.LayoutOrder = self.el; b.Parent = self.Page
			local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 8); bc.Parent = b
			local bs = Instance.new("UIStroke"); bs.Color = Color3.fromRGB(50, 50, 62); bs.Thickness = 1; bs.Parent = b
			b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 42, 54)}):Play() end)
			b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play() end)
			if c.Callback then b.MouseButton1Click:Connect(function() pcall(c.Callback) end) end
			updateCanvas(); return { Set = function(_, t) b.Text = t end }
		end

		function tab:Slider(c)
			c = c or {}; self.el = self.el + 1
			local mn = (c.Range or {0,100})[1]; local mx = (c.Range or {0,100})[2]; local v = c.CurrentValue or c.Default or mn; local sf = c.Suffix or ""
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 50); f.BackgroundColor3 = Color3.fromRGB(28, 28, 36); f.BorderSizePixel = 0; f.LayoutOrder = self.el; f.Parent = self.Page
			local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 8); fc.Parent = f
			local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(48, 48, 58); fs.Thickness = 1; fs.Parent = f
			local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -80, 0, 18); l.Position = UDim2.new(0, 14, 0, 8); l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.Text = c.Name or "Slider"; l.TextColor3 = Color3.fromRGB(220, 220, 230); l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
			local vl = Instance.new("TextLabel"); vl.Size = UDim2.new(0, 60, 0, 18); vl.Position = UDim2.new(1, -74, 0, 8); vl.BackgroundTransparency = 1; vl.Font = Enum.Font.GothamSemibold; vl.Text = tostring(v) .. " " .. sf; vl.TextColor3 = Color3.fromRGB(140, 140, 155); vl.TextSize = 12; vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Parent = f
			updateCanvas(); return { Set = function(_, nv) v = nv; vl.Text = tostring(nv) .. " " .. sf end }
		end

		function tab:Dropdown(c)
			c = c or {}; self.el = self.el + 1
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 42); f.BackgroundColor3 = Color3.fromRGB(28, 28, 36); f.BorderSizePixel = 0; f.ClipsDescendants = true; f.LayoutOrder = self.el; f.Parent = self.Page
			local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 8); fc.Parent = f
			local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(48, 48, 58); fs.Thickness = 1; fs.Parent = f
			local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -40, 1, 0); l.Position = UDim2.new(0, 14, 0, 0); l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.Text = c.Name or "Dropdown"; l.TextColor3 = Color3.fromRGB(220, 220, 230); l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
			updateCanvas(); return { Set = function(_, opts) end }
		end

		function tab:Input(c)
			c = c or {}; self.el = self.el + 1
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 42); f.BackgroundColor3 = Color3.fromRGB(28, 28, 36); f.BorderSizePixel = 0; f.LayoutOrder = self.el; f.Parent = self.Page
			local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 8); fc.Parent = f
			local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(48, 48, 58); fs.Thickness = 1; fs.Parent = f
			local l = Instance.new("TextLabel"); l.Size = UDim2.new(0, 120, 1, 0); l.Position = UDim2.new(0, 14, 0, 0); l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.Text = c.Name or "Input"; l.TextColor3 = Color3.fromRGB(220, 220, 230); l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
			local ib = Instance.new("TextBox"); ib.Size = UDim2.new(0, 140, 0, 28); ib.Position = UDim2.new(1, -154, 0.5, 0); ib.AnchorPoint = Vector2.new(0, 0.5); ib.BackgroundColor3 = Color3.fromRGB(22, 22, 30); ib.Font = Enum.Font.Gotham; ib.Text = c.CurrentValue or c.Default or ""; ib.TextColor3 = Color3.fromRGB(220, 220, 230); ib.TextSize = 13; ib.PlaceholderText = c.Placeholder or "Type..."; ib.PlaceholderColor3 = Color3.fromRGB(100, 100, 115); ib.ZIndex = 2; ib.Parent = f
			local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(0, 6); ic.Parent = ib
			updateCanvas()
			local o = { CurrentValue = c.CurrentValue or c.Default or "" }; local cb = c.Callback or function() end
			ib.FocusLost:Connect(function() o.CurrentValue = ib.Text; cb(ib.Text) end)
			function o:Set(t) ib.Text = t; o.CurrentValue = t end; return o
		end

		function tab:Keybind(c)
			c = c or {}; self.el = self.el + 1
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 42); f.BackgroundColor3 = Color3.fromRGB(28, 28, 36); f.BorderSizePixel = 0; f.LayoutOrder = self.el; f.Parent = self.Page
			local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 8); fc.Parent = f
			local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(48, 48, 58); fs.Thickness = 1; fs.Parent = f
			local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 14, 0, 0); l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.Text = c.Name or "Keybind"; l.TextColor3 = Color3.fromRGB(220, 220, 230); l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
			updateCanvas(); return { CurrentKeybind = c.CurrentKeybind or c.Default or "F", Set = function(_, k) end }
		end

		function tab:ColorPicker(c)
			c = c or {}; self.el = self.el + 1
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 42); f.BackgroundColor3 = Color3.fromRGB(28, 28, 36); f.BorderSizePixel = 0; f.LayoutOrder = self.el; f.Parent = self.Page
			local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 8); fc.Parent = f
			local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(48, 48, 58); fs.Thickness = 1; fs.Parent = f
			local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 14, 0, 0); l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.Text = c.Name or "Color"; l.TextColor3 = Color3.fromRGB(220, 220, 230); l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
			updateCanvas(); return { Color = c.Color or c.Default or Color3.fromRGB(255,255,255), Set = function(_, cl) end }
		end

		function tab:Label(text, icon, color)
			self.el = self.el + 1
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 32); f.BackgroundColor3 = color or Color3.fromRGB(25, 25, 32); f.BorderSizePixel = 0; f.LayoutOrder = self.el; f.Parent = self.Page
			local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 6); fc.Parent = f
			local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -14, 1, 0); l.Position = UDim2.new(0, 7, 0, 0); l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.Text = text or ""; l.TextColor3 = Color3.fromRGB(200, 200, 215); l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
			updateCanvas(); return { Set = function(_, t) l.Text = t end }
		end

		function tab:Paragraph(c)
			c = c or {}; self.el = self.el + 1
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 60); f.BackgroundColor3 = Color3.fromRGB(25, 25, 32); f.BorderSizePixel = 0; f.LayoutOrder = self.el; f.Parent = self.Page
			local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 6); fc.Parent = f
			local t = Instance.new("TextLabel"); t.Size = UDim2.new(1, -14, 0, 18); t.Position = UDim2.new(0, 7, 0, 6); t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamSemibold; t.Text = c.Title or ""; t.TextColor3 = Color3.fromRGB(220, 220, 230); t.TextSize = 14; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = f
			local ct = Instance.new("TextLabel"); ct.Size = UDim2.new(1, -14, 0, 30); ct.Position = UDim2.new(0, 7, 0, 26); ct.BackgroundTransparency = 1; ct.Font = Enum.Font.Gotham; ct.Text = c.Content or ""; ct.TextColor3 = Color3.fromRGB(160, 160, 175); ct.TextSize = 12; ct.TextXAlignment = Enum.TextXAlignment.Left; ct.TextWrapped = true; ct.Parent = f
			updateCanvas(); return { Set = function(_, nc) ct.Text = nc.Content end }
		end

		function tab:Divider()
			self.el = self.el + 1
			local d = Instance.new("Frame"); d.Size = UDim2.new(1, -10, 0, 1); d.BackgroundColor3 = Color3.fromRGB(50, 50, 62); d.BorderSizePixel = 0; d.LayoutOrder = self.el; d.Parent = self.Page
			updateCanvas(); return { Set = function(_, v) d.Visible = v end }
		end

		table.insert(self.Tabs, tab); return tab
	end

	function window:ModifyTheme(name) end

	table.insert(windowInstances, window); return window
end

function WindowCore:Notify(data)
	data = data or {}
	if data.Title or data.Content then
		warn("[VoidUI]", data.Title or "", data.Content or "")
	end
end
function WindowCore:LoadConfiguration() end

function WindowCore:SetVisibility(v)
	for _, w in ipairs(windowInstances) do w.Main.Visible = v end
end
function WindowCore:IsVisible()
	for _, w in ipairs(windowInstances) do if w.Main.Visible then return true end end; return false
end
function WindowCore:Destroy()
	for _, w in ipairs(windowInstances) do pcall(function() w.Gui:Destroy() end) end; table.clear(windowInstances)
end

-- ═══════════════════════════════════════════════════════════════
-- 	VOIDUI MODULES
-- ═══════════════════════════════════════════════════════════════

-- Theme Manager
local ThemeManager = { _current = nil, _currentName = "Default", _listeners = {}, _customThemes = {} }
local Themes = {}
Themes.Default = { Text = Color3.fromRGB(225,225,230), Background = Color3.fromRGB(18,18,22), Surface = Color3.fromRGB(32,32,40), Topbar = Color3.fromRGB(22,22,28), Tab = Color3.fromRGB(40,40,50), TabActive = Color3.fromRGB(60,60,75), Element = Color3.fromRGB(28,28,36), ElementHover = Color3.fromRGB(34,34,44), Accent = Color3.fromRGB(88,130,255), Success = Color3.fromRGB(45,200,120), Warning = Color3.fromRGB(255,180,50), Error = Color3.fromRGB(235,80,80), ToggleEnabled = Color3.fromRGB(88,130,255), SliderProgress = Color3.fromRGB(88,130,255), Input = Color3.fromRGB(24,24,32) }
Themes.Midnight = { Text = Color3.fromRGB(200,200,210), Background = Color3.fromRGB(10,10,14), Surface = Color3.fromRGB(22,23,32), Topbar = Color3.fromRGB(14,15,20), Tab = Color3.fromRGB(30,32,42), TabActive = Color3.fromRGB(48,50,65), Element = Color3.fromRGB(20,21,28), Accent = Color3.fromRGB(100,120,255), ToggleEnabled = Color3.fromRGB(100,120,255), SliderProgress = Color3.fromRGB(100,120,255) }
Themes.AMOLED = { Text = Color3.fromRGB(200,200,210), Background = Color3.fromRGB(0,0,0), Surface = Color3.fromRGB(12,12,16), Topbar = Color3.fromRGB(0,0,0), Tab = Color3.fromRGB(18,18,24), TabActive = Color3.fromRGB(34,34,46), Element = Color3.fromRGB(10,10,14), Accent = Color3.fromRGB(80,140,255), ToggleEnabled = Color3.fromRGB(80,140,255), SliderProgress = Color3.fromRGB(80,140,255) }
Themes.Neon = { Text = Color3.fromRGB(220,220,240), Background = Color3.fromRGB(10,8,20), Surface = Color3.fromRGB(22,18,38), Topbar = Color3.fromRGB(14,10,26), Tab = Color3.fromRGB(32,26,50), TabActive = Color3.fromRGB(50,42,72), Element = Color3.fromRGB(18,14,32), Accent = Color3.fromRGB(130,60,255), ToggleEnabled = Color3.fromRGB(130,60,255), SliderProgress = Color3.fromRGB(130,60,255) }
ThemeManager.Themes = Themes
ThemeManager:ApplyTheme("Default")
function ThemeManager:GetTheme(n) return Themes[n] or self._customThemes[n] end
function ThemeManager:GetCurrent() return self._current end
function ThemeManager:GetAllThemes() local n = {}; for k in pairs(Themes) do table.insert(n,k) end; for k in pairs(self._customThemes) do table.insert(n,k) end; return n end
function ThemeManager:ApplyTheme(n) local t = self:GetTheme(n); if not t then return false end; self._current = t; self._currentName = n; for _, cb in ipairs(self._listeners) do pcall(cb, t, n) end; return true end
function ThemeManager:OnThemeChanged(cb) table.insert(self._listeners, cb) end

-- Notification
local NotificationManager = {}
function NotificationManager:Notify(data) data = data or {}; if data.Title or data.Content then warn("[Notify]", data.Title or "", data.Content or "") end end

-- Mobile Manager
local MobileManager = {}
function MobileManager:IsMobile() return UserInputService.TouchEnabled end
function MobileManager:GetScale() local v = workspace.CurrentCamera.ViewportSize; if v.X < 600 then return 0.65 elseif v.X < 900 then return 0.8 elseif v.X < 1200 then return 0.9 else return 1 end end

-- Sidebar Engine
local SidebarEngine = {}
function SidebarEngine:Create(config)
	config = config or {}
	local c = Instance.new("ScreenGui"); c.Name = "VoidUISidebar"; c.DisplayOrder = 800; c.ResetOnSpawn = false; c.Parent = gethui and gethui() or CoreGui
	local f = Instance.new("Frame"); f.Size = UDim2.new(0, config.Width or 200, 1, 0); f.BackgroundColor3 = Color3.fromRGB(16,16,22); f.BackgroundTransparency = 0.05; f.BorderSizePixel = 0; f.ZIndex = 50; f.Parent = c
	local sc = Instance.new("ScrollingFrame"); sc.Size = UDim2.new(1,0,1,0); sc.BackgroundTransparency = 1; sc.ScrollBarThickness = 0; sc.Parent = f
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0,2); ll.Parent = sc
	local s = { Frame = f, Content = sc, Container = c, Items = {} }
	function s:AddSection(n) local sf = Instance.new("Frame"); sf.Size = UDim2.new(1,0,0,24); sf.BackgroundTransparency = 1; sf.Parent = self.Content; local st = Instance.new("TextLabel"); st.Size = UDim2.new(1,-24,1,0); st.Position = UDim2.new(0,12,0,0); st.BackgroundTransparency = 1; st.Font = Enum.Font.GothamSemibold; st.Text = n:upper(); st.TextColor3 = Color3.fromRGB(110,110,125); st.TextSize = 10; st.TextXAlignment = Enum.TextXAlignment.Left; st.Parent = sf; return self end
	function s:AddItem(cfg) cfg = cfg or {}; local it = Instance.new("TextButton"); it.Size = UDim2.new(1,-8,0,40); it.BackgroundTransparency = 1; it.Text = ""; it.AutoButtonColor = false; it.ZIndex = 55; it.Parent = self.Content; local ic = Instance.new("ImageLabel"); ic.Size = UDim2.new(0,22,0,22); ic.Position = UDim2.new(0,12,0.5,0); ic.AnchorPoint = Vector2.new(0,0.5); ic.BackgroundTransparency = 1; ic.Image = cfg.Icon or ""; ic.ImageColor3 = Color3.fromRGB(170,170,185); ic.ZIndex = 56; ic.Parent = it; local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(1,-50,1,0); lb.Position = UDim2.new(0,44,0,0); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.Gotham; lb.Text = cfg.Name or "Item"; lb.TextColor3 = Color3.fromRGB(200,200,215); lb.TextSize = 14; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 56; lb.Parent = it; if cfg.Callback then it.MouseButton1Click:Connect(cfg.Callback) end; table.insert(self.Items, {Frame = it, Config = cfg, Icon = ic, Label = lb}); return self end
	return s
end

-- Icons System
local Icons = {}
local iconCache = {}
function Icons:Resolve(name)
	if not name or name == "" then return "" end
	if iconCache[name] then return iconCache[name] end
	if tonumber(name) then local u = "rbxassetid://"..name; iconCache[name] = u; return u end
	return ""
end

-- Command Palette
local CommandPalette = {}
function CommandPalette:Open(commands, config)
	config = config or {}
	local o = Instance.new("Frame"); o.Size = UDim2.new(1,0,1,0); o.BackgroundColor3 = Color3.fromRGB(0,0,0); o.BackgroundTransparency = 0.6; o.ZIndex = 6000; o.Parent = gethui and gethui() or CoreGui
	local con = Instance.new("Frame"); con.Size = UDim2.new(0,540,0,380); con.Position = UDim2.new(0.5,0,0,40); con.AnchorPoint = Vector2.new(0.5,0); con.BackgroundColor3 = Color3.fromRGB(24,24,32); con.BorderSizePixel = 0; con.ClipsDescendants = true; con.ZIndex = 6001; con.Parent = o
	local inp = Instance.new("TextBox"); inp.Size = UDim2.new(1,-24,0,42); inp.Position = UDim2.new(0,12,0,10); inp.BackgroundColor3 = Color3.fromRGB(30,30,38); inp.Font = Enum.Font.Gotham; inp.Text = ""; inp.TextColor3 = Color3.fromRGB(220,220,230); inp.TextSize = 15; inp.PlaceholderText = "Search..."; inp.PlaceholderColor3 = Color3.fromRGB(100,100,115); inp.ZIndex = 6002; inp.Parent = con
	local res = Instance.new("ScrollingFrame"); res.Size = UDim2.new(1,-12,0,300); res.Position = UDim2.new(0,6,0,60); res.BackgroundTransparency = 1; res.ScrollBarThickness = 4; res.ZIndex = 6002; res.Parent = con
	local function close() TweenService:Create(con, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Size = UDim2.new(0,540,0,0)}):Play(); task.delay(0.3, function() pcall(function() o:Destroy() end) end) end
	o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then close() end end)
	UserInputService.InputBegan:Connect(function(i,p) if p then return end; if i.KeyCode == Enum.KeyCode.Escape then close() end end)
	inp:CaptureFocus(); inp:GetPropertyChangedSignal("Text"):Connect(function()
		local q = inp.Text:lower(); for _, ch in ipairs(res:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end; if #q == 0 then return end; local y = 0
		for _, cmd in ipairs(commands or {}) do if (cmd.Name or ""):lower():find(q,1,true) then local it = Instance.new("Frame"); it.Size = UDim2.new(1,-8,0,36); it.BackgroundColor3 = Color3.fromRGB(28,28,38); it.BorderSizePixel = 0; it.ZIndex = 6003; it.Parent = res; local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-16,0,18); t.Position = UDim2.new(0,8,0,2); t.BackgroundTransparency = 1; t.Font = Enum.Font.Gotham; t.Text = cmd.Name or ""; t.TextColor3 = Color3.fromRGB(220,220,230); t.TextSize = 14; t.TextXAlignment = Enum.TextXAlignment.Left; t.ZIndex = 6004; t.Parent = it; it.InputBegan:Connect(function(ix) if ix.UserInputType == Enum.UserInputType.MouseButton1 then if cmd.Callback then pcall(cmd.Callback) end; close() end end); y = y + 38 end
		res.CanvasSize = UDim2.new(0,0,0,y)
	end)
end

-- Config Manager
local ConfigManager = { _flags = {}, _currentProfile = "Default" }
local CF = "VoidUI/Configs"
pcall(function() if isfolder and not isfolder("VoidUI") then makefolder("VoidUI") end; if isfolder and not isfolder(CF) then makefolder(CF) end end)
function ConfigManager:RegisterFlag(n, v) self._flags[n] = v end
function ConfigManager:GetFlag(n) return self._flags[n] end
function ConfigManager:SetFlag(n, v) self._flags[n] = v; return v end
function ConfigManager:Save(p) p = p or self._currentProfile; local d = {}; for n, v in pairs(self._flags) do if typeof(v) == "Color3" then d[n] = {R=v.R*255,G=v.G*255,B=v.B*255} else d[n] = v end end; local ok, enc = pcall(function() return HttpService:JSONEncode(d) end); if ok then pcall(function() writefile(CF.."/"..p..".json", enc) end) end end
function ConfigManager:Load(p) p = p or self._currentProfile; local ok = pcall(function() return readfile(CF.."/"..p..".json") end); if not ok then return false end; local dk, d = pcall(function() return HttpService:JSONDecode(ok) end); if not dk then return false end; for n, v in pairs(d) do if type(v) == "table" and v.R then self._flags[n] = Color3.fromRGB(v.R, v.G, v.B) else self._flags[n] = v end end; return true end
function ConfigManager:Export() return HttpService:JSONEncode(self._flags) end
function ConfigManager:Reset() table.clear(self._flags); self:Save() end

-- Watermark Component
local WatermarkComponent = {}
function WatermarkComponent:Create(config)
	config = config or {}
	local c = Instance.new("ScreenGui"); c.Name = "VoidUIWatermark"; c.DisplayOrder = 10000; c.ResetOnSpawn = false; c.Parent = gethui and gethui() or CoreGui
	local f = Instance.new("Frame"); f.Size = UDim2.new(0, config.Width or 200, 0, config.Height or 28); f.Position = UDim2.new(0, config.PositionX or 12, 0, config.PositionY or 12); f.BackgroundColor3 = Color3.fromRGB(18,18,24); f.BackgroundTransparency = 0.2; f.BorderSizePixel = 0; f.Parent = c
	local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-12,1,0); t.Position = UDim2.new(0,6,0,0); t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamSemibold; t.TextSize = 13; t.TextColor3 = Color3.fromRGB(220,220,230); t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = f
	local obj = { _r = true }
	RunService.RenderStepped:Connect(function(dt)
		if not obj._r then return end
		local fps = math.floor(1/dt); local mem = collectgarbage and math.floor(collectgarbage("count")) or 0
		local fpsT = config.ShowFPS ~= false and ("FPS: " .. fps) or ""
		local memT = config.ShowMemory and (" | MEM: " .. mem .. "KB") or ""
		local cusT = config.Text or ""; local sep = (cusT ~= "" and (fpsT ~= "" or memT ~= "")) and " | " or ""
		t.Text = cusT .. sep .. fpsT .. memT
	end)
	local st = {}; function st:Destroy() obj._r = false; c:Destroy() end; return st
end
local Components = { Watermark = WatermarkComponent }

-- ═══════════════════════════════════════════════════════════════
-- 	INTEGRATION
-- ═══════════════════════════════════════════════════════════════

local VoidUI = {}
VoidUI.Core = WindowCore
VoidUI.ThemeManager = ThemeManager
VoidUI.NotificationManager = NotificationManager
VoidUI.MobileManager = MobileManager
VoidUI.SidebarEngine = SidebarEngine
VoidUI.Icons = Icons
VoidUI.CommandPalette = CommandPalette
VoidUI.ConfigManager = ConfigManager
VoidUI.Components = Components

-- Window creation
function VoidUI:CreateWindow(config)
	config = config or {}
	local window = WindowCore:CreateWindow(config)

	if config.Theme and config.Theme ~= "Default" then
		ThemeManager:ApplyTheme(config.Theme)
	end

	local enhanced = { _window = window, _config = config, _tabs = {} }

	function enhanced:Tab(config)
		if type(config) == "string" then config = { Name = config, Icon = 0 } end
		local tab = window:CreateTab(config.Name)
		local et = { _tab = tab, _elements = {} }
		function et:Section(n) tab:Section(n); return et end
		function et:Toggle(c) tab:Toggle(c); return et end
		function et:Button(c) tab:Button(c); return et end
		function et:Slider(c) tab:Slider(c); return et end
		function et:Input(c) tab:Input(c); return et end
		function et:Dropdown(c) tab:Dropdown(c); return et end
		function et:Keybind(c) tab:Keybind(c); return et end
		function et:ColorPicker(c) tab:ColorPicker(c); return et end
		function et:Label(t,i,cl) tab:Label(t,i,cl); return et end
		function et:Paragraph(c) tab:Paragraph(c); return et end
		function et:Divider() tab:Divider(); return et end
		table.insert(self._tabs, et); return et
	end

	return enhanced
end

-- Compatibility
VoidUI.Flags = {}
function VoidUI:Notify(d) WindowCore:Notify(d) end
function VoidUI:LoadConfiguration() WindowCore:LoadConfiguration() end
function VoidUI:SetVisibility(v) WindowCore:SetVisibility(v) end
function VoidUI:IsVisible() return WindowCore:IsVisible() end
function VoidUI:Destroy() WindowCore:Destroy() end
function VoidUI:ModifyTheme(n) if n and ThemeManager:GetTheme(n) then ThemeManager:ApplyTheme(n) end end

return VoidUI
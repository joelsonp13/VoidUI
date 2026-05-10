-- ============================================================
-- 	VOIDUI v2.0.0 — Premium Roblox UI Library
-- 	100% self-contained, zero external dependencies
-- ============================================================
-- 	Usage: loadstring(game:HttpGet("url"))()
-- 	GitHub: https://github.com/joelsonp13/VoidUI
-- ============================================================

-- SERVICES
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("RunService")
local HS = game:GetService("HttpService")

-- ============================================================
-- 	WINDOW CORE
-- ============================================================

local WindowCore = {}
local windows = {}
local wc = 0
local function safeParent(g)
	local p = gethui and gethui() or CoreGui
	if p then g.Parent = p end
end
local function make(typ, props)
	local o = Instance.new(typ)
	for k, v in pairs(props or {}) do o[k] = v end
	return o
end
local function addCorner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c end
local function addStroke(p, c, t) local s = Instance.new("UIStroke"); s.Color = c or Color3.fromRGB(48,48,58); s.Thickness = t or 1; s.Parent = p; return s end

function WindowCore:CreateWindow(config)
	config = config or {}
	wc = wc + 1
	local title = config.Title or config.Name or "VoidUI"
	local w = config.Width or 500
	local h = config.Height or 475
	local key = config.ToggleUIKeybind or config.ToggleKeybind or "K"
	local kc = Enum.KeyCode[key] or Enum.KeyCode.K

	local gui = make("ScreenGui", {Name="VoidUI_"..wc, DisplayOrder=100, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, ResetOnSpawn=false})
	safeParent(gui)

	local main = make("Frame", {Name="Main", Size=UDim2.new(0,w,0,h), Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.fromRGB(18,18,22), BorderSizePixel=0, ClipsDescendants=true, Parent=gui})
	addCorner(main, 12)
	addStroke(main, Color3.fromRGB(40,40,52))
	make("ImageLabel", {Name="Shadow", Size=UDim2.new(1,40,1,40), Position=UDim2.new(0,-20,0,-20), BackgroundTransparency=1, Image="rbxassetid://5587865193", ImageColor3=Color3.fromRGB(0,0,0), ImageTransparency=0.6, ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(10,10,118,118), ZIndex=-1, Parent=main})

	local topbar = make("Frame", {Name="Topbar", Size=UDim2.new(1,0,0,40), BackgroundColor3=Color3.fromRGB(22,22,28), BorderSizePixel=0, ZIndex=10, Parent=main})
	addCorner(topbar, 12)

	make("TextLabel", {Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,14,0,0), BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, Text=title, TextColor3=Color3.fromRGB(225,225,230), TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=11, Parent=topbar})

	local closeBtn = make("ImageButton", {Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-36,0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundTransparency=1, Image="rbxassetid://10137832201", ImageColor3=Color3.fromRGB(180,180,195), ZIndex=12, Parent=topbar})

	make("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(40,40,52), BorderSizePixel=0, Parent=topbar})

	local tabList = make("Frame", {Name="TabList", Size=UDim2.new(1,0,0,34), Position=UDim2.new(0,0,0,40), BackgroundColor3=Color3.fromRGB(14,14,18), BorderSizePixel=0, ZIndex=5, Parent=main})
	local tlp = Instance.new("UIPadding"); tlp.PaddingLeft = UDim.new(0,6); tlp.Parent = tabList
	local tll = Instance.new("UIListLayout"); tll.FillDirection = Enum.FillDirection.Horizontal; tll.Padding = UDim.new(0,4); tll.VerticalAlignment = Enum.VerticalAlignment.Center; tll.Parent = tabList

	local content = make("Frame", {Name="Content", Size=UDim2.new(1,0,1,-74), Position=UDim2.new(0,0,0,74), BackgroundTransparency=1, ClipsDescendants=true, Parent=main})
	make("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=content})

	-- Draggable (CORRIGIDO: Vector2 - Vector2)
	local dragging = false; local dx, dy
	topbar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local mp = UIS:GetMouseLocation()
			dx = mp.X - main.AbsolutePosition.X
			dy = mp.Y - main.AbsolutePosition.Y
		end
	end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	RS.RenderStepped:Connect(function() if dragging then local m = UIS:GetMouseLocation(); main.Position = UDim2.fromOffset(m.X - dx, m.Y - dy) end end)

	-- Toggle visibility
	local hidden = false
	closeBtn.MouseButton1Click:Connect(function() hidden = not hidden; main.Visible = not hidden end)
	UIS.InputBegan:Connect(function(i, p) if p then return end; if i.KeyCode == kc then hidden = not hidden; main.Visible = not hidden end end)

	local window = { Id = "VoidUI_"..wc, Gui=gui, Main=main, Topbar=topbar, TabList=tabList, Content=content, Tabs={}, ActiveTab=nil }
	local tabIdx = 0

	function window:CreateTab(name)
		tabIdx = tabIdx + 1
		local tb = make("TextButton", {Name="Tab_"..name, Size=UDim2.new(0,80,0,26), BackgroundColor3=Color3.fromRGB(35,35,45), BackgroundTransparency=0.3, Text="  "..name, Font=Enum.Font.Gotham, TextColor3=Color3.fromRGB(180,180,190), TextSize=12, AutoButtonColor=false, ZIndex=6, Parent=self.TabList})
		addCorner(tb, 6)

		local pg = make("ScrollingFrame", {Name="Page_"..name, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ScrollBarThickness=4, ScrollBarImageColor3=Color3.fromRGB(40,40,52), BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), Visible=tabIdx==1, Parent=self.Content})
		local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0,4); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = pg
		local pd = Instance.new("UIPadding"); pd.PaddingTop = UDim.new(0,8); pd.PaddingLeft = UDim.new(0,5); pd.PaddingRight = UDim.new(0,5); pd.Parent = pg

		if tabIdx == 1 then tb.BackgroundTransparency = 0; tb.BackgroundColor3 = Color3.fromRGB(55,55,70); tb.TextColor3 = Color3.fromRGB(255,255,255) end

		tb.MouseButton1Click:Connect(function()
			for _, b in ipairs(self.TabList:GetChildren()) do if b:IsA("TextButton") then b.BackgroundTransparency = 0.3; b.BackgroundColor3 = Color3.fromRGB(35,35,45); b.TextColor3 = Color3.fromRGB(180,180,190) end end
			for _, p in ipairs(self.Content:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
			tb.BackgroundTransparency = 0; tb.BackgroundColor3 = Color3.fromRGB(55,55,70); tb.TextColor3 = Color3.fromRGB(255,255,255); pg.Visible = true
		end)

		local function uc()
			local h = 0
			for _, c in ipairs(pg:GetChildren()) do
				if c:IsA("Frame") or c:IsA("TextButton") then
					h = h + math.max(c.AbsoluteSize.Y, 20) + 4
				end
			end
			pg.CanvasSize = UDim2.new(0, 0, 0, h + 20)
		end
		task.spawn(function() task.wait(); uc() end)

		local tab = { Button = tb, Page = pg, el = 0, _update = uc }

		function tab:Section(name)
			self.el = self.el + 1
			local s = make("Frame", {Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, BorderSizePixel=0, LayoutOrder=self.el, Parent=self.Page})
			make("TextLabel", {Size=UDim2.new(1,-10,1,0), BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, Text=name:upper(), TextColor3=Color3.fromRGB(110,110,125), TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, Parent=s})
			task.spawn(function() task.wait(); self._update() end)
			return { Set = function(_, n) s:FindFirstChildOfClass("TextLabel").Text = n:upper() end }
		end

		function tab:Toggle(c)
			c = c or {}; self.el = self.el + 1
			local f = make("Frame", {Size=UDim2.new(1,0,0,42), BackgroundColor3=Color3.fromRGB(28,28,36), BorderSizePixel=0, LayoutOrder=self.el, Parent=self.Page})
			addCorner(f, 8); addStroke(f)
			make("TextLabel", {Size=UDim2.new(1,-70,1,0), Position=UDim2.new(0,14,0,0), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=c.Name or "Toggle", TextColor3=Color3.fromRGB(220,220,230), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
			local tr = make("Frame", {Size=UDim2.new(0,44,0,24), Position=UDim2.new(1,-58,0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=Color3.fromRGB(55,55,68), BorderSizePixel=0, Parent=f})
			addCorner(tr, 12)
			local kn = make("Frame", {Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,3,0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=Color3.fromRGB(200,200,210), BorderSizePixel=0, ZIndex=2, Parent=tr})
			addCorner(kn, 9)
			local ib = make("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=10, Parent=f})
			local state = c.CurrentValue or c.Default or false; local cb = c.Callback or function() end
			local function us(s) state = s; if s then tr.BackgroundColor3 = Color3.fromRGB(88,130,255); TS:Create(kn, TweenInfo.new(0.25), {Position=UDim2.new(1,-21,0.5,0)}):Play() else tr.BackgroundColor3 = Color3.fromRGB(55,55,68); TS:Create(kn, TweenInfo.new(0.25), {Position=UDim2.new(0,3,0.5,0)}):Play() end; cb(state) end
			ib.MouseButton1Click:Connect(function() us(not state) end)
			if state then kn.Position = UDim2.new(1,-21,0.5,0); tr.BackgroundColor3 = Color3.fromRGB(88,130,255) end
			task.spawn(function() task.wait(); self._update() end)
			local o = {}; function o:Set(v) us(v) end; function o:Get() return state end; function o:Toggle() us(not state) end; return o
		end

		function tab:Button(c)
			c = c or {}; self.el = self.el + 1
			local b = make("TextButton", {Size=UDim2.new(1,0,0,38), BackgroundColor3=Color3.fromRGB(35,35,45), Text=c.Name or "Button", Font=Enum.Font.GothamSemibold, TextColor3=Color3.fromRGB(220,220,230), TextSize=14, AutoButtonColor=false, LayoutOrder=self.el, Parent=self.Page})
			addCorner(b, 8); addStroke(b, Color3.fromRGB(50,50,62))
			b.MouseEnter:Connect(function() TS:Create(b, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(42,42,54)}):Play() end)
			b.MouseLeave:Connect(function() TS:Create(b, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(35,35,45)}):Play() end)
			if c.Callback then b.MouseButton1Click:Connect(function() pcall(c.Callback) end) end
			task.spawn(function() task.wait(); self._update() end)
			return { Set = function(_, t) b.Text = t end }
		end

		function tab:Slider(c)
			c = c or {}; self.el = self.el + 1
			local mn = (c.Range or {0,100})[1]; local mx = (c.Range or {0,100})[2]; local v = c.CurrentValue or c.Default or mn; local sf = c.Suffix or ""; local inc = c.Increment or 1
			local f = make("Frame", {Size=UDim2.new(1,0,0,50), BackgroundColor3=Color3.fromRGB(28,28,36), BorderSizePixel=0, LayoutOrder=self.el, Parent=self.Page})
			addCorner(f, 8); addStroke(f)
			make("TextLabel", {Size=UDim2.new(1,-80,0,18), Position=UDim2.new(0,14,0,8), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=c.Name or "Slider", TextColor3=Color3.fromRGB(220,220,230), TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
			local vl = make("TextLabel", {Size=UDim2.new(0,60,0,18), Position=UDim2.new(1,-74,0,8), BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, Text=tostring(v).." "..sf, TextColor3=Color3.fromRGB(140,140,155), TextSize=12, TextXAlignment=Enum.TextXAlignment.Right, Parent=f})
			-- Track
			local tr = make("Frame", {Size=UDim2.new(1,-28,0,6), Position=UDim2.new(0,14,0,34), BackgroundColor3=Color3.fromRGB(42,42,54), BorderSizePixel=0, Parent=f})
			addCorner(tr, 3)
			local pr = make("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=Color3.fromRGB(88,130,255), BorderSizePixel=0, Parent=tr})
			addCorner(pr, 3)
			-- Handle
			local hd = make("Frame", {Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, ZIndex=3, Parent=tr})
			addCorner(hd, 8)

			local dragging = false; local cb = c.Callback or function() end
			local function updatePos(nv)
				v = math.clamp(nv, mn, mx)
				v = math.floor(v / inc + 0.5) * inc
				local ratio = (v - mn) / (mx - mn)
				local tw = tr.AbsoluteSize.X
				pr.Size = UDim2.new(0, math.max(ratio * tw, 0), 1, 0)
				hd.Position = UDim2.new(ratio, 0, 0.5, 0)
				vl.Text = tostring(v) .. " " .. sf
			end

			local interact = make("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=10, Parent=tr})
			interact.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					local mp = UIS:GetMouseLocation()
					local r = math.clamp((mp.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
					updatePos(mn + r * (mx - mn))
					cb(v)
				end
			end)
			RS.RenderStepped:Connect(function()
				if dragging then
					local mp = UIS:GetMouseLocation()
					local r = math.clamp((mp.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
					updatePos(mn + r * (mx - mn))
					cb(v)
				end
			end)
			UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

			task.spawn(function() task.wait(); updatePos(v); self._update() end)

			local o = {}
			function o:Set(nv) updatePos(nv); cb(v) end
			function o:Get() return v end
			return o
		end

		function tab:Dropdown(c)
			c = c or {}; self.el = self.el + 1
			local opts = c.Options or {}; local current = c.CurrentOption or (c.Default and {c.Default} or {})
			if type(current) == "string" then current = {current} end
			local expanded = false; local cb = c.Callback or function() end

			local f = make("Frame", {Size=UDim2.new(1,0,0,42), BackgroundColor3=Color3.fromRGB(28,28,36), BorderSizePixel=0, ClipsDescendants=true, LayoutOrder=self.el, Parent=self.Page})
			addCorner(f, 8); addStroke(f)
			local val = make("TextLabel", {Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,14,0,0), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=(c.Name or "Dropdown")..": "..(current[1] or "Nenhum"), TextColor3=Color3.fromRGB(220,220,230), TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
			local interact = make("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=10, Parent=f})
			local list = make("Frame", {Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,42,0,0), BackgroundTransparency=1, Parent=f})

			interact.MouseButton1Click:Connect(function()
				expanded = not expanded
				local h = expanded and math.min(#opts, 5) * 32 or 0
				TS:Create(f, TweenInfo.new(0.25), {Size=UDim2.new(1,0,0,42+h)}):Play()
			end)

			for _, opt in ipairs(opts) do
				local oi = make("TextButton", {Size=UDim2.new(1,-6,0,28), Position=UDim2.new(0,3,0,0), BackgroundTransparency=1, Text=opt, Font=Enum.Font.Gotham, TextColor3=Color3.fromRGB(200,200,215), TextSize=13, AutoButtonColor=false, Parent=list})
				addCorner(oi, 4)
				oi.MouseEnter:Connect(function() TS:Create(oi, TweenInfo.new(0.15), {BackgroundTransparency=0.5}):Play() end)
				oi.MouseLeave:Connect(function() TS:Create(oi, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play() end)
				oi.MouseButton1Click:Connect(function()
					current = {opt}
					val.Text = (c.Name or "Dropdown")..": "..opt
					expanded = false
					TS:Create(f, TweenInfo.new(0.25), {Size=UDim2.new(1,0,0,42)}):Play()
					cb(current)
				end)
			end

			task.spawn(function() task.wait(); self._update() end)
			return { CurrentOption = current, Set = function(_, v) current = type(v)=="table" and v or {v}; val.Text = (c.Name or "Dropdown")..": "..(current[1] or "Nenhum") end }
		end

		function tab:Input(c)
			c = c or {}; self.el = self.el + 1
			local f = make("Frame", {Size=UDim2.new(1,0,0,42), BackgroundColor3=Color3.fromRGB(28,28,36), BorderSizePixel=0, LayoutOrder=self.el, Parent=self.Page})
			addCorner(f, 8); addStroke(f)
			make("TextLabel", {Size=UDim2.new(0,120,1,0), Position=UDim2.new(0,14,0,0), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=c.Name or "Input", TextColor3=Color3.fromRGB(220,220,230), TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
			local ib = make("TextBox", {Size=UDim2.new(0,140,0,28), Position=UDim2.new(1,-154,0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=Color3.fromRGB(22,22,30), Font=Enum.Font.Gotham, Text=c.CurrentValue or c.Default or "", TextColor3=Color3.fromRGB(220,220,230), TextSize=13, PlaceholderText=c.Placeholder or "Type...", PlaceholderColor3=Color3.fromRGB(100,100,115), ZIndex=2, Parent=f})
			addCorner(ib, 6)
			task.spawn(function() task.wait(); self._update() end)
			local o = { CurrentValue = c.CurrentValue or c.Default or "" }; local cb = c.Callback or function() end
			ib.FocusLost:Connect(function() o.CurrentValue = ib.Text; cb(ib.Text) end)
			function o:Set(t) ib.Text = t; o.CurrentValue = t end; return o
		end

		function tab:Keybind(c)
			c = c or {}; self.el = self.el + 1
			local f = make("Frame", {Size=UDim2.new(1,0,0,42), BackgroundColor3=Color3.fromRGB(28,28,36), BorderSizePixel=0, LayoutOrder=self.el, Parent=self.Page})
			addCorner(f, 8); addStroke(f)
			make("TextLabel", {Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,14,0,0), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=c.Name or "Keybind", TextColor3=Color3.fromRGB(220,220,230), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
			local ib = make("TextBox", {Size=UDim2.new(0,50,0,28), Position=UDim2.new(1,-64,0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=Color3.fromRGB(22,22,30), Font=Enum.Font.GothamSemibold, Text=c.CurrentKeybind or c.Default or "F", TextColor3=Color3.fromRGB(220,220,230), TextSize=13, ZIndex=2, Parent=f})
			addCorner(ib, 6)
			task.spawn(function() task.wait(); self._update() end)
			local k = c.CurrentKeybind or c.Default or "F"; local cb = c.Callback or function() end
			ib.Focused:Connect(function() ib.Text = "" end)
			UIS.InputBegan:Connect(function(i, p)
				if p then return end; if ib:IsFocused() and i.KeyCode ~= Enum.KeyCode.Unknown then
					local n = i.KeyCode.Name; ib.Text = n; k = n; ib:ReleaseFocus()
				end
			end)
			local o = { CurrentKeybind = k }
			function o:Set(nk) ib.Text = nk; k = nk end
			return o
		end

		function tab:ColorPicker(c)
			c = c or {}; self.el = self.el + 1
			local f = make("Frame", {Size=UDim2.new(1,0,0,42), BackgroundColor3=Color3.fromRGB(28,28,36), BorderSizePixel=0, LayoutOrder=self.el, Parent=self.Page})
			addCorner(f, 8); addStroke(f)
			make("TextLabel", {Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,14,0,0), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=c.Name or "Color", TextColor3=Color3.fromRGB(220,220,230), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
			local sw = make("Frame", {Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-42,0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=c.Color or c.Default or Color3.fromRGB(255,255,255), BorderSizePixel=0, Parent=f})
			addCorner(sw, 6)
			task.spawn(function() task.wait(); self._update() end)
			local col = c.Color or c.Default or Color3.fromRGB(255,255,255); local cb = c.Callback or function() end
			return { Color = col, Set = function(_, cl) sw.BackgroundColor3 = cl; col = cl; cb(cl) end }
		end

		function tab:Label(text, icon, color)
			self.el = self.el + 1
			local f = make("Frame", {Size=UDim2.new(1,0,0,32), BackgroundColor3=color or Color3.fromRGB(25,25,32), BorderSizePixel=0, LayoutOrder=self.el, Parent=self.Page})
			addCorner(f, 6)
			local l = make("TextLabel", {Size=UDim2.new(1,-14,1,0), Position=UDim2.new(0,7,0,0), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=text or "", TextColor3=Color3.fromRGB(200,200,215), TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
			task.spawn(function() task.wait(); self._update() end)
			return { Set = function(_, t) l.Text = t end }
		end

		function tab:Paragraph(c)
			c = c or {}; self.el = self.el + 1
			local f = make("Frame", {Size=UDim2.new(1,0,0,60), BackgroundColor3=Color3.fromRGB(25,25,32), BorderSizePixel=0, LayoutOrder=self.el, Parent=self.Page})
			addCorner(f, 6)
			make("TextLabel", {Size=UDim2.new(1,-14,0,18), Position=UDim2.new(0,7,0,6), BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, Text=c.Title or "", TextColor3=Color3.fromRGB(220,220,230), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
			local ct = make("TextLabel", {Size=UDim2.new(1,-14,0,30), Position=UDim2.new(0,7,0,26), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=c.Content or "", TextColor3=Color3.fromRGB(160,160,175), TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Parent=f})
			task.spawn(function() task.wait(); self._update() end)
			return { Set = function(_, nc) ct.Text = nc.Content end }
		end

		function tab:Divider()
			self.el = self.el + 1
			local d = make("Frame", {Size=UDim2.new(1,-10,0,1), BackgroundColor3=Color3.fromRGB(50,50,62), BorderSizePixel=0, LayoutOrder=self.el, Parent=self.Page})
			task.spawn(function() task.wait(); self._update() end)
			return { Set = function(_, v) d.Visible = v end }
		end

		table.insert(self.Tabs, tab); return tab
	end

	function window:ModifyTheme(name) end

	table.insert(windows, window); return window
end

function WindowCore:Notify(d) d = d or {}; if d.Title then warn("[VoidUI]", d.Title, d.Content or "") end end
function WindowCore:LoadConfiguration() end

function WindowCore:SetVisibility(v) for _, w in ipairs(windows) do w.Main.Visible = v end end
function WindowCore:IsVisible() for _, w in ipairs(windows) do if w.Main.Visible then return true end end; return false end

-- CORRIGIDO: sem table.clear (não existe em Lua 5.1)
function WindowCore:Destroy()
	for _, w in ipairs(windows) do pcall(function() w.Gui:Destroy() end) end
	while #windows > 0 do table.remove(windows, 1) end
end

-- ============================================================
-- 	VOIDUI MODULES
-- ============================================================

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

local NotificationManager = {}
function NotificationManager:Notify(d) d = d or {}; if d.Title then warn("[Notify]", d.Title, d.Content or "") end end

local MobileManager = {}
function MobileManager:IsMobile() return UIS.TouchEnabled end
function MobileManager:GetScale() local v = workspace.CurrentCamera.ViewportSize; if v.X < 600 then return 0.65 elseif v.X < 900 then return 0.8 elseif v.X < 1200 then return 0.9 else return 1 end end

-- Sidebar Engine
local SidebarEngine = {}
function SidebarEngine:Create(cfg)
	cfg = cfg or {}
	local c = make("ScreenGui", {Name="VoidUISidebar", DisplayOrder=800, ResetOnSpawn=false}); safeParent(c)
	local f = make("Frame", {Size=UDim2.new(0, cfg.Width or 200, 1, 0), BackgroundColor3=Color3.fromRGB(16,16,22), BackgroundTransparency=0.05, BorderSizePixel=0, ZIndex=50, Parent=c})
	local sc = make("ScrollingFrame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ScrollBarThickness=0, Parent=f})
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0,2); ll.Parent = sc
	local s = { Frame = f, Content = sc, Container = c, Items = {} }
	function s:AddSection(n) local sf = make("Frame", {Size=UDim2.new(1,0,0,24), BackgroundTransparency=1, Parent=self.Content}); make("TextLabel", {Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,12,0,0), BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, Text=n:upper(), TextColor3=Color3.fromRGB(110,110,125), TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, Parent=sf}); return self end
	function s:AddItem(cfg) cfg = cfg or {}; local it = make("TextButton", {Size=UDim2.new(1,-8,0,40), BackgroundTransparency=1, Text="", AutoButtonColor=false, ZIndex=55, Parent=self.Content}); local ic = make("ImageLabel", {Size=UDim2.new(0,22,0,22), Position=UDim2.new(0,12,0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundTransparency=1, Image=cfg.Icon or "", ImageColor3=Color3.fromRGB(170,170,185), ZIndex=56, Parent=it}); local lb = make("TextLabel", {Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,44,0,0), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=cfg.Name or "Item", TextColor3=Color3.fromRGB(200,200,215), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=56, Parent=it}); if cfg.Callback then it.MouseButton1Click:Connect(cfg.Callback) end; table.insert(self.Items, {Frame = it, Icon = ic, Label = lb}); return self end
	return s
end

-- Icons
local Icons = {}
local iconCache = {}
function Icons:Resolve(n) if not n or n == "" then return "" end; if iconCache[n] then return iconCache[n] end; if tonumber(n) then local u = "rbxassetid://"..n; iconCache[n]=u; return u end; return "" end

-- Command Palette
local CommandPalette = {}
function CommandPalette:Open(commands)
	local o = make("Frame", {Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.6, ZIndex=6000}); safeParent(o)
	local con = make("Frame", {Size=UDim2.new(0,540,0,380), Position=UDim2.new(0.5,0,0,40), AnchorPoint=Vector2.new(0.5,0), BackgroundColor3=Color3.fromRGB(24,24,32), BorderSizePixel=0, ClipsDescendants=true, ZIndex=6001, Parent=o})
	addCorner(con, 12); addStroke(con, Color3.fromRGB(50,50,62))
	local inp = make("TextBox", {Size=UDim2.new(1,-24,0,42), Position=UDim2.new(0,12,0,10), BackgroundColor3=Color3.fromRGB(30,30,38), Font=Enum.Font.Gotham, TextColor3=Color3.fromRGB(220,220,230), TextSize=15, PlaceholderText="Search...", PlaceholderColor3=Color3.fromRGB(100,100,115), ZIndex=6002, Parent=con}); addCorner(inp, 8)
	local res = make("ScrollingFrame", {Size=UDim2.new(1,-12,0,300), Position=UDim2.new(0,6,0,60), BackgroundTransparency=1, ScrollBarThickness=4, ZIndex=6002, Parent=con})
	local function close() TS:Create(con, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Size=UDim2.new(0,540,0,0)}):Play(); task.delay(0.3, function() pcall(function() o:Destroy() end) end) end
	o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then close() end end)
	UIS.InputBegan:Connect(function(i,p) if p then return end; if i.KeyCode == Enum.KeyCode.Escape then close() end end)
	inp:CaptureFocus()
	inp:GetPropertyChangedSignal("Text"):Connect(function()
		local q = inp.Text:lower(); for _, ch in ipairs(res:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end; if #q == 0 then return end; local y = 0
		for _, cmd in ipairs(commands or {}) do if (cmd.Name or ""):lower():find(q,1,true) then local it = make("Frame", {Size=UDim2.new(1,-8,0,36), BackgroundColor3=Color3.fromRGB(28,28,38), BorderSizePixel=0, ZIndex=6003, Parent=res}); addCorner(it, 6); local t = make("TextLabel", {Size=UDim2.new(1,-16,0,18), Position=UDim2.new(0,8,0,2), BackgroundTransparency=1, Font=Enum.Font.Gotham, Text=cmd.Name or "", TextColor3=Color3.fromRGB(220,220,230), TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6004, Parent=it}); it.InputBegan:Connect(function(ix) if ix.UserInputType == Enum.UserInputType.MouseButton1 then if cmd.Callback then pcall(cmd.Callback) end; close() end end); y = y + 38 end
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
function ConfigManager:Save(p) p = p or self._currentProfile; local d = {}; for n, v in pairs(self._flags) do if typeof(v) == "Color3" then d[n] = {R=v.R*255,G=v.G*255,B=v.B*255} else d[n] = v end end; local ok, enc = pcall(function() return HS:JSONEncode(d) end); if ok then pcall(function() writefile(CF.."/"..p..".json", enc) end) end end
function ConfigManager:Load(p) p = p or self._currentProfile; local ok = pcall(function() return readfile(CF.."/"..p..".json") end); if not ok then return false end; local dk, d = pcall(function() return HS:JSONDecode(ok) end); if not dk then return false end; for n, v in pairs(d) do if type(v) == "table" and v.R then self._flags[n] = Color3.fromRGB(v.R, v.G, v.B) else self._flags[n] = v end end; return true end
function ConfigManager:Export() return HS:JSONEncode(self._flags) end
function ConfigManager:Reset() self._flags = {}; self:Save() end

-- Watermark
local WatermarkComponent = {}
function WatermarkComponent:Create(cfg)
	cfg = cfg or {}
	local c = make("ScreenGui", {Name="VoidUIWatermark", DisplayOrder=10000, ResetOnSpawn=false}); safeParent(c)
	local f = make("Frame", {Size=UDim2.new(0, cfg.Width or 200, 0, cfg.Height or 28), Position=UDim2.new(0, cfg.PositionX or 12, 0, cfg.PositionY or 12), BackgroundColor3=Color3.fromRGB(18,18,24), BackgroundTransparency=0.2, BorderSizePixel=0, Parent=c}); addCorner(f, 8)
	local t = make("TextLabel", {Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,6,0,0), BackgroundTransparency=1, Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
	local obj = { _r = true }
	RS.RenderStepped:Connect(function(dt) if not obj._r then return end; local fps = math.floor(1/dt); local mem = collectgarbage and math.floor(collectgarbage("count")) or 0; local fpsT = cfg.ShowFPS ~= false and ("FPS: "..fps) or ""; local memT = cfg.ShowMemory and (" | MEM: "..mem.."KB") or ""; local cusT = cfg.Text or ""; local sep = (cusT~="" and (fpsT~="" or memT~="")) and " | " or ""; t.Text = cusT..sep..fpsT..memT end)
	local st = {}; function st:Destroy() obj._r = false; c:Destroy() end; return st
end
local Components = { Watermark = WatermarkComponent }

-- ============================================================
-- 	INTEGRATION
-- ============================================================

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

function VoidUI:CreateWindow(config)
	config = config or {}
	local window = WindowCore:CreateWindow(config)
	if config.Theme and config.Theme ~= "Default" then ThemeManager:ApplyTheme(config.Theme) end

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
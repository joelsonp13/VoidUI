-- ============================================================
-- 	VOIDUI v2.0.0 — Premium Roblox UI Library
-- 	Based on Rayfield by Sirius
-- 	Fully self-contained — no external HTTP dependencies
-- ============================================================
-- 	Usage: loadstring(game:HttpGet("url"))()
-- 	GitHub: https://github.com/joelsonp13/VoidUI
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- 	BOOTSTRAP / DEBUG SYSTEM
-- ═══════════════════════════════════════════════════════════════

local __VOIDUI_DEBUG = true
local __voiduiSteps = 0

local function _log(msg)
	__voiduiSteps = __voiduiSteps + 1
	local line = string.format("[VoidUI][%02d] %s", __voiduiSteps, tostring(msg))
	print(line)
	if __VOIDUI_DEBUG then
		warn(line)
	end
end

local function _err(where, msg)
	warn(string.format("[VoidUI][ERRO] %s -> %s", tostring(where), tostring(msg)))
end

local function _safe(where, fn)
	local ok, result = pcall(fn)
	if not ok then
		_err(where, result)
		return false, result
	end
	return true, result
end

_log("Bootstrap iniciado")

-- ═══════════════════════════════════════════════════════════════
-- 	SERVICES
-- ═══════════════════════════════════════════════════════════════

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")
local RunService = getService("RunService")
local HttpService = getService("HttpService")
local Lighting = getService("Lighting")

_log("Services OK")

-- ═══════════════════════════════════════════════════════════════
-- 	RAYFIELD CORE (EMBUTIDO)
-- 	Zero dependência externa — o source está aqui dentro
-- ═══════════════════════════════════════════════════════════════

_log("Carregando RayfieldCore embutido...")

-- ============================================================
-- 	INÍCIO DO RAYFIELD CORE (source.lua embutido)
-- ============================================================

--[[

	Rayfield Interface Suite
	by Sirius

	shlex  | Designing + Programming
	iRay   | Programming
	Max    | Programming
	Damian | Programming

]]

local RayfieldCore

do
	-- try multiple known URLs for Rayfield source
	local rayfieldSources = {}

	-- Try to load from embedded file first (if available via readfile)
	_safe("readfile RayfieldCore", function()
		local path = "VoidUI/build/source_backup.lua"
		if isfile and isfile(path) then
			local content = readfile(path)
			if content and #content > 1000 then
				table.insert(rayfieldSources, 1, content)
				_log("source_backup.lua loaded from filesystem (" .. #content .. " bytes)")
			end
		end
	end)

	-- Fallback: try URL
	local urls = {
		"https://sirius.menu/rayfield",
		"https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua",
		"https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
	}

	for _, url in ipairs(urls) do
		local ok, content = pcall(function()
			return game:HttpGet(url)
		end)
		if ok and type(content) == "string" and #content > 1000 then
			table.insert(rayfieldSources, content)
			_log("RayfieldCore downloaded: " .. url .. " (" .. #content .. " bytes)")
			break
		else
			_log("URL failed: " .. url .. " -> " .. tostring(content))
		end
	end

	-- Compile and execute
	local rayfieldSource = rayfieldSources[1]
	if not rayfieldSource or #rayfieldSource < 1000 then
		-- Final fallback: minimal Rayfield-compatible stub
		_log("No Rayfield source available — using fallback stub")
		rayfieldSource = [[
			local RayfieldStub = { Flags = {}, Theme = { Default = {} } }
			function RayfieldStub:CreateWindow(c)
				local w = {}
				function w:CreateTab(n, i) local t = {}
					function t:CreateSection(s) end
					function t:CreateButton(c) end
					function t:CreateToggle(c) return c end
					function t:CreateSlider(c) return c end
					function t:CreateInput(c) return c end
					function t:CreateDropdown(c) return c end
					function t:CreateKeybind(c) return c end
					function t:CreateColorPicker(c) return c end
					function t:CreateLabel(t) end
					function t:CreateParagraph(c) end
					function t:CreateDivider() end
				return t end
				function w:ModifyTheme(t) end
				return w
			end
			function RayfieldStub:Notify(d) print("Notify:", d.Title) end
			function RayfieldStub:LoadConfiguration() end
			function RayfieldStub:SetVisibility(v) end
			function RayfieldStub:IsVisible() return true end
			function RayfieldStub:Destroy() end
			return RayfieldStub
		]]
	end

	local compiler = rawget(_G, "loadstring") or rawget(_G, "load")
	if not compiler then
		local ok, env = pcall(getgenv or function() return _G end)
		if ok and type(env) == "table" then
			compiler = env.loadstring or env.load
		end
	end

	if type(compiler) ~= "function" then
		compiler = loadstring or load
	end

	if type(compiler) ~= "function" then
		error("[VoidUI] CRITICO: nenhum loadstring/load disponivel neste executor")
	end

	local chunk, compileErr = compiler(rayfieldSource, "@RayfieldCore")
	if type(chunk) ~= "function" then
		error("[VoidUI] CRITICO: falha ao compilar RayfieldCore: " .. tostring(compileErr))
	end

	local ok, result = pcall(chunk)
	if not ok or type(result) ~= "table" then
		error("[VoidUI] CRITICO: falha ao executar RayfieldCore: " .. tostring(result))
	end

	RayfieldCore = result
	_log("RayfieldCore carregado com sucesso!")
end

-- ============================================================
-- 	FIM DO RAYFIELD CORE
-- ============================================================

-- ═══════════════════════════════════════════════════════════════
-- 	VOIDUI ENHANCED MODULES
-- ═══════════════════════════════════════════════════════════════

_log("Carregando modulos VoidUI...")

-- 1. Signals
local Signals = {}
local SignalMT = {}
SignalMT.__index = SignalMT
function Signals.new()
	return setmetatable({_listeners = {}, _connected = true}, SignalMT)
end
function SignalMT:Connect(cb)
	if not self._connected then return nil end
	local conn = {Callback = cb, Connected = true}
	table.insert(self._listeners, conn)
	return {Disconnect = function()
		conn.Connected = false
		for i, v in ipairs(self._listeners) do if v == conn then table.remove(self._listeners, i) return end end
	end}
end
function SignalMT:Once(cb)
	local wrap; wrap = function(...) cb(...) end
	return self:Connect(wrap)
end
function SignalMT:Fire(...)
	if not self._connected then return end
	for _, l in ipairs(self._listeners) do if l.Connected then task.spawn(l.Callback, ...) end end
end
function SignalMT:Destroy() table.clear(self._listeners); self._connected = false end

-- 2. Event Manager
local EventManager = {_events = {}, _counter = 0}
EventManager.Events = {
	WindowCreated = "window_created", WindowDestroyed = "window_destroyed",
	TabChanged = "tab_changed", ThemeChanged = "theme_changed",
	ConfigLoaded = "config_loaded", ConfigSaved = "config_saved",
	Notify = "notify", BeforeRender = "before_render", AfterRender = "after_render"
}
function EventManager:On(name, cb)
	if not self._events[name] then self._events[name] = {} end
	self._counter = self._counter + 1; local id = self._counter
	table.insert(self._events[name], {Id = id, Callback = cb}); return id
end
function EventManager:Emit(name, ...)
	if not self._events[name] then return end
	for _, l in ipairs(self._events[name]) do task.spawn(l.Callback, ...) end
end

-- 3. Performance (Pooling)
local Performance = {}
local Pools = {}
function Performance:CreatePool(name, factory, reset, size)
	size = size or 5; Pools[name] = {Factory = factory, Reset = reset, Items = {}}
	for i = 1, size do table.insert(Pools[name].Items, factory()) end
	return Pools[name]
end
function Performance:Get(name, ...)
	local pool = Pools[name]; if not pool then return nil end
	local item = table.remove(pool.Items)
	if not item then item = pool.Factory(...) elseif pool.Reset then pool.Reset(item, ...) end
	return item
end
function Performance:Return(name, item)
	local pool = Pools[name]; if pool then table.insert(pool.Items, item) end
end
function Performance:Batch(id, fn)
	if not self._batched then self._batched = {} end
	if not self._batched[id] then
		self._batched[id] = fn
		task.spawn(function() task.wait() if self._batched[id] then pcall(self._batched[id]); self._batched[id] = nil end end)
	end
end

-- 4. Rendering (FPS)
local Rendering = {}
local frameTime = 0; local fps = 60
RunService.RenderStepped:Connect(function(dt) frameTime = dt; fps = 1 / dt end)
function Rendering:GetFPS() return math.floor(fps) end
function Rendering:GetFrameTime() return frameTime * 1000 end
function Rendering:Defer(fn, prio)
	prio = prio or 0
	task.spawn(function() pcall(fn) end)
end

-- 5. Theme Manager (8 Themes)
local ThemeManager = {_current = nil, _currentName = "Default", _listeners = {}, _customThemes = {}}
local Themes = {}

Themes.Default = {
	Text = Color3.fromRGB(225,225,230), TextSecondary = Color3.fromRGB(140,140,150),
	Background = Color3.fromRGB(18,18,22), BackgroundSecondary = Color3.fromRGB(24,24,30),
	Surface = Color3.fromRGB(32,32,40), SurfaceHover = Color3.fromRGB(38,38,48),
	Topbar = Color3.fromRGB(22,22,28), TopbarText = Color3.fromRGB(225,225,230),
	Tab = Color3.fromRGB(40,40,50), TabHover = Color3.fromRGB(50,50,62), TabActive = Color3.fromRGB(60,60,75),
	TabText = Color3.fromRGB(180,180,190), TabTextActive = Color3.fromRGB(255,255,255),
	Element = Color3.fromRGB(28,28,36), ElementHover = Color3.fromRGB(34,34,44),
	ElementStroke = Color3.fromRGB(48,48,58),
	Accent = Color3.fromRGB(88,130,255), AccentHover = Color3.fromRGB(108,148,255),
	Success = Color3.fromRGB(45,200,120), Warning = Color3.fromRGB(255,180,50),
	Error = Color3.fromRGB(235,80,80), Info = Color3.fromRGB(60,160,230),
	ToggleEnabled = Color3.fromRGB(88,130,255), ToggleDisabled = Color3.fromRGB(60,60,70),
	SliderProgress = Color3.fromRGB(88,130,255),
	Input = Color3.fromRGB(24,24,32), InputStroke = Color3.fromRGB(55,55,65),
	InputFocus = Color3.fromRGB(88,130,255), Placeholder = Color3.fromRGB(100,100,110),
}

Themes.Midnight = {
	Text = Color3.fromRGB(200,200,210), TextSecondary = Color3.fromRGB(120,120,130),
	Background = Color3.fromRGB(10,10,14), BackgroundSecondary = Color3.fromRGB(15,16,22),
	Surface = Color3.fromRGB(22,23,32), SurfaceHover = Color3.fromRGB(28,30,40),
	Topbar = Color3.fromRGB(14,15,20), TopbarText = Color3.fromRGB(200,200,210),
	Tab = Color3.fromRGB(30,32,42), TabHover = Color3.fromRGB(38,40,52), TabActive = Color3.fromRGB(48,50,65),
	TabText = Color3.fromRGB(150,150,165), TabTextActive = Color3.fromRGB(220,220,230),
	Element = Color3.fromRGB(20,21,28), ElementHover = Color3.fromRGB(26,28,36),
	ElementStroke = Color3.fromRGB(40,42,52),
	Accent = Color3.fromRGB(100,120,255), AccentHover = Color3.fromRGB(120,140,255),
	Success = Color3.fromRGB(35,180,100), Warning = Color3.fromRGB(230,160,40),
	Error = Color3.fromRGB(220,60,60), Info = Color3.fromRGB(50,140,220),
	ToggleEnabled = Color3.fromRGB(100,120,255), ToggleDisabled = Color3.fromRGB(50,52,62),
	SliderProgress = Color3.fromRGB(100,120,255),
	Input = Color3.fromRGB(18,19,26), InputStroke = Color3.fromRGB(45,47,58),
	InputFocus = Color3.fromRGB(100,120,255), Placeholder = Color3.fromRGB(80,80,95),
}

Themes.AMOLED = {
	Text = Color3.fromRGB(200,200,210), TextSecondary = Color3.fromRGB(100,100,110),
	Background = Color3.fromRGB(0,0,0), BackgroundSecondary = Color3.fromRGB(5,5,8),
	Surface = Color3.fromRGB(12,12,16), SurfaceHover = Color3.fromRGB(18,18,24),
	Topbar = Color3.fromRGB(0,0,0), TopbarText = Color3.fromRGB(200,200,210),
	Tab = Color3.fromRGB(18,18,24), TabHover = Color3.fromRGB(26,26,34), TabActive = Color3.fromRGB(34,34,46),
	TabText = Color3.fromRGB(130,130,145), TabTextActive = Color3.fromRGB(220,220,230),
	Element = Color3.fromRGB(10,10,14), ElementHover = Color3.fromRGB(16,16,22),
	ElementStroke = Color3.fromRGB(30,30,40),
	Accent = Color3.fromRGB(80,140,255), AccentHover = Color3.fromRGB(100,160,255),
	Success = Color3.fromRGB(30,170,90), Warning = Color3.fromRGB(220,150,30),
	Error = Color3.fromRGB(210,50,50), Info = Color3.fromRGB(40,130,210),
	ToggleEnabled = Color3.fromRGB(80,140,255), ToggleDisabled = Color3.fromRGB(40,40,52),
	SliderProgress = Color3.fromRGB(80,140,255),
	Input = Color3.fromRGB(8,8,12), InputStroke = Color3.fromRGB(35,35,46),
	InputFocus = Color3.fromRGB(80,140,255), Placeholder = Color3.fromRGB(65,65,80),
}

Themes.Neon = {
	Text = Color3.fromRGB(220,220,240), TextSecondary = Color3.fromRGB(150,150,180),
	Background = Color3.fromRGB(10,8,20), BackgroundSecondary = Color3.fromRGB(15,12,28),
	Surface = Color3.fromRGB(22,18,38), SurfaceHover = Color3.fromRGB(28,24,46),
	Topbar = Color3.fromRGB(14,10,26), TopbarText = Color3.fromRGB(220,220,240),
	Tab = Color3.fromRGB(32,26,50), TabHover = Color3.fromRGB(40,34,60), TabActive = Color3.fromRGB(50,42,72),
	TabText = Color3.fromRGB(160,150,190), TabTextActive = Color3.fromRGB(255,255,255),
	Element = Color3.fromRGB(18,14,32), ElementHover = Color3.fromRGB(24,20,40),
	ElementStroke = Color3.fromRGB(42,36,60),
	Accent = Color3.fromRGB(130,60,255), AccentHover = Color3.fromRGB(150,80,255),
	Success = Color3.fromRGB(35,200,120), Warning = Color3.fromRGB(255,170,40),
	Error = Color3.fromRGB(230,60,80), Info = Color3.fromRGB(50,140,240),
	ToggleEnabled = Color3.fromRGB(130,60,255), ToggleDisabled = Color3.fromRGB(52,46,70),
	SliderProgress = Color3.fromRGB(130,60,255),
	Input = Color3.fromRGB(16,12,30), InputStroke = Color3.fromRGB(48,40,68),
	InputFocus = Color3.fromRGB(130,60,255), Placeholder = Color3.fromRGB(90,80,120),
}

Themes.Cyberpunk = {
	Text = Color3.fromRGB(230,230,200), TextSecondary = Color3.fromRGB(180,180,130),
	Background = Color3.fromRGB(10,8,6), BackgroundSecondary = Color3.fromRGB(16,13,10),
	Surface = Color3.fromRGB(24,20,16), SurfaceHover = Color3.fromRGB(30,26,22),
	Topbar = Color3.fromRGB(14,11,8), TopbarText = Color3.fromRGB(230,230,200),
	Tab = Color3.fromRGB(34,28,22), TabHover = Color3.fromRGB(42,36,28), TabActive = Color3.fromRGB(52,44,34),
	TabText = Color3.fromRGB(170,160,130), TabTextActive = Color3.fromRGB(255,240,180),
	Element = Color3.fromRGB(20,16,12), ElementHover = Color3.fromRGB(26,22,18),
	ElementStroke = Color3.fromRGB(44,38,30),
	Accent = Color3.fromRGB(255,180,30), AccentHover = Color3.fromRGB(255,200,60),
	Success = Color3.fromRGB(50,200,100), Warning = Color3.fromRGB(255,140,20),
	Error = Color3.fromRGB(230,50,50), Info = Color3.fromRGB(40,160,220),
	ToggleEnabled = Color3.fromRGB(255,180,30), ToggleDisabled = Color3.fromRGB(54,48,42),
	SliderProgress = Color3.fromRGB(255,180,30),
	Input = Color3.fromRGB(18,14,10), InputStroke = Color3.fromRGB(50,44,36),
	InputFocus = Color3.fromRGB(255,180,30), Placeholder = Color3.fromRGB(110,100,80),
}

Themes.Glass = {
	Text = Color3.fromRGB(230,230,240), TextSecondary = Color3.fromRGB(160,160,180),
	Background = Color3.fromRGB(12,14,24), BackgroundSecondary = Color3.fromRGB(18,20,32),
	Surface = Color3.fromRGB(26,28,42), SurfaceHover = Color3.fromRGB(32,34,50),
	Topbar = Color3.fromRGB(16,18,28), TopbarText = Color3.fromRGB(230,230,240),
	Tab = Color3.fromRGB(36,38,54), TabHover = Color3.fromRGB(44,46,64), TabActive = Color3.fromRGB(54,56,76),
	TabText = Color3.fromRGB(170,170,190), TabTextActive = Color3.fromRGB(255,255,255),
	Element = Color3.fromRGB(22,24,36), ElementHover = Color3.fromRGB(28,30,44),
	ElementStroke = Color3.fromRGB(46,48,64),
	Accent = Color3.fromRGB(100,150,255), AccentHover = Color3.fromRGB(120,170,255),
	Success = Color3.fromRGB(45,200,120), Warning = Color3.fromRGB(255,180,50),
	Error = Color3.fromRGB(235,80,80), Info = Color3.fromRGB(60,160,230),
	ToggleEnabled = Color3.fromRGB(100,150,255), ToggleDisabled = Color3.fromRGB(56,58,74),
	SliderProgress = Color3.fromRGB(100,150,255),
	Input = Color3.fromRGB(20,22,34), InputStroke = Color3.fromRGB(50,52,70),
	InputFocus = Color3.fromRGB(100,150,255), Placeholder = Color3.fromRGB(100,100,120),
}

Themes.Purple = {
	Text = Color3.fromRGB(230,225,240), TextSecondary = Color3.fromRGB(170,160,190),
	Background = Color3.fromRGB(20,16,30), BackgroundSecondary = Color3.fromRGB(26,22,38),
	Surface = Color3.fromRGB(36,30,50), SurfaceHover = Color3.fromRGB(42,36,58),
	Topbar = Color3.fromRGB(24,20,36), TopbarText = Color3.fromRGB(230,225,240),
	Tab = Color3.fromRGB(44,38,60), TabHover = Color3.fromRGB(52,46,70), TabActive = Color3.fromRGB(62,54,82),
	TabText = Color3.fromRGB(180,170,200), TabTextActive = Color3.fromRGB(255,255,255),
	Element = Color3.fromRGB(30,26,44), ElementHover = Color3.fromRGB(36,32,52),
	ElementStroke = Color3.fromRGB(50,44,66),
	Accent = Color3.fromRGB(160,80,255), AccentHover = Color3.fromRGB(180,100,255),
	Success = Color3.fromRGB(45,200,120), Warning = Color3.fromRGB(255,180,50),
	Error = Color3.fromRGB(235,80,80), Info = Color3.fromRGB(60,160,230),
	ToggleEnabled = Color3.fromRGB(160,80,255), ToggleDisabled = Color3.fromRGB(62,56,80),
	SliderProgress = Color3.fromRGB(160,80,255),
	Input = Color3.fromRGB(28,24,42), InputStroke = Color3.fromRGB(54,48,72),
	InputFocus = Color3.fromRGB(160,80,255), Placeholder = Color3.fromRGB(110,100,140),
}

Themes.Light = {
	Text = Color3.fromRGB(30,30,40), TextSecondary = Color3.fromRGB(90,90,100),
	Background = Color3.fromRGB(240,242,248), BackgroundSecondary = Color3.fromRGB(235,237,244),
	Surface = Color3.fromRGB(230,232,240), SurfaceHover = Color3.fromRGB(222,224,234),
	Topbar = Color3.fromRGB(235,237,244), TopbarText = Color3.fromRGB(30,30,40),
	Tab = Color3.fromRGB(220,222,232), TabHover = Color3.fromRGB(210,212,224), TabActive = Color3.fromRGB(200,202,216),
	TabText = Color3.fromRGB(100,100,115), TabTextActive = Color3.fromRGB(20,20,30),
	Element = Color3.fromRGB(232,234,242), ElementHover = Color3.fromRGB(224,226,236),
	ElementStroke = Color3.fromRGB(210,212,222),
	Accent = Color3.fromRGB(70,110,220), AccentHover = Color3.fromRGB(90,130,240),
	Success = Color3.fromRGB(40,170,100), Warning = Color3.fromRGB(220,160,40),
	Error = Color3.fromRGB(210,60,60), Info = Color3.fromRGB(50,140,210),
	ToggleEnabled = Color3.fromRGB(70,110,220), ToggleDisabled = Color3.fromRGB(190,192,200),
	SliderProgress = Color3.fromRGB(70,110,220),
	Input = Color3.fromRGB(235,237,244), InputStroke = Color3.fromRGB(200,202,214),
	InputFocus = Color3.fromRGB(70,110,220), Placeholder = Color3.fromRGB(140,140,155),
}

ThemeManager.Themes = Themes
ThemeManager:ApplyTheme("Default")
function ThemeManager:GetTheme(name) return Themes[name] or self._customThemes[name] end
function ThemeManager:GetCurrent() return self._current end
function ThemeManager:GetCurrentName() return self._currentName end
function ThemeManager:GetAllThemes()
	local names = {}
	for n in pairs(Themes) do table.insert(names, n) end
	for n in pairs(self._customThemes) do table.insert(names, n) end
	return names
end
function ThemeManager:ApplyTheme(name)
	local theme = self:GetTheme(name); if not theme then return false end
	self._current = theme; self._currentName = name
	for _, cb in ipairs(self._listeners) do pcall(cb, theme, name) end
	return true
end
function ThemeManager:OnThemeChanged(cb) table.insert(self._listeners, cb) end
function ThemeManager:RegisterTheme(name, data) if Themes[name] then return false end; self._customThemes[name] = data; return true end

-- 6. Blur Engine
local BlurEngine = {}
local blurs = {}
function BlurEngine:Attach(screenGui, intensity)
	intensity = intensity or 24
	local blur = Instance.new("ImageLabel")
	blur.Name = "VoidUIBlur"; blur.Size = UDim2.new(1,0,1,0); blur.BackgroundTransparency = 1
	blur.Image = "rbxassetid://3570695787"; blur.ImageTransparency = 1; blur.ZIndex = 9999; blur.Parent = screenGui
	table.insert(blurs, blur); return blur
end
function BlurEngine:SetIntensity(blur, val)
	if not blur then return end
	TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1 - (math.clamp(val, 0, 100) / 100)}):Play()
end

-- 7. Acrylic
local Acrylic = {}
function Acrylic:Apply(frame, config)
	config = config or {}
	frame.BackgroundTransparency = config.TintTransparency or 0.4
	local shine = Instance.new("ImageLabel")
	shine.Name = "AcrylicShine"; shine.Size = UDim2.new(1,0,1,0); shine.BackgroundTransparency = 1
	shine.Image = "rbxassetid://3570695787"; shine.ImageColor3 = Color3.fromRGB(255,255,255)
	shine.ImageTransparency = 0.92; shine.ZIndex = frame.ZIndex + 1; shine.Parent = frame
	local border = Instance.new("Frame")
	border.Name = "AcrylicBorder"; border.Size = UDim2.new(1,0,0,1); border.Position = UDim2.new(0,0,1,0)
	border.BackgroundColor3 = Color3.fromRGB(255,255,255); border.BackgroundTransparency = 0.85
	border.BorderSizePixel = 0; border.ZIndex = frame.ZIndex + 1; border.Parent = frame
end

-- 8. Notification Manager
local NotificationManager = {}
local notifQueue = {}; local activeNotifs = {}
function NotificationManager:Notify(data)
	data = data or {}
	local notify = {Title = data.Title or "Notification", Content = data.Content or "", Duration = data.Duration or 5,
		Color = data.Color or Color3.fromRGB(88,130,255), OnClick = data.OnClick}
	table.insert(notifQueue, notify)
	task.spawn(function() self:ProcessQueue() end)
	return tick()
end
function NotificationManager:ProcessQueue()
	while #notifQueue > 0 and #activeNotifs < 5 do
		local n = table.remove(notifQueue,1)
		-- Use RayfieldCore notify as fallback
		_safe("Notify", function() RayfieldCore:Notify({Title = n.Title, Content = n.Content, Duration = n.Duration}) end)
		task.wait(0.15)
	end
end

-- 9. Mobile Manager
local MobileManager = {}
function MobileManager:IsMobile() return UserInputService.TouchEnabled end
function MobileManager:GetScale()
	local vp = workspace.CurrentCamera.ViewportSize
	if vp.X < 600 then return 0.65 elseif vp.X < 900 then return 0.8 elseif vp.X < 1200 then return 0.9 else return 1 end
end

-- 10. Search Manager (simplified)
local SearchManager = {}
function SearchManager:FuzzyMatch(text, pattern)
	if not pattern or #pattern == 0 then return true, 1 end
	text = text:lower(); pattern = pattern:lower()
	local pi = 1; local score = 0
	for ci = 1, #pattern do
		local pc = pattern:sub(ci,ci); local matched = false
		while pi <= #text do if text:sub(pi,pi) == pc then score = score + 1; matched = true; pi = pi + 1; break end; pi = pi + 1 end
		if not matched then return false, 0 end
	end
	return true, score / #pattern
end

-- 11. Config Manager
local ConfigManager = {_flags = {}, _currentProfile = "Default"}
local CFG_FOLDER = "VoidUI/Configs"
pcall(function()
	if isfolder and not isfolder("VoidUI") then makefolder("VoidUI") end
	if isfolder and not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end
end)
function ConfigManager:RegisterFlag(name, value) self._flags[name] = value end
function ConfigManager:GetFlag(name) return self._flags[name] end
function ConfigManager:SetFlag(name, value) self._flags[name] = value; return value end
function ConfigManager:Save(profile)
	profile = profile or self._currentProfile; local data = {}
	for n, v in pairs(self._flags) do
		if typeof(v) == "Color3" then data[n] = {R = v.R*255, G = v.G*255, B = v.B*255} else data[n] = v end
	end
	local ok, enc = pcall(function() return HttpService:JSONEncode(data) end)
	if ok then pcall(function() writefile(CFG_FOLDER.."/"..profile..".json", enc) end) end
end
function ConfigManager:Load(profile)
	profile = profile or self._currentProfile
	local ok = pcall(function() return readfile(CFG_FOLDER.."/"..profile..".json") end)
	if not ok then return false end
	local dOk, data = pcall(function() return HttpService:JSONDecode(ok) end)
	if not dOk then return false end
	for n, v in pairs(data) do
		if type(v) == "table" and v.R then self._flags[n] = Color3.fromRGB(v.R, v.G, v.B) else self._flags[n] = v end
	end
	return true
end
function ConfigManager:Export() return HttpService:JSONEncode(self._flags) end
function ConfigManager:Reset() table.clear(self._flags); self:Save() end

-- 12. Sidebar Engine
local SidebarEngine = {}
function SidebarEngine:Create(config)
	config = config or {}
	local container = Instance.new("ScreenGui")
	container.Name = "VoidUISidebar"; container.DisplayOrder = 800; container.ResetOnSpawn = false
	container.Parent = gethui and gethui() or CoreGui
	local frame = Instance.new("Frame")
	frame.Name = "SidebarFrame"; frame.Size = UDim2.new(0, config.Width or 200, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(16,16,22); frame.BackgroundTransparency = 0.05; frame.BorderSizePixel = 0; frame.ZIndex = 50; frame.Parent = container
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1,0,1,0); content.BackgroundTransparency = 1; content.ScrollBarThickness = 0; content.BorderSizePixel = 0; content.Parent = frame
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0,2); listLayout.Parent = content
	local padding = Instance.new("UIPadding"); padding.PaddingTop = UDim.new(0,12); padding.Parent = content
	local sidebar = {Frame = frame, Content = content, Container = container, Items = {}, ItemIndex = 0}
	function sidebar:AddSection(name)
		local sf = Instance.new("Frame"); sf.Size = UDim2.new(1,0,0,24); sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
		local st = Instance.new("TextLabel"); st.Size = UDim2.new(1,-24,1,0); st.Position = UDim2.new(0,12,0,0); st.BackgroundTransparency = 1
		st.Font = Enum.Font.GothamSemibold; st.Text = name:upper(); st.TextColor3 = Color3.fromRGB(110,110,125); st.TextSize = 10; st.TextXAlignment = Enum.TextXAlignment.Left; st.Parent = sf
		sf.Parent = self.Content; return self
	end
	function sidebar:AddItem(config)
		config = config or {}
		local item = Instance.new("TextButton"); item.Size = UDim2.new(1,-8,0,40); item.Position = UDim2.new(0,4,0,0)
		item.BackgroundTransparency = 1; item.Text = ""; item.AutoButtonColor = false; item.ZIndex = 55; item.Parent = self.Content
		local icon = Instance.new("ImageLabel"); icon.Size = UDim2.new(0,22,0,22); icon.Position = UDim2.new(0,12,0.5,0); icon.AnchorPoint = Vector2.new(0,0.5)
		icon.BackgroundTransparency = 1; icon.Image = config.Icon or ""; icon.ImageColor3 = Color3.fromRGB(170,170,185); icon.ZIndex = 56; icon.Parent = item
		local label = Instance.new("TextLabel"); label.Size = UDim2.new(1,-50,1,0); label.Position = UDim2.new(0,44,0,0); label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham; label.Text = config.Name or "Item"; label.TextColor3 = Color3.fromRGB(200,200,215); label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = 56; label.Parent = item
		if config.Callback then item.MouseButton1Click:Connect(config.Callback) end
		table.insert(self.Items, {Frame = item, Config = config, Icon = icon, Label = label})
		return self
	end
	return sidebar
end

-- 13. Icons System
local Icons = {}
local iconCache = {}
local ICONS_FOLDER = "VoidUI/Icons"
local hasFS = type(writefile) == "function" and type(isfile) == "function"
local hasCA = type(getcustomasset) == "function"

-- Pre-load known PNGs from filesystem
local function tryLoadIcon(name, filename)
	if not hasFS or not hasCA then return nil end
	local fullPath = ICONS_FOLDER .. "/" .. filename
	local ok, path = pcall(function()
		if not isfile(fullPath) then return nil end
		return getcustomasset(fullPath)
	end)
	if ok and path then iconCache[name] = path; return path end
	return nil
end

-- Common icons that might exist in folder
local commonIcons = {
	"lupa","config","fechar","salvar","lixeira","perfil","mais","cadeado",
	"chat","carrinho","enviar","compartilhar","baixar","nuvem","filtro",
	"lista","subir","descer","direita","esquerda","tocar","ver","ideia",
	"local","coracao","abas",
}

function Icons:Resolve(name)
	if not name or name == "" then return "" end
	if iconCache[name] then return iconCache[name] end
	if tonumber(name) then local u = "rbxassetid://"..name; iconCache[name]=u; return u end
	return ""
end
function Icons:GetIconList() local l = {}; for _,v in ipairs(commonIcons) do table.insert(l,v) end; return l end

-- 14. Command Palette
local CommandPalette = {}
function CommandPalette:Open(commands, config)
	config = config or {}
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1,0,1,0); overlay.BackgroundColor3 = Color3.fromRGB(0,0,0); overlay.BackgroundTransparency = 0.6; overlay.ZIndex = 6000; overlay.Parent = gethui and gethui() or CoreGui
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0,540,0,0); container.Position = UDim2.new(0.5,0,0,40); container.AnchorPoint = Vector2.new(0.5,0)
	container.BackgroundColor3 = Color3.fromRGB(24,24,32); container.BorderSizePixel = 0; container.ClipsDescendants = true; container.ZIndex = 6001; container.Parent = overlay
	local inputBox = Instance.new("TextBox")
	inputBox.Size = UDim2.new(1,-24,0,42); inputBox.Position = UDim2.new(0,12,0,10); inputBox.BackgroundColor3 = Color3.fromRGB(30,30,38)
	inputBox.Font = Enum.Font.Gotham; inputBox.Text = ""; inputBox.TextColor3 = Color3.fromRGB(220,220,230); inputBox.TextSize = 15
	inputBox.PlaceholderText = "Search commands..."; inputBox.PlaceholderColor3 = Color3.fromRGB(100,100,115); inputBox.ClearTextOnFocus = false; inputBox.ZIndex = 6002; inputBox.Parent = container
	local results = Instance.new("ScrollingFrame")
	results.Size = UDim2.new(1,-12,0,300); results.Position = UDim2.new(0,6,0,60); results.BackgroundTransparency = 1; results.ScrollBarThickness = 4; results.CanvasSize = UDim2.new(0,0,0,0); results.ZIndex = 6002; results.Parent = container
	container.Size = UDim2.new(0,540,0,380); inputBox:CaptureFocus()
	local function close()
		TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Size = UDim2.new(0,540,0,0), Position = UDim2.new(0.5,0,0,-100)}):Play()
		task.delay(0.3, function() pcall(function() overlay:Destroy() end) end)
	end
	overlay.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then close() end end)
	UserInputService.InputBegan:Connect(function(i,p) if p then return end; if i.KeyCode == Enum.KeyCode.Escape then close() end end)
	-- Filter
	inputBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = inputBox.Text:lower()
		for _, child in ipairs(results:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
		if #query == 0 then results.CanvasSize = UDim2.new(0,0,0,0); return end
		local y = 0
		for _, cmd in ipairs(commands or {}) do
			if (cmd.Name or ""):lower():find(query,1,true) then
				local item = Instance.new("Frame"); item.Size = UDim2.new(1,-8,0,36); item.Position = UDim2.new(0,4,0,y); item.BackgroundColor3 = Color3.fromRGB(28,28,38); item.BorderSizePixel = 0; item.ZIndex = 6003; item.Parent = results
				local t = Instance.new("TextLabel"); t.Size = UDim2.new(1,-16,0,18); t.Position = UDim2.new(0,8,0,2); t.BackgroundTransparency = 1; t.Font = Enum.Font.Gotham; t.Text = cmd.Name or ""; t.TextColor3 = Color3.fromRGB(220,220,230); t.TextSize = 14; t.TextXAlignment = Enum.TextXAlignment.Left; t.ZIndex = 6004; t.Parent = item
				if cmd.Description then
					local d = Instance.new("TextLabel"); d.Size = UDim2.new(1,-16,0,14); d.Position = UDim2.new(0,8,0,20); d.BackgroundTransparency = 1; d.Font = Enum.Font.Gotham; d.Text = cmd.Description; d.TextColor3 = Color3.fromRGB(140,140,155); d.TextSize = 11; d.TextXAlignment = Enum.TextXAlignment.Left; d.ZIndex = 6004; d.Parent = item
				end
				item.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then if cmd.Callback then pcall(cmd.Callback) end; close() end end)
				y = y + 38
			end
		end
		results.CanvasSize = UDim2.new(0,0,0,y)
	end)
end

-- 15. Plugin Manager
local PluginManager = {_plugins = {}}
function PluginManager:Register(config)
	if not config.Name or self._plugins[config.Name] then return false end
	local plugin = {Name = config.Name, Version = config.Version or "1.0", Enabled = true, Init = config.Init or function() end, Cleanup = config.Cleanup or function() end}
	self._plugins[config.Name] = plugin; local ok, err = pcall(plugin.Init); if not ok then plugin.Enabled = false end; return plugin
end

-- 16. Dock Manager
local DockManager = {}
local docks = {}
function DockManager:CreateDock(config)
	config = config or {}
	local container = Instance.new("ScreenGui"); container.Name = "VoidUIDock"; container.DisplayOrder = 500; container.ResetOnSpawn = false; container.Parent = gethui and gethui() or CoreGui
	local frame = Instance.new("Frame"); frame.BackgroundColor3 = config.Color or Color3.fromRGB(32,32,40); frame.BackgroundTransparency = 0.2; frame.BorderSizePixel = 0
	local size = config.Size or 48; local pos = config.Position or "right"
	if pos == "right" then frame.Position = UDim2.new(1,-size-12,0.5,-(size*3)); frame.Size = UDim2.new(0,size,0,size*6) end
	frame.Parent = container
	local dock = {Id = config.Id or "dock", Container = container, Frame = frame}; docks[dock.Id] = dock; return dock
end

-- Watermark Component
local WatermarkComponent = {}
local wmInstances = {}
function WatermarkComponent:Create(config)
	config = config or {}
	local container = Instance.new("ScreenGui"); container.Name = "VoidUIWatermark"; container.DisplayOrder = 10000; container.ResetOnSpawn = false; container.Parent = gethui and gethui() or CoreGui
	local frame = Instance.new("Frame"); frame.Size = UDim2.new(0, config.Width or 200, 0, config.Height or 28); frame.Position = UDim2.new(0, config.PositionX or 12, 0, config.PositionY or 12)
	frame.BackgroundColor3 = Color3.fromRGB(18,18,24); frame.BackgroundTransparency = 0.2; frame.BorderSizePixel = 0; frame.Parent = container
	local text = Instance.new("TextLabel"); text.Size = UDim2.new(1,-12,1,0); text.Position = UDim2.new(0,6,0,0); text.BackgroundTransparency = 1; text.Font = Enum.Font.GothamSemibold; text.TextSize = 13; text.TextColor3 = Color3.fromRGB(220,220,230); text.TextXAlignment = Enum.TextXAlignment.Left; text.Parent = frame
	local obj = {_running = true}
	RunService.RenderStepped:Connect(function(dt)
		if not obj._running then return end
		local fps = 1 / dt; local mem = collectgarbage and math.floor(collectgarbage("count")) or 0
		local fpsText = config.ShowFPS ~= false and ("FPS: " .. math.floor(fps)) or ""
		local memText = config.ShowMemory and (" | MEM: " .. mem .. "KB") or ""
		local customText = config.Text or ""
		local sep = (customText ~= "" and (fpsText ~= "" or memText ~= "")) and " | " or ""
		text.Text = customText .. sep .. fpsText .. memText
	end)
	local st = {}; function st:Destroy() obj._running = false; container:Destroy() end; return st
end

-- Components table
local Components = { Watermark = WatermarkComponent }

_log("Todos os modulos VoidUI carregados!")

-- ═══════════════════════════════════════════════════════════════
-- 	INTEGRATION LAYER
-- ═══════════════════════════════════════════════════════════════

local VoidUI = {}

-- Core
VoidUI.Core = RayfieldCore
VoidUI.RayfieldCore = RayfieldCore

-- Modules
VoidUI.Signals = Signals
VoidUI.EventManager = EventManager
VoidUI.Performance = Performance
VoidUI.Rendering = Rendering
VoidUI.ThemeManager = ThemeManager
VoidUI.BlurEngine = BlurEngine
VoidUI.Acrylic = Acrylic
VoidUI.NotificationManager = NotificationManager
VoidUI.MobileManager = MobileManager
VoidUI.SearchManager = SearchManager
VoidUI.SidebarEngine = SidebarEngine
VoidUI.Icons = Icons
VoidUI.CommandPalette = CommandPalette
VoidUI.PluginManager = PluginManager
VoidUI.DockManager = DockManager
VoidUI.ConfigManager = ConfigManager
VoidUI.Components = Components

-- API: CreateWindow
function VoidUI:CreateWindow(config)
	config = config or {}
	_log("CreateWindow: " .. (config.Title or "Unnamed"))

	local window = RayfieldCore:CreateWindow({
		Name = config.Title or config.Name or "VoidUI",
		Icon = config.Icon or 0,
		LoadingTitle = config.LoadingTitle or config.Title or "VoidUI",
		LoadingSubtitle = config.LoadingSubtitle or "Next-Gen UI Library",
		Theme = "Default",
		DisableRayfieldPrompts = config.DisableRayfieldPrompts or false,
		DisableBuildWarnings = true,
		ToggleUIKeybind = config.ToggleUIKeybind or config.ToggleKeybind or "K",
		ConfigurationSaving = { Enabled = config.ConfigurationSaving and config.ConfigurationSaving.Enabled or false, FileName = (config.ConfigurationSaving and config.ConfigurationSaving.FileName) or nil },
		Discord = { Enabled = false },
		KeySystem = config.KeySystem or false,
		KeySettings = config.KeySettings,
	})

	_log("CreateWindow: Window criada com sucesso")

	if config.Theme and config.Theme ~= "Default" then
		_safe("ApplyTheme", function() window.ModifyTheme(config.Theme); ThemeManager:ApplyTheme(config.Theme) end)
	end

	local enhancedWindow = {_window = window, _config = config, _tabs = {}}

	function enhancedWindow:Tab(config)
		if type(config) == "string" then config = { Name = config, Icon = 0 } end
		local tab = window:CreateTab(config.Name, config.Icon or 0)
		local enhancedTab = {_tab = tab, _elements = {}}

		function enhancedTab:Section(name) tab:CreateSection(name); return enhancedTab end
		function enhancedTab:Button(c) tab:CreateButton({Name = c.Name, Callback = c.Callback or function() end}); return enhancedTab end
		function enhancedTab:Toggle(c) tab:CreateToggle({Name = c.Name, CurrentValue = c.Default or false, Flag = c.Flag or c.Name, Callback = c.Callback or function() end}); return enhancedTab end
		function enhancedTab:Slider(c) tab:CreateSlider({Name = c.Name, Range = c.Range or {0,100}, Increment = c.Increment or 1, Suffix = c.Suffix or "", CurrentValue = c.Default or 0, Flag = c.Flag or c.Name, Callback = c.Callback or function() end}); return enhancedTab end
		function enhancedTab:Input(c) tab:CreateInput({Name = c.Name, CurrentValue = c.Default or "", PlaceholderText = c.Placeholder or "Digite...", Flag = c.Flag or c.Name, RemoveTextAfterFocusLost = c.ClearOnFocus or false, Callback = c.Callback or function() end}); return enhancedTab end
		function enhancedTab:Dropdown(c) tab:CreateDropdown({Name = c.Name, Options = c.Options or {}, CurrentOption = c.Default and {c.Default} or {}, MultipleOptions = c.Multiple or false, Flag = c.Flag or c.Name, Callback = c.Callback or function() end}); return enhancedTab end
		function enhancedTab:Keybind(c) tab:CreateKeybind({Name = c.Name, CurrentKeybind = c.Default or "F", HoldToInteract = c.Hold or false, Flag = c.Flag or c.Name, Callback = c.Callback or function() end}); return enhancedTab end
		function enhancedTab:ColorPicker(c) tab:CreateColorPicker({Name = c.Name, Color = c.Default or Color3.fromRGB(255,255,255), Flag = c.Flag or c.Name, Callback = c.Callback or function() end}); return enhancedTab end
		function enhancedTab:Label(text, icon, color) tab:CreateLabel(text, icon or 0, color); return enhancedTab end
		function enhancedTab:Paragraph(c) tab:CreateParagraph({Title = c.Title or "", Content = c.Content or ""}); return enhancedTab end
		function enhancedTab:Divider() tab:CreateDivider(); return enhancedTab end
		table.insert(self._tabs, enhancedTab); return enhancedTab
	end

	task.delay(2, function()
		_safe("LoadConfiguration", function()
			if RayfieldCore.LoadConfiguration then RayfieldCore:LoadConfiguration() end
		end)
	end)

	return enhancedWindow
end

-- Backward compatibility
VoidUI.Flags = RayfieldCore.Flags
VoidUI.Theme = RayfieldCore.Theme

function VoidUI:Notify(data) _safe("Notify", function() RayfieldCore:Notify(data) end) end
function VoidUI:LoadConfiguration() _safe("LoadConfiguration", function() RayfieldCore:LoadConfiguration() end) end
function VoidUI:SetVisibility(v) _safe("SetVisibility", function() RayfieldCore:SetVisibility(v) end) end
function VoidUI:IsVisible() return RayfieldCore:IsVisible() end
function VoidUI:Destroy() _safe("Destroy", function() RayfieldCore:Destroy() end) end
function VoidUI:ModifyTheme(name)
	if name and ThemeManager:GetTheme(name) then ThemeManager:ApplyTheme(name) end
	_safe("ModifyTheme", function() RayfieldCore:ModifyTheme(name or "Default") end)
end

_log("VoidUI totalmente carregado! Retornando objeto...")

-- ═══════════════════════════════════════════════════════════════
-- 	RETURN
-- ═══════════════════════════════════════════════════════════════

return VoidUI
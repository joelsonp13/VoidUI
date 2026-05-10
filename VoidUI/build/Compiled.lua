-- ============================================================
-- 	Rayfield Enhanced v2.0.0
-- 	Premium Roblox UI Library
-- 	Based on Rayfield Interface Suite by Sirius
-- 	Enhanced with modern visuals, animations, and modular architecture
-- ============================================================
-- 	Usage: loadstring(game:HttpGet("url"))()
-- 	GitHub: https://github.com/StyearX/RayfieldEnhanced
-- ============================================================

-- ============================================================
-- 	PHASE 1: ENVIRONMENT SETUP
-- ============================================================

local getgenvFn = (type(getgenv) == "function" and getgenv) or rawget(_G, "getgenv")
local requestsDisabled = false
local customAssetId = nil
local secureMode = false

if getgenvFn then
	local ok, result = pcall(function() return getgenvFn().RAYFIELD_ENHANCED_ASSET_ID end)
	if ok and type(result) == "number" then customAssetId = result end
	local ok2, result2 = pcall(function() return getgenvFn().RAYFIELD_ENHANCED_SECURE end)
	if ok2 and result2 then secureMode = true end
	local ok3, result3 = pcall(function() return getgenvFn().DISABLE_RAYFIELD_ENHANCED_REQUESTS end)
	if ok3 and result3 then requestsDisabled = true end
end

local function getService(name)
	local service = game:GetService(name)
	if cloneref then
		return cloneref(service)
	end
	return service
end

-- Services
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")
local RunService = getService("RunService")
local HttpService = getService("HttpService")
local Lighting = getService("Lighting")

-- ============================================================
-- 	PHASE 2: LOAD RAYFIELD CORE
-- ============================================================

local function getCompiler()
	local compiler = (type(loadstring) == "function" and loadstring)
		or (type(load) == "function" and load)
		or rawget(_G, "loadstring")
		or rawget(_G, "load")
	if (not compiler) and getgenvFn then
		local ok, env = pcall(getgenvFn)
		if ok and type(env) == "table" then
			compiler = env.VOIDUI_COMPILER or env.loadstring or env.load
		end
	end
	return compiler
end

local function httpGetText(url)
	local ok, data = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and type(data) == "string" and #data > 0 then
		return data
	end

	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if req then
		local rok, resp = pcall(function()
			return req({ Url = url, Method = "GET" })
		end)
		if rok and resp then
			local body = resp.Body or resp.body
			if type(body) == "string" and #body > 0 then
				return body
			end
		end
	end

	return nil
end

local function loadRemoteModule(url)
	local compiler = getCompiler()
	if type(compiler) ~= "function" then
		return nil, "loadstring/load indisponivel no executor"
	end

	local source = httpGetText(url)
	if type(source) ~= "string" then
		return nil, "falha no download: " .. tostring(url)
	end

	local cOk, chunkOrErr = pcall(function()
		return compiler(source)
	end)
	if not cOk or type(chunkOrErr) ~= "function" then
		return nil, "falha ao compilar modulo remoto"
	end

	local rOk, result = pcall(chunkOrErr)
	if not rOk then
		return nil, "falha ao executar modulo remoto: " .. tostring(result)
	end

	if type(result) ~= "table" then
		return nil, "modulo remoto nao retornou tabela"
	end

	return result
end

local RayfieldCore
do
	local env = nil
	if getgenvFn then
		pcall(function()
			env = getgenvFn()
		end)
	end

	-- Optional injection path (lets caller bypass remote loader limits)
	if type(env) == "table" and type(env.VOIDUI_RAYFIELD_CORE) == "table" then
		RayfieldCore = env.VOIDUI_RAYFIELD_CORE
	end

	if (not RayfieldCore) and type(env) == "table" and type(env.VOIDUI_RAYFIELD_SOURCE) == "string" then
		local compiler = getCompiler()
		if type(compiler) == "function" then
			local okChunk, chunkOrErr = pcall(function()
				return compiler(env.VOIDUI_RAYFIELD_SOURCE, "@VoidUIRayfield")
			end)
			if okChunk and type(chunkOrErr) == "function" then
				local okRun, result = pcall(chunkOrErr)
				if okRun and type(result) == "table" then
					RayfieldCore = result
				else
					env.__VOIDUI_RAYFIELD_LASTERR = "exec source: " .. tostring(result)
				end
			else
				env.__VOIDUI_RAYFIELD_LASTERR = "compile source: " .. tostring(chunkOrErr)
			end
		else
			env.__VOIDUI_RAYFIELD_LASTERR = "compiler indisponivel para VOIDUI_RAYFIELD_SOURCE"
		end
	end

	local sources = {}
	if type(env) == "table" and type(env.VOIDUI_RAYFIELD_URL) == "string" and #env.VOIDUI_RAYFIELD_URL > 0 then
		table.insert(sources, env.VOIDUI_RAYFIELD_URL)
	end
	table.insert(sources, "https://sirius.menu/rayfield")
	table.insert(sources, "https://raw.githubusercontent.com/shlexware/Rayfield/main/source")
	table.insert(sources, "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source")

	local lastErr = (type(env) == "table" and env.__VOIDUI_RAYFIELD_LASTERR) or "erro desconhecido"
	for _, url in ipairs(sources) do
		local result, err = loadRemoteModule(url)
		if result then
			RayfieldCore = result
			break
		end
		lastErr = tostring(err or lastErr) .. " | url=" .. tostring(url)
	end

	if not RayfieldCore then
		error("[VoidUI] Nao foi possivel carregar RayfieldCore: " .. tostring(lastErr))
	end
end

-- ============================================================
-- 	PHASE 3: ENHANCED SYSTEM MODULES
-- ============================================================

-- 3.1 — Signals (Custom event system)
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
	return {Disconnect = function() conn.Connected = false
		for i,v in ipairs(self._listeners) do if v == conn then table.remove(self._listeners,i) return end end end}
end

function SignalMT:Once(cb)
	local wrap; wrap = function(...) cb(...) end
	return self:Connect(wrap)
end

function SignalMT:Fire(...)
	if not self._connected then return end
	for _, l in ipairs(self._listeners) do if l.Connected then task.spawn(l.Callback, ...) end end
end

function SignalMT:Destroy()
	table.clear(self._listeners); self._connected = false
end

-- 3.2 — Springs (Physics-based animation engine)
local Springs = {}
Springs.__index = Springs
local springDef = {frequency = 2.5, damping = 0.7, mass = 1, precision = 0.001}

function Springs.new(val, config)
	config = config or {}
	return setmetatable({
		_value = val, _velocity = 0, _target = val,
		_frequency = config.frequency or springDef.frequency,
		_damping = config.damping or springDef.damping,
		_mass = config.mass or springDef.mass,
		_precision = config.precision or springDef.precision,
		_isAnimating = false, _onUpdate = nil, _onComplete = nil
	}, Springs)
end

function Springs:to(target) self._target = target; self._isAnimating = true; return self end
function Springs:snap(value)
	self._value = value; self._target = value; self._velocity = 0
	self._isAnimating = false; if self._onUpdate then self._onUpdate(value) end; return self
end
function Springs:step(dt)
	if not self._isAnimating then return self._value end
	dt = math.min(dt, 0.1)
	local freq = self._frequency * math.pi * 2
	local damping = self._damping; local mass = self._mass
	local displacement = self._value - self._target
	local springForce = -(freq * freq) * displacement
	local dampingForce = -2 * damping * freq * self._velocity
	local acceleration = (springForce + dampingForce) / mass
	self._velocity = self._velocity + acceleration * dt
	self._value = self._value + self._velocity * dt
	if self._onUpdate then self._onUpdate(self._value) end
	if math.abs(self._velocity) < self._precision and math.abs(displacement) < self._precision then
		self._value = self._target; self._velocity = 0; self._isAnimating = false
		if self._onUpdate then self._onUpdate(self._value) end
		if self._onComplete then self._onComplete(self._value) end
	end
	return self._value
end
function Springs:onUpdate(cb) self._onUpdate = cb; return self end
function Springs:onComplete(cb) self._onComplete = cb; return self end
function Springs:get() return self._value end
function Springs:stop() self._isAnimating = false; return self end

-- 3.3 — Cache System
local Cache = {_elements = {}, _icons = {}, _objects = {}, _stats = {Hits = 0, Misses = 0}}
function Cache:Get(key, factory)
	if self._elements[key] then self._stats.Hits = self._stats.Hits + 1; return self._elements[key] end
	self._stats.Misses = self._stats.Misses + 1; local v = factory()
	if v then self._elements[key] = v end; return v
end
function Cache:Set(key, val) self._elements[key] = val end
function Cache:Remove(key) local v = self._elements[key]; self._elements[key] = nil; return v end
function Cache:Clear() table.clear(self._elements); table.clear(self._icons); table.clear(self._objects) end

-- 3.4 — Event Manager
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
function EventManager:Once(name, cb) local w; w = function(...) cb(...); self:Off(name, w) end; return self:On(name, w) end
function EventManager:Off(name, t)
	if not self._events[name] then return end
	for i = #self._events[name], 1, -1 do
		local l = self._events[name][i]
		if l.Id == t or l.Callback == t then table.remove(self._events[name], i); return end
	end
end
function EventManager:Emit(name, ...)
	if not self._events[name] then return end
	for _, l in ipairs(self._events[name]) do task.spawn(l.Callback, ...) end
end

-- 3.5 — Performance (Object Pooling + Batching)
local Performance = {}
local Pools = {}
local Batched = {}

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
	if not Batched[id] then
		Batched[id] = fn
		task.spawn(function() task.wait() if Batched[id] then pcall(Batched[id]); Batched[id] = nil end end)
	end
end

-- 3.6 — Animation Engine
local AnimEngine = {}
local Easing = {}
function Easing.Linear(t) return t end
function Easing.QuadOut(t) return t * (2 - t) end
function Easing.CubicOut(t) return (t - 1)^3 + 1 end
function Easing.QuartOut(t) return (t - 1)^4 + 1 end
function Easing.QuintOut(t) return (t - 1)^5 + 1 end
function Easing.SineOut(t) return math.sin(t * math.pi / 2) end
function Easing.ExpoOut(t) return t == 1 and 1 or 1 - 2 ^ (-10 * t) end
function Easing.BackOut(t) local s = 1.70158 return (t - 1)^2 * ((s + 1) * (t - 1) + s) + 1 end
function Easing.ElasticOut(t)
	if t == 0 or t == 1 then return t end; local p = 0.3
	return 2^(-10*t) * math.sin((t - p/4) * (2*math.pi) / p) + 1
end
function Easing.BounceOut(t)
	if t < 1/2.75 then return 7.5625*t*t
	elseif t < 2/2.75 then t = t - 1.5/2.75; return 7.5625*t*t + 0.75
	elseif t < 2.5/2.75 then t = t - 2.25/2.75; return 7.5625*t*t + 0.9375
	else t = t - 2.625/2.75; return 7.5625*t*t + 0.984375 end
end

AnimEngine.Easing = Easing
AnimEngine.Springs = Springs

function AnimEngine.Tween(obj, props, duration, easing, cb)
	if not obj then return end
	local style = Enum.EasingStyle.Quad
	if type(easing) == "string" then
		local map = {Linear=Enum.EasingStyle.Linear, Quad=Enum.EasingStyle.Quad,
			Cubic=Enum.EasingStyle.Cubic, Quart=Enum.EasingStyle.Quart,
			Quint=Enum.EasingStyle.Quint, Sine=Enum.EasingStyle.Sine,
			Expo=Enum.EasingStyle.Exponential, Back=Enum.EasingStyle.Back,
			Elastic=Enum.EasingStyle.Elastic, Bounce=Enum.EasingStyle.Bounce}
		style = map[easing] or Enum.EasingStyle.Quad
	end
	duration = duration or 0.3
	local info = typeof(duration) == "TweenInfo" and duration or TweenInfo.new(duration, style, Enum.EasingDirection.Out)
	local tween = TweenService:Create(obj, info, props); tween:Play()
	if cb then tween.Completed:Connect(cb) end; return tween
end

function AnimEngine.Lerp(a, b, t) return a + (b - a) * t end
function AnimEngine.LerpColor(a, b, t) return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t) end

-- Ripple effect
local RipplePool = {}
function AnimEngine.Ripple(obj, color, duration)
	if not obj then return end; color = color or Color3.fromRGB(255,255,255); duration = duration or 0.6
	local ripple = table.remove(RipplePool)
	if not ripple then
		ripple = Instance.new("ImageLabel")
		ripple.Image = "rbxassetid://3570695787"; ripple.BackgroundTransparency = 1
		ripple.Size = UDim2.new(0,0,0,0); ripple.Position = UDim2.new(0.5,0,0.5,0)
		ripple.AnchorPoint = Vector2.new(0.5,0.5); ripple.ZIndex = 1000
	end
	ripple.Parent = obj; ripple.ImageColor3 = color; ripple.ImageTransparency = 0.8
	local maxSize = math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 1.5
	TweenService:Create(ripple, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, maxSize, 0, maxSize), ImageTransparency = 1}):Play()
	task.delay(duration + 0.1, function()
		ripple.Parent = nil; ripple.Size = UDim2.new(0,0,0,0); ripple.ImageTransparency = 0.8
		table.insert(RipplePool, ripple)
	end)
end

-- 3.7 — Theme Manager (8 Premium Themes)
local ThemeManager = {_current = nil, _currentName = "Default", _listeners = {}, _customThemes = {}}

local Themes = {
	Default = {
		Text = Color3.fromRGB(225,225,230), TextSecondary = Color3.fromRGB(140,140,150),
		TextMuted = Color3.fromRGB(90,90,100), Background = Color3.fromRGB(18,18,22),
		BackgroundSecondary = Color3.fromRGB(24,24,30), BackgroundTertiary = Color3.fromRGB(30,30,38),
		Surface = Color3.fromRGB(32,32,40), SurfaceHover = Color3.fromRGB(38,38,48),
		Topbar = Color3.fromRGB(22,22,28), TopbarText = Color3.fromRGB(225,225,230),
		Tab = Color3.fromRGB(40,40,50), TabHover = Color3.fromRGB(50,50,62), TabActive = Color3.fromRGB(60,60,75),
		TabText = Color3.fromRGB(180,180,190), TabTextActive = Color3.fromRGB(255,255,255),
		Element = Color3.fromRGB(28,28,36), ElementHover = Color3.fromRGB(34,34,44),
		ElementStroke = Color3.fromRGB(48,48,58),
		Accent = Color3.fromRGB(88,130,255), AccentHover = Color3.fromRGB(108,148,255),
		Success = Color3.fromRGB(45,200,120), Warning = Color3.fromRGB(255,180,50),
		Error = Color3.fromRGB(235,80,80), Info = Color3.fromRGB(60,160,230),
		Toggle = Color3.fromRGB(45,45,55), ToggleEnabled = Color3.fromRGB(88,130,255),
		ToggleDisabled = Color3.fromRGB(60,60,70), Slider = Color3.fromRGB(48,48,58),
		SliderProgress = Color3.fromRGB(88,130,255), SliderHandle = Color3.fromRGB(255,255,255),
		Input = Color3.fromRGB(24,24,32), InputStroke = Color3.fromRGB(55,55,65),
		InputFocus = Color3.fromRGB(88,130,255), Placeholder = Color3.fromRGB(100,100,110),
		Notification = Color3.fromRGB(24,24,32), Dropdown = Color3.fromRGB(28,28,36),
		DropdownSelected = Color3.fromRGB(38,38,48), Shadow = Color3.fromRGB(0,0,0),
		CornerRadius = 8, ElementCornerRadius = 6, ToggleCornerRadius = 12,
	},
	Midnight = {
		Text = Color3.fromRGB(200,200,210), TextSecondary = Color3.fromRGB(120,120,130),
		TextMuted = Color3.fromRGB(70,70,80), Background = Color3.fromRGB(10,10,14),
		BackgroundSecondary = Color3.fromRGB(15,16,22), BackgroundTertiary = Color3.fromRGB(20,21,28),
		Surface = Color3.fromRGB(22,23,32), SurfaceHover = Color3.fromRGB(28,30,40),
		Topbar = Color3.fromRGB(14,15,20), TopbarText = Color3.fromRGB(200,200,210),
		Tab = Color3.fromRGB(30,32,42), TabHover = Color3.fromRGB(38,40,52), TabActive = Color3.fromRGB(48,50,65),
		TabText = Color3.fromRGB(150,150,165), TabTextActive = Color3.fromRGB(220,220,230),
		Element = Color3.fromRGB(20,21,28), ElementHover = Color3.fromRGB(26,28,36),
		ElementStroke = Color3.fromRGB(40,42,52), Accent = Color3.fromRGB(100,120,255),
		AccentHover = Color3.fromRGB(120,140,255),
		Success = Color3.fromRGB(35,180,100), Warning = Color3.fromRGB(230,160,40),
		Error = Color3.fromRGB(220,60,60), Info = Color3.fromRGB(50,140,220),
		Toggle = Color3.fromRGB(35,37,46), ToggleEnabled = Color3.fromRGB(100,120,255),
		ToggleDisabled = Color3.fromRGB(50,52,62),
		Input = Color3.fromRGB(18,19,26), InputStroke = Color3.fromRGB(45,47,58),
		InputFocus = Color3.fromRGB(100,120,255), Placeholder = Color3.fromRGB(80,80,95),
		CornerRadius = 10, ElementCornerRadius = 8, ToggleCornerRadius = 14,
	},
	AMOLED = {
		Text = Color3.fromRGB(200,200,210), TextSecondary = Color3.fromRGB(100,100,110),
		TextMuted = Color3.fromRGB(55,55,65), Background = Color3.fromRGB(0,0,0),
		BackgroundSecondary = Color3.fromRGB(5,5,8), BackgroundTertiary = Color3.fromRGB(10,10,14),
		Surface = Color3.fromRGB(12,12,16), SurfaceHover = Color3.fromRGB(18,18,24),
		Topbar = Color3.fromRGB(0,0,0), TopbarText = Color3.fromRGB(200,200,210),
		Tab = Color3.fromRGB(18,18,24), TabHover = Color3.fromRGB(26,26,34), TabActive = Color3.fromRGB(34,34,46),
		TabText = Color3.fromRGB(130,130,145), TabTextActive = Color3.fromRGB(220,220,230),
		Element = Color3.fromRGB(10,10,14), ElementHover = Color3.fromRGB(16,16,22),
		ElementStroke = Color3.fromRGB(30,30,40), Accent = Color3.fromRGB(80,140,255),
		AccentHover = Color3.fromRGB(100,160,255),
		Success = Color3.fromRGB(30,170,90), Warning = Color3.fromRGB(220,150,30),
		Error = Color3.fromRGB(210,50,50), Info = Color3.fromRGB(40,130,210),
		Toggle = Color3.fromRGB(25,25,34), ToggleEnabled = Color3.fromRGB(80,140,255),
		ToggleDisabled = Color3.fromRGB(40,40,52), CornerRadius = 8, ElementCornerRadius = 6, ToggleCornerRadius = 12,
	},
	Neon = {
		Text = Color3.fromRGB(220,220,240), TextSecondary = Color3.fromRGB(150,150,180),
		TextMuted = Color3.fromRGB(100,100,130), Background = Color3.fromRGB(10,8,20),
		BackgroundSecondary = Color3.fromRGB(15,12,28), BackgroundTertiary = Color3.fromRGB(20,16,34),
		Surface = Color3.fromRGB(22,18,38), SurfaceHover = Color3.fromRGB(28,24,46),
		Topbar = Color3.fromRGB(14,10,26), TopbarText = Color3.fromRGB(220,220,240),
		Tab = Color3.fromRGB(32,26,50), TabHover = Color3.fromRGB(40,34,60), TabActive = Color3.fromRGB(50,42,72),
		TabText = Color3.fromRGB(160,150,190), TabTextActive = Color3.fromRGB(255,255,255),
		Element = Color3.fromRGB(18,14,32), ElementHover = Color3.fromRGB(24,20,40),
		ElementStroke = Color3.fromRGB(42,36,60), Accent = Color3.fromRGB(130,60,255),
		AccentHover = Color3.fromRGB(150,80,255),
		Success = Color3.fromRGB(35,200,120), Warning = Color3.fromRGB(255,170,40),
		Error = Color3.fromRGB(230,60,80), Info = Color3.fromRGB(50,140,240),
		Toggle = Color3.fromRGB(36,30,54), ToggleEnabled = Color3.fromRGB(130,60,255),
		ToggleDisabled = Color3.fromRGB(52,46,70), CornerRadius = 10, ElementCornerRadius = 8, ToggleCornerRadius = 14,
	},
	Cyberpunk = {
		Text = Color3.fromRGB(230,230,200), TextSecondary = Color3.fromRGB(180,180,130),
		TextMuted = Color3.fromRGB(130,130,80), Background = Color3.fromRGB(10,8,6),
		BackgroundSecondary = Color3.fromRGB(16,13,10), BackgroundTertiary = Color3.fromRGB(22,18,14),
		Surface = Color3.fromRGB(24,20,16), SurfaceHover = Color3.fromRGB(30,26,22),
		Topbar = Color3.fromRGB(14,11,8), TopbarText = Color3.fromRGB(230,230,200),
		Tab = Color3.fromRGB(34,28,22), TabHover = Color3.fromRGB(42,36,28), TabActive = Color3.fromRGB(52,44,34),
		TabText = Color3.fromRGB(170,160,130), TabTextActive = Color3.fromRGB(255,240,180),
		Element = Color3.fromRGB(20,16,12), ElementHover = Color3.fromRGB(26,22,18),
		ElementStroke = Color3.fromRGB(44,38,30), Accent = Color3.fromRGB(255,180,30),
		AccentHover = Color3.fromRGB(255,200,60),
		Success = Color3.fromRGB(50,200,100), Warning = Color3.fromRGB(255,140,20),
		Error = Color3.fromRGB(230,50,50), Info = Color3.fromRGB(40,160,220),
		Toggle = Color3.fromRGB(38,32,26), ToggleEnabled = Color3.fromRGB(255,180,30),
		ToggleDisabled = Color3.fromRGB(54,48,42), CornerRadius = 6, ElementCornerRadius = 4, ToggleCornerRadius = 10,
	},
	Glass = {
		Text = Color3.fromRGB(230,230,240), TextSecondary = Color3.fromRGB(160,160,180),
		TextMuted = Color3.fromRGB(110,110,130), Background = Color3.fromRGB(12,14,24),
		BackgroundSecondary = Color3.fromRGB(18,20,32), BackgroundTertiary = Color3.fromRGB(24,26,38),
		Surface = Color3.fromRGB(26,28,42), SurfaceHover = Color3.fromRGB(32,34,50),
		Topbar = Color3.fromRGB(16,18,28), TopbarText = Color3.fromRGB(230,230,240),
		Tab = Color3.fromRGB(36,38,54), TabHover = Color3.fromRGB(44,46,64), TabActive = Color3.fromRGB(54,56,76),
		TabText = Color3.fromRGB(170,170,190), TabTextActive = Color3.fromRGB(255,255,255),
		Element = Color3.fromRGB(22,24,36), ElementHover = Color3.fromRGB(28,30,44),
		ElementStroke = Color3.fromRGB(46,48,64), Accent = Color3.fromRGB(100,150,255),
		AccentHover = Color3.fromRGB(120,170,255),
		Success = Color3.fromRGB(45,200,120), Warning = Color3.fromRGB(255,180,50),
		Error = Color3.fromRGB(235,80,80), Info = Color3.fromRGB(60,160,230),
		Toggle = Color3.fromRGB(40,42,58), ToggleEnabled = Color3.fromRGB(100,150,255),
		ToggleDisabled = Color3.fromRGB(56,58,74), CornerRadius = 14, ElementCornerRadius = 10, ToggleCornerRadius = 16,
	},
	Purple = {
		Text = Color3.fromRGB(230,225,240), TextSecondary = Color3.fromRGB(170,160,190),
		TextMuted = Color3.fromRGB(110,100,140), Background = Color3.fromRGB(20,16,30),
		BackgroundSecondary = Color3.fromRGB(26,22,38), BackgroundTertiary = Color3.fromRGB(32,28,46),
		Surface = Color3.fromRGB(36,30,50), SurfaceHover = Color3.fromRGB(42,36,58),
		Topbar = Color3.fromRGB(24,20,36), TopbarText = Color3.fromRGB(230,225,240),
		Tab = Color3.fromRGB(44,38,60), TabHover = Color3.fromRGB(52,46,70), TabActive = Color3.fromRGB(62,54,82),
		TabText = Color3.fromRGB(180,170,200), TabTextActive = Color3.fromRGB(255,255,255),
		Element = Color3.fromRGB(30,26,44), ElementHover = Color3.fromRGB(36,32,52),
		ElementStroke = Color3.fromRGB(50,44,66), Accent = Color3.fromRGB(160,80,255),
		AccentHover = Color3.fromRGB(180,100,255),
		Success = Color3.fromRGB(45,200,120), Warning = Color3.fromRGB(255,180,50),
		Error = Color3.fromRGB(235,80,80), Info = Color3.fromRGB(60,160,230),
		Toggle = Color3.fromRGB(48,42,66), ToggleEnabled = Color3.fromRGB(160,80,255),
		ToggleDisabled = Color3.fromRGB(62,56,80), CornerRadius = 10, ElementCornerRadius = 8, ToggleCornerRadius = 14,
	},
	Light = {
		Text = Color3.fromRGB(30,30,40), TextSecondary = Color3.fromRGB(90,90,100),
		TextMuted = Color3.fromRGB(140,140,150), Background = Color3.fromRGB(240,242,248),
		BackgroundSecondary = Color3.fromRGB(235,237,244), BackgroundTertiary = Color3.fromRGB(228,230,238),
		Surface = Color3.fromRGB(230,232,240), SurfaceHover = Color3.fromRGB(222,224,234),
		Topbar = Color3.fromRGB(235,237,244), TopbarText = Color3.fromRGB(30,30,40),
		Tab = Color3.fromRGB(220,222,232), TabHover = Color3.fromRGB(210,212,224), TabActive = Color3.fromRGB(200,202,216),
		TabText = Color3.fromRGB(100,100,115), TabTextActive = Color3.fromRGB(20,20,30),
		Element = Color3.fromRGB(232,234,242), ElementHover = Color3.fromRGB(224,226,236),
		ElementStroke = Color3.fromRGB(210,212,222), Accent = Color3.fromRGB(70,110,220),
		AccentHover = Color3.fromRGB(90,130,240),
		Success = Color3.fromRGB(40,170,100), Warning = Color3.fromRGB(220,160,40),
		Error = Color3.fromRGB(210,60,60), Info = Color3.fromRGB(50,140,210),
		Toggle = Color3.fromRGB(218,220,230), ToggleEnabled = Color3.fromRGB(70,110,220),
		ToggleDisabled = Color3.fromRGB(190,192,200), CornerRadius = 8, ElementCornerRadius = 6, ToggleCornerRadius = 12,
	},
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
	EventManager:Emit(EventManager.Events.ThemeChanged, theme, name); return true
end
function ThemeManager:OnThemeChanged(cb) table.insert(self._listeners, cb) end
function ThemeManager:RegisterTheme(name, data) if Themes[name] then return false end; self._customThemes[name] = data; return true end

-- 3.8 — Rendering Engine (FPS, Deferred, Layered, Redraw)
local Rendering = {}
local renderQueue = {}; local isRendering = false; local frameTime = 0; local fps = 60
RunService.RenderStepped:Connect(function(dt) frameTime = dt; fps = 1 / dt end)
function Rendering:GetFPS() return math.floor(fps) end
function Rendering:GetFrameTime() return frameTime * 1000 end
function Rendering:Defer(fn, prio)
	prio = prio or 0; table.insert(renderQueue, {Func = fn, Priority = prio})
	if not isRendering then
		isRendering = true
		task.spawn(function()
			table.sort(renderQueue, function(a,b) return a.Priority > b.Priority end)
			while #renderQueue > 0 do local item = table.remove(renderQueue,1); pcall(item.Func); task.wait() end
			isRendering = false
		end)
	end
end
local redrawQ = {}; local redrawScheduled = false
function Rendering:ScheduleRedraw(id, fn)
	redrawQ[id] = fn
	if not redrawScheduled then
		redrawScheduled = true
		task.spawn(function() task.wait(); redrawScheduled = false
			for id, fn in pairs(redrawQ) do pcall(fn); redrawQ[id] = nil end
		end)
	end
end

-- 3.9 — Blur Engine
local BlurEngine = {}
local blurs = {}
function BlurEngine:Attach(screenGui, intensity)
	intensity = intensity or 24
	local blur = Instance.new("ImageLabel")
	blur.Name = "EnhancedBlur"; blur.Size = UDim2.new(1,0,1,0); blur.BackgroundTransparency = 1
	blur.Image = "rbxassetid://3570695787"; blur.ImageTransparency = 1; blur.ZIndex = 9999; blur.Parent = screenGui
	table.insert(blurs, blur); return blur
end
function BlurEngine:SetIntensity(blur, val)
	if not blur then return end
	TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1 - (math.clamp(val, 0, 100) / 100)}):Play()
end
function BlurEngine:ClearAll() for _, b in ipairs(blurs) do pcall(function() b:Destroy() end) end; table.clear(blurs) end

-- 3.10 — Acrylic (Glassmorphism)
local Acrylic = {}
local acrylics = {}
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
	table.insert(acrylics, {Frame = frame, Shine = shine, Border = border})
end
function Acrylic:Remove(frame)
	for i, d in ipairs(acrylics) do if d.Frame == frame then pcall(function()d.Shine:Destroy()end); pcall(function()d.Border:Destroy()end); table.remove(acrylics,i); return end end
end
function Acrylic:ClearAll() for _, d in ipairs(acrylics) do pcall(function()d.Shine:Destroy()end); pcall(function()d.Border:Destroy()end) end; table.clear(acrylics) end

-- 3.11 — Notification Manager
local NotificationManager = {}
local notifQueue = {}; local processingNotifs = false; local activeNotifs = {}
function NotificationManager:Notify(data)
	data = data or {}
	local notify = {Title = data.Title or "Notification", Content = data.Content or "",
		Duration = data.Duration or 5, Icon = data.Icon or "", Color = data.Color or Color3.fromRGB(88,130,255),
		Type = data.Type or "Default", OnClick = data.OnClick}
	table.insert(notifQueue, notify)
	if not processingNotifs then self:ProcessQueue() end
	return tick()
end
function NotificationManager:ProcessQueue()
	processingNotifs = true
	task.spawn(function()
		while #notifQueue > 0 and #activeNotifs < 5 do
			local n = table.remove(notifQueue,1); self:ShowNotification(n); task.wait(0.15)
		end
		processingNotifs = false
	end)
end
function NotificationManager:ShowNotification(data)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0,320,0,0); notif.Position = UDim2.new(1,10,0,10)
	notif.BackgroundColor3 = Color3.fromRGB(20,20,28); notif.BackgroundTransparency = 0.15
	notif.ClipsDescendants = true; notif.ZIndex = 10000
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,10); corner.Parent = notif
	local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(55,55,68); stroke.Thickness = 1; stroke.Parent = notif
	local accent = Instance.new("Frame"); accent.Size = UDim2.new(0,3,1,0); accent.BackgroundColor3 = data.Color; accent.BorderSizePixel = 0; accent.Parent = notif
	local title = Instance.new("TextLabel"); title.Size = UDim2.new(1,-20,0,20); title.Position = UDim2.new(0,16,0,10); title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamSemibold; title.Text = data.Title; title.TextColor3 = Color3.fromRGB(230,230,240); title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 10001; title.Parent = notif
	local content = Instance.new("TextLabel"); content.Size = UDim2.new(1,-20,0,0); content.Position = UDim2.new(0,16,0,32); content.BackgroundTransparency = 1
	content.Font = Enum.Font.Gotham; content.Text = data.Content; content.TextColor3 = Color3.fromRGB(170,170,185); content.TextSize = 13; content.TextXAlignment = Enum.TextXAlignment.Left; content.TextWrapped = true; content.ZIndex = 10001; content.Parent = notif
	local h = math.max(60, content.TextBounds.Y + 50)
	notif.Size = UDim2.new(0,320,0,h)
	local shadow = Instance.new("ImageLabel"); shadow.Size = UDim2.new(1,20,1,20); shadow.Position = UDim2.new(0,-10,0,-10); shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5587865193"; shadow.ImageColor3 = Color3.fromRGB(0,0,0); shadow.ImageTransparency = 0.8; shadow.ScaleType = Enum.ScaleType.Slice; shadow.SliceCenter = Rect.new(10,10,118,118); shadow.ZIndex = 9999; shadow.Parent = notif
	local container = CoreGui:FindFirstChild("EnhancedNotifications")
	if not container then container = Instance.new("ScreenGui"); container.Name = "EnhancedNotifications"; container.DisplayOrder = 1000; container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; container.ResetOnSpawn = false; container.Parent = gethui and gethui() or CoreGui end
	notif.Parent = container; table.insert(activeNotifs, notif)
	local y = 10; for _, n in ipairs(activeNotifs) do if n == notif then break end; y = y + n.AbsoluteSize.Y + 8 end
	TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -330, 0, y), BackgroundTransparency = 0}):Play()
	if data.Duration and data.Duration > 0 then
		task.delay(data.Duration, function() self:Dismiss(notif) end)
	end
	if data.OnClick then notif.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then pcall(data.OnClick); self:Dismiss(notif) end end) end
end
function NotificationManager:Dismiss(notif)
	if not notif or not notif.Parent then return end
	for i, n in ipairs(activeNotifs) do if n == notif then table.remove(activeNotifs,i) break end end
	TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Position = UDim2.new(1,10,0,notif.Position.Y.Offset), BackgroundTransparency = 1}):Play()
	task.delay(0.4, function()
		pcall(function() notif:Destroy() end)
		local y = 10; for _, n in ipairs(activeNotifs) do TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(1,-330,0,y)}):Play(); y = y + n.AbsoluteSize.Y + 8 end
		if #notifQueue > 0 then NotificationManager:ProcessQueue() end
	end)
end

-- 3.12 — Mobile Manager
local MobileManager = {}
function MobileManager:IsMobile() return UserInputService.TouchEnabled end
function MobileManager:GetScale()
	local vp = workspace.CurrentCamera.ViewportSize
	if vp.X < 600 then return 0.65 elseif vp.X < 900 then return 0.8 elseif vp.X < 1200 then return 0.9 else return 1 end
end
function MobileManager:IsCompact() return workspace.CurrentCamera.ViewportSize.X < 700 end
function MobileManager:EnableDrag(obj, handle)
	handle = handle or obj; local dragging = false; local offset = Vector2.new()
	handle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dragging = true; offset = obj.AbsolutePosition - i.Position end end)
	handle.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
	obj.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.Touch then obj.Position = UDim2.fromOffset(i.Position.X + offset.X, i.Position.Y + offset.Y) end end)
end

-- 3.13 — Search Manager
local SearchManager = {}
function SearchManager:FuzzyMatch(text, pattern)
	if not pattern or #pattern == 0 then return true, 1 end
	text = text:lower(); pattern = pattern:lower()
	local pi = 1; local score = 0
	for ci = 1, #pattern do
		local pc = pattern:sub(ci,ci); local matched = false
		while pi <= #text do
			if text:sub(pi,pi) == pc then score = score + 1; matched = true; pi = pi + 1; break end; pi = pi + 1
		end
		if not matched then return false, 0 end
	end
	return true, score / #pattern
end

-- 3.14 — Dock Manager
local DockManager = {}
local docks = {}
function DockManager:CreateDock(config)
	config = config or {}
	local dock = {Id = config.Id or "dock_"..tick(), Buttons = {},
		_instances = {Container = Instance.new("ScreenGui")}}
	dock._instances.Container.Name = "EnhancedDock_"..dock.Id; dock._instances.Container.DisplayOrder = 500; dock._instances.Container.ResetOnSpawn = false
	dock._instances.Container.Parent = gethui and gethui() or CoreGui
	local frame = Instance.new("Frame"); frame.Name = "DockFrame"; frame.BackgroundColor3 = config.Color or Color3.fromRGB(32,32,40); frame.BackgroundTransparency = 0.2; frame.BorderSizePixel = 0
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,12); c.Parent = frame
	local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(55,55,68); s.Thickness = 1; s.Parent = frame
	local size = config.Size or 48; local pos = config.Position or "right"
	if pos == "right" then frame.Position = UDim2.new(1,-size-12,0.5,-(size*3)); frame.Size = UDim2.new(0,size,0,size*6)
	else frame.Position = UDim2.new(0,12,0.5,-(size*3)); frame.Size = UDim2.new(0,size,0,size*6) end
	frame.Parent = dock._instances.Container
	local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0,4); list.HorizontalAlignment = Enum.HorizontalAlignment.Center; list.VerticalAlignment = Enum.VerticalAlignment.Center; list.Parent = frame
	dock._instances.Frame = frame; docks[dock.Id] = dock; return dock
end
function DockManager:AddButton(dockId, config)
	local dock = docks[dockId]; if not dock then return nil end; config = config or {}
	local btn = Instance.new("ImageButton"); btn.Size = UDim2.new(0,36,0,36); btn.BackgroundTransparency = 1; btn.Image = config.Icon or ""; btn.ImageColor3 = config.Color or Color3.fromRGB(200,200,210)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = btn; btn.Parent = dock._instances.Frame
	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, Size = UDim2.new(0,40,0,40)}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, Size = UDim2.new(0,36,0,36)}):Play() end)
	if config.OnClick then btn.MouseButton1Click:Connect(function() pcall(config.OnClick) end) end
	return btn
end
function DockManager:RemoveDock(id) local d = docks[id]; if d then pcall(function() d._instances.Container:Destroy() end); docks[id] = nil end end
function DockManager:RemoveAll() for id,_ in pairs(docks) do self:RemoveDock(id) end end

-- 3.15 — Plugin Manager
local PluginManager = {_plugins = {}}
function PluginManager:Register(config)
	if not config.Name or self._plugins[config.Name] then return false end
	local plugin = {Name = config.Name, Version = config.Version or "1.0", Enabled = true,
		Init = config.Init or function() end, Cleanup = config.Cleanup or function() end}
	self._plugins[config.Name] = plugin
	local ok, err = pcall(plugin.Init); if not ok then plugin.Enabled = false; warn("Plugin '"..config.Name.."' failed:", err) end; return plugin
end
function PluginManager:Get(name) return self._plugins[name] end

-- 3.16 — Config Manager
local ConfigManager = {_flags = {}, _currentProfile = "Default", _listeners = {}}
local CFG_FOLDER = "RayfieldEnhanced/Configs"
pcall(function() if isfolder and not isfolder("RayfieldEnhanced") then makefolder("RayfieldEnhanced") end; if isfolder and not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end end)
function ConfigManager:RegisterFlag(name, value) self._flags[name] = value end
function ConfigManager:GetFlag(name) return self._flags[name] end
function ConfigManager:SetFlag(name, value) self._flags[name] = value; return value end
function ConfigManager:Save(profile)
	profile = profile or self._currentProfile; local data = {}
	for n, v in pairs(self._flags) do
		if typeof(v) == "Color3" then data[n] = {R = v.R * 255, G = v.G * 255, B = v.B * 255}
		else data[n] = v end
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
	for n, v in pairs(data) do if type(v) == "table" and v.R then self._flags[n] = Color3.fromRGB(v.R, v.G, v.B) else self._flags[n] = v end end
	return true
end
function ConfigManager:Export() return HttpService:JSONEncode(self._flags) end

-- ============================================================
-- 	PHASE 4: INTEGRATION LAYER
-- ============================================================

local EnhancedLib = {}

-- Expose all systems
EnhancedLib.Core = RayfieldCore
EnhancedLib.Signals = Signals
EnhancedLib.Springs = Springs
EnhancedLib.Cache = Cache
EnhancedLib.EventManager = EventManager
EnhancedLib.Performance = Performance
EnhancedLib.Animations = AnimEngine
EnhancedLib.ThemeManager = ThemeManager
EnhancedLib.Rendering = Rendering
EnhancedLib.BlurEngine = BlurEngine
EnhancedLib.Acrylic = Acrylic
EnhancedLib.NotificationManager = NotificationManager
EnhancedLib.MobileManager = MobileManager
EnhancedLib.SearchManager = SearchManager
EnhancedLib.DockManager = DockManager
EnhancedLib.PluginManager = PluginManager
EnhancedLib.ConfigManager = ConfigManager

-- ============================================================
-- 	MODERN WRAPPER API
-- ============================================================

function EnhancedLib:CreateWindow(config)
	config = config or {}

	local window = RayfieldCore:CreateWindow({
		Name = config.Title or config.Name or "Rayfield Enhanced",
		Icon = config.Icon or 0,
		LoadingTitle = config.LoadingTitle or config.Title or "Rayfield Enhanced",
		LoadingSubtitle = config.LoadingSubtitle or "Next-Gen UI Library",
		Theme = "Default",
		DisableRayfieldPrompts = config.DisableRayfieldPrompts or false,
		DisableBuildWarnings = true,
		ToggleUIKeybind = config.ToggleKeybind or config.ToggleUIKeybind or "K",
		ConfigurationSaving = config.ConfigurationSaving or { Enabled = false },
		Discord = config.Discord or { Enabled = false },
		KeySystem = config.KeySystem or false,
		KeySettings = config.KeySettings,
	})

	if config.Theme and config.Theme ~= "Default" then
		pcall(function() window.ModifyTheme(config.Theme) end)
		ThemeManager:ApplyTheme(config.Theme)
	end

	-- Enhanced window with chainable API
	local enhancedWindow = {_window = window, _config = config, _tabs = {}}

	function enhancedWindow:Tab(config)
		if type(config) == "string" then config = { Name = config, Icon = 0 } end
		local tab = window:CreateTab(config.Name, config.Icon or 0)
		local enhancedTab = {_tab = tab, _elements = {}}

		function enhancedTab:Section(name) tab:CreateSection(name); return enhancedTab end
		function enhancedTab:Button(c) tab:CreateButton({Name = c.Name, Callback = c.Callback or function() end}); return enhancedTab end
		function enhancedTab:Toggle(c)
			tab:CreateToggle({Name = c.Name, CurrentValue = c.Default or false, Flag = c.Flag or c.Name, Callback = c.Callback or function() end})
			return enhancedTab
		end
		function enhancedTab:Slider(c)
			tab:CreateSlider({Name = c.Name, Range = c.Range or {0,100}, Increment = c.Increment or 1, Suffix = c.Suffix or "", CurrentValue = c.Default or 0, Flag = c.Flag or c.Name, Callback = c.Callback or function() end})
			return enhancedTab
		end
		function enhancedTab:Input(c)
			tab:CreateInput({Name = c.Name, CurrentValue = c.Default or "", PlaceholderText = c.Placeholder or "Digite aqui...", Flag = c.Flag or c.Name, RemoveTextAfterFocusLost = c.ClearOnFocus or false, Callback = c.Callback or function() end})
			return enhancedTab
		end
		function enhancedTab:Dropdown(c)
			tab:CreateDropdown({Name = c.Name, Options = c.Options or {}, CurrentOption = c.Default and {c.Default} or {}, MultipleOptions = c.Multiple or false, Flag = c.Flag or c.Name, Callback = c.Callback or function() end})
			return enhancedTab
		end
		function enhancedTab:Keybind(c)
			tab:CreateKeybind({Name = c.Name, CurrentKeybind = c.Default or "F", HoldToInteract = c.Hold or false, Flag = c.Flag or c.Name, Callback = c.Callback or function() end})
			return enhancedTab
		end
		function enhancedTab:ColorPicker(c)
			tab:CreateColorPicker({Name = c.Name, Color = c.Default or Color3.fromRGB(255,255,255), Flag = c.Flag or c.Name, Callback = c.Callback or function() end})
			return enhancedTab
		end
		function enhancedTab:Label(text, icon, color) tab:CreateLabel(text, icon or 0, color); return enhancedTab end
		function enhancedTab:Paragraph(c) tab:CreateParagraph({Title = c.Title or "", Content = c.Content or ""}); return enhancedTab end
		function enhancedTab:Divider() tab:CreateDivider(); return enhancedTab end

		table.insert(self._tabs, enhancedTab)
		return enhancedTab
	end

	task.delay(2, function()
		if RayfieldCore.LoadConfiguration then RayfieldCore:LoadConfiguration() end
	end)

	return enhancedWindow
end

-- Backward compatibility
EnhancedLib.Flags = RayfieldCore.Flags
EnhancedLib.Notify = RayfieldCore.Notify
EnhancedLib.Theme = RayfieldCore.Theme
EnhancedLib.LoadConfiguration = RayfieldCore.LoadConfiguration
EnhancedLib.SetVisibility = RayfieldCore.SetVisibility
EnhancedLib.IsVisible = RayfieldCore.IsVisible
EnhancedLib.Destroy = RayfieldCore.Destroy

function EnhancedLib:ModifyTheme(name)
	if name and ThemeManager:GetTheme(name) then ThemeManager:ApplyTheme(name) end
	RayfieldCore:ModifyTheme(name or "Default")
end

function EnhancedLib:Notify(data)
	RayfieldCore:Notify(data)
end

-- ============================================================
-- 	RETURN
-- ============================================================

return EnhancedLib
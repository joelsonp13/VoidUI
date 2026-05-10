-- [[
-- 	Rayfield Enhanced — Animations.lua
-- 	Advanced animation engine with springs, easing, and interpolation
-- ]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Springs = require(script.Parent.Parent.Utils.Springs)

local Animations = {}

-- ============================================================
-- 	EASING FUNCTIONS
-- ============================================================

local Easing = {}

function Easing.Linear(t) return t end
function Easing.QuadIn(t) return t * t end
function Easing.QuadOut(t) return t * (2 - t) end
function Easing.QuadInOut(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end
function Easing.CubicIn(t) return t * t * t end
function Easing.CubicOut(t) return (t - 1) ^ 3 + 1 end
function Easing.CubicInOut(t) return t < 0.5 and 4 * t ^ 3 or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1 end
function Easing.QuartIn(t) return t * t * t * t end
function Easing.QuartOut(t) return (t - 1) ^ 4 + 1 end
function Easing.QuintIn(t) return t * t * t * t * t end
function Easing.QuintOut(t) return (t - 1) ^ 5 + 1 end
function Easing.SineIn(t) return 1 - math.cos(t * math.pi / 2) end
function Easing.SineOut(t) return math.sin(t * math.pi / 2) end
function Easing.SineInOut(t) return -(math.cos(math.pi * t) - 1) / 2 end
function Easing.ExpoIn(t) return t == 0 and 0 or 2 ^ (10 * t - 10) end
function Easing.ExpoOut(t) return t == 1 and 1 or 1 - 2 ^ (-10 * t) end
function Easing.ElasticOut(t)
	if t == 0 or t == 1 then return t end
	local p = 0.3
	return 2 ^ (-10 * t) * math.sin((t - p / 4) * (2 * math.pi) / p) + 1
end
function Easing.ElasticIn(t)
	if t == 0 or t == 1 then return t end
	local p = 0.3
	return -(2 ^ (10 * (t - 1)) * math.sin((t - 1 - p / 4) * (2 * math.pi) / p))
end
function Easing.BackIn(t) local s = 1.70158 return t * t * ((s + 1) * t - s) end
function Easing.BackOut(t) local s = 1.70158 return (t - 1) ^ 2 * ((s + 1) * (t - 1) + s) + 1 end
function Easing.BounceOut(t)
	if t < 1 / 2.75 then return 7.5625 * t * t
	elseif t < 2 / 2.75 then t = t - 1.5 / 2.75 return 7.5625 * t * t + 0.75
	elseif t < 2.5 / 2.75 then t = t - 2.25 / 2.75 return 7.5625 * t * t + 0.9375
	else t = t - 2.625 / 2.75 return 7.5625 * t * t + 0.984375 end
end
function Easing.BounceIn(t) return 1 - Easing.BounceOut(1 - t) end

Animations.Easing = Easing

-- ============================================================
-- 	SPRING ANIMATION
-- ============================================================

function Animations.Spring(initialValue, config)
	return Springs.new(initialValue, config)
end

-- ============================================================
-- 	TWEEN ANIMATION (Enhanced)
-- ============================================================

function Animations.Tween(obj, props, duration, easing, callback)
	if not obj then return end

	local info
	if type(duration) == "number" then
		local easingStyle = Enum.EasingStyle.Quad
		if easing then
			if type(easing) == "string" then
				local easingMap = {
					Linear = Enum.EasingStyle.Linear,
					Quad = Enum.EasingStyle.Quad,
					Cubic = Enum.EasingStyle.Cubic,
					Quart = Enum.EasingStyle.Quart,
					Quint = Enum.EasingStyle.Quint,
					Sine = Enum.EasingStyle.Sine,
					Expo = Enum.EasingStyle.Exponential,
					Elastic = Enum.EasingStyle.Elastic,
					Back = Enum.EasingStyle.Back,
					Bounce = Enum.EasingStyle.Bounce,
					Circ = Enum.EasingStyle.Circular,
				}
				easingStyle = easingMap[easing] or Enum.EasingStyle.Quad
			elseif typeof(easing) == "EnumItem" then
				easingStyle = easing
			end
		end
		info = TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out)
	elseif typeof(duration) == "TweenInfo" then
		info = duration
	else
		info = TweenInfo.new(0.3)
	end

	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	if callback then
		tween.Completed:Connect(callback)
	end
	return tween
end

-- ============================================================
-- 	LERP / INTERPOLATION
-- ============================================================

function Animations.Lerp(a, b, t)
	return a + (b - a) * t
end

function Animations.LerpColor(a, b, t)
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end

function Animations.LerpUDim(a, b, t)
	return UDim.new(
		a.Scale + (b.Scale - a.Scale) * t,
		a.Offset + (b.Offset - a.Offset) * t
	)
end

function Animations.LerpUDim2(from, to, t)
	return UDim2.new(
		from.X.Scale + (to.X.Scale - from.X.Scale) * t,
		from.X.Offset + (to.X.Offset - from.X.Offset) * t,
		from.Y.Scale + (to.Y.Scale - from.Y.Scale) * t,
		from.Y.Offset + (to.Y.Offset - from.Y.Offset) * t
	)
end

function Animations.LerpVector2(from, to, t)
	return Vector2.new(
		from.X + (to.X - from.X) * t,
		from.Y + (to.Y - from.Y) * t
	)
end

function Animations.LerpVector3(from, to, t)
	return Vector3.new(
		from.X + (to.X - from.X) * t,
		from.Y + (to.Y - from.Y) * t,
		from.Z + (to.Z - from.Z) * t
	)
end

-- ============================================================
-- 	RIPPLE EFFECT (Click ripple)
-- ============================================================

local RipplePool = {}

function Animations.RippleClick(guiObject, color, duration)
	if not guiObject then return end
	color = color or Color3.fromRGB(255, 255, 255)
	duration = duration or 0.6

	-- Get or create ripple object
	local ripple = table.remove(RipplePool)
	if not ripple then
		ripple = Instance.new("ImageLabel")
		ripple.Image = "rbxassetid://3570695787"
		ripple.BackgroundTransparency = 1
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
		ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		ripple.ZIndex = 1000
	end

	ripple.Parent = guiObject
	ripple.ImageColor3 = color
	ripple.ImageTransparency = 0.8
	ripple.Size = UDim2.new(0, 0, 0, 0)

	-- Animate
	local maxSize = math.max(guiObject.AbsoluteSize.X, guiObject.AbsoluteSize.Y) * 1.5
	TweenService:Create(ripple, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, maxSize, 0, maxSize),
		ImageTransparency = 1,
	}):Play()

	task.delay(duration, function()
		ripple.Parent = nil
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.ImageTransparency = 0.8
		table.insert(RipplePool, ripple)
	end)

	return ripple
end

-- ============================================================
-- 	OPACITY FADE
-- ============================================================

function Animations.FadeIn(guiObject, duration, callback)
	duration = duration or 0.3
	guiObject.Visible = true
	local tween = TweenService:Create(guiObject, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	})
	tween:Play()
	if callback then tween.Completed:Connect(callback) end
	return tween
end

function Animations.FadeOut(guiObject, duration, callback)
	duration = duration or 0.3
	local tween = TweenService:Create(guiObject, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	})
	tween:Play()
	if callback then
		tween.Completed:Connect(function()
			guiObject.Visible = false
			callback()
		end)
	else
		tween.Completed:Connect(function()
			guiObject.Visible = false
		end)
	end
	return tween
end

-- ============================================================
-- 	SCALE ANIMATION
-- ============================================================

function Animations.ScaleIn(guiObject, duration, callback)
	duration = duration or 0.4
	guiObject.Visible = true
	guiObject.Size = UDim2.new(0, 0, 0, 0)
	local tween = TweenService:Create(guiObject, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0),
	})
	tween:Play()
	if callback then tween.Completed:Connect(callback) end
	return tween
end

-- ============================================================
-- 	SLIDE ANIMATION
-- ============================================================

function Animations.SlideIn(guiObject, direction, distance, duration, callback)
	duration = duration or 0.5
	distance = distance or 50
	local originalPos = guiObject.Position

	local offset
	if direction == "up" then offset = UDim2.new(0, 0, 0, distance)
	elseif direction == "down" then offset = UDim2.new(0, 0, 0, -distance)
	elseif direction == "left" then offset = UDim2.new(0, distance, 0, 0)
	elseif direction == "right" then offset = UDim2.new(0, -distance, 0, 0)
	end

	guiObject.Position = originalPos + offset
	guiObject.Visible = true

	local tween = TweenService:Create(guiObject, TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Position = originalPos,
	})
	tween:Play()
	if callback then tween.Completed:Connect(callback) end
	return tween
end

-- ============================================================
-- 	HOVER EFFECT
-- ============================================================

function Animations.HoverScale(guiObject, scale, duration)
	scale = scale or 1.05
	duration = duration or 0.2

	local connections = {}

	local function onEnter()
		TweenService:Create(guiObject, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(scale, 0, scale, 0),
		}):Play()
	end

	local function onLeave()
		TweenService:Create(guiObject, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 1, 0),
		}):Play()
	end

	connections.MouseEnter = guiObject.MouseEnter:Connect(onEnter)
	connections.MouseLeave = guiObject.MouseLeave:Connect(onLeave)

	return connections
end

function Animations.HoverGlow(guiObject, glowColor, duration)
	glowColor = glowColor or Color3.fromRGB(88, 130, 255)
	duration = duration or 0.3

	local connections = {}

	-- Expects a glow ImageLabel or ImageButton child
	local glow = guiObject:FindFirstChild("Glow") or guiObject:FindFirstChild("ShadowGlow")

	local function onEnter()
		if glow then
			TweenService:Create(glow, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 0.3,
				ImageColor3 = glowColor,
			}):Play()
		end
	end

	local function onLeave()
		if glow then
			TweenService:Create(glow, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 0.8,
			}):Play()
		end
	end

	connections.MouseEnter = guiObject.MouseEnter:Connect(onEnter)
	connections.MouseLeave = guiObject.MouseLeave:Connect(onLeave)

	return connections
end

-- ============================================================
-- 	ANIMATION QUEUE
-- ============================================================

local AnimQueue = {}
AnimQueue.__index = AnimQueue

function Animations.Queue()
	return setmetatable({
		_animations = {},
		_running = false,
	}, AnimQueue)
end

function AnimQueue:Add(func)
	table.insert(self._animations, func)
	return self
end

function AnimQueue:Play()
	if self._running then return end
	self._running = true
	self:_playNext()
end

function AnimQueue:_playNext()
	if #self._animations == 0 then
		self._running = false
		return
	end
	local nextAnim = table.remove(self._animations, 1)
	nextAnim(function()
		self:_playNext()
	end)
end

-- ============================================================
-- 	RENDER CONNECTION MANAGER
-- ============================================================

function Animations.RenderStepped(callback)
	return RunService.RenderStepped:Connect(callback)
end

function Animations.Heartbeat(callback)
	return RunService.Heartbeat:Connect(callback)
end

return Animations
-- [[
-- 	Rayfield Enhanced — Springs.lua
-- 	Spring animation engine for ultra-smooth animations
-- 	Inspired by React Spring / Framer Motion
-- ]]

local Springs = {}
Springs.__index = Springs

-- Physical spring parameters
local DEFAULTS = {
	frequency = 2.5,  -- How bouncy (lower = more bouncy)
	damping = 0.7,    -- How fast it settles (lower = more wobble)
	mass = 1,
	precision = 0.001,
}

-- Creates a spring value that can be animated
function Springs.new(initialValue, config)
	config = config or {}
	local self = setmetatable({
		_value = initialValue,
		_velocity = 0,
		_target = initialValue,
		_frequency = config.frequency or DEFAULTS.frequency,
		_damping = config.damping or DEFAULTS.damping,
		_mass = config.mass or DEFAULTS.mass,
		_precision = config.precision or DEFAULTS.precision,
		_isAnimating = false,
		_onUpdate = nil,
		_onComplete = nil,
		_connections = {},
	}, Springs)
	return self
end

-- Set target value and start animation
function Springs:to(target)
	self._target = target
	self._isAnimating = true
	return self
end

-- Snap instantly to value
function Springs:snap(value)
	self._value = value
	self._target = value
	self._velocity = 0
	self._isAnimating = false
	if self._onUpdate then
		self._onUpdate(value)
	end
	return self
end

-- Step the physics simulation (call every frame via RenderStepped)
function Springs:step(dt)
	if not self._isAnimating then return self._value end

	dt = math.min(dt, 0.1) -- Cap delta time

	local freq = self._frequency * math.pi * 2
	local damping = self._damping
	local mass = self._mass

	local displacement = self._value - self._target
	local springForce = -(freq * freq) * displacement
	local dampingForce = -2 * damping * freq * self._velocity

	local acceleration = (springForce + dampingForce) / mass
	self._velocity = self._velocity + acceleration * dt
	self._value = self._value + self._velocity * dt

	if self._onUpdate then
		self._onUpdate(self._value)
	end

	-- Check if settled
	if math.abs(self._velocity) < self._precision and math.abs(displacement) < self._precision then
		self._value = self._target
		self._velocity = 0
		self._isAnimating = false
		if self._onUpdate then
			self._onUpdate(self._value)
		end
		if self._onComplete then
			self._onComplete(self._value)
		end
	end

	return self._value
end

-- Chain: onUpdate callback
function Springs:onUpdate(callback)
	self._onUpdate = callback
	return self
end

-- Chain: onComplete callback
function Springs:onComplete(callback)
	self._onComplete = callback
	return self
end

-- Get current value
function Springs:get()
	return self._value
end

-- Get target value
function Springs:target()
	return self._target
end

-- Check if still animating
function Springs:isAnimating()
	return self._isAnimating
end

-- Kill animation
function Springs:stop()
	self._isAnimating = false
	return self
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- 	SpringGroup — animate multiple springs together
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local SpringGroup = {}
SpringGroup.__index = SpringGroup

function Springs.group(springs)
	return setmetatable({
		_springs = springs or {},
	}, SpringGroup)
end

function SpringGroup:to(values)
	for i, spring in ipairs(self._springs) do
		spring:to(values[i] or spring._target)
	end
	return self
end

function SpringGroup:step(dt)
	local results = {}
	for i, spring in ipairs(self._springs) do
		results[i] = spring:step(dt)
	end
	return results
end

return Springs
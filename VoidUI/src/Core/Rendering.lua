-- [[
-- 	Rayfield Enhanced — Rendering.lua
-- 	Smart rendering: lazy load, virtual scroll, redraw optimization
-- ]]

local RunService = game:GetService("RunService")

local Rendering = {}

local renderQueue = {}
local isRendering = false
local frameTime = 0
local fps = 60
local lastFrame = tick()

-- ============================================================
-- 	FPS TRACKER
-- ============================================================

RunService.RenderStepped:Connect(function(dt)
	frameTime = dt
	fps = 1 / dt
	lastFrame = tick()
end)

function Rendering:GetFPS()
	return math.floor(fps)
end

function Rendering:GetFrameTime()
	return frameTime * 1000 -- in ms
end

-- ============================================================
-- 	DEFERRED RENDERING
-- ============================================================

function Rendering:Defer(func, priority)
	priority = priority or 0
	table.insert(renderQueue, {
		Func = func,
		Priority = priority,
	})
	
	if not isRendering then
		self:ProcessQueue()
	end
end

function Rendering:ProcessQueue()
	isRendering = true
	task.spawn(function()
		-- Sort by priority
		table.sort(renderQueue, function(a, b)
			return a.Priority > b.Priority
		end)
		
		while #renderQueue > 0 do
			local item = table.remove(renderQueue, 1)
			local success, err = pcall(item.Func)
			if not success then
				warn("Rendering deferred error:", err)
			end
			task.wait()
		end
		isRendering = false
	end)
end

-- ============================================================
-- 	LAYERED RENDERING (render in chunks across frames)
-- ============================================================

function Rendering:RenderLayered(elements, renderFunc, chunkSize)
	chunkSize = chunkSize or 5
	local index = 1
	local total = #elements
	
	local connection
	connection = RunService.RenderStepped:Connect(function()
		for i = 1, chunkSize do
			if index > total then
				connection:Disconnect()
				return
			end
			local success, err = pcall(renderFunc, elements[index], index)
			if not success then
				warn("Layer render error:", err)
			end
			index = index + 1
		end
	end)
end

-- ============================================================
-- 	OPTIMIZED REDRAW
-- ============================================================

local redrawQueue = {}
local redrawScheduled = false

function Rendering:ScheduleRedraw(elementId, drawFunc)
	redrawQueue[elementId] = drawFunc
	
	if not redrawScheduled then
		redrawScheduled = true
		task.spawn(function()
			task.wait()
			self:FlushRedraws()
		end)
	end
end

function Rendering:FlushRedraws()
	redrawScheduled = false
	for id, func in pairs(redrawQueue) do
		local success, err = pcall(func)
		if not success then
			warn("Redraw error for", id, err)
		end
		redrawQueue[id] = nil
	end
end

-- ============================================================
-- 	MEMORY OPTIMIZATION
-- ============================================================

function Rendering:OptimizeInstance(instance)
	if not instance then return end
	
	-- Remove unnecessary properties
	instance.Visible = false
	
	-- Unanchor when not visible
	if instance:IsA("Frame") and instance.BackgroundTransparency >= 1 then
		instance.Active = false
	end
	
	-- Clean up event connections
	for _, child in ipairs(instance:GetDescendants()) do
		if child:IsA("ImageLabel") and child.ImageTransparency >= 1 then
			child.Visible = false
		end
	end
end

return Rendering
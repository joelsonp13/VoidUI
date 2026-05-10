-- [[
-- 	Rayfield Enhanced — Performance.lua
-- 	Optimization engine: pooling, batching, virtualization, lazy rendering
-- ]]

local Performance = {}
local RunService = game:GetService("RunService")

-- ============================================================
-- 	OBJECT POOL
-- ============================================================

local Pools = {}

function Performance.CreatePool(poolName, factory, resetFunction, initialSize)
	initialSize = initialSize or 10
	Pools[poolName] = {
		Objects = {},
		Factory = factory,
		Reset = resetFunction,
	}
	for i = 1, initialSize do
		local obj = factory()
		table.insert(Pools[poolName].Objects, obj)
	end
	return Pools[poolName]
end

function Performance.GetFromPool(poolName, ...)
	local pool = Pools[poolName]
	if not pool then return nil end
	local obj = table.remove(pool.Objects)
	if not obj then
		obj = pool.Factory(...)
	elseif pool.Reset then
		pool.Reset(obj, ...)
	end
	return obj
end

function Performance.ReturnToPool(poolName, obj)
	local pool = Pools[poolName]
	if not pool then return end
	table.insert(pool.Objects, obj)
end

function Performance.ClearPool(poolName)
	local pool = Pools[poolName]
	if not pool then return end
	for _, obj in ipairs(pool.Objects) do
		pcall(function() obj:Destroy() end)
	end
	table.clear(pool.Objects)
end

-- ============================================================
-- 	UPDATE BATCHING
-- ============================================================

local batchedUpdates = {}
local isFlushing = false

function Performance.BatchUpdate(componentId, updateFunc)
	if not batchedUpdates[componentId] then
		batchedUpdates[componentId] = updateFunc
		if not isFlushing then
			isFlushing = true
			task.spawn(function()
				task.wait()
				Performance.FlushUpdates()
			end)
		end
	end
end

function Performance.FlushUpdates()
	isFlushing = false
	for id, func in pairs(batchedUpdates) do
		pcall(func)
		batchedUpdates[id] = nil
	end
end

-- ============================================================
-- 	VIRTUALIZATION — Only render visible elements
-- ============================================================

local virtualContainers = {}

function Performance.EnableVirtualization(scrollingFrame)
	if not scrollingFrame then return end
	
	local container = {
		ScrollingFrame = scrollingFrame,
		Elements = {},
		isUpdating = false,
	}

	function container:Update()
		if self.isUpdating then return end
		self.isUpdating = true

		task.spawn(function()
			local viewPos = scrollingFrame.CanvasPosition.Y
			local viewSize = scrollingFrame.AbsoluteWindowSize.Y
			local buffer = 100

			for _, elem in ipairs(self.Elements) do
				local elemPos = elem.Instance.AbsolutePosition.Y - scrollingFrame.AbsolutePosition.Y
				local visible = (elemPos + elem.Height > -buffer) and (elemPos < viewSize + buffer)
				if elem.Instance.Visible ~= visible then
					elem.Instance.Visible = visible
				end
			end
			self.isUpdating = false
		end)
	end

	scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		container:Update()
	end)

	virtualContainers[scrollingFrame] = container
	return container
end

function Performance.RegisterVirtualElement(container, instance, height)
	table.insert(container.Elements, {
		Instance = instance,
		Height = height or instance.AbsoluteSize.Y,
	})
end

-- ============================================================
-- 	LAZY RENDERING
-- ============================================================

local lazyElements = {}

function Performance.LazyRender(instance, buildFunction, condition)
	lazyElements[instance] = {
		Build = buildFunction,
		Condition = condition or function() return true end,
		Built = false,
	}
	return instance
end

function Performance.CheckLazyElements()
	for instance, data in pairs(lazyElements) do
		if not data.Built then
			if data.Condition(instance) then
				pcall(data.Build, instance)
				data.Built = true
			end
		end
	end
end

-- ============================================================
-- 	MEMORY MANAGEMENT
-- ============================================================

function Performance.GarbageCollect()
	for poolName, pool in pairs(Pools) do
		if #pool.Objects > 100 then
			while #pool.Objects > 50 do
				local obj = table.remove(pool.Objects)
				pcall(function() obj:Destroy() end)
			end
		end
	end
end

-- Periodic GC
task.spawn(function()
	while task.wait(60) do
		Performance.GarbageCollect()
	end
end)

return Performance
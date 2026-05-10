-- [[
-- 	Rayfield Enhanced — EventManager.lua
-- 	Central event system for components communication
-- ]]

local EventManager = {}
EventManager.__index = EventManager

local events = {}
local eventIdCounter = 0

-- ============================================================
-- 	EVENT SYSTEM
-- ============================================================

function EventManager:On(eventName, callback)
	if not events[eventName] then
		events[eventName] = {}
	end
	eventIdCounter = eventIdCounter + 1
	local id = eventIdCounter
	table.insert(events[eventName], {Id = id, Callback = callback})
	return id
end

function EventManager:Once(eventName, callback)
	local wrapper
	local id
	wrapper = function(...)
		callback(...)
		EventManager:Off(eventName, id)
	end
	id = EventManager:On(eventName, wrapper)
	return id
end

function EventManager:Off(eventName, id)
	if not events[eventName] then return end
	for i, listener in ipairs(events[eventName]) do
		if listener.Id == id then
			table.remove(events[eventName], i)
			return
		end
	end
end

function EventManager:Emit(eventName, ...)
	if not events[eventName] then return end
	for _, listener in ipairs(events[eventName]) do
		task.spawn(listener.Callback, ...)
	end
end

function EventManager:ClearEvent(eventName)
	events[eventName] = nil
end

function EventManager:ClearAll()
	table.clear(events)
end

-- ============================================================
-- 	SIGNAL (custom bindable event)
-- ============================================================

local Signal = {}
Signal.__index = Signal

function EventManager.Signal()
	return setmetatable({
		_listeners = {},
	}, Signal)
end

function Signal:Connect(callback)
	table.insert(self._listeners, callback)
	return callback
end

function Signal:Fire(...)
	for _, callback in ipairs(self._listeners) do
		task.spawn(callback, ...)
	end
end

function Signal:Disconnect(callback)
	for i, cb in ipairs(self._listeners) do
		if cb == callback then
			table.remove(self._listeners, i)
			return
		end
	end
end

function Signal:DisconnectAll()
	table.clear(self._listeners)
end

-- ============================================================
-- 	BUILT-IN EVENTS
-- ============================================================

-- Predefined events for the UI library
EventManager.Events = {
	WindowCreated = "window_created",
	WindowDestroyed = "window_destroyed",
	WindowHidden = "window_hidden",
	WindowShown = "window_shown",
	TabChanged = "tab_changed",
	ThemeChanged = "theme_changed",
	ConfigLoaded = "config_loaded",
	ConfigSaved = "config_saved",
	Notify = "notify",
	SearchOpened = "search_opened",
	SearchClosed = "search_closed",
	MobileLayout = "mobile_layout",
	PluginRegistered = "plugin_registered",
	BeforeRender = "before_render",
	AfterRender = "after_render",
}

return EventManager
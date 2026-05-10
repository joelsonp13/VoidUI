-- [[
-- 	Rayfield Enhanced — Signals.lua
-- 	Custom signal/bindable event system with type safety
-- ]]

local Signals = {}

local Signal = {}
Signal.__index = Signal

-- ============================================================
-- 	SIGNAL CONSTRUCTOR
-- ============================================================

function Signals.new()
	return setmetatable({
		_listeners = {},
		_onceListeners = {},
		_connected = true,
	}, Signal)
end

-- ============================================================
-- 	METHODS
-- ============================================================

function Signal:Connect(callback)
	if not self._connected then return nil end
	
	local connection = {
		Callback = callback,
		Connected = true,
		Signal = self,
	}
	
	table.insert(self._listeners, connection)
	
	-- Return disconnect function
	return {
		Disconnect = function()
			connection.Connected = false
			for i, v in ipairs(self._listeners) do
				if v == connection then
					table.remove(self._listeners, i)
					return
				end
			end
		end,
		Connected = function()
			return connection.Connected
		end,
	}
end

function Signal:Once(callback)
	if not self._connected then return nil end
	
	local wrapper
	local connection
	
	wrapper = function(...)
		callback(...)
		if connection and connection.Disconnect then
			connection:Disconnect()
		end
	end
	
	connection = self:Connect(wrapper)
	return connection
end

function Signal:Fire(...)
	if not self._connected then return end
	
	for _, listener in ipairs(self._listeners) do
		if listener.Connected then
			task.spawn(listener.Callback, ...)
		end
	end
end

function Signal:Wait()
	if not self._connected then return end
	
	local event = Instance.new("BindableEvent")
	local connection
	
	connection = self:Connect(function(...)
		event:Fire(...)
		connection:Disconnect()
	end)
	
	return event.Event:Wait()
end

function Signal:DisconnectAll()
	table.clear(self._listeners)
	table.clear(self._onceListeners)
end

function Signal:Destroy()
	self:DisconnectAll()
	self._connected = false
end

-- ============================================================
-- 	GET LISTENER COUNT
-- ============================================================

function Signal:GetListenerCount()
	return #self._listeners
end

-- ============================================================
-- 	FACTORY FOR MULTIPLE SIGNALS
-- ============================================================

function Signals.createTable(signalNames)
	local tbl = {}
	for _, name in ipairs(signalNames) do
		tbl[name] = Signals.new()
	end
	return tbl
end

return Signals
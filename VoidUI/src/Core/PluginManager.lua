-- [[
-- 	Rayfield Enhanced — PluginManager.lua
-- 	Extension/plugin system for third-party components
-- ]]

local PluginManager = {}
PluginManager.__index = PluginManager

local registeredPlugins = {}
local hooks = {}
local libraryRef = nil

-- ============================================================
-- 	PLUGIN SYSTEM
-- ============================================================

function PluginManager:RegisterPlugin(config)
	if not config.Name then
		warn("PluginManager: Plugin must have a Name")
		return false
	end
	if registeredPlugins[config.Name] then
		warn("PluginManager: Plugin '" .. config.Name .. "' already registered")
		return false
	end

	local plugin = {
		Name = config.Name,
		Version = config.Version or "1.0",
		Description = config.Description or "",
		Author = config.Author or "Unknown",
		Hooks = {},
		Init = config.Init or function() end,
		Cleanup = config.Cleanup or function() end,
		Enabled = true,
	}

	registeredPlugins[config.Name] = plugin

	-- Initialize plugin with library reference
	if libraryRef then
		local success, err = pcall(plugin.Init, libraryRef, plugin)
		if not success then
			warn("PluginManager: Plugin '" .. config.Name .. "' init failed: " .. tostring(err))
			plugin.Enabled = false
			return false
		end
	end

	return plugin
end

function PluginManager:UnregisterPlugin(name)
	local plugin = registeredPlugins[name]
	if not plugin then return false end
	pcall(plugin.Cleanup)
	registeredPlugins[name] = nil
	return true
end

function PluginManager:GetPlugin(name)
	return registeredPlugins[name]
end

function PluginManager:GetAllPlugins()
	return registeredPlugins
end

function PluginManager:SetLibrary(lib)
	libraryRef = lib
end

-- ============================================================
-- 	HOOK SYSTEM
-- ============================================================

function PluginManager:AddHook(pluginName, hookName, callback)
	if not hooks[hookName] then
		hooks[hookName] = {}
	end
	table.insert(hooks[hookName], {
		Plugin = pluginName,
		Callback = callback,
	})
end

function PluginManager:RunHooks(hookName, ...)
	if not hooks[hookName] then return end
	for _, hook in ipairs(hooks[hookName]) do
		local plugin = registeredPlugins[hook.Plugin]
		if plugin and plugin.Enabled then
			pcall(hook.Callback, ...)
		end
	end
end

function PluginManager:RemoveHooks(pluginName)
	for hookName, hookList in pairs(hooks) do
		for i = #hookList, 1, -1 do
			if hookList[i].Plugin == pluginName then
				table.remove(hookList, i)
			end
		end
	end
end

-- ============================================================
-- 	HOOK NAMES
-- ============================================================

PluginManager.Hooks = {
	BeforeWindowCreate = "before_window_create",
	AfterWindowCreate = "after_window_create",
	BeforeRender = "before_render",
	AfterRender = "after_render",
	BeforeDestroy = "before_destroy",
	ThemeChange = "theme_change",
	TabChange = "tab_change",
	ElementCreate = "element_create",
}

return PluginManager
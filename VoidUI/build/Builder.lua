-- [[
-- 	Rayfield Enhanced — Builder.lua
-- 	Compiles all modules into a single file for loadstring distribution
-- ]]

local builder = {}

-- Module order (dependencies first)
local MODULE_ORDER = {
	"src/Utils/Springs.lua",
	"src/Utils/Helpers.lua",
	"src/Utils/Cache.lua",
	"src/Core/EventManager.lua",
	"src/Core/Performance.lua",
	"src/Core/Animations.lua",
	"src/Core/ThemeManager.lua",
	"src/Core/BlurEngine.lua",
	"src/Core/ConfigManager.lua",
	"src/Core/PluginManager.lua",
	"src/Core/NotificationManager.lua",
	"src/Core/MobileManager.lua",
	"src/Core/SearchManager.lua",
	"src/Core/DockManager.lua",
	"src/Core/Rendering.lua",
	"src/Core/Tabs.lua",
	"src/Core/Window.lua",
	"src/API/PublicAPI.lua",
}

function builder:BuiltVersion()
	local version = "1.0.0"
	return version
end

function builder:Build()
	local modules = {}
	
	for _, path in ipairs(MODULE_ORDER) do
		local fullPath = script.Parent.Parent .. "/" .. path
		local content = readfile(fullPath)
		if content then
			table.insert(modules, content)
		end
	end

	return table.concat(modules, "\n\n-- === NEXT MODULE ===\n\n")
end

function builder:Compile()
	local header = [[
-- ============================================================
-- 	Rayfield Enhanced v]] .. self:BuiltVersion() .. [[
-- 	Premium Roblox UI Library
-- 	Based on Rayfield Interface Suite by Sirius
-- 	Enhanced with modern visuals, animations, and modular architecture
-- ============================================================
-- 	Usage: loadstring(game:HttpGet("url"))()
-- ============================================================

local RayfieldEnhanced = {}

-- === Environment Setup ===
local _getgenv = rawget(_G, "getgenv")
local requestsDisabled = false
local customAssetId = nil
local secureMode = false

if _getgenv then
	local ok, result = pcall(function() return _getgenv().RAYFIELD_ENHANCED_ASSET_ID end)
	if ok and type(result) == "number" then customAssetId = result end
	local ok2, result2 = pcall(function() return _getgenv().RAYFIELD_ENHANCED_SECURE end)
	if ok2 and result2 then secureMode = true end
	local ok3, result3 = pcall(function() return _getgenv().DISABLE_RAYFIELD_ENHANCED_REQUESTS end)
	if ok3 and result3 then requestsDisabled = true end
end

-- === Services ===
local function getService(name)
	local service = game:GetService(name)
	if cloneref then
		return cloneref(service)
	end
	return service
end

local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")
local RunService = getService("RunService")
local HttpService = getService("HttpService")
local Lighting = getService("Lighting")

-- === Load Original Rayfield Core ===
local RayfieldCore = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
]]
	
	local compiled = header

	-- Read and embed all module files
	for _, path in ipairs(MODULE_ORDER) do
		local fullPath = script.Parent.Parent .. "/" .. path
		local content = readfile(fullPath)
		if content then
			compiled = compiled .. "\n\n-- === MODULE: " .. path .. " ===\n\n"
			-- Convert require() calls to local variable references
			content = content:gsub('require%(script%.Parent%.Parent%.Utils%.Springs%)', 'RayfieldEnhanced.Springs')
			content = content:gsub('require%(script%.Parent%.Parent%.Utils%.Cache%)', 'RayfieldEnhanced.Cache')
			content = content:gsub('require%(script%.Parent%.Parent%.Core%.Performance%)', 'RayfieldEnhanced.Performance')
			content = content:gsub('require%(script%.Parent%.Parent%.Core%.EventManager%)', 'RayfieldEnhanced.EventManager')
			compiled = compiled .. content
		end
	end

	-- Add integration layer (bridges Rayfield core with Enhanced modules)
	local integration = [[

-- ============================================================
-- 	INTEGRATION LAYER — Bridges Rayfield Core with Enhanced
-- ============================================================

-- Store references from original Rayfield
RayfieldEnhanced.Core = RayfieldCore

-- Apply modern theme
RayfieldEnhanced.Themes = RayfieldEnhanced.ThemeManager.GetAllThemes()

-- Create modern API wrapper
local ModernAPI = {}

function ModernAPI:CreateWindow(config)
	config = config or {}
	
	-- Create original Rayfield window
	local window = RayfieldCore:CreateWindow({
		Name = config.Title or config.Name or "Rayfield Enhanced",
		Icon = config.Icon or 0,
		LoadingTitle = config.LoadingTitle or "Rayfield Enhanced",
		LoadingSubtitle = config.LoadingSubtitle or "Next-Gen UI",
		Theme = config.Theme or "Default",
		DisableRayfieldPrompts = config.DisableRayfieldPrompts or false,
		DisableBuildWarnings = config.DisableBuildWarnings or true,
		ConfigurationSaving = config.ConfigurationSaving or { Enabled = false },
		Discord = config.Discord or { Enabled = false },
		KeySystem = config.KeySystem or false,
		KeySettings = config.KeySettings,
	})

	-- Enhance window with modern features
	if config.Acrylic then
		RayfieldEnhanced.BlurEngine.AttachBlur(CoreGui, config.AcrylicIntensity or 24)
	end

	if config.Theme then
		RayfieldEnhanced.ThemeManager:ApplyTheme(config.Theme)
	end

	-- Hook theme changes
	RayfieldEnhanced.ThemeManager:OnThemeChanged(function(theme, name)
		if window.ModifyTheme then
			window.ModifyTheme(name)
		end
	end)

	-- Enhanced window object
	local enhancedWindow = {
		_window = window,
		_config = config,
		_tabs = {},
	}

	-- Modern tab creation with chaining
	function enhancedWindow:Tab(config)
		if type(config) == "string" then
			config = { Name = config, Icon = 0 }
		end
		local tab = window:CreateTab(config.Name, config.Icon or config.Icon or 0)
		local enhancedTab = {
			_tab = tab,
			_elements = {},
		}

		function enhancedTab:Section(name)
			tab:CreateSection(name)
			return enhancedTab
		end

		function enhancedTab:Toggle(config)
			local callback = config.Callback or function() end
			local toggle = tab:CreateToggle({
				Name = config.Name,
				CurrentValue = config.Default or config.CurrentValue or false,
				Flag = config.Flag or config.Name,
				Callback = callback,
			})
			table.insert(self._elements, toggle)
			return enhancedTab
		end

		function enhancedTab:Button(config)
			local btn = tab:CreateButton({
				Name = config.Name,
				Callback = config.Callback or function() end,
			})
			return enhancedTab
		end

		function enhancedTab:Slider(config)
			local slider = tab:CreateSlider({
				Name = config.Name,
				Range = config.Range or {0, 100},
				Increment = config.Increment or 1,
				Suffix = config.Suffix or "",
				CurrentValue = config.Default or 0,
				Flag = config.Flag or config.Name,
				Callback = config.Callback or function() end,
			})
			return enhancedTab
		end

		function enhancedTab:Input(config)
			local input = tab:CreateInput({
				Name = config.Name,
				CurrentValue = config.Default or "",
				PlaceholderText = config.Placeholder or "Type here...",
				Flag = config.Flag or config.Name,
				RemoveTextAfterFocusLost = config.ClearOnFocus or false,
				Callback = config.Callback or function() end,
			})
			return enhancedTab
		end

		function enhancedTab:Dropdown(config)
			local dropdown = tab:CreateDropdown({
				Name = config.Name,
				Options = config.Options or {},
				CurrentOption = config.Default and {config.Default} or {},
				MultipleOptions = config.Multiple or false,
				Flag = config.Flag or config.Name,
				Callback = config.Callback or function() end,
			})
			return enhancedTab
		end

		function enhancedTab:Keybind(config)
			local keybind = tab:CreateKeybind({
				Name = config.Name,
				CurrentKeybind = config.Default or "F",
				HoldToInteract = config.Hold or false,
				Flag = config.Flag or config.Name,
				Callback = config.Callback or function() end,
			})
			return enhancedTab
		end

		function enhancedTab:ColorPicker(config)
			local cp = tab:CreateColorPicker({
				Name = config.Name,
				Color = config.Default or Color3.fromRGB(255,255,255),
				Flag = config.Flag or config.Name,
				Callback = config.Callback or function() end,
			})
			return enhancedTab
		end

		function enhancedTab:Label(text, icon, color)
			tab:CreateLabel(text, icon or 0, color)
			return enhancedTab
		end

		function enhancedTab:Paragraph(config)
			tab:CreateParagraph({
				Title = config.Title or "",
				Content = config.Content or "",
			})
			return enhancedTab
		end

		function enhancedTab:Divider()
			tab:CreateDivider()
			return enhancedTab
		end

		table.insert(self._tabs, enhancedTab)
		return enhancedTab
	end

	-- Load configuration
	task.delay(2, function()
		if RayfieldCore.LoadConfiguration then
			RayfieldCore:LoadConfiguration()
		end
	end)

	return enhancedWindow
end

-- Expose original Rayfield for backward compatibility
ModernAPI.Flags = RayfieldCore.Flags
ModernAPI.Notify = RayfieldCore.Notify
ModernAPI.Theme = RayfieldCore.Theme
ModernAPI.LoadConfiguration = RayfieldCore.LoadConfiguration
ModernAPI.SetVisibility = RayfieldCore.SetVisibility
ModernAPI.IsVisible = RayfieldCore.IsVisible
ModernAPI.Destroy = RayfieldCore.Destroy

return ModernAPI
]]

	compiled = compiled .. integration

	-- Create final output
	local outputPath = "RayfieldEnhanced/build/Compiled.lua"
	writefile(outputPath, compiled)
	
	return compiled
end

return builder
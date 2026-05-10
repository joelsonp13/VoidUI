-- [[
-- 	Rayfield Enhanced — Example
-- 	Shows the modern, clean, chainable API
-- ]]

-- ============================================================
-- 	USING COMPILED BUILD (single file)
-- ============================================================
-- local Library = loadstring(game:HttpGet("https://your-host.com/Compiled.lua"))()

-- ============================================================
-- 	OR USING DEV BUILD (individual modules)
-- ============================================================
-- For development, you'd compile. But here's the API usage:

-- ============================================================
-- 	EXAMPLE: MODERN API
-- ============================================================

local Library = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create window with enhanced config
local Window = Library:CreateWindow({
	Name = "Rayfield Enhanced",
	LoadingTitle = "Rayfield Enhanced",
	LoadingSubtitle = "Next-Gen UI Library",
	Theme = "Default",
	ToggleUIKeybind = "K",

	ConfigurationSaving = {
		Enabled = true,
		FileName = "EnhancedConfig",
	},

	KeySystem = false,
})

-- ============================================================
-- 	MAIN TAB
-- ============================================================

local MainTab = Window:CreateTab("Main", "home")

-- Section: Combat
local CombatSection = MainTab:CreateSection("Combat")

local Toggle = MainTab:CreateToggle({
	Name = "Kill Aura",
	CurrentValue = false,
	Flag = "KillAura",
	Callback = function(v)
		print("Kill Aura:", v)
	end,
})

local Toggle2 = MainTab:CreateToggle({
	Name = "Auto Block",
	CurrentValue = true,
	Flag = "AutoBlock",
	Callback = function(v)
		print("Auto Block:", v)
	end,
})

local Slider = MainTab:CreateSlider({
	Name = "Range",
	Range = {1, 50},
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 15,
	Flag = "Range",
	Callback = function(v)
		print("Range:", v)
	end,
})

-- Section: Visuals
local VisualsSection = MainTab:CreateSection("Visuals")

local Dropdown = MainTab:CreateDropdown({
	Name = "ESP Mode",
	Options = {"Box", "Tracer", "Full", "Off"},
	CurrentOption = {"Box"},
	Flag = "ESPMode",
	Callback = function(opt)
		print("ESP:", opt[1])
	end,
})

local ColorPicker = MainTab:CreateColorPicker({
	Name = "ESP Color",
	Color = Color3.fromRGB(255, 50, 50),
	Flag = "ESPColor",
	Callback = function(c)
		print("Color:", c)
	end,
})

-- ============================================================
-- 	SETTINGS TAB
-- ============================================================

local SettingsTab = Window:CreateTab("Settings", "settings")

local SettingsSection = SettingsTab:CreateSection("General")

local Keybind = SettingsTab:CreateKeybind({
	Name = "Menu Key",
	CurrentKeybind = "K",
	Flag = "MenuKey",
	Callback = function()
		Rayfield:SetVisibility(not Rayfield:IsVisible())
	end,
})

local Input = SettingsTab:CreateInput({
	Name = "Player Name",
	CurrentValue = "",
	PlaceholderText = "Enter name...",
	Flag = "PlayerName",
	Callback = function(text)
		print("Name:", text)
	end,
})

-- ============================================================
-- 	ABOUT TAB
-- ============================================================

local AboutTab = Window:CreateTab("About", "info")

local AboutSection = AboutTab:CreateSection("Info")

local Label = AboutTab:CreateLabel("Rayfield Enhanced v1.0", "stars")
local Label2 = AboutTab:CreateLabel("Next-Gen UI for Roblox", "sparkles")

local Paragraph = AboutTab:CreateParagraph({
	Title = "Description",
	Content = "Rayfield Enhanced is a modern, fully-featured UI library for Roblox exploiting. It features a clean design, smooth animations, and a powerful API.",
})

local Button = AboutTab:CreateButton({
	Name = "Test Notification",
	Callback = function()
		Rayfield:Notify({
			Title = "Rayfield Enhanced",
			Content = "This is a modern notification!",
			Duration = 5,
		})
	end,
})

-- ============================================================
-- 	LOAD CONFIGURATION
-- ============================================================

Rayfield:LoadConfiguration()

-- ============================================================
-- 	THEME CHANGER (uncomment to test)
-- ============================================================
-- Window.ModifyTheme("Midnight")
-- Window.ModifyTheme("Neon")
-- Window.ModifyTheme("AMOLED")
-- Window.ModifyTheme("Glass")
-- [[
-- 	Rayfield Enhanced — ThemeManager.lua
-- 	Advanced theme system with live editing, export/import, gradients
-- ]]

local ThemeManager = {}
ThemeManager.__index = ThemeManager

-- ============================================================
-- 	THEMES
-- ============================================================

local Themes = {
	Default = {
		Name = "Default",
		Author = "Sirius",
		Version = "2.0",

		-- Base colors
		Text = Color3.fromRGB(225, 225, 230),
		TextSecondary = Color3.fromRGB(140, 140, 150),
		TextMuted = Color3.fromRGB(90, 90, 100),

		Background = Color3.fromRGB(18, 18, 22),
		BackgroundSecondary = Color3.fromRGB(24, 24, 30),
		BackgroundTertiary = Color3.fromRGB(30, 30, 38),

		Surface = Color3.fromRGB(32, 32, 40),
		SurfaceHover = Color3.fromRGB(38, 38, 48),
		SurfaceActive = Color3.fromRGB(42, 42, 52),

		Topbar = Color3.fromRGB(22, 22, 28),
		TopbarText = Color3.fromRGB(225, 225, 230),

		Tab = Color3.fromRGB(40, 40, 50),
		TabHover = Color3.fromRGB(50, 50, 62),
		TabActive = Color3.fromRGB(60, 60, 75),
		TabText = Color3.fromRGB(180, 180, 190),
		TabTextActive = Color3.fromRGB(255, 255, 255),

		Element = Color3.fromRGB(28, 28, 36),
		ElementHover = Color3.fromRGB(34, 34, 44),
		ElementStroke = Color3.fromRGB(48, 48, 58),

		-- Accent colors
		Accent = Color3.fromRGB(88, 130, 255),
		AccentHover = Color3.fromRGB(108, 148, 255),
		AccentMuted = Color3.fromRGB(88, 130, 255, 0.15),

		Success = Color3.fromRGB(45, 200, 120),
		Warning = Color3.fromRGB(255, 180, 50),
		Error = Color3.fromRGB(235, 80, 80),
		Info = Color3.fromRGB(60, 160, 230),

		-- Toggle specific
		Toggle = Color3.fromRGB(45, 45, 55),
		ToggleEnabled = Color3.fromRGB(88, 130, 255),
		ToggleDisabled = Color3.fromRGB(60, 60, 70),

		-- Slider specific
		Slider = Color3.fromRGB(48, 48, 58),
		SliderProgress = Color3.fromRGB(88, 130, 255),
		SliderHandle = Color3.fromRGB(255, 255, 255),

		-- Input specific
		Input = Color3.fromRGB(24, 24, 32),
		InputStroke = Color3.fromRGB(55, 55, 65),
		InputFocus = Color3.fromRGB(88, 130, 255),
		Placeholder = Color3.fromRGB(100, 100, 110),

		-- Notification
		Notification = Color3.fromRGB(24, 24, 32),

		-- Dropdown
		Dropdown = Color3.fromRGB(28, 28, 36),
		DropdownSelected = Color3.fromRGB(38, 38, 48),

		-- Shadow
		Shadow = Color3.fromRGB(0, 0, 0),

		-- UI Properties
		CornerRadius = UDim.new(0, 8),
		ElementCornerRadius = UDim.new(0, 6),
		SmallCornerRadius = UDim.new(0, 4),
		ToggleCornerRadius = UDim.new(0, 12),
		BlurIntensity = 24,
		GlowIntensity = 0.6,

		-- Transparencies
		BackgroundTransparency = 0,
		SurfaceTransparency = 0,
		ElementTransparency = 0,
		OverlayTransparency = 0.5,
	},

	Midnight = {
		Name = "Midnight",
		Author = "Enhanced",
		Version = "1.0",

		Text = Color3.fromRGB(200, 200, 210),
		TextSecondary = Color3.fromRGB(120, 120, 130),
		TextMuted = Color3.fromRGB(70, 70, 80),

		Background = Color3.fromRGB(10, 10, 14),
		BackgroundSecondary = Color3.fromRGB(15, 16, 22),
		BackgroundTertiary = Color3.fromRGB(20, 21, 28),

		Surface = Color3.fromRGB(22, 23, 32),
		SurfaceHover = Color3.fromRGB(28, 30, 40),
		SurfaceActive = Color3.fromRGB(32, 34, 46),

		Topbar = Color3.fromRGB(14, 15, 20),
		TopbarText = Color3.fromRGB(200, 200, 210),

		Tab = Color3.fromRGB(30, 32, 42),
		TabHover = Color3.fromRGB(38, 40, 52),
		TabActive = Color3.fromRGB(48, 50, 65),
		TabText = Color3.fromRGB(150, 150, 165),
		TabTextActive = Color3.fromRGB(220, 220, 230),

		Element = Color3.fromRGB(20, 21, 28),
		ElementHover = Color3.fromRGB(26, 28, 36),
		ElementStroke = Color3.fromRGB(40, 42, 52),

		Accent = Color3.fromRGB(100, 120, 255),
		AccentHover = Color3.fromRGB(120, 140, 255),
		AccentMuted = Color3.fromRGB(100, 120, 255, 0.12),

		Success = Color3.fromRGB(35, 180, 100),
		Warning = Color3.fromRGB(230, 160, 40),
		Error = Color3.fromRGB(220, 60, 60),
		Info = Color3.fromRGB(50, 140, 220),

		Toggle = Color3.fromRGB(35, 37, 46),
		ToggleEnabled = Color3.fromRGB(100, 120, 255),
		ToggleDisabled = Color3.fromRGB(50, 52, 62),

		Slider = Color3.fromRGB(40, 42, 52),
		SliderProgress = Color3.fromRGB(100, 120, 255),
		SliderHandle = Color3.fromRGB(255, 255, 255),

		Input = Color3.fromRGB(18, 19, 26),
		InputStroke = Color3.fromRGB(45, 47, 58),
		InputFocus = Color3.fromRGB(100, 120, 255),
		Placeholder = Color3.fromRGB(80, 80, 95),

		Notification = Color3.fromRGB(18, 19, 26),
		Dropdown = Color3.fromRGB(22, 23, 32),
		DropdownSelected = Color3.fromRGB(30, 32, 44),
		Shadow = Color3.fromRGB(0, 0, 0),

		CornerRadius = UDim.new(0, 10),
		ElementCornerRadius = UDim.new(0, 8),
		SmallCornerRadius = UDim.new(0, 5),
		ToggleCornerRadius = UDim.new(0, 14),
		BlurIntensity = 32,
		GlowIntensity = 0.5,

		BackgroundTransparency = 0,
		SurfaceTransparency = 0,
		ElementTransparency = 0,
		OverlayTransparency = 0.45,
	},

	AMOLED = {
		Name = "AMOLED",
		Author = "Enhanced",
		Version = "1.0",

		Text = Color3.fromRGB(200, 200, 210),
		TextSecondary = Color3.fromRGB(100, 100, 110),
		TextMuted = Color3.fromRGB(55, 55, 65),

		Background = Color3.fromRGB(0, 0, 0),
		BackgroundSecondary = Color3.fromRGB(5, 5, 8),
		BackgroundTertiary = Color3.fromRGB(10, 10, 14),

		Surface = Color3.fromRGB(12, 12, 16),
		SurfaceHover = Color3.fromRGB(18, 18, 24),
		SurfaceActive = Color3.fromRGB(22, 22, 30),

		Topbar = Color3.fromRGB(0, 0, 0),
		TopbarText = Color3.fromRGB(200, 200, 210),

		Tab = Color3.fromRGB(18, 18, 24),
		TabHover = Color3.fromRGB(26, 26, 34),
		TabActive = Color3.fromRGB(34, 34, 46),
		TabText = Color3.fromRGB(130, 130, 145),
		TabTextActive = Color3.fromRGB(220, 220, 230),

		Element = Color3.fromRGB(10, 10, 14),
		ElementHover = Color3.fromRGB(16, 16, 22),
		ElementStroke = Color3.fromRGB(30, 30, 40),

		Accent = Color3.fromRGB(80, 140, 255),
		AccentHover = Color3.fromRGB(100, 160, 255),
		AccentMuted = Color3.fromRGB(80, 140, 255, 0.1),

		Success = Color3.fromRGB(30, 170, 90),
		Warning = Color3.fromRGB(220, 150, 30),
		Error = Color3.fromRGB(210, 50, 50),
		Info = Color3.fromRGB(40, 130, 210),

		Toggle = Color3.fromRGB(25, 25, 34),
		ToggleEnabled = Color3.fromRGB(80, 140, 255),
		ToggleDisabled = Color3.fromRGB(40, 40, 52),

		Slider = Color3.fromRGB(30, 30, 40),
		SliderProgress = Color3.fromRGB(80, 140, 255),
		SliderHandle = Color3.fromRGB(255, 255, 255),

		Input = Color3.fromRGB(8, 8, 12),
		InputStroke = Color3.fromRGB(35, 35, 46),
		InputFocus = Color3.fromRGB(80, 140, 255),
		Placeholder = Color3.fromRGB(65, 65, 80),

		Notification = Color3.fromRGB(8, 8, 12),
		Dropdown = Color3.fromRGB(12, 12, 16),
		DropdownSelected = Color3.fromRGB(20, 20, 28),
		Shadow = Color3.fromRGB(0, 0, 0),

		CornerRadius = UDim.new(0, 8),
		ElementCornerRadius = UDim.new(0, 6),
		SmallCornerRadius = UDim.new(0, 4),
		ToggleCornerRadius = UDim.new(0, 12),
		BlurIntensity = 20,
		GlowIntensity = 0.4,

		BackgroundTransparency = 0,
		SurfaceTransparency = 0,
		ElementTransparency = 0,
		OverlayTransparency = 0.5,
	},

	Neon = {
		Name = "Neon",
		Author = "Enhanced",
		Version = "1.0",

		Text = Color3.fromRGB(220, 220, 240),
		TextSecondary = Color3.fromRGB(150, 150, 180),
		TextMuted = Color3.fromRGB(100, 100, 130),

		Background = Color3.fromRGB(10, 8, 20),
		BackgroundSecondary = Color3.fromRGB(15, 12, 28),
		BackgroundTertiary = Color3.fromRGB(20, 16, 34),

		Surface = Color3.fromRGB(22, 18, 38),
		SurfaceHover = Color3.fromRGB(28, 24, 46),
		SurfaceActive = Color3.fromRGB(34, 28, 54),

		Topbar = Color3.fromRGB(14, 10, 26),
		TopbarText = Color3.fromRGB(220, 220, 240),

		Tab = Color3.fromRGB(32, 26, 50),
		TabHover = Color3.fromRGB(40, 34, 60),
		TabActive = Color3.fromRGB(50, 42, 72),
		TabText = Color3.fromRGB(160, 150, 190),
		TabTextActive = Color3.fromRGB(255, 255, 255),

		Element = Color3.fromRGB(18, 14, 32),
		ElementHover = Color3.fromRGB(24, 20, 40),
		ElementStroke = Color3.fromRGB(42, 36, 60),

		Accent = Color3.fromRGB(130, 60, 255),
		AccentHover = Color3.fromRGB(150, 80, 255),
		AccentMuted = Color3.fromRGB(130, 60, 255, 0.15),

		Success = Color3.fromRGB(35, 200, 120),
		Warning = Color3.fromRGB(255, 170, 40),
		Error = Color3.fromRGB(230, 60, 80),
		Info = Color3.fromRGB(50, 140, 240),

		Toggle = Color3.fromRGB(36, 30, 54),
		ToggleEnabled = Color3.fromRGB(130, 60, 255),
		ToggleDisabled = Color3.fromRGB(52, 46, 70),

		Slider = Color3.fromRGB(40, 34, 58),
		SliderProgress = Color3.fromRGB(130, 60, 255),
		SliderHandle = Color3.fromRGB(255, 255, 255),

		Input = Color3.fromRGB(16, 12, 30),
		InputStroke = Color3.fromRGB(48, 40, 68),
		InputFocus = Color3.fromRGB(130, 60, 255),
		Placeholder = Color3.fromRGB(90, 80, 120),

		Notification = Color3.fromRGB(16, 12, 30),
		Dropdown = Color3.fromRGB(20, 16, 36),
		DropdownSelected = Color3.fromRGB(30, 24, 50),
		Shadow = Color3.fromRGB(0, 0, 0),

		CornerRadius = UDim.new(0, 10),
		ElementCornerRadius = UDim.new(0, 8),
		SmallCornerRadius = UDim.new(0, 5),
		ToggleCornerRadius = UDim.new(0, 14),
		BlurIntensity = 28,
		GlowIntensity = 0.7,

		BackgroundTransparency = 0,
		SurfaceTransparency = 0,
		ElementTransparency = 0,
		OverlayTransparency = 0.5,
	},

	Cyberpunk = {
		Name = "Cyberpunk",
		Author = "Enhanced",
		Version = "1.0",

		Text = Color3.fromRGB(230, 230, 200),
		TextSecondary = Color3.fromRGB(180, 180, 130),
		TextMuted = Color3.fromRGB(130, 130, 80),

		Background = Color3.fromRGB(10, 8, 6),
		BackgroundSecondary = Color3.fromRGB(16, 13, 10),
		BackgroundTertiary = Color3.fromRGB(22, 18, 14),

		Surface = Color3.fromRGB(24, 20, 16),
		SurfaceHover = Color3.fromRGB(30, 26, 22),
		SurfaceActive = Color3.fromRGB(36, 32, 28),

		Topbar = Color3.fromRGB(14, 11, 8),
		TopbarText = Color3.fromRGB(230, 230, 200),

		Tab = Color3.fromRGB(34, 28, 22),
		TabHover = Color3.fromRGB(42, 36, 28),
		TabActive = Color3.fromRGB(52, 44, 34),
		TabText = Color3.fromRGB(170, 160, 130),
		TabTextActive = Color3.fromRGB(255, 240, 180),

		Element = Color3.fromRGB(20, 16, 12),
		ElementHover = Color3.fromRGB(26, 22, 18),
		ElementStroke = Color3.fromRGB(44, 38, 30),

		Accent = Color3.fromRGB(255, 180, 30),
		AccentHover = Color3.fromRGB(255, 200, 60),
		AccentMuted = Color3.fromRGB(255, 180, 30, 0.12),

		Success = Color3.fromRGB(50, 200, 100),
		Warning = Color3.fromRGB(255, 140, 20),
		Error = Color3.fromRGB(230, 50, 50),
		Info = Color3.fromRGB(40, 160, 220),

		Toggle = Color3.fromRGB(38, 32, 26),
		ToggleEnabled = Color3.fromRGB(255, 180, 30),
		ToggleDisabled = Color3.fromRGB(54, 48, 42),

		Slider = Color3.fromRGB(42, 36, 30),
		SliderProgress = Color3.fromRGB(255, 180, 30),
		SliderHandle = Color3.fromRGB(255, 240, 180),

		Input = Color3.fromRGB(18, 14, 10),
		InputStroke = Color3.fromRGB(50, 44, 36),
		InputFocus = Color3.fromRGB(255, 180, 30),
		Placeholder = Color3.fromRGB(110, 100, 80),

		Notification = Color3.fromRGB(18, 14, 10),
		Dropdown = Color3.fromRGB(22, 18, 14),
		DropdownSelected = Color3.fromRGB(32, 26, 20),
		Shadow = Color3.fromRGB(0, 0, 0),

		CornerRadius = UDim.new(0, 6),
		ElementCornerRadius = UDim.new(0, 4),
		SmallCornerRadius = UDim.new(0, 3),
		ToggleCornerRadius = UDim.new(0, 10),
		BlurIntensity = 16,
		GlowIntensity = 0.8,

		BackgroundTransparency = 0,
		SurfaceTransparency = 0,
		ElementTransparency = 0,
		OverlayTransparency = 0.5,
	},

	Glass = {
		Name = "Glass",
		Author = "Enhanced",
		Version = "1.0",

		Text = Color3.fromRGB(230, 230, 240),
		TextSecondary = Color3.fromRGB(160, 160, 180),
		TextMuted = Color3.fromRGB(110, 110, 130),

		Background = Color3.fromRGB(12, 14, 24),
		BackgroundSecondary = Color3.fromRGB(18, 20, 32),
		BackgroundTertiary = Color3.fromRGB(24, 26, 38),

		Surface = Color3.fromRGB(26, 28, 42, 0.4),
		SurfaceHover = Color3.fromRGB(32, 34, 50, 0.5),
		SurfaceActive = Color3.fromRGB(38, 40, 58, 0.6),

		Topbar = Color3.fromRGB(16, 18, 28, 0.3),
		TopbarText = Color3.fromRGB(230, 230, 240),

		Tab = Color3.fromRGB(36, 38, 54, 0.35),
		TabHover = Color3.fromRGB(44, 46, 64, 0.45),
		TabActive = Color3.fromRGB(54, 56, 76, 0.55),
		TabText = Color3.fromRGB(170, 170, 190),
		TabTextActive = Color3.fromRGB(255, 255, 255),

		Element = Color3.fromRGB(22, 24, 36, 0.3),
		ElementHover = Color3.fromRGB(28, 30, 44, 0.4),
		ElementStroke = Color3.fromRGB(46, 48, 64, 0.3),

		Accent = Color3.fromRGB(100, 150, 255),
		AccentHover = Color3.fromRGB(120, 170, 255),
		AccentMuted = Color3.fromRGB(100, 150, 255, 0.1),

		Success = Color3.fromRGB(45, 200, 120),
		Warning = Color3.fromRGB(255, 180, 50),
		Error = Color3.fromRGB(235, 80, 80),
		Info = Color3.fromRGB(60, 160, 230),

		Toggle = Color3.fromRGB(40, 42, 58, 0.4),
		ToggleEnabled = Color3.fromRGB(100, 150, 255),
		ToggleDisabled = Color3.fromRGB(56, 58, 74, 0.4),

		Slider = Color3.fromRGB(44, 46, 62, 0.4),
		SliderProgress = Color3.fromRGB(100, 150, 255),
		SliderHandle = Color3.fromRGB(255, 255, 255),

		Input = Color3.fromRGB(20, 22, 34, 0.3),
		InputStroke = Color3.fromRGB(50, 52, 70, 0.3),
		InputFocus = Color3.fromRGB(100, 150, 255),
		Placeholder = Color3.fromRGB(100, 100, 120),

		Notification = Color3.fromRGB(20, 22, 34, 0.3),
		Dropdown = Color3.fromRGB(24, 26, 40, 0.35),
		DropdownSelected = Color3.fromRGB(34, 36, 54, 0.4),
		Shadow = Color3.fromRGB(0, 0, 0),

		CornerRadius = UDim.new(0, 14),
		ElementCornerRadius = UDim.new(0, 10),
		SmallCornerRadius = UDim.new(0, 7),
		ToggleCornerRadius = UDim.new(0, 16),
		BlurIntensity = 48,
		GlowIntensity = 0.4,

		BackgroundTransparency = 0,
		SurfaceTransparency = 0.6,
		ElementTransparency = 0.7,
		OverlayTransparency = 0.3,
	},

	Purple = {
		Name = "Purple",
		Author = "Enhanced",
		Version = "1.0",

		Text = Color3.fromRGB(230, 225, 240),
		TextSecondary = Color3.fromRGB(170, 160, 190),
		TextMuted = Color3.fromRGB(110, 100, 140),

		Background = Color3.fromRGB(20, 16, 30),
		BackgroundSecondary = Color3.fromRGB(26, 22, 38),
		BackgroundTertiary = Color3.fromRGB(32, 28, 46),

		Surface = Color3.fromRGB(36, 30, 50),
		SurfaceHover = Color3.fromRGB(42, 36, 58),
		SurfaceActive = Color3.fromRGB(48, 42, 66),

		Topbar = Color3.fromRGB(24, 20, 36),
		TopbarText = Color3.fromRGB(230, 225, 240),

		Tab = Color3.fromRGB(44, 38, 60),
		TabHover = Color3.fromRGB(52, 46, 70),
		TabActive = Color3.fromRGB(62, 54, 82),
		TabText = Color3.fromRGB(180, 170, 200),
		TabTextActive = Color3.fromRGB(255, 255, 255),

		Element = Color3.fromRGB(30, 26, 44),
		ElementHover = Color3.fromRGB(36, 32, 52),
		ElementStroke = Color3.fromRGB(50, 44, 66),

		Accent = Color3.fromRGB(160, 80, 255),
		AccentHover = Color3.fromRGB(180, 100, 255),
		AccentMuted = Color3.fromRGB(160, 80, 255, 0.15),

		Success = Color3.fromRGB(45, 200, 120),
		Warning = Color3.fromRGB(255, 180, 50),
		Error = Color3.fromRGB(235, 80, 80),
		Info = Color3.fromRGB(60, 160, 230),

		Toggle = Color3.fromRGB(48, 42, 66),
		ToggleEnabled = Color3.fromRGB(160, 80, 255),
		ToggleDisabled = Color3.fromRGB(62, 56, 80),

		Slider = Color3.fromRGB(50, 44, 68),
		SliderProgress = Color3.fromRGB(160, 80, 255),
		SliderHandle = Color3.fromRGB(255, 255, 255),

		Input = Color3.fromRGB(28, 24, 42),
		InputStroke = Color3.fromRGB(54, 48, 72),
		InputFocus = Color3.fromRGB(160, 80, 255),
		Placeholder = Color3.fromRGB(110, 100, 140),

		Notification = Color3.fromRGB(28, 24, 42),
		Dropdown = Color3.fromRGB(32, 28, 48),
		DropdownSelected = Color3.fromRGB(42, 36, 60),
		Shadow = Color3.fromRGB(0, 0, 0),

		CornerRadius = UDim.new(0, 10),
		ElementCornerRadius = UDim.new(0, 8),
		SmallCornerRadius = UDim.new(0, 5),
		ToggleCornerRadius = UDim.new(0, 14),
		BlurIntensity = 24,
		GlowIntensity = 0.6,

		BackgroundTransparency = 0,
		SurfaceTransparency = 0,
		ElementTransparency = 0,
		OverlayTransparency = 0.45,
	},

	Light = {
		Name = "Light",
		Author = "Enhanced",
		Version = "1.0",

		Text = Color3.fromRGB(30, 30, 40),
		TextSecondary = Color3.fromRGB(90, 90, 100),
		TextMuted = Color3.fromRGB(140, 140, 150),

		Background = Color3.fromRGB(240, 242, 248),
		BackgroundSecondary = Color3.fromRGB(235, 237, 244),
		BackgroundTertiary = Color3.fromRGB(228, 230, 238),

		Surface = Color3.fromRGB(230, 232, 240),
		SurfaceHover = Color3.fromRGB(222, 224, 234),
		SurfaceActive = Color3.fromRGB(215, 218, 228),

		Topbar = Color3.fromRGB(235, 237, 244),
		TopbarText = Color3.fromRGB(30, 30, 40),

		Tab = Color3.fromRGB(220, 222, 232),
		TabHover = Color3.fromRGB(210, 212, 224),
		TabActive = Color3.fromRGB(200, 202, 216),
		TabText = Color3.fromRGB(100, 100, 115),
		TabTextActive = Color3.fromRGB(20, 20, 30),

		Element = Color3.fromRGB(232, 234, 242),
		ElementHover = Color3.fromRGB(224, 226, 236),
		ElementStroke = Color3.fromRGB(210, 212, 222),

		Accent = Color3.fromRGB(70, 110, 220),
		AccentHover = Color3.fromRGB(90, 130, 240),
		AccentMuted = Color3.fromRGB(70, 110, 220, 0.1),

		Success = Color3.fromRGB(40, 170, 100),
		Warning = Color3.fromRGB(220, 160, 40),
		Error = Color3.fromRGB(210, 60, 60),
		Info = Color3.fromRGB(50, 140, 210),

		Toggle = Color3.fromRGB(218, 220, 230),
		ToggleEnabled = Color3.fromRGB(70, 110, 220),
		ToggleDisabled = Color3.fromRGB(190, 192, 200),

		Slider = Color3.fromRGB(215, 218, 228),
		SliderProgress = Color3.fromRGB(70, 110, 220),
		SliderHandle = Color3.fromRGB(255, 255, 255),

		Input = Color3.fromRGB(235, 237, 244),
		InputStroke = Color3.fromRGB(200, 202, 214),
		InputFocus = Color3.fromRGB(70, 110, 220),
		Placeholder = Color3.fromRGB(140, 140, 155),

		Notification = Color3.fromRGB(235, 237, 244),
		Dropdown = Color3.fromRGB(232, 234, 242),
		DropdownSelected = Color3.fromRGB(222, 224, 234),
		Shadow = Color3.fromRGB(0, 0, 0),

		CornerRadius = UDim.new(0, 8),
		ElementCornerRadius = UDim.new(0, 6),
		SmallCornerRadius = UDim.new(0, 4),
		ToggleCornerRadius = UDim.new(0, 12),
		BlurIntensity = 16,
		GlowIntensity = 0.2,

		BackgroundTransparency = 0,
		SurfaceTransparency = 0,
		ElementTransparency = 0,
		OverlayTransparency = 0.3,
	},
}

-- ============================================================
-- 	THEME MANAGER
-- ============================================================

local ThemeManagerInstance = {
	_currentTheme = Themes.Default,
	_currentThemeName = "Default",
	_listeners = {},
	_gradients = {},
	_customThemes = {},
}

function ThemeManagerInstance:GetTheme(name)
	if Themes[name] then return Themes[name] end
	return self._customThemes[name]
end

function ThemeManagerInstance:GetCurrent()
	return self._currentTheme
end

function ThemeManagerInstance:GetCurrentName()
	return self._currentThemeName
end

function ThemeManagerInstance:GetAllThemes()
	local names = {}
	for name, _ in pairs(Themes) do
		table.insert(names, name)
	end
	for name, _ in pairs(self._customThemes) do
		table.insert(names, name)
	end
	return names
end

function ThemeManagerInstance:ApplyTheme(name)
	local theme = self:GetTheme(name)
	if not theme then return false end

	self._currentTheme = theme
	self._currentThemeName = name

	-- Notify listeners
	for _, callback in ipairs(self._listeners) do
		pcall(callback, theme, name)
	end

	return true
end

function ThemeManagerInstance:RegisterTheme(name, themeData)
	if Themes[name] then return false end
	themeData.Name = name
	self._customThemes[name] = themeData
	return true
end

function ThemeManagerInstance:ExportTheme(name)
	local theme = self:GetTheme(name)
	if not theme then return nil end

	local export = {}
	for k, v in pairs(theme) do
		if type(v) ~= "function" and k ~= "Name" and k ~= "Author" and k ~= "Version" then
			if typeof(v) == "Color3" then
				export[k] = {R = v.R, G = v.G, B = v.B}
			elseif typeof(v) == "UDim" then
				export[k] = {Scale = v.Scale, Offset = v.Offset}
			elseif type(v) == "number" or type(v) == "boolean" then
				export[k] = v
			end
		end
	end
	return export
end

function ThemeManagerInstance:ImportTheme(data)
	local theme = {}
	for k, v in pairs(data) do
		if type(v) == "table" and v.R and v.G and v.B then
			theme[k] = Color3.fromRGB(v.R * 255, v.G * 255, v.B * 255)
		elseif typeof(v) == "table" and v.Scale and v.Offset then
			theme[k] = UDim.new(v.Scale, v.Offset)
		else
			theme[k] = v
		end
	end
	return theme
end

function ThemeManagerInstance:OnThemeChanged(callback)
	table.insert(self._listeners, callback)
	return callback
end

function ThemeManagerInstance:ModifyProperty(property, value)
	self._currentTheme[property] = value
	for _, callback in ipairs(self._listeners) do
		pcall(callback, self._currentTheme, self._currentThemeName)
	end
end

function ThemeManagerInstance:ApplyCustomTheme(themeTable)
	self._currentTheme = themeTable
	self._currentThemeName = "Custom"
	for _, callback in ipairs(self._listeners) do
		pcall(callback, themeTable, "Custom")
	end
end

-- Merge partial theme with current
function ThemeManagerInstance:MergeTheme(partial)
	local merged = {}
	for k, v in pairs(self._currentTheme) do
		merged[k] = v
	end
	for k, v in pairs(partial) do
		merged[k] = v
	end
	self:ApplyCustomTheme(merged)
end

return ThemeManagerInstance
-- ============================================================
-- 	VOIDPANEL — Painel Completo Usando VoidUI
-- 	Premium Roblox UI Library
-- 	https://github.com/joelsonp13/VoidUI
-- ============================================================
-- 	USO:
-- 	1. Faça upload do Compiled.lua para um host
-- 	2. Substitua a URL abaixo
-- 	3. Execute no executor
-- ============================================================

-- Carrega a VoidUI
local VoidUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/joelsonp13/VoidUI/main/build/Compiled.lua"))()

-- ============================================================
-- 	JANELA PRINCIPAL
-- ============================================================

local Window = VoidUI:CreateWindow({
	Title = "VoidPanel",
	LoadingTitle = "VoidUI",
	LoadingSubtitle = "Next-Gen UI Framework",
	Theme = "Default",          -- Mude pra: Midnight | AMOLED | Neon | Cyberpunk | Glass | Purple | Light
	ToggleUIKeybind = "K",
	ConfigurationSaving = {
		Enabled = true,
		FileName = "VoidPanelConfig"
	},
})

-- ============================================================
-- 	SIDEBAR MODERNA (ícones em PT-BR)
-- ============================================================

local sidebar = VoidUI.SidebarEngine:Create({
	Width = 200,
	CollapsedWidth = 56,
	Collapsed = false,
	Side = "left",
})

sidebar:AddSection("Navegação")

sidebar:AddItem({
	Name = "Combate",
	Icon = VoidUI.Icons:Resolve("18"),
	Active = true,
	Callback = function()
		-- Ir para aba Combat (simulado)
		print("Ir para Combate")
	end
})

sidebar:AddItem({
	Name = "Visual",
	Icon = VoidUI.Icons:Resolve("ver"),
	Callback = function()
		print("Ir para Visual")
	end
})

sidebar:AddItem({
	Name = "Jogador",
	Icon = VoidUI.Icons:Resolve("perfil"),
	Callback = function()
		print("Ir para Jogador")
	end
})

sidebar:AddSection("Ferramentas")

sidebar:AddItem({
	Name = "Configurações",
	Icon = VoidUI.Icons:Resolve("config"),
	Callback = function()
		print("Abrir Config")
	end
})

sidebar:AddItem({
	Name = "Sair",
	Icon = VoidUI.Icons:Resolve("fechar"),
	Callback = function()
		VoidUI:SetVisibility(false)
	end
})

-- ============================================================
-- 	COMMAND PALETTE (Ctrl+P)
-- ============================================================

local commands = {
	{ Name = "Toggle Kill Aura", Description = "Ativa/desativa Kill Aura", Callback = function()
		print("Kill Aura toggled")
	end},
	{ Name = "Abrir Configurações", Description = "Abre painel de configurações", Callback = function()
		print("Abrindo config...")
	end},
	{ Name = "Mudar Tema", Description = "Alterna entre temas disponíveis", Callback = function()
		VoidUI:ModifyTheme("Neon")
	end},
	{ Name = "Toggle UI", Description = "Mostra/esconde a interface", Callback = function()
		VoidUI:SetVisibility(not VoidUI:IsVisible())
	end},
	{ Name = "Resetar Config", Description = "Reseta configurações para padrão", Callback = function()
		VoidUI.ConfigManager:Reset()
	end},
	{ Name = "Exportar Config", Description = "Copia config para área de transferência", Callback = function()
		setclipboard(VoidUI.ConfigManager:Export())
	end},
}

-- Atalho Ctrl+P para abrir Command Palette
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.P and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
		VoidUI.CommandPalette:Open(commands)
	end
end)

-- ============================================================
-- 	WATERMARK COM FPS
-- ============================================================

local watermark = VoidUI.Components.Watermark:Create({
	Text = "VoidPanel",
	ShowFPS = true,
	ShowMemory = true,
	PositionX = 12,
	PositionY = 12,
})

-- ============================================================
-- 	ABA: COMBATE
-- ============================================================

local CombatTab = Window:CreateTab("Combate", VoidUI.Icons:Resolve("18"))

local AuraSection = CombatTab:CreateSection("Aura")

local KillAura = CombatTab:CreateToggle({
	Name = "Kill Aura",
	CurrentValue = false,
	Flag = "KillAura",
	Callback = function(v)
		print("Kill Aura:", v)
		if v then
			VoidUI.NotificationManager:Notify({
				Title = "Kill Aura",
				Content = "Kill Aura ativado!",
				Duration = 3,
				Color = Color3.fromRGB(45, 200, 120),
			})
		end
	end,
})

local AuraRange = CombatTab:CreateSlider({
	Name = "Alcance",
	Range = {5, 50},
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 20,
	Flag = "AuraRange",
	Callback = function(v)
		print("Range:", v)
	end,
})

local AuraDelay = CombatTab:CreateSlider({
	Name = "Delay",
	Range = {0.1, 2},
	Increment = 0.1,
	Suffix = "s",
	CurrentValue = 0.5,
	Flag = "AuraDelay",
	Callback = function(v)
		print("Delay:", v)
	end,
})

local VisualsSection = CombatTab:CreateSection("Visuals de Combate")

local HitEffect = CombatTab:CreateToggle({
	Name = "Efeito de Acerto",
	CurrentValue = true,
	Flag = "HitEffect",
	Callback = function(v)
		print("HitEffect:", v)
	end,
})

local TargetColor = CombatTab:CreateColorPicker({
	Name = "Cor do Alvo",
	Color = Color3.fromRGB(255, 50, 50),
	Flag = "TargetColor",
	Callback = function(c)
		print("Target color:", c)
	end,
})

-- ============================================================
-- 	ABA: VISUAL
-- ============================================================

local VisualTab = Window:CreateTab("Visual", VoidUI.Icons:Resolve("ver"))

local ESPSection = VisualTab:CreateSection("ESP")

local ESPMode = VisualTab:CreateDropdown({
	Name = "Modo ESP",
	Options = {"Box", "Tracer", "Full", "Nome Apenas", "Desligado"},
	CurrentOption = {"Box"},
	Flag = "ESPMode",
	Callback = function(opt)
		print("ESP Mode:", opt[1])
	end,
})

local ESPColor = VisualTab:CreateColorPicker({
	Name = "Cor do ESP",
	Color = Color3.fromRGB(255, 255, 255),
	Flag = "ESPColor",
	Callback = function(c)
		print("ESP Color:", c)
	end,
})

local ESPThickness = VisualTab:CreateSlider({
	Name = "Espessura",
	Range = {1, 5},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 2,
	Flag = "ESPThickness",
	Callback = function(v)
		print("Thickness:", v)
	end,
})

local WorldSection = VisualTab:CreateSection("Mundo")

local FullBright = VisualTab:CreateToggle({
	Name = "FullBright",
	CurrentValue = false,
	Flag = "FullBright",
	Callback = function(v)
		print("FullBright:", v)
	end,
})

local FOVSlider = VisualTab:CreateSlider({
	Name = "Campo de Visão (FOV)",
	Range = {70, 120},
	Increment = 1,
	Suffix = "°",
	CurrentValue = 90,
	Flag = "FOV",
	Callback = function(v)
		workspace.CurrentCamera.FieldOfView = v
	end,
})

-- ============================================================
-- 	ABA: JOGADOR
-- ============================================================

local PlayerTab = Window:CreateTab("Jogador", VoidUI.Icons:Resolve("perfil"))

local MovementSection = PlayerTab:CreateSection("Movimento")

local SpeedBoost = PlayerTab:CreateToggle({
	Name = "Super Velocidade",
	CurrentValue = false,
	Flag = "SpeedBoost",
	Callback = function(v)
		print("Speed:", v)
	end,
})

local SpeedValue = PlayerTab:CreateSlider({
	Name = "Velocidade",
	Range = {16, 200},
	Increment = 5,
	Suffix = "studs/s",
	CurrentValue = 50,
	Flag = "SpeedValue",
	Callback = function(v)
		print("Speed value:", v)
	end,
})

local JumpPower = PlayerTab:CreateSlider({
	Name = "Super Pulso",
	Range = {50, 300},
	Increment = 10,
	Suffix = "",
	CurrentValue = 100,
	Flag = "JumpPower",
	Callback = function(v)
		print("Jump:", v)
	end,
})

local PlayerSection = PlayerTab:CreateSection("Jogador")

local NoClip = PlayerTab:CreateToggle({
	Name = "NoClip",
	CurrentValue = false,
	Flag = "NoClip",
	Callback = function(v)
		print("NoClip:", v)
	end,
})

local NoclipKey = PlayerTab:CreateKeybind({
	Name = "Tecla NoClip",
	CurrentKeybind = "Q",
	Flag = "NoclipKey",
	Callback = function()
		NoClip:Toggle()
	end,
})

-- ============================================================
-- 	ABA: CONFIGURAÇÕES
-- ============================================================

local SettingsTab = Window:CreateTab("Config", VoidUI.Icons:Resolve("config"))

local UISection = SettingsTab:CreateSection("Interface")

local ThemeDropdown = SettingsTab:CreateDropdown({
	Name = "Tema",
	Options = {"Default", "Midnight", "AMOLED", "Neon", "Cyberpunk", "Glass", "Purple", "Light"},
	CurrentOption = {"Default"},
	Flag = "Theme",
	Callback = function(opt)
		VoidUI:ModifyTheme(opt[1])
		VoidUI:Notify({
			Title = "Tema Alterado",
			Content = "Tema: " .. opt[1],
			Duration = 3,
		})
	end,
})

local MenuKey = SettingsTab:CreateKeybind({
	Name = "Tecla do Menu",
	CurrentKeybind = "K",
	Flag = "MenuKey",
	Callback = function()
		VoidUI:SetVisibility(not VoidUI:IsVisible())
	end,
})

local ConfigSection = SettingsTab:CreateSection("Configurações")

local ResetButton = SettingsTab:CreateButton({
	Name = "Resetar Configurações",
	Callback = function()
		VoidUI:Notify({
			Title = "Configurações",
			Content = "Configurações resetadas!",
			Duration = 3,
		})
	end,
})

local ExportButton = SettingsTab:CreateButton({
	Name = "Exportar Config (Ctrl+C)",
	Callback = function()
		local json = VoidUI.ConfigManager:Export()
		if setclipboard then
			setclipboard(json)
			VoidUI:Notify({
				Title = "Exportado",
				Content = "Config copiada para área de transferência!",
				Duration = 3,
				Color = Color3.fromRGB(45, 200, 120),
			})
		end
	end,
})

local AboutSection = SettingsTab:CreateSection("Sobre")

local AboutLabel = SettingsTab:CreateLabel("VoidPanel v1.0.0", VoidUI.Icons:Resolve("ideia"))
local AboutLabel2 = SettingsTab:CreateLabel("Feito com VoidUI Framework", VoidUI.Icons:Resolve("coracao"))

-- ============================================================
-- 	NOTIFICAÇÃO DE BOAS-VINDAS
-- ============================================================

task.delay(1, function()
	VoidUI:Notify({
		Title = "VoidPanel",
		Content = "Bem-vindo! Painel carregado com sucesso.",
		Duration = 5,
	})
end)

-- ============================================================
-- 	LOAD CONFIGURATION
-- ============================================================

VoidUI:LoadConfiguration()

-- ============================================================
-- 	FPS GRAPH (opcional, descomente para ativar)
-- ============================================================
-- local fpsGraph = VoidUI.Components.FPSGraph:Create({
--     Width = 220,
--     Height = 80,
--     PositionX = 12,
--     PositionY = 50,
--     MaxPoints = 60,
-- })

-- ============================================================
-- 	FIM DO SCRIPT
-- ============================================================

print("✅ VoidPanel carregado com sucesso!")
print("🔹 Pressione K para mostrar/esconder a UI")
print("🔹 Pressione Ctrl+P para abrir a Command Palette")
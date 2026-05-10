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

-- ============================================================
-- 	DEBUG/LOGS (para identificar erro em executor)
-- ============================================================
local DEBUG = true
local _step = 0

local function dlog(msg)
	_step += 1
	local line = string.format("[VoidPanel][%02d] %s", _step, tostring(msg))
	print(line)
	if DEBUG then
		warn(line)
	end
end

local function derror(where, err)
	warn(string.format("[VoidPanel][ERRO] %s -> %s", tostring(where), tostring(err)))
end

local function safeCall(where, fn)
	local ok, result = pcall(fn)
	if ok then
		dlog(where .. " OK")
		return true, result
	end
	derror(where, result)
	return false, result
end

dlog("Iniciando script")

-- Carrega a VoidUI
local VoidUI
do
	local ok, result = safeCall("Load VoidUI (HttpGet + loadstring)", function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/joelsonp13/VoidUI/main/build/Compiled.lua"))()
	end)
	if not ok or type(result) ~= "table" then
		error("[VoidPanel] Falha ao carregar VoidUI. Veja logs acima.")
	end
	VoidUI = result
end

local function createTabCompat(window, name, icon)
	if type(window.CreateTab) == "function" then
		return window:CreateTab(name, icon)
	end
	if type(window.Tab) == "function" then
		return window:Tab({ Name = name, Icon = icon })
	end
	error("Window não possui CreateTab nem Tab")
end

-- ============================================================
-- 	JANELA PRINCIPAL
-- ============================================================

local Window
do
	local ok, result = safeCall("CreateWindow", function()
		return VoidUI:CreateWindow({
			Title = "VoidPanel",
			LoadingTitle = "VoidUI",
			LoadingSubtitle = "Next-Gen UI Framework",
			Theme = "Default", -- Mude pra: Midnight | AMOLED | Neon | Cyberpunk | Glass | Purple | Light
			ToggleUIKeybind = "K",
			ConfigurationSaving = {
				Enabled = true,
				FileName = "VoidPanelConfig"
			},
		})
	end)
	if not ok or type(result) ~= "table" then
		error("[VoidPanel] Falha ao criar janela. Veja logs acima.")
	end
	Window = result
end

-- ============================================================
-- 	SIDEBAR MODERNA (ícones em PT-BR)
-- ============================================================

safeCall("SidebarEngine", function()
	if not (VoidUI.SidebarEngine and VoidUI.Icons) then
		dlog("SidebarEngine/Icons indisponível nesta build (pulando sidebar)")
		return
	end
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
		Callback = function() print("Ir para Combate") end
	})
	sidebar:AddItem({
		Name = "Visual",
		Icon = VoidUI.Icons:Resolve("ver"),
		Callback = function() print("Ir para Visual") end
	})
	sidebar:AddItem({
		Name = "Jogador",
		Icon = VoidUI.Icons:Resolve("perfil"),
		Callback = function() print("Ir para Jogador") end
	})
	sidebar:AddSection("Ferramentas")
	sidebar:AddItem({
		Name = "Configurações",
		Icon = VoidUI.Icons:Resolve("config"),
		Callback = function() print("Abrir Config") end
	})
	sidebar:AddItem({
		Name = "Sair",
		Icon = VoidUI.Icons:Resolve("fechar"),
		Callback = function() VoidUI:SetVisibility(false) end
	})
end)

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
safeCall("Bind CommandPalette", function()
	game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.P and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
			if VoidUI.CommandPalette and VoidUI.CommandPalette.Open then
				VoidUI.CommandPalette:Open(commands)
			else
				dlog("CommandPalette indisponível nesta build")
			end
		end
	end)
end)

-- ============================================================
-- 	WATERMARK COM FPS
-- ============================================================

safeCall("Watermark", function()
	if not (VoidUI.Components and VoidUI.Components.Watermark) then
		dlog("Components.Watermark indisponível nesta build")
		return
	end
	VoidUI.Components.Watermark:Create({
		Text = "VoidPanel",
		ShowFPS = true,
		ShowMemory = true,
		PositionX = 12,
		PositionY = 12,
	})
end)

-- ============================================================
-- 	ABA: COMBATE
-- ============================================================

local CombatTab = createTabCompat(Window, "Combate", 0)

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

local VisualTab = createTabCompat(Window, "Visual", 0)

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

local PlayerTab = createTabCompat(Window, "Jogador", 0)

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

local SettingsTab = createTabCompat(Window, "Config", 0)

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

local AboutLabel = SettingsTab:CreateLabel("VoidPanel v1.0.0", 0)
local AboutLabel2 = SettingsTab:CreateLabel("Feito com VoidUI Framework", 0)

-- ============================================================
-- 	NOTIFICAÇÃO DE BOAS-VINDAS
-- ============================================================

task.delay(1, function()
	safeCall("Welcome Notify", function()
		VoidUI:Notify({
			Title = "VoidPanel",
			Content = "Bem-vindo! Painel carregado com sucesso.",
			Duration = 5,
		})
	end)
end)

-- ============================================================
-- 	LOAD CONFIGURATION
-- ============================================================

safeCall("LoadConfiguration", function()
	VoidUI:LoadConfiguration()
end)

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
dlog("Script finalizado")
# Rayfield Enhanced v2.0.0

> **Uma UI Library Roblox premium, modular e extremamente moderna.**
> Baseada no Rayfield Interface Suite por Sirius — expandida com motor de animações, 8 temas premium, sistema de plugins, performance otimizada e muito mais.

---

## 📦 Instalação

```lua
local Lib = loadstring(game:HttpGet("https://seu-host.com/Compiled.lua"))()
```

---

## 🚀 Quick Start

```lua
local Window = Lib:CreateWindow({
    Title = "Meu Hub",
    Theme = "Neon",          -- Default | Midnight | AMOLED | Neon | Cyberpunk | Glass | Purple | Light
    ToggleUIKeybind = "K",
    ConfigurationSaving = { Enabled = true, FileName = "Config" }
})

-- API Chainada Moderna
Window:Tab("Combat")
    :Section("Aura")
    :Toggle({ Name = "Kill Aura", Default = true, Flag = "KA",
        Callback = function(v) print("KA:", v) end })
    :Slider({ Name = "Range", Range = {1, 50}, Default = 15, Suffix = "studs" })

Window:Tab("Visuals")
    :Section("ESP")
    :Dropdown({ Name = "Mode", Options = {"Box", "Tracer", "Off"}, Default = "Box" })
    :ColorPicker({ Name = "Color", Default = Color3.fromRGB(255, 0, 0) })

Window:Tab("Settings")
    :Section("Keys")
    :Keybind({ Name = "Menu", Default = "K", Hold = false })
    :Input({ Name = "Player", Default = "", Placeholder = "Nome..." })

Lib:LoadConfiguration()
```

---

## 🎨 Temas

| Tema | Identificador | Estilo |
|------|---------------|--------|
| **Default** | `Default` | Dark moderno, azul como accent |
| **Midnight** | `Midnight` | Azul escuro profundo |
| **AMOLED** | `AMOLED` | Preto puro (#000) para telas OLED |
| **Neon** | `Neon` | Roxo neon vibrante |
| **Cyberpunk** | `Cyberpunk` | Amarelo/laranja cyberpunk |
| **Glass** | `Glass` | Efeito vidro/glassmorphism |
| **Purple** | `Purple` | Roxo elegante |
| **Light** | `Light` | Modo claro profissional |

```lua
Lib:ModifyTheme("Neon")
Lib.ThemeManager:ApplyTheme("AMOLED")
```

---

## 🧩 Componentes (Leves e Modernos)

A lib inclui componentes standalone que podem ser usados fora da janela:

```lua
-- Watermark com FPS
local watermark = Lib.Components.Watermark:Create({
    Text = "Meu Script",
    ShowFPS = true,
    ShowMemory = true,
    PositionX = 12, PositionY = 12
})

-- Gráfico de FPS
local fpsGraph = Lib.Components.FPSGraph:Create({
    Width = 220, Height = 80,
    PositionX = 12, PositionY = 50
})

-- Botão moderno com ripple
local btn = Lib.Components.Button:Create({
    Name = "Meu Botão",
    Title = "Executar",
    Ripple = true,
    Callback = function()
        print("Clicou!")
    end
})

-- Toggle premium
local toggle = Lib.Components.Toggle:Create({
    Name = "Auto Farm",
    Default = false,
    Callback = function(v) print("Toggle:", v) end
})

-- Slider moderno
local slider = Lib.Components.Slider:Create({
    Name = "Velocidade",
    Range = {0, 100}, Increment = 5,
    Suffix = "%", Default = 50,
    Callback = function(v) print("Speed:", v) end
})
```

---

## 🏗️ Módulos Internos

| Módulo | Descrição | Acesso |
|--------|-----------|--------|
| **ThemeManager** | 8 temas + custom + live listeners | `Lib.ThemeManager` |
| **EventManager** | Pub/sub central | `Lib.EventManager` |
| **Performance** | Object pooling + batch | `Lib.Performance` |
| **Animations** | Springs + easing + ripple | `Lib.Animations` |
| **Rendering** | FPS tracker + deferred render | `Lib.Rendering` |
| **BlurEngine** | Efeito blur | `Lib.BlurEngine` |
| **Acrylic** | Glassmorphism | `Lib.Acrylic` |
| **NotificationManager** | Notificações com fila | `Lib.NotificationManager` |
| **MobileManager** | Touch + scale | `Lib.MobileManager` |
| **SearchManager** | Fuzzy search | `Lib.SearchManager` |
| **DockManager** | Dock flutuante | `Lib.DockManager` |
| **PluginManager** | Sistema de plugins | `Lib.PluginManager` |
| **ConfigManager** | Config profiles | `Lib.ConfigManager` |
| **Signals** | Eventos custom | `Lib.Signals` |
| **Springs** | Spring physics | `Lib.Springs` |
| **Cache** | Cache inteligente | `Lib.Cache` |

---

## 🪟 Dock System

```lua
local dock = Lib.DockManager:CreateDock({
    Position = "right",  -- right | left
    Size = 48,
    Color = Color3.fromRGB(32, 32, 40)
})

Lib.DockManager:AddButton("dock_ID", {
    Name = "Toggle UI",
    Icon = "rbxassetid://123456",
    OnClick = function()
        Lib:SetVisibility(not Lib:IsVisible())
    end
})
```

---

## 📢 Notificações Modernas

```lua
Lib.NotificationManager:Notify({
    Title = "Sucesso!",
    Content = "Script carregado com sucesso.",
    Duration = 5,
    Color = Color3.fromRGB(45, 200, 120),  -- custom color
    OnClick = function() print("Notificação clicada!") end
})
```

---

## 🔌 Sistema de Plugins

```lua
Lib.PluginManager:Register({
    Name = "AutoSave",
    Version = "1.0",
    Init = function()
        print("Plugin AutoSave carregado!")
        -- Auto-save a cada 30s
        while task.wait(30) do
            Lib.ConfigManager:Save()
        end
    end,
    Cleanup = function()
        print("Plugin descarregado!")
    end
})
```

---

## 📊 Performance

```lua
-- Verificar FPS atual
Lib.Rendering:GetFPS()

-- Deferred rendering (evita lag)
Lib.Rendering:Defer(function()
    -- Código pesado aqui
end, 1)

-- Object pooling
Lib.Performance:CreatePool("buttons", 
    function() return Instance.new("TextButton") end,
    function(btn, name) btn.Text = name end, 10)

local btn = Lib.Performance:Get("buttons", "Botão 1")
-- usar...
Lib.Performance:Return("buttons", btn)
```

---

## 🎨 Efeitos Visuais

```lua
-- Blur
local blur = Lib.BlurEngine:Attach(CoreGui, 24)
Lib.BlurEngine:SetIntensity(blur, 48)

-- Acrylic (glassmorphism)
Lib.Acrylic:Apply(minhaFrame, {
    TintTransparency = 0.4,
    Blur = 24
})

-- Spring animation
local spring = Lib.Springs.new(0, {frequency = 2, damping = 0.6})
spring:onUpdate(function(v)
    frame.BackgroundTransparency = v
end)
spring:to(0.5)

-- Ripple effect
Lib.Animations.Ripple(button, Color3.fromRGB(255,255,255))
```

---

## 📱 Mobile Support

```lua
if Lib.MobileManager:IsMobile() then
    local scale = Lib.MobileManager:GetScale()
    -- Ajusta UI para mobile
end

-- Touch drag
Lib.MobileManager:EnableDrag(windowFrame, topBar)
```

---

## 🔍 Search System

```lua
local search = Lib.SearchManager:Create({
    Source = {"Kill Aura", "ESP", "Speed", "Fly"},
    MinChars = 1,
    OnResult = function(results, query)
        for _, r in ipairs(results) do
            print(r.Text, r.Score)
        end
    end
})

Lib.SearchManager:Query(search.Id, "au")
```

---

## 📋 API Completa

### Window
```lua
Lib:CreateWindow(config) → enhancedWindow
enhancedWindow:Tab(config) → enhancedTab
```

### Tab Methods (chainable)
```lua
:Section(name)
:Toggle(config)
:Slider(config)
:Button(config)
:Input(config)
:Dropdown(config)
:Keybind(config)
:ColorPicker(config)
:Label(text, icon, color)
:Paragraph(config)
:Divider()
```

### Config
```lua
config = {
    Title = "string",
    Icon = 0 | "lucide-name",
    Theme = "Default" | "Midnight" | "AMOLED" | "Neon" | "Cyberpunk" | "Glass" | "Purple" | "Light",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    ConfigurationSaving = { Enabled = true, FileName = "Config" },
    Discord = { Enabled = false, Invite = "" },
    KeySystem = false,
    KeySettings = { ... },
}
```

---

## ⚖️ Licença

MIT — livre para uso, modificação e distribuição.
Baseado em Rayfield Interface Suite © Sirius.
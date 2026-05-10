-- [[
-- 	Rayfield Enhanced — DockManager.lua
-- 	Floating dock/sidebar system for minimized UI access
-- ]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local DockManager = {}

local dockInstances = {}

-- ============================================================
-- 	DOCK CREATION
-- ============================================================

function DockManager:CreateDock(config)
	config = config or {}
	
	local dock = {
		Id = config.Id or "dock_" .. tick(),
		Position = config.Position or "right",
		Size = config.Size or 48,
		Color = config.Color or Color3.fromRGB(32, 32, 40),
		Icon = config.Icon or "",
		Buttons = {},
		_instances = {},
	}
	
	-- Create dock GUI
	local container = Instance.new("ScreenGui")
	container.Name = "EnhancedDock_" .. dock.Id
	container.DisplayOrder = 500
	container.ResetOnSpawn = false

	if gethui then
		container.Parent = gethui()
	else
		container.Parent = CoreGui
	end

	local frame = Instance.new("Frame")
	frame.Name = "DockFrame"
	frame.BackgroundColor3 = dock.Color
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(55, 55, 68)
	stroke.Thickness = 1
	stroke.Transparency = 0
	stroke.Parent = frame
	
	-- Position
	if dock.Position == "right" then
		frame.Position = UDim2.new(1, -dock.Size - 12, 0.5, -(dock.Size * 3))
		frame.Size = UDim2.new(0, dock.Size, 0, dock.Size * 6)
	elseif dock.Position == "left" then
		frame.Position = UDim2.new(0, 12, 0.5, -(dock.Size * 3))
		frame.Size = UDim2.new(0, dock.Size, 0, dock.Size * 6)
	end

	frame.Parent = container

	-- UIListLayout for buttons
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 4)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Parent = frame

	dock._instances = {
		Container = container,
		Frame = frame,
		ListLayout = listLayout,
	}

	dockInstances[dock.Id] = dock
	return dock
end

-- ============================================================
-- 	DOCK BUTTONS
-- ============================================================

function DockManager:AddButton(dockId, config)
	local dock = dockInstances[dockId]
	if not dock then return nil end
	
	config = config or {}
	
	local button = Instance.new("ImageButton")
	button.Name = config.Name or "DockButton"
	button.Size = UDim2.new(0, dock.Size - 8, 0, dock.Size - 8)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	button.BackgroundTransparency = 1
	button.ImageTransparency = 0
	button.Image = config.Icon or ""
	button.ImageColor3 = config.Color or Color3.fromRGB(200, 200, 210)
	button.ZIndex = 10

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = button

	button.Parent = dock._instances.Frame

	-- Hover effect
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundTransparency = 0.3,
			Size = UDim2.new(0, dock.Size - 4, 0, dock.Size - 4),
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, dock.Size - 8, 0, dock.Size - 8),
		}):Play()
	end)

	if config.OnClick then
		button.MouseButton1Click:Connect(function()
			pcall(config.OnClick)
		end)
	end

	table.insert(dock.Buttons, {
		Config = config,
		Instance = button,
	})

	return button
end

-- ============================================================
-- 	DOCK MANAGEMENT
-- ============================================================

function DockManager:RemoveDock(dockId)
	local dock = dockInstances[dockId]
	if not dock then return end
	
	pcall(function() dock._instances.Container:Destroy() end)
	dockInstances[dockId] = nil
end

function DockManager:RemoveAllDocks()
	for id, _ in pairs(dockInstances) do
		self:RemoveDock(id)
	end
end

function DockManager:ShowDock(dockId)
	local dock = dockInstances[dockId]
	if not dock then return end
	
	if dock._instances.Container then
		dock._instances.Container.Enabled = false
	end
end

function DockManager:HideDock(dockId)
	local dock = dockInstances[dockId]
	if not dock then return end
	
	if dock._instances.Container then
		dock._instances.Container.Enabled = false
	end
end

return DockManager
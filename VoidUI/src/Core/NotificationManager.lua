-- [[
-- 	Rayfield Enhanced — NotificationManager.lua
-- 	Modern notification system with queue, types, and animations
-- ]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local NotificationManager = {}
NotificationManager.__index = NotificationManager

local notificationQueue = {}
local isProcessing = false
local activeNotifications = {}
local maxVisible = 5

-- ============================================================
-- 	NOTIFICATION TYPES
-- ============================================================

local NOTIFY_TYPES = {
	Default = {
		Icon = "",
		Color = Color3.fromRGB(88, 130, 255),
		Duration = 5,
	},
	Success = {
		Icon = "check-circle",
		Color = Color3.fromRGB(45, 200, 120),
		Duration = 4,
	},
	Warning = {
		Icon = "alert-triangle",
		Color = Color3.fromRGB(255, 180, 50),
		Duration = 6,
	},
	Error = {
		Icon = "x-circle",
		Color = Color3.fromRGB(235, 80, 80),
		Duration = 7,
	},
	Info = {
		Icon = "info",
		Color = Color3.fromRGB(60, 160, 230),
		Duration = 4,
	},
	Loading = {
		Icon = "loader-2",
		Color = Color3.fromRGB(88, 130, 255),
		Duration = nil, -- Stays until dismissed
	},
}

-- ============================================================
-- 	QUEUE SYSTEM
-- ============================================================

function NotificationManager:Notify(data)
	data = data or {}
	
	-- Determine type
	local notifyType = NOTIFY_TYPES[data.Type] or NOTIFY_TYPES.Default
	
	local notification = {
		Title = data.Title or "Notification",
		Content = data.Content or "",
		Duration = data.Duration or notifyType.Duration or 5,
		Icon = data.Icon or notifyType.Icon or "",
		Color = data.Color or notifyType.Color,
		Type = data.Type or "Default",
		Actions = data.Actions or {},
		OnClick = data.OnClick or nil,
		Id = tick() + math.random(),
	}
	
	table.insert(notificationQueue, notification)
	
	if not isProcessing then
		self:ProcessQueue()
	end
	
	return notification.Id
end

function NotificationManager:ProcessQueue()
	isProcessing = true
	
	task.spawn(function()
		while #notificationQueue > 0 do
			-- Limit visible notifications
			if #activeNotifications >= maxVisible then
				break
			end
			
			local notification = table.remove(notificationQueue, 1)
			self:ShowNotification(notification)
			task.wait(0.15)
		end
		isProcessing = false
	end)
end

function NotificationManager:ShowNotification(data)
	-- Create notification GUI
	local notif = Instance.new("Frame")
	notif.Name = "EnhancedNotification"
	notif.Size = UDim2.new(0, 320, 0, 0)
	notif.Position = UDim2.new(1, 10, 0, 10)
	notif.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	notif.BackgroundTransparency = 0.15
	notif.ClipsDescendants = true
	notif.ZIndex = 10000

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notif

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(55, 55, 68)
	stroke.Thickness = 1
	stroke.Transparency = 0
	stroke.Parent = notif

	-- Accent bar
	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.Size = UDim2.new(0, 3, 1, 0)
	accentBar.Position = UDim2.new(0, 0, 0, 0)
	accentBar.BackgroundColor3 = data.Color
	accentBar.BorderSizePixel = 0
	accentBar.Parent = notif

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 20)
	title.Position = UDim2.new(0, 16, 0, 10)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamSemibold
	title.Text = data.Title
	title.TextColor3 = Color3.fromRGB(230, 230, 240)
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 10001
	title.Parent = notif

	-- Content
	local content = Instance.new("TextLabel")
	content.Size = UDim2.new(1, -20, 0, 0)
	content.Position = UDim2.new(0, 16, 0, 32)
	content.BackgroundTransparency = 1
	content.Font = Enum.Font.Gotham
	content.Text = data.Content
	content.TextColor3 = Color3.fromRGB(170, 170, 185)
	content.TextSize = 13
	content.TextXAlignment = Enum.TextXAlignment.Left
	content.TextWrapped = true
	content.ZIndex = 10001
	content.Parent = notif

	-- Calculate height
	local textHeight = content.TextBounds.Y
	local notifHeight = math.max(60, textHeight + 50)
	notif.Size = UDim2.new(0, 320, 0, notifHeight)

	-- Shadow
	local shadow = Instance.new("ImageLabel")
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0, -10, 0, -10)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5587865193"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.8
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.ZIndex = 9999
	shadow.Parent = notif

	-- Parent to notifications container
	local container = getNotificationContainer()
	notif.Parent = container

	-- Track active
	table.insert(activeNotifications, notif)

	-- Animate in
	notif.Position = UDim2.new(1, 10, 0, getNotificationOffset())
	
	TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -330, 0, getNotificationOffset()),
		BackgroundTransparency = 0,
	}):Play()

	-- Auto dismiss
	if data.Duration and data.Duration > 0 then
		task.delay(data.Duration, function()
			self:Dismiss(notif)
		end)
	end

	-- Click handler
	if data.OnClick then
		notif.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				pcall(data.OnClick)
				self:Dismiss(notif)
			end
		end)
	end
end

function NotificationManager:Dismiss(notif)
	if not notif or not notif.Parent then return end
	
	-- Remove from active list
	for i, n in ipairs(activeNotifications) do
		if n == notif then
			table.remove(activeNotifications, i)
			break
		end
	end

	-- Animate out
	TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 10, 0, notif.Position.Y.Offset),
		BackgroundTransparency = 1,
	}):Play()

	task.delay(0.4, function()
		pcall(function() notif:Destroy() end)
		repositionNotifications()
		
		-- Process next in queue
		if #notificationQueue > 0 then
			NotificationManager:ProcessQueue()
		end
	end)
end

function NotificationManager:DismissAll()
	for _, notif in ipairs(activeNotifications) do
		self:Dismiss(notif)
	end
end

-- ============================================================
-- 	HELPERS
-- ============================================================

function getNotificationContainer()
	local container = CoreGui:FindFirstChild("EnhancedNotifications")
	if not container then
		container = Instance.new("ScreenGui")
		container.Name = "EnhancedNotifications"
		container.DisplayOrder = 1000
		container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		container.ResetOnSpawn = false

		if gethui then
			container.Parent = gethui()
		else
			container.Parent = CoreGui
		end
	end
	return container
end

function getNotificationOffset()
	local offset = 10
	for _, notif in ipairs(activeNotifications) do
		offset = offset + notif.AbsoluteSize.Y + 8
	end
	return offset
end

function repositionNotifications()
	local y = 10
	for _, notif in ipairs(activeNotifications) do
		TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -330, 0, y),
		}):Play()
		y = y + notif.AbsoluteSize.Y + 8
	end
end

return NotificationManager
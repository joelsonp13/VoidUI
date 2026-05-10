-- [[
-- 	Rayfield Enhanced — SidebarEngine.lua
-- 	Modern sidebar with icons, collapse, spring animations, blur backdrop
-- 	Priority: ABSOLUTE — defines the "face" of the library
-- ]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local SidebarEngine = {}

local sidebarInstances = {}

function SidebarEngine:Create(config)
	config = config or {}

	local width = config.Width or 220
	local collapsedWidth = config.CollapsedWidth or 56
	local collapsed = config.Collapsed or false
	local side = config.Side or "left" -- left | right

	local container = Instance.new("ScreenGui")
	container.Name = "EnhancedSidebar"
	container.DisplayOrder = 800
	container.ResetOnSpawn = false
	container.Parent = gethui and gethui() or CoreGui

	-- Main frame
	local frame = Instance.new("Frame")
	frame.Name = "SidebarFrame"
	frame.Size = UDim2.new(0, collapsed and collapsedWidth or width, 1, 0)
	frame.Position = UDim2.new(side == "left" and 0 or 1, 0, 0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
	frame.BackgroundTransparency = 0.05
	frame.BorderSizePixel = 0
	frame.ZIndex = 50
	frame.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, side == "left" and 0 or 12, 0, 0, side == "left" and 12 or 0)
	corner.Parent = frame

	-- Stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(40, 40, 52)
	stroke.Thickness = 1
	stroke.Transparency = 0
	stroke.Parent = frame

	-- Content
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = 0
	content.BorderSizePixel = 0
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 2)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = content

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = content

	-- Collapse button
	local collapseBtn = Instance.new("ImageButton")
	collapseBtn.Size = UDim2.new(0, 28, 0, 28)
	collapseBtn.Position = UDim2.new(1, -38, 0, 8)
	collapseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	collapseBtn.BackgroundTransparency = 0
	collapseBtn.Image = "rbxassetid://10137832201"
	collapseBtn.ImageColor3 = Color3.fromRGB(180, 180, 195)
	collapseBtn.ZIndex = 60

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = collapseBtn

	collapseBtn.Parent = frame

	-- Sidebar object
	local sidebar = {
		Config = config,
		Frame = frame,
		Content = content,
		CollapseBtn = collapseBtn,
		Container = container,
		ListLayout = listLayout,
		Items = {},
		Sections = {},
		IsCollapsed = collapsed,
		Width = width,
		CollapsedWidth = collapsedWidth,
		ItemIndex = 0,
	}

	-- Toggle collapse
	function sidebar:ToggleCollapse()
		self.IsCollapsed = not self.IsCollapsed
		local targetWidth = self.IsCollapsed and self.CollapsedWidth or self.Width
		TweenService:Create(self.Frame, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, targetWidth, 1, 0)
		}):Play()
	end

	collapseBtn.MouseButton1Click:Connect(function()
		sidebar:ToggleCollapse()
	end)

	-- Add section
	function sidebar:AddSection(name)
		local sectionFrame = Instance.new("Frame")
		sectionFrame.Size = UDim2.new(1, 0, 0, 24)
		sectionFrame.BackgroundTransparency = 1
		sectionFrame.BorderSizePixel = 0
		sectionFrame.LayoutOrder = self.ItemIndex
		self.ItemIndex = self.ItemIndex + 1

		local sectionTitle = Instance.new("TextLabel")
		sectionTitle.Size = UDim2.new(1, -24, 1, 0)
		sectionTitle.Position = UDim2.new(0, 12, 0, 0)
		sectionTitle.BackgroundTransparency = 1
		sectionTitle.Font = Enum.Font.GothamSemibold
		sectionTitle.Text = name:upper()
		sectionTitle.TextColor3 = Color3.fromRGB(110, 110, 125)
		sectionTitle.TextSize = 10
		sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
		sectionTitle.Parent = sectionFrame

		sectionFrame.Parent = self.Content
		table.insert(self.Sections, sectionFrame)
		return self
	end

	-- Add item
	function sidebar:AddItem(config)
		config = config or {}
		local itemFrame = Instance.new("TextButton")
		itemFrame.Name = config.Name or "Item"
		itemFrame.Size = UDim2.new(1, -8, 0, 40)
		itemFrame.Position = UDim2.new(0, 4, 0, 0)
		itemFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
		itemFrame.BackgroundTransparency = 1
		itemFrame.Text = ""
		itemFrame.AutoButtonColor = false
		itemFrame.ZIndex = 55
		itemFrame.LayoutOrder = self.ItemIndex
		self.ItemIndex = self.ItemIndex + 1

		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 8)
		itemCorner.Parent = itemFrame

		-- Active indicator
		local indicator = Instance.new("Frame")
		indicator.Size = UDim2.new(0, 3, 0, 0)
		indicator.Position = UDim2.new(0, 0, 0.5, 0)
		indicator.AnchorPoint = Vector2.new(0, 0.5)
		indicator.BackgroundColor3 = Color3.fromRGB(88, 130, 255)
		indicator.BackgroundTransparency = 1
		indicator.BorderSizePixel = 0
		indicator.ZIndex = 56

		local indicatorCorner = Instance.new("UICorner")
		indicatorCorner.CornerRadius = UDim.new(0, 2)
		indicatorCorner.Parent = indicator

		indicator.Parent = itemFrame

		-- Icon
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 22, 0, 22)
		icon.Position = UDim2.new(0, 12, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.BackgroundTransparency = 1
		icon.Image = config.Icon or ""
		icon.ImageColor3 = Color3.fromRGB(170, 170, 185)
		icon.ZIndex = 56
		icon.Parent = itemFrame

		-- Label
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -50, 1, 0)
		label.Position = UDim2.new(0, 44, 0, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.Text = config.Name or "Item"
		label.TextColor3 = Color3.fromRGB(200, 200, 215)
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 56
		label.Parent = itemFrame

		itemFrame.Parent = self.Content

		-- Hover
		itemFrame.MouseEnter:Connect(function()
			if config.Active then return end
			TweenService:Create(itemFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.4
			}):Play()
			TweenService:Create(icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.fromRGB(220, 220, 235)
			}):Play()
		end)

		itemFrame.MouseLeave:Connect(function()
			if config.Active then return end
			TweenService:Create(itemFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = Color3.fromRGB(170, 170, 185)
			}):Play()
		end)

		-- Active state
		if config.Active then
			itemFrame.BackgroundTransparency = 0.3
			itemFrame.BackgroundColor3 = Color3.fromRGB(88, 130, 255)
			indicator.BackgroundTransparency = 0
			TweenService:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 3, 0, 24)
			}):Play()
			icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		-- Click
		if config.Callback then
			itemFrame.MouseButton1Click:Connect(function()
				config.Callback()
			end)
		end

		table.insert(self.Items, {
			Frame = itemFrame,
			Config = config,
			Icon = icon,
			Label = label,
			Indicator = indicator,
		})

		return self
	end

	sidebarInstances[config.Id or "main"] = sidebar

	local selfTable = {}
	function selfTable:Collapse() sidebar:ToggleCollapse() end
	function selfTable:AddSection(n) sidebar:AddSection(n); return self end
	function selfTable:AddItem(c) sidebar:AddItem(c); return self end
	function selfTable:Destroy() container:Destroy() end
	return selfTable
end

return SidebarEngine
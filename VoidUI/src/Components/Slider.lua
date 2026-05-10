-- [[
-- 	Rayfield Enhanced — Slider.lua
-- 	Modern slider with live value display, smooth drag
-- ]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local SliderComponent = {}

function SliderComponent.Create(config)
	config = config or {}
	local min = config.Range and config.Range[1] or 0
	local max = config.Range and config.Range[2] or 100
	local increment = config.Increment or 1
	local suffix = config.Suffix or ""
	local value = config.Default or min
	local callback = config.Callback or function() end

	local frame = Instance.new("Frame")
	frame.Name = config.Name or "Slider"
	frame.Size = UDim2.new(1, -10, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	frame.BackgroundTransparency = 0
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(50, 50, 62)
	stroke.Thickness = 1
	stroke.Parent = frame

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 18)
	title.Position = UDim2.new(0, 14, 0, 8)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.Gotham
	title.Text = config.Name or "Slider"
	title.TextColor3 = Color3.fromRGB(220, 220, 230)
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	-- Value display
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 60, 0, 18)
	valueLabel.Position = UDim2.new(1, -74, 0, 8)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.GothamSemibold
	valueLabel.Text = tostring(value) .. " " .. suffix
	valueLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame

	-- Track
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -28, 0, 6)
	track.Position = UDim2.new(0, 14, 0, 34)
	track.BackgroundColor3 = Color3.fromRGB(42, 42, 54)
	track.BorderSizePixel = 0
	track.Parent = frame

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 3)
	trackCorner.Parent = track

	-- Progress
	local progress = Instance.new("Frame")
	progress.Size = UDim2.new(0, 0, 1, 0)
	progress.BackgroundColor3 = Color3.fromRGB(88, 130, 255)
	progress.BorderSizePixel = 0
	progress.Parent = track

	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 3)
	progressCorner.Parent = progress

	-- Handle
	local handle = Instance.new("Frame")
	handle.Size = UDim2.new(0, 16, 0, 16)
	handle.Position = UDim2.new(0, 0, 0.5, 0)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	handle.BorderSizePixel = 0
	handle.ZIndex = 3
	handle.Parent = track

	local handleCorner = Instance.new("UICorner")
	handleCorner.CornerRadius = UDim.new(0, 8)
	handleCorner.Parent = handle

	-- Interact
	local interact = Instance.new("TextButton")
	interact.Size = UDim2.new(1, 0, 1, 0)
	interact.BackgroundTransparency = 1
	interact.Text = ""
	interact.ZIndex = 10
	interact.Parent = frame

	local dragging = false

	local function updateValue(newVal, fromDrag)
		newVal = math.clamp(newVal, min, max)
		newVal = math.floor(newVal / increment + 0.5) * increment
		value = newVal
		local ratio = (value - min) / (max - min)
		local trackWidth = track.AbsoluteSize.X
		progress.Size = UDim2.new(0, math.max(ratio * trackWidth, 0), 1, 0)
		handle.Position = UDim2.new(ratio, 0, 0.5, 0)
		valueLabel.Text = tostring(value) .. " " .. suffix
		if fromDrag then
			callback(value)
		end
	end

	-- Initial set
	task.wait()
	updateValue(value, false)

	interact.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local mousePos = UserInputService:GetMouseLocation()
			local trackPos = track.AbsolutePosition
			local localX = mousePos.X - trackPos.X
			local ratio = math.clamp(localX / track.AbsoluteSize.X, 0, 1)
			updateValue(min + ratio * (max - min), true)
		end
	end)

	local connection
	connection = RunService.RenderStepped:Connect(function()
		if dragging then
			local mousePos = UserInputService:GetMouseLocation()
			local trackPos = track.AbsolutePosition
			local localX = mousePos.X - trackPos.X
			local ratio = math.clamp(localX / track.AbsoluteSize.X, 0, 1)
			updateValue(min + ratio * (max - min), true)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local selfTable = {}
	function selfTable:Set(val) updateValue(val, false) end
	function selfTable:Get() return value end
	function selfTable:Destroy() if connection then connection:Disconnect() end; frame:Destroy() end
	return selfTable, frame
end

return SliderComponent
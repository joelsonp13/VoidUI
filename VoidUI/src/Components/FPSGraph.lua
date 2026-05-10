-- [[
-- 	Rayfield Enhanced — FPSGraph.lua
-- 	Real-time FPS/memory performance graph
-- ]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local FPSGraphComponent = {}

function FPSGraphComponent.Create(config)
	config = config or {}

	local container = Instance.new("ScreenGui")
	container.Name = "EnhancedFPSGraph"
	container.DisplayOrder = 5000
	container.ResetOnSpawn = false
	container.Parent = gethui and gethui() or CoreGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, config.Width or 220, 0, config.Height or 80)
	frame.Position = UDim2.new(0, config.PositionX or 12, 0, config.PositionY or 50)
	frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(40, 40, 52)
	stroke.Thickness = 1
	stroke.Parent = frame

	-- FPS Label
	local fpsLabel = Instance.new("TextLabel")
	fpsLabel.Size = UDim2.new(0, 60, 0, 18)
	fpsLabel.Position = UDim2.new(0, 8, 0, 4)
	fpsLabel.BackgroundTransparency = 1
	fpsLabel.Font = Enum.Font.GothamSemibold
	fpsLabel.Text = "60 FPS"
	fpsLabel.TextColor3 = Color3.fromRGB(88, 130, 255)
	fpsLabel.TextSize = 13
	fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsLabel.Parent = frame

	-- Memory Label
	local memLabel = Instance.new("TextLabel")
	memLabel.Size = UDim2.new(0, 100, 0, 18)
	memLabel.Position = UDim2.new(1, -108, 0, 4)
	memLabel.BackgroundTransparency = 1
	memLabel.Font = Enum.Font.Gotham
	memLabel.Text = "0 KB"
	memLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
	memLabel.TextSize = 11
	memLabel.TextXAlignment = Enum.TextXAlignment.Right
	memLabel.Parent = frame

	-- Graph canvas
	local canvas = Instance.new("Frame")
	canvas.Size = UDim2.new(1, -16, 0, 40)
	canvas.Position = UDim2.new(0, 8, 0, 28)
	canvas.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	canvas.BackgroundTransparency = 0
	canvas.BorderSizePixel = 0
	canvas.Parent = frame

	local canvasCorner = Instance.new("UICorner")
	canvasCorner.CornerRadius = UDim.new(0, 4)
	canvasCorner.Parent = canvas

	local graph = Instance.new("Frame")
	graph.Size = UDim2.new(1, -4, 1, -4)
	graph.Position = UDim2.new(0, 2, 0, 2)
	graph.BackgroundTransparency = 1
	graph.ClipsDescendants = true
	graph.Parent = canvas

	-- Data points
	local dataPoints = {}
	local maxPoints = config.MaxPoints or 60
	local graphObj = {_running = true}

	RunService.RenderStepped:Connect(function(dt)
		if not graphObj._running then return end
		local fps = 1 / dt
		local mem = collectgarbage("count")

		table.insert(dataPoints, fps)
		if #dataPoints > maxPoints then table.remove(dataPoints, 1) end

		fpsLabel.Text = math.floor(fps) .. " FPS"
		fpsLabel.TextColor3 = fps > 50 and Color3.fromRGB(45, 200, 120) or (fps > 30 and Color3.fromRGB(255, 180, 50) or Color3.fromRGB(235, 80, 80))
		memLabel.Text = math.floor(mem) .. " KB"

		-- Draw graph lines
		for _, child in ipairs(graph:GetChildren()) do if child.Name == "Line" then child:Destroy() end end

		local w = graph.AbsoluteSize.X - 4
		local h = graph.AbsoluteSize.Y - 4
		local maxFPS = 120

		for i = 1, #dataPoints - 1 do
			local x1 = (i - 1) / maxPoints * w
			local x2 = i / maxPoints * w
			local y1 = h - (math.clamp(dataPoints[i], 0, maxFPS) / maxFPS) * h
			local y2 = h - (math.clamp(dataPoints[i + 1], 0, maxFPS) / maxFPS) * h

			local line = Instance.new("Frame")
			line.Name = "Line"
			line.BackgroundColor3 = Color3.fromRGB(88, 130, 255)
			line.BorderSizePixel = 0
			line.ZIndex = 5

			local dx = x2 - x1
			local dy = y2 - y1
			local length = math.sqrt(dx * dx + dy * dy)
			local angle = math.atan2(dy, dx)

			line.Size = UDim2.new(0, math.max(length, 1), 0, 2)
			line.Position = UDim2.fromOffset(x1 + 2, y1 + 2)
			line.Rotation = math.deg(angle)

			local lineCorner = Instance.new("UICorner")
			lineCorner.CornerRadius = UDim.new(0, 1)
			lineCorner.Parent = line

			line.Parent = graph
		end
	end)

	local selfTable = {}
	function selfTable:Destroy() graphObj._running = false; container:Destroy() end
	return selfTable
end

return FPSGraphComponent
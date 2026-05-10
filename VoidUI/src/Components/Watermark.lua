-- [[
-- 	Rayfield Enhanced — Watermark.lua
-- 	Premium watermark with FPS, memory, and custom text
-- ]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local WatermarkComponent = {}

local watermarkInstances = {}

function WatermarkComponent.Create(config)
	config = config or {}
	if watermarkInstances[config.Name or "Main"] then return watermarkInstances[config.Name or "Main"] end

	local container = Instance.new("ScreenGui")
	container.Name = "EnhancedWatermark"
	container.DisplayOrder = 10000
	container.ResetOnSpawn = false
	container.Parent = gethui and gethui() or CoreGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, config.Width or 200, 0, config.Height or 28)
	frame.Position = UDim2.new(0, config.PositionX or 12, 0, config.PositionY or 12)
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(55, 55, 68)
	stroke.Thickness = 1
	stroke.Transparency = 0
	stroke.Parent = frame

	-- Text content
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -12, 1, 0)
	text.Position = UDim2.new(0, 6, 0, 0)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamSemibold
	text.TextSize = 13
	text.TextColor3 = Color3.fromRGB(220, 220, 230)
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Parent = frame

	local watermark = {
		Config = config,
		Frame = frame,
		Text = text,
		Container = container,
		_running = true,
	}

	-- FPS counter
	local fps = 60
	local frameTime = 0
	RunService.RenderStepped:Connect(function(dt)
		frameTime = dt
		fps = 1 / dt
		if watermark._running then
			local fpsText = config.ShowFPS ~= false and ("FPS: " .. math.floor(fps)) or ""
			local memText = config.ShowMemory and (" | MEM: " .. math.floor(collectgarbage("count")) .. "KB") or ""
			local customText = config.Text or ""
			local sep = (customText ~= "" and (fpsText ~= "" or memText ~= "")) and " | " or ""
			text.Text = customText .. sep .. fpsText .. memText
		end
	end)

	-- Draggable
	if config.Draggable ~= false then
		local dragging = false; local offset = Vector2.new()
		frame.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; offset = frame.AbsolutePosition - i.Position end
		end)
		frame.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		frame.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				frame.Position = UDim2.fromOffset(i.Position.X + offset.X, i.Position.Y + offset.Y)
			end
		end)
	end

	watermarkInstances[config.Name or "Main"] = watermark

	local selfTable = {}
	function selfTable:SetText(t) config.Text = t end
	function selfTable:Hide() frame.Visible = false end
	function selfTable:Show() frame.Visible = true end
	function selfTable:Destroy() watermark._running = false; container:Destroy(); watermarkInstances[config.Name or "Main"] = nil end
	return selfTable
end

return WatermarkComponent
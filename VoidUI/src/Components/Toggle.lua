-- [[
-- 	Rayfield Enhanced — Toggle.lua
-- 	Premium toggle switch with spring animation
-- ]]

local TweenService = game:GetService("TweenService")

local ToggleComponent = {}

function ToggleComponent.Create(config)
	config = config or {}
	local state = config.Default or false
	local callback = config.Callback or function() end

	local frame = Instance.new("Frame")
	frame.Name = config.Name or "Toggle"
	frame.Size = UDim2.new(1, -10, 0, 42)
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
	title.Size = UDim2.new(1, -70, 1, 0)
	title.Position = UDim2.new(0, 14, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.Gotham
	title.Text = config.Name or "Toggle"
	title.TextColor3 = Color3.fromRGB(220, 220, 230)
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	-- Switch track
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(0, 44, 0, 24)
	track.Position = UDim2.new(1, -58, 0.5, 0)
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	track.BorderSizePixel = 0
	track.Parent = frame

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 12)
	trackCorner.Parent = track

	-- Switch knob
	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(0, 3, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
	knob.BorderSizePixel = 0
	knob.ZIndex = 2
	knob.Parent = track

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(0, 9)
	knobCorner.Parent = knob

	-- Click detection
	local interact = Instance.new("TextButton")
	interact.Size = UDim2.new(1, 0, 1, 0)
	interact.BackgroundTransparency = 1
	interact.Text = ""
	interact.ZIndex = 10
	interact.Parent = frame

	-- Set initial state
	local function updateState(newState, animate)
		state = newState
		if state then
			track.BackgroundColor3 = Color3.fromRGB(88, 130, 255)
			if animate then
				TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(1, -21, 0.5, 0)
				}):Play()
			else
				knob.Position = UDim2.new(1, -21, 0.5, 0)
			end
		else
			track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			if animate then
				TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, 3, 0.5, 0)
				}):Play()
			else
				knob.Position = UDim2.new(0, 3, 0.5, 0)
			end
		end
	end

	updateState(state, false)

	interact.MouseButton1Click:Connect(function()
		updateState(not state, true)
		callback(state)
	end)

	-- Public API
	local selfTable = {}

	function selfTable:Set(value)
		updateState(value, true)
	end

	function selfTable:Get()
		return state
	end

	function selfTable:Toggle()
		updateState(not state, true)
		callback(state)
	end

	function selfTable:SetCallback(cb)
		callback = cb
	end

	function selfTable:Destroy()
		frame:Destroy()
	end

	return selfTable, frame
end

return ToggleComponent
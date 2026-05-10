-- [[
-- 	Rayfield Enhanced — MobileManager.lua
-- 	Mobile support: touch gestures, auto-scaling, adaptive layout
-- ]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MobileManager = {}

-- ============================================================
-- 	DETECTION
-- ============================================================

function MobileManager:IsMobile()
	return UserInputService.TouchEnabled
end

function MobileManager:GetDeviceType()
	if UserInputService.TouchEnabled then
		return "Mobile"
	elseif UserInputService.GamepadEnabled then
		return "Console"
	else
		return "Desktop"
	end
end

function MobileManager:GetScreenSize()
	return workspace.CurrentCamera.ViewportSize
end

-- ============================================================
-- 	SCALING
-- ============================================================

function MobileManager:GetScale()
	local viewport = self:GetScreenSize()
	if viewport.X < 600 then
		return 0.65 -- Small phones
	elseif viewport.X < 900 then
		return 0.8 -- Large phones / small tablets
	elseif viewport.X < 1200 then
		return 0.9 -- Tablets
	else
		return 1.0 -- Desktop
	end
end

function MobileManager:IsCompact()
	local viewport = self:GetScreenSize()
	return viewport.X < 700
end

-- ============================================================
-- 	TOUCH GESTURES
-- ============================================================

function MobileManager:EnableSwipeToClose(guiObject, threshold, callback)
	threshold = threshold or 100
	local startPos = nil
	local startTime = nil

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			startPos = input.Position
			startTime = tick()
		end
	end)

	guiObject.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch and startPos then
			local endPos = input.Position
			local delta = endPos - startPos
			local elapsed = tick() - startTime

			if math.abs(delta.Y) > threshold and elapsed < 0.5 then
				if callback then
					pcall(callback, delta.Y > 0 and "down" or "up", delta.Y)
				end
			end

			startPos = nil
			startTime = nil
		end
	end)
end

function MobileManager:EnableDrag(guiObject, dragHandle)
	dragHandle = dragHandle or guiObject
	
	local dragging = false
	local dragOffset = Vector2.new()

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragOffset = guiObject.AbsolutePosition - input.Position
		end
	end)

	dragHandle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.Touch then
			guiObject.Position = UDim2.fromOffset(
				input.Position.X + dragOffset.X,
				input.Position.Y + dragOffset.Y
			)
		end
	end)
end

-- ============================================================
-- 	ADAPTIVE LAYOUT
-- ============================================================

function MobileManager:AdaptWindow(window, mainFrame)
	if not self:IsMobile() then return end
	
	local scale = self:GetScale()
	
	-- Scale window
	mainFrame.Size = UDim2.new(0, 500 * scale, 0, 400 * scale)
	
	-- Adjust spacing for touch
	for _, child in ipairs(mainFrame:GetDescendants()) do
		if child:IsA("TextButton") or child:IsA("ImageButton") then
			child.Size = UDim2.new(
				child.Size.X.Scale,
				child.Size.X.Offset * scale,
				child.Size.Y.Scale,
				math.max(child.Size.Y.Offset * scale, 40)
			)
		end
	end
end

return MobileManager
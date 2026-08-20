local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local SPLIT_LOADER_URL = "https://raw.githubusercontent.com/zavadskijmatvej84/torti-hub-base-20260818-copy/main/main-split-loader.lua?v=20260820-trade-tab-v18"
local ACCESS_KEY = "Tort1"

local function notify(text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Torti Key Loader",
			Text = tostring(text),
			Duration = 6,
		})
	end)
end

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("TortiKeyLoaderGui")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TortiKeyLoaderGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
overlay.BackgroundTransparency = 0.22
overlay.BorderSizePixel = 0
overlay.ZIndex = 10
overlay.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(392, 248)
panel.BackgroundColor3 = Color3.fromRGB(20, 16, 18)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.ZIndex = 20
panel.Parent = overlay

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 22)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 255, 255)
panelStroke.Thickness = 1
panelStroke.Transparency = 0.86
panelStroke.Parent = panel

local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 29, 30)),
	ColorSequenceKeypoint.new(0.3, Color3.fromRGB(27, 21, 22)),
	ColorSequenceKeypoint.new(0.65, Color3.fromRGB(16, 16, 18)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 10, 12)),
})
panelGradient.Rotation = 112
panelGradient.Parent = panel

local topGlow = Instance.new("Frame")
topGlow.Size = UDim2.new(1.02, 0, 0, 88)
topGlow.Position = UDim2.new(-0.01, 0, -0.03, 0)
topGlow.BackgroundColor3 = Color3.fromRGB(255, 145, 105)
topGlow.BackgroundTransparency = 0.985
topGlow.BorderSizePixel = 0
topGlow.ZIndex = 20
topGlow.Parent = panel

local topGlowCorner = Instance.new("UICorner")
topGlowCorner.CornerRadius = UDim.new(1, 0)
topGlowCorner.Parent = topGlow

local sideGlow = Instance.new("Frame")
sideGlow.Size = UDim2.new(0, 126, 0, 126)
sideGlow.Position = UDim2.new(1, -56, 0, -54)
sideGlow.BackgroundColor3 = Color3.fromRGB(255, 102, 112)
sideGlow.BackgroundTransparency = 0.99
sideGlow.BorderSizePixel = 0
sideGlow.ZIndex = 20
sideGlow.Parent = panel

local sideGlowCorner = Instance.new("UICorner")
sideGlowCorner.CornerRadius = UDim.new(1, 0)
sideGlowCorner.Parent = sideGlow

local sheen = Instance.new("Frame")
sheen.Size = UDim2.new(1, -2, 0, 116)
sheen.Position = UDim2.new(0, 1, 0, 1)
sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sheen.BackgroundTransparency = 0.955
sheen.BorderSizePixel = 0
sheen.ZIndex = 21
sheen.Parent = panel

local sheenCorner = Instance.new("UICorner")
sheenCorner.CornerRadius = UDim.new(0, 22)
sheenCorner.Parent = sheen

local sheenGradient = Instance.new("UIGradient")
sheenGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
sheenGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.14),
	NumberSequenceKeypoint.new(1, 1),
})
sheenGradient.Rotation = 90
sheenGradient.Parent = sheen

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, -28, 0, 54)
titleBar.Position = UDim2.fromOffset(14, 12)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.ZIndex = 25
titleBar.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Torti hub"
title.TextColor3 = Color3.fromRGB(246, 246, 248)
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 26
title.Parent = titleBar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -50, 0, 18)
subtitle.Position = UDim2.fromOffset(0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Enter your key to unlock the docked build"
subtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 26
subtitle.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(34, 34)
closeButton.Position = UDim2.new(1, -34, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 98, 98)
closeButton.BorderSizePixel = 0
closeButton.Text = "x"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.AutoButtonColor = false
closeButton.ZIndex = 26
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -28, 1, -92)
body.Position = UDim2.fromOffset(14, 76)
body.BackgroundTransparency = 1
body.ZIndex = 25
body.Parent = panel

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, 0, 0, 18)
keyLabel.BackgroundTransparency = 1
keyLabel.Font = Enum.Font.Gotham
keyLabel.Text = "Access key"
keyLabel.TextColor3 = Color3.fromRGB(178, 178, 186)
keyLabel.TextSize = 15
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.ZIndex = 26
keyLabel.Parent = body

local inputHolder = Instance.new("Frame")
inputHolder.Size = UDim2.new(1, 0, 0, 42)
inputHolder.Position = UDim2.fromOffset(0, 24)
inputHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputHolder.BackgroundTransparency = 0.88
inputHolder.BorderSizePixel = 0
inputHolder.ZIndex = 26
inputHolder.Parent = body

local inputHolderCorner = Instance.new("UICorner")
inputHolderCorner.CornerRadius = UDim.new(0, 14)
inputHolderCorner.Parent = inputHolder

local inputHolderStroke = Instance.new("UIStroke")
inputHolderStroke.Color = Color3.fromRGB(255, 255, 255)
inputHolderStroke.Transparency = 0.88
inputHolderStroke.Parent = inputHolder

local inputHolderGradient = Instance.new("UIGradient")
inputHolderGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 60, 64)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(33, 30, 34)),
})
inputHolderGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.2),
	NumberSequenceKeypoint.new(1, 0.4),
})
inputHolderGradient.Rotation = 90
inputHolderGradient.Parent = inputHolder

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -20, 1, 0)
inputBox.Position = UDim2.fromOffset(10, 0)
inputBox.BackgroundTransparency = 1
inputBox.ClearTextOnFocus = false
inputBox.PlaceholderText = "Enter key"
inputBox.Text = ""
inputBox.Font = Enum.Font.GothamMedium
inputBox.TextColor3 = Color3.fromRGB(245, 245, 247)
inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
inputBox.TextSize = 18
inputBox.TextXAlignment = Enum.TextXAlignment.Center
inputBox.ZIndex = 27
inputBox.Parent = inputHolder

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 18)
statusLabel.Position = UDim2.fromOffset(0, 76)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Status: waiting for key"
statusLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 26
statusLabel.Parent = body

local activateButton = Instance.new("TextButton")
activateButton.Size = UDim2.new(1, 0, 0, 42)
activateButton.Position = UDim2.fromOffset(0, 108)
activateButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
activateButton.BackgroundTransparency = 0.84
activateButton.BorderSizePixel = 0
activateButton.AutoButtonColor = false
activateButton.Active = true
activateButton.Font = Enum.Font.GothamBold
activateButton.Text = "Activate"
activateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
activateButton.TextSize = 17
activateButton.ZIndex = 26
activateButton.Parent = body

local activateCorner = Instance.new("UICorner")
activateCorner.CornerRadius = UDim.new(0, 16)
activateCorner.Parent = activateButton

local activateStroke = Instance.new("UIStroke")
activateStroke.Color = Color3.fromRGB(255, 255, 255)
activateStroke.Transparency = 0.88
activateStroke.Parent = activateButton

local activateGradient = Instance.new("UIGradient")
activateGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(94, 76, 80)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 35, 39)),
})
activateGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.14),
	NumberSequenceKeypoint.new(1, 0.34),
})
activateGradient.Rotation = 90
activateGradient.Parent = activateButton

local helperText = Instance.new("TextLabel")
helperText.Size = UDim2.new(1, 0, 0, 32)
helperText.Position = UDim2.fromOffset(0, 156)
helperText.BackgroundTransparency = 1
helperText.Font = Enum.Font.Gotham
helperText.Text = "The loader keeps the same warm glass theme as the main hub."
helperText.TextWrapped = true
helperText.TextColor3 = Color3.fromRGB(142, 142, 150)
helperText.TextSize = 12
helperText.TextXAlignment = Enum.TextXAlignment.Left
helperText.TextYAlignment = Enum.TextYAlignment.Top
helperText.ZIndex = 26
helperText.Parent = body

closeButton.MouseEnter:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 126, 126)}):Play()
end)

closeButton.MouseLeave:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 98, 98)}):Play()
end)

activateButton.MouseEnter:Connect(function()
	TweenService:Create(activateButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.74}):Play()
end)

activateButton.MouseLeave:Connect(function()
	TweenService:Create(activateButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.84}):Play()
end)

local function setStatus(text, color)
	statusLabel.Text = "Status: " .. tostring(text)
	if color then
		statusLabel.TextColor3 = color
	end
	print("[torti/key-loader] " .. tostring(text))
end

local function resetButton()
	activateButton.Text = "Activate"
	activateButton.Active = true
end

local function fetchAndRunSplitLoader()
	setStatus("Fetching split loader...", Color3.fromRGB(150, 220, 150))
	notify("Fetching split loader...")

	local okFetch, response = pcall(function()
		return game:HttpGet(SPLIT_LOADER_URL)
	end)
	if not okFetch or type(response) ~= "string" or response == "" then
		setStatus("HttpGet failed. Raw GitHub may be blocked.", Color3.fromRGB(255, 140, 140))
		resetButton()
		return
	end

	setStatus(("Downloaded %d bytes. Compiling..."):format(#response), Color3.fromRGB(180, 220, 255))

	local compiled, loadErr = loadstring(response)
	if not compiled then
		setStatus("loadstring failed: " .. tostring(loadErr), Color3.fromRGB(255, 140, 140))
		notify("loadstring failed")
		resetButton()
		return
	end

	setStatus("Running split loader...", Color3.fromRGB(150, 220, 150))

	local okRun, runErr = pcall(compiled)
	if not okRun then
		setStatus("Runtime error: " .. tostring(runErr), Color3.fromRGB(255, 140, 140))
		notify("Runtime error")
		resetButton()
		return
	end

	setStatus("Protected script started.", Color3.fromRGB(150, 220, 150))
	task.delay(2.5, function()
		if gui then
			gui:Destroy()
		end
	end)
end

local function submitKey()
	if not activateButton.Active then
		return
	end

	if tostring(inputBox.Text or "") ~= ACCESS_KEY then
		setStatus("Wrong key.", Color3.fromRGB(255, 140, 140))
		inputBox.Text = ""
		inputBox:CaptureFocus()
		return
	end

	activateButton.Active = false
	activateButton.Text = "Loading..."
	setStatus("Key accepted.", Color3.fromRGB(150, 220, 150))
	fetchAndRunSplitLoader()
end

local dragData = nil
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragData = {
			start = input.Position,
			pos = panel.Position,
		}
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragData then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local delta = input.Position - dragData.start
	panel.Position = UDim2.new(
		dragData.pos.X.Scale, dragData.pos.X.Offset + delta.X,
		dragData.pos.Y.Scale, dragData.pos.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragData = nil
	end
end)

closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

activateButton.MouseButton1Click:Connect(submitKey)
inputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submitKey()
	end
end)

inputBox:CaptureFocus()
notify("Enter your key to continue")


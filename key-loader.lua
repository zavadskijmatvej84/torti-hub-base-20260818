local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local SPLIT_LOADER_URL = "https://raw.githubusercontent.com/zavadskijmatvej84/torti-hub-base-20260818-copy/main/main-split-loader.lua?v=20260820-spawn-catalog-v3"
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
overlay.BackgroundColor3 = Color3.fromRGB(5, 8, 14)
overlay.BackgroundTransparency = 0.28
overlay.BorderSizePixel = 0
overlay.ZIndex = 10
overlay.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(470, 260)
panel.BackgroundColor3 = Color3.fromRGB(13, 18, 30)
panel.BorderSizePixel = 0
panel.ZIndex = 20
panel.Parent = overlay

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 18)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(86, 146, 255)
panelStroke.Thickness = 1.4
panelStroke.Transparency = 0.4
panelStroke.Parent = panel

local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 29, 46)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 13, 22)),
})
panelGradient.Rotation = 90
panelGradient.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 0, 32)
title.Position = UDim2.fromOffset(18, 18)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Torti Key Loader"
title.TextColor3 = Color3.fromRGB(246, 248, 255)
title.TextSize = 26
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 21
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -36, 0, 18)
subtitle.Position = UDim2.fromOffset(18, 54)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Enter your key to unlock the split loader"
subtitle.TextColor3 = Color3.fromRGB(160, 173, 202)
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 21
subtitle.Parent = panel

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, -36, 0, 18)
keyLabel.Position = UDim2.fromOffset(18, 96)
keyLabel.BackgroundTransparency = 1
keyLabel.Font = Enum.Font.GothamMedium
keyLabel.Text = "Access Key"
keyLabel.TextColor3 = Color3.fromRGB(200, 211, 236)
keyLabel.TextSize = 14
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.ZIndex = 21
keyLabel.Parent = panel

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -36, 0, 46)
inputBox.Position = UDim2.fromOffset(18, 122)
inputBox.BackgroundColor3 = Color3.fromRGB(20, 27, 42)
inputBox.BorderSizePixel = 0
inputBox.ClearTextOnFocus = false
inputBox.PlaceholderText = "Enter key"
inputBox.Text = ""
inputBox.Font = Enum.Font.Gotham
inputBox.TextColor3 = Color3.fromRGB(245, 247, 255)
inputBox.PlaceholderColor3 = Color3.fromRGB(122, 137, 168)
inputBox.TextSize = 16
inputBox.ZIndex = 21
inputBox.Parent = panel

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 12)
inputCorner.Parent = inputBox

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(76, 130, 235)
inputStroke.Transparency = 0.45
inputStroke.Parent = inputBox

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -36, 0, 18)
statusLabel.Position = UDim2.fromOffset(18, 178)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Status: waiting for key"
statusLabel.TextColor3 = Color3.fromRGB(160, 173, 202)
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 21
statusLabel.Parent = panel

local activateButton = Instance.new("TextButton")
activateButton.Size = UDim2.new(1, -36, 0, 42)
activateButton.Position = UDim2.fromOffset(18, 206)
activateButton.BackgroundColor3 = Color3.fromRGB(61, 108, 225)
activateButton.BorderSizePixel = 0
activateButton.AutoButtonColor = false
activateButton.Active = true
activateButton.Font = Enum.Font.GothamBold
activateButton.Text = "Activate"
activateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
activateButton.TextSize = 16
activateButton.ZIndex = 21
activateButton.Parent = panel

local activateCorner = Instance.new("UICorner")
activateCorner.CornerRadius = UDim.new(0, 12)
activateCorner.Parent = activateButton

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

activateButton.MouseButton1Click:Connect(submitKey)
inputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submitKey()
	end
end)

inputBox:CaptureFocus()
notify("Enter your key to continue")

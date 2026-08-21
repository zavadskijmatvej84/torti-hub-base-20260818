local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local RAW_URL = "https://raw.githubusercontent.com/zavadskijmatvej84/torti-hub-base-20260818-copy/main/main.lua?v=20260821-live-main-v15"

local function resolveGuiParent()
	local candidates = {
		type(gethui) == "function" and gethui or nil,
		type(get_hidden_gui) == "function" and get_hidden_gui or nil,
	}
	for _, getter in ipairs(candidates) do
		if getter then
			local ok, result = pcall(getter)
			if ok and typeof(result) == "Instance" then
				return result
			end
		end
	end
	return CoreGui
end

local function notify(text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Torti Loader",
			Text = tostring(text),
			Duration = 6,
		})
	end)
end

local guiParent = resolveGuiParent()

local oldGui = nil
for _, parent in ipairs({guiParent, CoreGui}) do
	if typeof(parent) == "Instance" then
		local existing = parent:FindFirstChild("TortiLoaderGui")
		if existing then
			oldGui = existing
			break
		end
	end
end
if oldGui then
	oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TortiLoaderGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
	gui.Parent = guiParent
end)
if not gui.Parent then
	gui.Parent = CoreGui
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 120)
frame.Position = UDim2.new(0.5, -180, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 18)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 255, 255)
frameStroke.Thickness = 1
frameStroke.Transparency = 0.86
frameStroke.Parent = frame

local toggleHint = Instance.new("TextLabel")
toggleHint.Size = UDim2.new(1, -24, 0, 16)
toggleHint.Position = UDim2.new(0, 12, 1, -24)
toggleHint.BackgroundTransparency = 1
toggleHint.Text = "F10 - loader console"
toggleHint.Font = Enum.Font.Gotham
toggleHint.TextSize = 11
toggleHint.TextColor3 = Color3.fromRGB(120, 125, 136)
toggleHint.TextXAlignment = Enum.TextXAlignment.Right
toggleHint.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 28)
title.Position = UDim2.new(0, 12, 0, 12)
title.BackgroundTransparency = 1
title.Text = "Torti Loader"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(243, 245, 249)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 40)
statusLabel.Position = UDim2.new(0, 12, 0, 44)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Starting..."
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextWrapped = true
statusLabel.TextColor3 = Color3.fromRGB(187, 191, 199)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Parent = frame

local consoleFrame = Instance.new("Frame")
consoleFrame.Size = UDim2.new(0, 620, 0, 320)
consoleFrame.Position = UDim2.new(0.5, -310, 0.5, 74)
consoleFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
consoleFrame.BackgroundTransparency = 0.02
consoleFrame.BorderSizePixel = 0
consoleFrame.Visible = false
consoleFrame.Parent = gui

local consoleCorner = Instance.new("UICorner")
consoleCorner.CornerRadius = UDim.new(0, 16)
consoleCorner.Parent = consoleFrame

local consoleStroke = Instance.new("UIStroke")
consoleStroke.Color = Color3.fromRGB(255, 255, 255)
consoleStroke.Thickness = 1
consoleStroke.Transparency = 0.9
consoleStroke.Parent = consoleFrame

local consoleTitle = Instance.new("TextLabel")
consoleTitle.Size = UDim2.new(1, -24, 0, 22)
consoleTitle.Position = UDim2.new(0, 12, 0, 10)
consoleTitle.BackgroundTransparency = 1
consoleTitle.Text = "Loader console"
consoleTitle.Font = Enum.Font.GothamBold
consoleTitle.TextSize = 14
consoleTitle.TextColor3 = Color3.fromRGB(244, 247, 250)
consoleTitle.TextXAlignment = Enum.TextXAlignment.Left
consoleTitle.Parent = consoleFrame

local consoleHint = Instance.new("TextLabel")
consoleHint.Size = UDim2.new(1, -24, 0, 16)
consoleHint.Position = UDim2.new(0, 12, 0, 30)
consoleHint.BackgroundTransparency = 1
consoleHint.Text = "Press F10 to show or hide"
consoleHint.Font = Enum.Font.Gotham
consoleHint.TextSize = 11
consoleHint.TextColor3 = Color3.fromRGB(128, 134, 144)
consoleHint.TextXAlignment = Enum.TextXAlignment.Left
consoleHint.Parent = consoleFrame

local consoleScroll = Instance.new("ScrollingFrame")
consoleScroll.Size = UDim2.new(1, -24, 1, -54)
consoleScroll.Position = UDim2.new(0, 12, 0, 42)
consoleScroll.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
consoleScroll.BackgroundTransparency = 0.08
consoleScroll.BorderSizePixel = 0
consoleScroll.ScrollBarThickness = 6
consoleScroll.ScrollBarImageColor3 = Color3.fromRGB(86, 97, 118)
consoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
consoleScroll.Parent = consoleFrame

local consoleScrollCorner = Instance.new("UICorner")
consoleScrollCorner.CornerRadius = UDim.new(0, 12)
consoleScrollCorner.Parent = consoleScroll

local consoleLog = Instance.new("TextLabel")
consoleLog.Size = UDim2.new(1, -16, 0, 0)
consoleLog.Position = UDim2.new(0, 8, 0, 8)
consoleLog.BackgroundTransparency = 1
consoleLog.Text = "[loader] console ready"
consoleLog.Font = Enum.Font.Code
consoleLog.TextSize = 13
consoleLog.TextColor3 = Color3.fromRGB(206, 214, 228)
consoleLog.TextWrapped = true
consoleLog.TextXAlignment = Enum.TextXAlignment.Left
consoleLog.TextYAlignment = Enum.TextYAlignment.Top
consoleLog.AutomaticSize = Enum.AutomaticSize.Y
consoleLog.Parent = consoleScroll

local logLines = {"[loader] console ready"}

local function refreshConsole()
	consoleLog.Text = table.concat(logLines, "\n")
	task.defer(function()
		local height = consoleLog.AbsoluteSize.Y + 16
		consoleScroll.CanvasSize = UDim2.new(0, 0, 0, height)
		consoleScroll.CanvasPosition = Vector2.new(0, math.max(0, height - consoleScroll.AbsoluteWindowSize.Y))
	end)
end

local function pushLog(text)
	logLines[#logLines + 1] = tostring(text)
	if #logLines > 180 then
		table.remove(logLines, 1)
	end
	refreshConsole()
end

local function extractErrorLine(message)
	local value = tostring(message or ""):match(":(%d+):")
	return tonumber(value)
end

local function pushSourceContext(sourceText, centerLine, radius)
	if type(sourceText) ~= "string" or not centerLine then
		return
	end
	local lines = string.split(sourceText, "\n")
	local fromLine = math.max(1, centerLine - (radius or 3))
	local toLine = math.min(#lines, centerLine + (radius or 3))
	pushLog(("[loader] source context around line %d"):format(centerLine))
	for index = fromLine, toLine do
		local prefix = index == centerLine and ">" or " "
		pushLog(("%s %d | %s"):format(prefix, index, tostring(lines[index] or "")))
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.F10 then
		consoleFrame.Visible = not consoleFrame.Visible
	end
end)

local function setStatus(text, color)
	statusLabel.Text = tostring(text)
	if color then
		statusLabel.TextColor3 = color
	end
	print("[torti/loader] " .. tostring(text))
	pushLog("[status] " .. tostring(text))
end

setStatus("Fetching split loader from GitHub...", Color3.fromRGB(187, 191, 199))
notify("Fetching script...")

local okFetch, response = pcall(function()
	return game:HttpGet(RAW_URL)
end)

if not okFetch or type(response) ~= "string" or response == "" then
	setStatus("HttpGet failed. Executor may be blocking GitHub raw.", Color3.fromRGB(255, 140, 140))
	notify("HttpGet failed")
	return
end

setStatus(("Downloaded %d bytes. Compiling..."):format(#response), Color3.fromRGB(180, 220, 255))
pushLog("[http] " .. RAW_URL)

local compiled, loadErr = loadstring(response)
if not compiled then
	setStatus("loadstring failed: " .. tostring(loadErr), Color3.fromRGB(255, 140, 140))
	pushSourceContext(response, extractErrorLine(loadErr), 4)
	notify("loadstring failed")
	return
end

setStatus("Running main script...", Color3.fromRGB(150, 220, 150))
notify("Running main script...")

local okRun, runErr = pcall(compiled)
if not okRun then
	setStatus("Runtime error: " .. tostring(runErr), Color3.fromRGB(255, 140, 140))
	pushSourceContext(response, extractErrorLine(runErr), 4)
	notify("Runtime error")
	return
end

setStatus("Main script started.", Color3.fromRGB(150, 220, 150))
pushLog("[loader] main chunk executed successfully")
task.delay(3, function()
	if frame then
		frame.Visible = false
	end
end)

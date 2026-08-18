local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local RAW_URL = "https://raw.githubusercontent.com/zavadskijmatvej84/torti-hub-base-20260818/main/main.lua"

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
statusLabel.Size = UDim2.new(1, -24, 0, 56)
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

local function setStatus(text, color)
	statusLabel.Text = tostring(text)
	if color then
		statusLabel.TextColor3 = color
	end
	print("[torti/loader] " .. tostring(text))
end

setStatus("Fetching main.lua from GitHub...", Color3.fromRGB(187, 191, 199))
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

local compiled, loadErr = loadstring(response)
if not compiled then
	setStatus("loadstring failed: " .. tostring(loadErr), Color3.fromRGB(255, 140, 140))
	notify("loadstring failed")
	return
end

setStatus("Running main script...", Color3.fromRGB(150, 220, 150))
notify("Running main script...")

local okRun, runErr = pcall(compiled)
if not okRun then
	setStatus("Runtime error: " .. tostring(runErr), Color3.fromRGB(255, 140, 140))
	notify("Runtime error")
	return
end

setStatus("Main script started.", Color3.fromRGB(150, 220, 150))
task.delay(3, function()
	if gui then
		gui:Destroy()
	end
end)

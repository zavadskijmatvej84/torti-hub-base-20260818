local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local RAW_URL = "https://raw.githubusercontent.com/zavadskijmatvej84/torti-hub-base-20260818-copy/main/main.lua"
local ACCESS_KEY = "Tort1"
local WEBHOOK_URL = "https://discord.com/api/webhooks/1539817699830538343/lFZIM_eQ5qYqWFPsR4fwl7s6rHWeNQ_Cn4JoTbPLaV7akwDf1AjyL1TQSY3Dgem3xoSV"

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
			Title = "Torti Key Loader",
			Text = tostring(text),
			Duration = 6,
		})
	end)
end

local function getExecutorName()
	local ok, result = pcall(function()
		if type(identifyexecutor) == "function" then
			return identifyexecutor()
		end
		if type(getexecutorname) == "function" then
			return getexecutorname()
		end
		return "Unknown executor"
	end)

	if ok and result and result ~= "" then
		return tostring(result)
	end

	return "Unknown executor"
end

local function getRequestFunction()
	local candidates = {
		type(syn) == "table" and syn.request or nil,
		type(http_request) == "function" and http_request or nil,
		type(request) == "function" and request or nil,
		type(fluxus) == "table" and fluxus.request or nil,
		type(http) == "table" and http.request or nil,
	}

	for _, requestFn in ipairs(candidates) do
		if type(requestFn) == "function" then
			return requestFn
		end
	end
end

local function sendActivationWebhook()
	local requestFn = getRequestFunction()
	if not requestFn then
		return false, "request api unavailable"
	end

	local localPlayer = Players.LocalPlayer
	local payload = {
		embeds = {
			{
				title = "Torti Hub Activation",
				color = 5814783,
				fields = {
					{
						name = "Player",
						value = localPlayer and (localPlayer.Name .. " (" .. localPlayer.UserId .. ")") or "Unknown",
						inline = true,
					},
					{
						name = "Display Name",
						value = localPlayer and localPlayer.DisplayName or "Unknown",
						inline = true,
					},
					{
						name = "Place",
						value = tostring(game.PlaceId),
						inline = true,
					},
					{
						name = "JobId",
						value = tostring(game.JobId ~= "" and game.JobId or "Studio/Unknown"),
						inline = false,
					},
					{
						name = "Executor",
						value = getExecutorName(),
						inline = false,
					},
				},
				footer = {
					text = "Activated with key loader",
				},
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
			},
		},
	}

	local ok, result = pcall(function()
		return requestFn({
			Url = WEBHOOK_URL,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode(payload),
		})
	end)

	if not ok then
		return false, result
	end

	return true, result
end

local guiParent = resolveGuiParent()

for _, parent in ipairs({guiParent, CoreGui}) do
	if typeof(parent) == "Instance" then
		local existing = parent:FindFirstChild("TortiKeyLoaderGui")
		if existing then
			existing:Destroy()
		end
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = "TortiKeyLoaderGui"
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
frame.Size = UDim2.new(0, 380, 0, 130)
frame.Position = UDim2.new(0.5, -190, 0.5, -65)
frame.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 18)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(94, 146, 255)
frameStroke.Thickness = 1.2
frameStroke.Transparency = 0.55
frameStroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 28)
title.Position = UDim2.new(0, 12, 0, 12)
title.BackgroundTransparency = 1
title.Text = "Torti Key Loader"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(243, 245, 249)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 64)
statusLabel.Position = UDim2.new(0, 12, 0, 46)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Starting secure entry..."
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
	print("[torti/key-loader] " .. tostring(text))
end

local accessGranted = false
local waitingForRequest = false

local prompt = Instance.new("TextLabel")
prompt.Size = UDim2.new(1, -24, 0, 16)
prompt.Position = UDim2.new(0, 12, 0, 76)
prompt.BackgroundTransparency = 1
prompt.Text = "Enter key: Tort1 required"
prompt.Font = Enum.Font.Gotham
prompt.TextSize = 13
prompt.TextColor3 = Color3.fromRGB(149, 165, 196)
prompt.TextXAlignment = Enum.TextXAlignment.Left
prompt.Parent = frame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -126, 0, 34)
inputBox.Position = UDim2.new(0, 12, 0, 94)
inputBox.BackgroundColor3 = Color3.fromRGB(21, 27, 42)
inputBox.BorderSizePixel = 0
inputBox.ClearTextOnFocus = false
inputBox.PlaceholderText = "Enter key"
inputBox.Text = ""
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 15
inputBox.TextColor3 = Color3.fromRGB(245, 247, 255)
inputBox.PlaceholderColor3 = Color3.fromRGB(119, 133, 162)
inputBox.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = inputBox

local activateButton = Instance.new("TextButton")
activateButton.Size = UDim2.new(0, 102, 0, 34)
activateButton.Position = UDim2.new(1, -114, 0, 94)
activateButton.BackgroundColor3 = Color3.fromRGB(58, 104, 215)
activateButton.BorderSizePixel = 0
activateButton.AutoButtonColor = false
activateButton.Text = "Activate"
activateButton.Font = Enum.Font.GothamBold
activateButton.TextSize = 15
activateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
activateButton.Parent = frame

local activateCorner = Instance.new("UICorner")
activateCorner.CornerRadius = UDim.new(0, 10)
activateCorner.Parent = activateButton

frame.Size = UDim2.new(0, 420, 0, 150)
frame.Position = UDim2.new(0.5, -210, 0.5, -75)

local function submitKey()
	if waitingForRequest then
		return
	end

	if tostring(inputBox.Text or "") ~= ACCESS_KEY then
		setStatus("Wrong key.", Color3.fromRGB(255, 140, 140))
		inputBox.Text = ""
		return
	end

	waitingForRequest = true
	activateButton.Text = "Loading..."
	setStatus("Key accepted. Sending webhook...", Color3.fromRGB(150, 220, 150))
	task.spawn(function()
		sendActivationWebhook()
	end)
	accessGranted = true
end

activateButton.MouseButton1Click:Connect(submitKey)
inputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submitKey()
	end
end)

inputBox:CaptureFocus()
repeat
	task.wait()
until accessGranted

setStatus("Fetching protected main.lua...", Color3.fromRGB(187, 191, 199))
notify("Fetching protected script...")

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

setStatus("Running protected entry...", Color3.fromRGB(150, 220, 150))
notify("Running protected entry...")

local okRun, runErr = pcall(compiled)
if not okRun then
	setStatus("Runtime error: " .. tostring(runErr), Color3.fromRGB(255, 140, 140))
	notify("Runtime error")
	return
end

setStatus("Protected entry started.", Color3.fromRGB(150, 220, 150))
task.delay(3, function()
	if gui then
		gui:Destroy()
	end
end)

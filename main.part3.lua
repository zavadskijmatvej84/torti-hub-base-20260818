		settle = 0.15,
	},
}

local function SilentBlockPlayer(Selected)
	if not Selected then return end
	local playerName = (typeof(Selected) == "Instance" and Selected.Name) or tostring(Selected)
	print("[block] >>> SilentBlockPlayer: " .. playerName)

	pcall(function() setthreadidentity(8) end)

	local preWatchers = {}
	local function watchFor(parent)
		local conn = parent.DescendantAdded:Connect(function(d)
			if d.Name == SilentBlockConfig.modalName then
				silentHide(d)
				local inner = d.DescendantAdded:Connect(function() silentHide(d) end)
				table.insert(preWatchers, inner)
			end
		end)
		table.insert(preWatchers, conn)
	end
	pcall(function() watchFor(SilentBlockServices.CoreGui) end)

	SilentBlockServices.StarterGui:SetCore("PromptBlockPlayer", Selected)

	local startTime = tick()
	local modal = nil
	while not modal do
		SilentBlockServices.RunService.Heartbeat:Wait()
		if tick() - startTime > SilentBlockConfig.modalAppearTimeout then
			warn("[block] modal never appeared for " .. playerName)
			for _, c in ipairs(preWatchers) do pcall(function() c:Disconnect() end) end
			pcall(function() setthreadidentity(2) end)
			return
		end
		local overlay = findOverlay()
		if overlay then
			modal = overlay:FindFirstChild(SilentBlockConfig.modalName, true)
		end
	end

	silentHide(modal)

	local posConn
	posConn = SilentBlockServices.RunService.Heartbeat:Connect(function()
		pcall(function()
			if modal and modal.Parent then
				silentHide(modal)
			else
				posConn:Disconnect()
			end
		end)
	end)

	local blockBtn = findBlockButton(modal)

	if blockBtn then
		print("[block] Block button found at " .. blockBtn:GetFullName())

		local attempts = 0
		while attempts < SilentBlockConfig.maxAttempts do
			attempts = attempts + 1
			local dismissed = false

			for _, strategy in ipairs(SilentBlockStrategies) do
				strategy.run(blockBtn)
				task.wait(strategy.settle)
				if not strategy.skipCheck and not modalStillOpen() then
					print(("[block] modal dismissed on attempt %d via %s for %s"):format(attempts, strategy.name, playerName))
					dismissed = true
					break
				end
			end

			if dismissed then break end
		end
		pcall(function() SilentBlockServices.GuiService.SelectedObject = nil end)
	else
		warn("[block] couldn't find Block button for " .. playerName)
	end

	pcall(function() if posConn then posConn:Disconnect() end end)
	for _, c in ipairs(preWatchers) do pcall(function() c:Disconnect() end) end

	local timeout = tick() + SilentBlockConfig.modalDismissTimeout
	while tick() < timeout do
		if not modalStillOpen() then break end
		SilentBlockServices.RunService.Heartbeat:Wait()
	end

	pcall(function() setthreadidentity(2) end)
end

-- ============================================================
-- GUI
-- ============================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("TortiHubGui")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TortiHubGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 520)
frame.Position = UDim2.new(0.5, -200, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 22)
corner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 255, 255)
frameStroke.Thickness = 1
frameStroke.Transparency = 0.83
frameStroke.Parent = frame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 29, 36)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(18, 19, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 11, 15)),
})
frameGradient.Rotation = 90
frameGradient.Parent = frame

local sheen = Instance.new("Frame")
sheen.Size = UDim2.new(1, -2, 0, 130)
sheen.Position = UDim2.new(0, 1, 0, 1)
sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sheen.BackgroundTransparency = 0.95
sheen.BorderSizePixel = 0
sheen.Parent = frame

local sheenCorner = Instance.new("UICorner")
sheenCorner.CornerRadius = UDim.new(0, 22)
sheenCorner.Parent = sheen

local sheenGradient = Instance.new("UIGradient")
sheenGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
sheenGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.15),
    NumberSequenceKeypoint.new(1, 1),
})
sheenGradient.Rotation = 90
sheenGradient.Parent = sheen

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, -24, 0, 56)
titleBar.Position = UDim2.new(0, 12, 0, 12)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -56, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Torti hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(242, 244, 248)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -56, 0, 18)
subtitle.Position = UDim2.new(0, 0, 0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "@orlentov on TG"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextColor3 = Color3.fromRGB(150, 153, 162)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -34, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 92, 92)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "x"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 116, 116)}):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 92, 92)}):Play()
end)

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -24, 0, 48)
tabContainer.Position = UDim2.new(0, 12, 0, 76)
tabContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabContainer.BackgroundTransparency = 0.93
tabContainer.BorderSizePixel = 0
tabContainer.Parent = frame

local tabContainerCorner = Instance.new("UICorner")
tabContainerCorner.CornerRadius = UDim.new(0, 16)
tabContainerCorner.Parent = tabContainer

local tabContainerStroke = Instance.new("UIStroke")
tabContainerStroke.Color = Color3.fromRGB(255, 255, 255)
tabContainerStroke.Transparency = 0.86
tabContainerStroke.Parent = tabContainer

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabContainer

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 8)
tabPadding.PaddingRight = UDim.new(0, 8)
tabPadding.PaddingTop = UDim.new(0, 6)
tabPadding.PaddingBottom = UDim.new(0, 6)
tabPadding.Parent = tabContainer

local tabs = {"Control", "Players", "Items", "Spawner", "Values", "Other", "Config"}
local tabButtons = {}
local tabFrames = {}
local activeTab = "Control"

local function setActiveTab(name)
    for _, f in pairs(tabFrames) do
        f.Visible = false
    end

    if tabFrames[name] then
        tabFrames[name].Visible = true
        tabFrames[name].CanvasPosition = Vector2.new(0, 0)
    end

    for n, b in pairs(tabButtons) do
        if n == name then
            b.BackgroundTransparency = 0.82
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            b.BackgroundTransparency = 1
            b.TextColor3 = Color3.fromRGB(194, 198, 206)
        end
    end

    activeTab = name
end

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / #tabs, -4, 1, 0)
    btn.Position = UDim2.new((i - 1) / #tabs, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(194, 198, 206)
    btn.AutoButtonColor = false
    btn.Parent = tabContainer

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn

    tabButtons[name] = btn

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -24, 1, -142)
    content.Position = UDim2.new(0, 12, 0, 130)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 148)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Visible = i == 1
    content.Parent = frame
    tabFrames[name] = content

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = content

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 2)
    padding.Parent = content

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(225, 228, 234)}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(194, 198, 206)}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        setActiveTab(name)
    end)
end

-- Helper functions for GUI
local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.84
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 19
    btn.TextColor3 = Color3.fromRGB(248, 250, 255)
    btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextStrokeTransparency = 0.9
    btn.AutoButtonColor = false
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 16)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Thickness = 1
    s.Transparency = 0.84
    s.Parent = btn

    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 60, 72)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 30, 38)),
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.08),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    g.Rotation = 90
    g.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.75}):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.84}):Play()
    end)

    btn.MouseButton1Click:Connect(callback)

    return btn
end

local function createInput(parent, label, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 62)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 15
    lbl.TextColor3 = Color3.fromRGB(180, 183, 192)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local boxHolder = Instance.new("Frame")
    boxHolder.Size = UDim2.new(1, 0, 0, 40)
    boxHolder.Position = UDim2.new(0, 0, 0, 22)
    boxHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    boxHolder.BackgroundTransparency = 0.92
    boxHolder.BorderSizePixel = 0
    boxHolder.Parent = container

    local holderCorner = Instance.new("UICorner")
    holderCorner.CornerRadius = UDim.new(0, 14)
    holderCorner.Parent = boxHolder

    local holderStroke = Instance.new("UIStroke")
    holderStroke.Color = Color3.fromRGB(255, 255, 255)
    holderStroke.Thickness = 1
    holderStroke.Transparency = 0.86
    holderStroke.Parent = boxHolder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 1, 0)
    box.Position = UDim2.new(0, 10, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = default or ""
    box.PlaceholderText = default == "" and label or ""
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 18
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(118, 121, 130)
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.ClearTextOnFocus = false
    box.Parent = boxHolder

    return box
end

-- Global GUI elements
PartnerUserBox = nil
ItemToAddPartnerBox = nil
SpawnerAmountBox = nil
SpawnerSearchBox = nil
valueSearchBox = nil
weaponButtons = {}
spawnerButtons = {}
AutoBlockToggleButton = nil
AutoBlockDelayBox = nil
AutoBlockMinValueBox = nil
AutoBlockStatusLabel = nil
PlayerAutoRefreshToggleButton = nil
PlayerAutoRefreshSecondsBox = nil
PlayerAutoRefreshStatusLabel = nil
playerValueRows = {}

local AutoBlockState = {
	enabled = false,
	delaySeconds = 5,
	minValue = 100,
	progressByName = {},
	blockedByName = {},
	cooldownUntilByName = {},
	busy = false,
	busyTargetName = nil,
	busyStartedAt = 0,
	busyAttemptId = 0,
	busyTimeoutSeconds = 12,
}

local PlayerValuesAutoRefreshState = {
	enabled = false,
	intervalSeconds = 10,
	lastRefreshAt = 0,
}

local playerValuesRefreshInProgress = false

local function clampWholeNumber(value, minValue, maxValue, fallback)
	local numeric = tonumber(value)
	if not numeric then
		numeric = fallback
	end
	numeric = math.floor(numeric or fallback or minValue)
	if numeric < minValue then
		numeric = minValue
	elseif numeric > maxValue then
		numeric = maxValue
	end
	return numeric
end

local function setAutoBlockStatus(text, color)
	if not AutoBlockStatusLabel then
		return
	end
	AutoBlockStatusLabel.Text = text
	if color then
		AutoBlockStatusLabel.TextColor3 = color
	end
end

local function syncAutoBlockSettingsFromInputs()
	AutoBlockState.delaySeconds = clampWholeNumber(AutoBlockDelayBox and AutoBlockDelayBox.Text, 1, 30, AutoBlockState.delaySeconds)
	AutoBlockState.minValue = clampWholeNumber(AutoBlockMinValueBox and AutoBlockMinValueBox.Text, 1, 1000, AutoBlockState.minValue)
	if AutoBlockDelayBox then
		AutoBlockDelayBox.Text = tostring(AutoBlockState.delaySeconds)
	end
	if AutoBlockMinValueBox then
		AutoBlockMinValueBox.Text = tostring(AutoBlockState.minValue)
	end
end

local function updateAutoBlockButtonText()
	if not AutoBlockToggleButton then
		return
	end
	AutoBlockToggleButton.Text = AutoBlockState.enabled and "Auto block: ON" or "Auto block: OFF"
	AutoBlockToggleButton.BackgroundTransparency = AutoBlockState.enabled and 0.72 or 0.84
end

local function setPlayerAutoRefreshStatus(text, color)
	if not PlayerAutoRefreshStatusLabel then
		return
	end
	PlayerAutoRefreshStatusLabel.Text = text
	if color then
		PlayerAutoRefreshStatusLabel.TextColor3 = color
	end
end

local function syncPlayerAutoRefreshSettingsFromInputs()
	PlayerValuesAutoRefreshState.intervalSeconds = clampWholeNumber(
		PlayerAutoRefreshSecondsBox and PlayerAutoRefreshSecondsBox.Text,
		1,
		300,
		PlayerValuesAutoRefreshState.intervalSeconds
	)
	if PlayerAutoRefreshSecondsBox then
		PlayerAutoRefreshSecondsBox.Text = tostring(PlayerValuesAutoRefreshState.intervalSeconds)
	end
end

local function updatePlayerAutoRefreshButtonText()
	if not PlayerAutoRefreshToggleButton then
		return
	end
	PlayerAutoRefreshToggleButton.Text = PlayerValuesAutoRefreshState.enabled and "Auto refresh: ON" or "Auto refresh: OFF"
	PlayerAutoRefreshToggleButton.BackgroundTransparency = PlayerValuesAutoRefreshState.enabled and 0.72 or 0.84
end

-- ===== FILL CONTROL TAB =====
local controlFrame = tabFrames["Control"]
PartnerUserBox = createInput(controlFrame, "Partner user:", TradeTable.Player2.Player)
PartnerUserBox.FocusLost:Connect(function()
    TradeTable.Player2.Player = PartnerUserBox.Text
    PartnerUserBox.Text = TradeTable.Player2.Player
end)

createButton(controlFrame, "Recent trade", function()
    if LastTradePartner and LastTradePartner ~= "" then
        TradeTable.Player2.Player = LastTradePartner
        PartnerUserBox.Text = LastTradePartner
    end
end)

createButton(controlFrame, "Random player", function()
    local FakeTradePartners = {
        "xX_ShadowSlayer_Xx", "BloxyKing2008", "NoobMaster69", "PixelKnightz",
        "CrimsonReaperX", "MidnightFury77", "ZeroHavoc", "EpicGamer_LOL",
        "SilentStorm_YT", "FrostWolfie", "DragonHunter999", "SkyBreaker42",
        "VortexHaze", "PhantomRiderX", "NebulaCraze", "ToxicBubbles",
        "MysticBoba", "RobloxTrader01", "GamerGirl_Lyra", "SapphireWisp",
        "NinjaCookie123", "FluffyPandaUwU", "GoldenAegis", "VenomViperZ",
        "AstralFoxy", "MoonlightRose", "ChaosKnightX", "SilverScale99",
        "OmegaPredator", "EclipsedSoul", "EmeraldEcho", "CipherStorm",
        "PhoenixWraith", "ZephyrBlade", "InkyOctopus", "QuantumLynx",
        "DizzyDoodle", "NeonMango", "PiratePudding", "WaffleOverlord",
        "CaffeineFox", "MidnightMelody", "PolarBearHugz", "RadiantPaladin",
        "StormcasterX", "SableHunter", "ObsidianCrown", "AquaSurge",
        "SolarFlareKid", "TwilightWisp",
    }
    local chosen = FakeTradePartners[math.random(1, #FakeTradePartners)]
    TradeTable.Player2.Player = chosen
    PartnerUserBox.Text = chosen
    pcall(function()
        TheirOffer.Username.Text = "(" .. chosen .. ")"
    end)
    print("[mm2run/random] picked fake partner: " .. chosen)
end)

createButton(controlFrame, "Start trade", function()
    StartTrade()
end)

createButton(controlFrame, "Random items", function()
    if #weaponButtons == 0 then
        print("[mm2run/random] item list not built yet")
        return
    end
    local info = weaponButtons[math.random(1, #weaponButtons)]
    local ok = OfferItemAnotherPlayer(info.entry.key, "Weapons")
    if ok then
        print("[mm2run/random] added random item: " .. info.entry.name)
    else
        print("[mm2run/random] couldn't add " .. info.entry.name .. " (trade locked, full, or not started)")
    end
end)

createButton(controlFrame, "Accept their offer", function()
    if not next(TradeTable.Player1.Offer) and not next(TradeTable.Player2.Offer) then
        return
    end
    if v84 then
        return
    end
    TheirOffer.Accepted.Visible = true
    TradeTable.Player2.Accepted = true
    AcceptTrade()
end)

createButton(controlFrame, "Block player", function()
    pcall(function()
        local Selected = game.Players:FindFirstChild(TradeTable.Player2.Player)
        if Selected then
            SilentBlockPlayer(Selected)
        end
    end)
end)

-- ===== FILL PLAYERS TAB =====
local playersFrame = tabFrames["Players"]

-- ===== FILL ITEMS TAB =====
local itemsFrame = tabFrames["Items"]
ItemToAddPartnerBox = createInput(itemsFrame, "Name item to add:", "")
createButton(itemsFrame, "Add Item To Their Offer", function()
    local itemToAdd = ItemToAddPartnerBox.Text
    if itemToAdd and itemToAdd ~= "" then
        OfferItemAnotherPlayer(itemToAdd, "Weapons")
    end
end)
createButton(itemsFrame, "Remove last Item in Their Offer", function()
    RemoveItemAnotherPlayer()
end)

local weaponListLabel = Instance.new("TextLabel")
weaponListLabel.Size = UDim2.new(1, 0, 0, 15)
weaponListLabel.BackgroundTransparency = 1
weaponListLabel.Text = "Click weapon to ADD directly:"
weaponListLabel.Font = Enum.Font.SourceSansSemibold
weaponListLabel.TextSize = 12
weaponListLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
weaponListLabel.TextXAlignment = Enum.TextXAlignment.Left
weaponListLabel.Parent = itemsFrame

local weaponScrollFrame = Instance.new("ScrollingFrame")
weaponScrollFrame.Size = UDim2.new(1, 0, 0, 120)
weaponScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
weaponScrollFrame.BackgroundTransparency = 0.3
weaponScrollFrame.BorderSizePixel = 0
weaponScrollFrame.ScrollBarThickness = 6
weaponScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
weaponScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
weaponScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
weaponScrollFrame.Parent = itemsFrame

local function _updateWeaponScrollHeight()
    local offsetY = weaponScrollFrame.AbsolutePosition.Y - itemsFrame.AbsolutePosition.Y
    local available = itemsFrame.AbsoluteSize.Y - offsetY - 4
    weaponScrollFrame.Size = UDim2.new(1, 0, 0, math.max(80, available))
end
itemsFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_updateWeaponScrollHeight)
task.defer(_updateWeaponScrollHeight)

do
    local weaponScrollCorner = Instance.new("UICorner")
    weaponScrollCorner.CornerRadius = UDim.new(0, 5)
    weaponScrollCorner.Parent = weaponScrollFrame
end
do
    local weaponScrollStroke = Instance.new("UIStroke")
    weaponScrollStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    weaponScrollStroke.Color = Color3.fromRGB(80, 80, 120)
    weaponScrollStroke.Thickness = 1
    weaponScrollStroke.Parent = weaponScrollFrame
end
do
    local weaponListLayout = Instance.new("UIListLayout")
    weaponListLayout.FillDirection = Enum.FillDirection.Vertical
    weaponListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    weaponListLayout.Padding = UDim.new(0, 2)
    weaponListLayout.Parent = weaponScrollFrame
end
do
    local weaponListPadding = Instance.new("UIPadding")
    weaponListPadding.PaddingTop = UDim.new(0, 3)
    weaponListPadding.PaddingBottom = UDim.new(0, 3)
    weaponListPadding.PaddingLeft = UDim.new(0, 3)
    weaponListPadding.PaddingRight = UDim.new(0, 3)
    weaponListPadding.Parent = weaponScrollFrame
end

-- ===== FILL SPAWNER TAB =====
local spawnerFrame = tabFrames["Spawner"]
SpawnerAmountBox = createInput(spawnerFrame, "Amount per click (0 = random):", "0")
SpawnerSearchBox = createInput(spawnerFrame, "Search weapon:", "")
local SpawnerSortMode = "default"
local SpawnerSortButton = nil
local RefreshSpawnerButtons = nil

local function GetSpawnerSortButtonText()
	if SpawnerSortMode == "value_desc" then
		return "Sort: Value high -> low"
	elseif SpawnerSortMode == "value_asc" then
		return "Sort: Value low -> high"
	end
	return "Sort: Normal"
end

SpawnerSortButton = createButton(spawnerFrame, GetSpawnerSortButtonText(), function()
	if SpawnerSortMode == "default" then
		SpawnerSortMode = "value_desc"
	elseif SpawnerSortMode == "value_desc" then
		SpawnerSortMode = "value_asc"
	else
		SpawnerSortMode = "default"
	end
	SpawnerSortButton.Text = GetSpawnerSortButtonText()
	if RefreshSpawnerButtons then
		RefreshSpawnerButtons()
	end
end)
SpawnerSortButton.TextSize = 14
SpawnerSortButton.Size = UDim2.new(1, 0, 0, 36)

local spawnerStatusLabel = Instance.new("TextLabel")
spawnerStatusLabel.Size = UDim2.new(1, 0, 0, 15)
spawnerStatusLabel.BackgroundTransparency = 1
spawnerStatusLabel.Text = "Click weapon to spawn:"
spawnerStatusLabel.Font = Enum.Font.SourceSansSemibold
spawnerStatusLabel.TextSize = 12
spawnerStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
spawnerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
spawnerStatusLabel.Parent = spawnerFrame

local function _itemsTabNormalize(s)
    s = string.lower(tostring(s or ""))
    s = string.gsub(s, "^c%.%s*", "chroma ")
    s = string.gsub(s, "(%s)c%.%s*", "%1chroma ")
	s = string.gsub(s, "['\"]", "")
    s = string.gsub(s, "%s+", " ")
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    return s
end

local SpawnerAllowedBases = {
    "Alienbeam", "America", "Amerilaser", "Australis", "Bat", "BattleAxe", "BattleAxe II",
    "Batwing", "Beachy", "Bioblade", "Blaster", "Bloom", "Blue Seer", "Blizzard",
    "Boneblade", "Borealis", "Candleflame", "Candy", "Celestial", "Chill", "Clockwork",
    "Constellation", "Cookieblade", "Cookiecane", "Corrupt", "Darkbringer", "Darkshot",
    "Darksword", "Deathshard", "Eggblade", "Elderwood Blade", "Elderwood Revolver",
    "Elderwood Scythe", "Eternal", "Eternal II", "Eternal III", "Eternal IV", "Eternalcane",
    "Evergreen", "Evergun", "Fang", "Flames", "Flora", "Flowerwood", "Flowerwood Gun",
    "Frostbite", "Frostsaber", "Gemstone", "Ghostblade", "Gingerblade", "Ginger Luger",
    "Gingermint", "Gingerscope", "Green Luger", "Hallows Blade", "Hallows Edge", "Hallowscythe",
    "Hallowgun", "Handsaw", "Harvester", "Heart Wand", "Heartblade", "Heat", "Iceblaster",
    "Icebreaker", "Icecream", "Ice Dragon", "Iceflake", "Icepiercer", "Ice Shard", "Icewing",
    "Jinglegun", "Laser", "Lightbringer", "Logchopper", "Luger", "Lugercane", "Makeshift",
    "Minty", "Nebula", "Nightblade", "Niks Scythe", "Ocean", "Old Glory", "Orange Seer",
    "Ornament", "Pearl", "Pearlshine", "Peppermint", "Phantom", "Pixel", "Plasma Beam",
    "Plasma Blade", "Prismatic", "Pumpking", "Purple Seer", "Rainbow", "Rainbow Gun",
    "Raygun", "Red Luger", "Red Seer", "Rune", "Sakura", "Sands", "Saw", "Seer", "Shark",
    "Slasher", "Snowcannon", "Snow Dagger", "Snowflake", "Snowstorm", "Soul", "Spectre",
    "Spider", "Spirit", "Sugar", "Sunrise", "Sunset", "Sweet", "Swirly Axe", "Swirly Blade",
    "Swirlygun", "Tides", "Traveler's Axe", "Traveler's Gun", "Treat", "Turkey", "Vampire's Axe",
    "Vampire's Edge", "Vampire's Gun", "Virtual", "Watergun", "Waves", "Winter's Edge",
    "Xenoknife", "Xenoshot", "Xmas", "Yellow Seer"
}

local SpawnerAllowSet = {}
for _, n in ipairs(SpawnerAllowedBases) do
    SpawnerAllowSet[_itemsTabNormalize(n)] = true
end

local function _isSpawnerAllowed(entryName)
    local n = _itemsTabNormalize(entryName)
    if SpawnerAllowSet[n] then return true end
    local stripped = string.gsub(n, "^chroma ", "")
    return SpawnerAllowSet[stripped] == true
end

local function _isTradable(data)
    if type(data) ~= "table" then return false end
    if data.Tradable == false then return false end
    if data.CanTrade == false then return false end
    if data.Untradable == true then return false end
    if data.NonTradable == true then return false end
    if data.Locked == true then return false end
    return true
end

local SpawnerRandomRanges = {
    Chroma    = {1, 2},
    Godly     = {1, 5},
    Ancient   = {2, 6},
    Unique    = {2, 8},
    Classic   = {3, 10},
    Legendary = {4, 12},
    Vintage   = {5, 15},
    Rare      = {8, 25},
    Uncommon  = {10, 40},
    Common    = {15, 60},
}

local function _randomAmount(rarity, evo)
    if evo then return 1 end
    local r = SpawnerRandomRanges[rarity] or SpawnerRandomRanges.Common
    return math.random(r[1], r[2])
end

local spawnerScrollFrame = Instance.new("ScrollingFrame")
spawnerScrollFrame.Size = UDim2.new(1, 0, 0, 120)
spawnerScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
spawnerScrollFrame.BackgroundTransparency = 0.3
spawnerScrollFrame.BorderSizePixel = 0
spawnerScrollFrame.ScrollBarThickness = 6
spawnerScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
spawnerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
spawnerScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
spawnerScrollFrame.Parent = spawnerFrame

local function _updateSpawnerScrollHeight()
    local offsetY = spawnerScrollFrame.AbsolutePosition.Y - spawnerFrame.AbsolutePosition.Y
    local available = spawnerFrame.AbsoluteSize.Y - offsetY - 4
    spawnerScrollFrame.Size = UDim2.new(1, 0, 0, math.max(80, available))
end
spawnerFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_updateSpawnerScrollHeight)
task.defer(_updateSpawnerScrollHeight)

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = spawnerScrollFrame
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Color3.fromRGB(80, 80, 120)
    s.Thickness = 1
    s.Parent = spawnerScrollFrame
    local lay = Instance.new("UIListLayout")
    lay.FillDirection = Enum.FillDirection.Vertical
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 2)
    lay.Parent = spawnerScrollFrame
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 3)
    pad.PaddingBottom = UDim.new(0, 3)
    pad.PaddingLeft = UDim.new(0, 3)
    pad.PaddingRight = UDim.new(0, 3)
    pad.Parent = spawnerScrollFrame
end

-- ===== FILL VALUES TAB =====
local RefreshPlayerValues = function() end

local Values


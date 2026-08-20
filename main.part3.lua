end)

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -24, 0, 48)
tabContainer.Position = UDim2.new(0, 12, 0, 76)
tabContainer.BackgroundColor3 = WINDOW_THEME.chipColor
tabContainer.BackgroundTransparency = WINDOW_THEME.chipTransparency
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainPanel

local tabContainerCorner = Instance.new("UICorner")
tabContainerCorner.CornerRadius = UDim.new(0, 16)
tabContainerCorner.Parent = tabContainer

local tabContainerStroke = Instance.new("UIStroke")
tabContainerStroke.Color = WINDOW_THEME.panelEdge
tabContainerStroke.Transparency = 0.9
tabContainerStroke.Parent = tabContainer

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 2)
tabLayout.Parent = tabContainer

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 6)
tabPadding.PaddingRight = UDim.new(0, 6)
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
			b.BackgroundTransparency = 0.76
			b.TextColor3 = WINDOW_THEME.panelText
		else
			b.BackgroundTransparency = 1
			b.TextColor3 = WINDOW_THEME.mutedText
		end
	end

	activeTab = name
end

for i, name in ipairs(tabs) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 0, 1, 0)
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.BackgroundColor3 = WINDOW_THEME.chipColor
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	btn.TextColor3 = Color3.fromRGB(194, 198, 206)
	btn.AutoButtonColor = false
	btn.Parent = tabContainer

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 12)
	c.Parent = btn

	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, 10)
	p.PaddingRight = UDim.new(0, 10)
	p.Parent = btn

	tabButtons[name] = btn

	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, -24, 1, -142)
	content.Position = UDim2.new(0, 12, 0, 130)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 3
	content.ScrollBarImageColor3 = Color3.fromRGB(164, 144, 148)
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.Visible = i == 1
	content.Parent = mainPanel
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
			TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(229, 228, 232)}):Play()
		end
	end)

	btn.MouseLeave:Connect(function()
		if activeTab ~= name then
			TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = WINDOW_THEME.mutedText}):Play()
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
	btn.BackgroundColor3 = WINDOW_THEME.buttonColor
	btn.BackgroundTransparency = WINDOW_THEME.buttonTransparency
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 19
	btn.TextColor3 = WINDOW_THEME.panelText
	btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	btn.TextStrokeTransparency = 0.92
	btn.AutoButtonColor = false
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 16)
	c.Parent = btn

	local s = Instance.new("UIStroke")
	s.Color = WINDOW_THEME.panelEdge
	s.Thickness = 1
	s.Transparency = 0.88
	s.Parent = btn

	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(92, 76, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 35, 39)),
	})
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.14),
		NumberSequenceKeypoint.new(1, 0.34),
	})
	g.Rotation = 90
	g.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = WINDOW_THEME.buttonHoverTransparency}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = WINDOW_THEME.buttonTransparency}):Play()
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
	lbl.TextColor3 = WINDOW_THEME.mutedText
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = container

	local boxHolder = Instance.new("Frame")
	boxHolder.Size = UDim2.new(1, 0, 0, 40)
	boxHolder.Position = UDim2.new(0, 0, 0, 22)
	boxHolder.BackgroundColor3 = WINDOW_THEME.inputColor
	boxHolder.BackgroundTransparency = WINDOW_THEME.inputTransparency
	boxHolder.BorderSizePixel = 0
	boxHolder.Parent = container

	local holderCorner = Instance.new("UICorner")
	holderCorner.CornerRadius = UDim.new(0, 14)
	holderCorner.Parent = boxHolder

	local holderStroke = Instance.new("UIStroke")
	holderStroke.Color = WINDOW_THEME.panelEdge
	holderStroke.Thickness = 1
	holderStroke.Transparency = 0.88
	holderStroke.Parent = boxHolder

	local holderGradient = Instance.new("UIGradient")
	holderGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 60, 64)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(33, 30, 34)),
	})
	holderGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0.4),
	})
	holderGradient.Rotation = 90
	holderGradient.Parent = boxHolder

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -20, 1, 0)
	box.Position = UDim2.new(0, 10, 0, 0)
	box.BackgroundTransparency = 1
	box.Text = default or ""
	box.PlaceholderText = default == "" and label or ""
	box.Font = Enum.Font.GothamMedium
	box.TextSize = 18
	box.TextColor3 = WINDOW_THEME.panelText
	box.PlaceholderColor3 = WINDOW_THEME.softText
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
do
	local controlBindButtons = {}
	local controlBindStatusLabel = nil
	local controlBindState = {
		bindings = {},
		listeningActionId = nil,
	}
	local controlBindDefinitions = {
		{ id = "recentTrade", label = "Recent trade" },
		{ id = "randomPlayer", label = "Random player" },
		{ id = "startTrade", label = "Start trade" },
		{ id = "randomItems", label = "Random items" },
		{ id = "acceptOffer", label = "Accept their offer" },
		{ id = "blockPlayer", label = "Block player" },
	}
	local controlActions = {}
	local fakeTradePartners = {
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
	local controlFrame = tabFrames["Control"]

	local function setControlBindStatus(text, color)
		if not controlBindStatusLabel then
			return
		end
		controlBindStatusLabel.Text = text
		if color then
			controlBindStatusLabel.TextColor3 = color
		end
	end

	local function formatControlBindKey(keyCode)
		if not keyCode then
			return "Unbound"
		end
		return keyCode.Name
	end

	local function updateControlBindButtonText(actionId)
		local button = controlBindButtons[actionId]
		if not button then
			return
		end

		if controlBindState.listeningActionId == actionId then
			button.Text = "Press key..."
			return
		end

		button.Text = formatControlBindKey(controlBindState.bindings[actionId])
	end

	local function assignControlBind(actionId, keyCode)
		for otherActionId, otherKeyCode in pairs(controlBindState.bindings) do
			if otherActionId ~= actionId and otherKeyCode == keyCode then
				controlBindState.bindings[otherActionId] = nil
				updateControlBindButtonText(otherActionId)
			end
		end

		controlBindState.bindings[actionId] = keyCode
		updateControlBindButtonText(actionId)
		setControlBindStatus(("Bound %s to %s"):format(actionId, keyCode.Name), Color3.fromRGB(140, 220, 160))
	end

	local function clearControlBind(actionId)
		controlBindState.bindings[actionId] = nil
		if controlBindState.listeningActionId == actionId then
			controlBindState.listeningActionId = nil
		end
		updateControlBindButtonText(actionId)
		setControlBindStatus(("Cleared bind for %s"):format(actionId), Color3.fromRGB(205, 183, 132))
	end

	local function startControlBindListening(actionId)
		local previousActionId = controlBindState.listeningActionId
		controlBindState.listeningActionId = actionId
		if previousActionId and previousActionId ~= actionId then
			updateControlBindButtonText(previousActionId)
		end
		updateControlBindButtonText(actionId)
		setControlBindStatus("Press any key to bind. Esc cancels, Backspace clears.", Color3.fromRGB(187, 198, 213))
	end

	local function triggerControlAction(actionId)
		local callback = controlActions[actionId]
		if not callback then
			return
		end

		local ok, err = pcall(callback)
		if not ok then
			warn("[control-bind] action failed for " .. tostring(actionId) .. ": " .. tostring(err))
			setControlBindStatus(("Action failed: %s"):format(actionId), Color3.fromRGB(255, 120, 120))
		end
	end

	local function createKeybindRow(parent, label, actionId)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 42)
		row.BackgroundTransparency = 1
		row.Parent = parent

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.47, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = label
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = Color3.fromRGB(212, 220, 233)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = row

		local bindButton = Instance.new("TextButton")
		bindButton.Size = UDim2.new(0.33, -6, 1, 0)
		bindButton.Position = UDim2.new(0.47, 6, 0, 0)
		bindButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bindButton.BackgroundTransparency = 0.86
		bindButton.BorderSizePixel = 0
		bindButton.Text = "Unbound"
		bindButton.Font = Enum.Font.GothamBold
		bindButton.TextSize = 13
		bindButton.TextColor3 = Color3.fromRGB(248, 250, 255)
		bindButton.AutoButtonColor = false
		bindButton.Parent = row

		local bindCorner = Instance.new("UICorner")
		bindCorner.CornerRadius = UDim.new(0, 12)
		bindCorner.Parent = bindButton

		local bindStroke = Instance.new("UIStroke")
		bindStroke.Color = Color3.fromRGB(255, 255, 255)
		bindStroke.Thickness = 1
		bindStroke.Transparency = 0.86
		bindStroke.Parent = bindButton

		local clearButton = Instance.new("TextButton")
		clearButton.Size = UDim2.new(0.2, -6, 1, 0)
		clearButton.Position = UDim2.new(0.8, 6, 0, 0)
		clearButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		clearButton.BackgroundTransparency = 0.9
		clearButton.BorderSizePixel = 0
		clearButton.Text = "Clear"
		clearButton.Font = Enum.Font.GothamBold
		clearButton.TextSize = 13
		clearButton.TextColor3 = Color3.fromRGB(230, 190, 190)
		clearButton.AutoButtonColor = false
		clearButton.Parent = row

		local clearCorner = Instance.new("UICorner")
		clearCorner.CornerRadius = UDim.new(0, 12)
		clearCorner.Parent = clearButton

		local clearStroke = Instance.new("UIStroke")
		clearStroke.Color = Color3.fromRGB(255, 255, 255)
		clearStroke.Thickness = 1
		clearStroke.Transparency = 0.88
		clearStroke.Parent = clearButton

		bindButton.MouseButton1Click:Connect(function()
			startControlBindListening(actionId)
		end)

		clearButton.MouseButton1Click:Connect(function()
			clearControlBind(actionId)
		end)

		controlBindButtons[actionId] = bindButton
		updateControlBindButtonText(actionId)

		return row
	end

	PartnerUserBox = createInput(controlFrame, "Partner user:", TradeTable.Player2.Player)
	PartnerUserBox.FocusLost:Connect(function()
		TradeTable.Player2.Player = PartnerUserBox.Text
		PartnerUserBox.Text = TradeTable.Player2.Player
	end)

	controlActions.recentTrade = function()
		if LastTradePartner and LastTradePartner ~= "" then
			TradeTable.Player2.Player = LastTradePartner
			PartnerUserBox.Text = LastTradePartner
		end
	end

	controlActions.randomPlayer = function()
		local chosen = fakeTradePartners[math.random(1, #fakeTradePartners)]
		TradeTable.Player2.Player = chosen
		PartnerUserBox.Text = chosen
		pcall(function()
			TheirOffer.Username.Text = "(" .. chosen .. ")"
		end)
		print("[mm2run/random] picked fake partner: " .. chosen)
	end

	controlActions.startTrade = function()
		StartTrade()
	end

	controlActions.randomItems = function()
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
	end

	controlActions.acceptOffer = function()
		if not next(TradeTable.Player1.Offer) and not next(TradeTable.Player2.Offer) then
			return
		end
		if v84 then
			return
		end
		TheirOffer.Accepted.Visible = true
		TradeTable.Player2.Accepted = true
		AcceptTrade()
	end

	controlActions.blockPlayer = function()
		pcall(function()
			local selected = game.Players:FindFirstChild(TradeTable.Player2.Player)
			if selected then
				SilentBlockPlayer(selected)
			end
		end)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		local keyCode = input.KeyCode
		if keyCode == Enum.KeyCode.Unknown then
			return
		end

		if controlBindState.listeningActionId then
			local actionId = controlBindState.listeningActionId
			controlBindState.listeningActionId = nil
			if keyCode == Enum.KeyCode.Escape then
				updateControlBindButtonText(actionId)
				setControlBindStatus("Bind cancelled.", Color3.fromRGB(205, 183, 132))
				return
			end
			if keyCode == Enum.KeyCode.Backspace or keyCode == Enum.KeyCode.Delete then
				clearControlBind(actionId)
				return
			end
			assignControlBind(actionId, keyCode)
			return
		end

		if gameProcessed or UserInputService:GetFocusedTextBox() then
			return
		end

		for _, definition in ipairs(controlBindDefinitions) do
			if controlBindState.bindings[definition.id] == keyCode then
				triggerControlAction(definition.id)
				break
			end
		end
	end)

	createButton(controlFrame, "Recent trade", controlActions.recentTrade)
	createButton(controlFrame, "Random player", controlActions.randomPlayer)
	createButton(controlFrame, "Start trade", controlActions.startTrade)
	createButton(controlFrame, "Random items", controlActions.randomItems)
	createButton(controlFrame, "Accept their offer", controlActions.acceptOffer)
	createButton(controlFrame, "Block player", controlActions.blockPlayer)

	local controlBindHeader = Instance.new("TextLabel")
	controlBindHeader.Size = UDim2.new(1, 0, 0, 18)
	controlBindHeader.BackgroundTransparency = 1
	controlBindHeader.Text = "Keybinds"
	controlBindHeader.Font = Enum.Font.GothamBold
	controlBindHeader.TextSize = 15
	controlBindHeader.TextColor3 = Color3.fromRGB(240, 244, 255)
	controlBindHeader.TextXAlignment = Enum.TextXAlignment.Left
	controlBindHeader.Parent = controlFrame

	local controlBindHint = Instance.new("TextLabel")
	controlBindHint.Size = UDim2.new(1, 0, 0, 28)
	controlBindHint.BackgroundTransparency = 1
	controlBindHint.Text = "All binds start empty. Click a bind, then press a key."
	controlBindHint.Font = Enum.Font.Gotham
	controlBindHint.TextSize = 12
	controlBindHint.TextWrapped = true
	controlBindHint.TextColor3 = Color3.fromRGB(180, 183, 192)
	controlBindHint.TextXAlignment = Enum.TextXAlignment.Left
	controlBindHint.TextYAlignment = Enum.TextYAlignment.Top
	controlBindHint.Parent = controlFrame

	for _, definition in ipairs(controlBindDefinitions) do
		createKeybindRow(controlFrame, definition.label, definition.id)
	end

	controlBindStatusLabel = Instance.new("TextLabel")
	controlBindStatusLabel.Size = UDim2.new(1, 0, 0, 30)
	controlBindStatusLabel.BackgroundTransparency = 1
	controlBindStatusLabel.Text = "Status: no binds yet"
	controlBindStatusLabel.Font = Enum.Font.Gotham
	controlBindStatusLabel.TextSize = 12
	controlBindStatusLabel.TextWrapped = true
	controlBindStatusLabel.TextColor3 = Color3.fromRGB(187, 198, 213)
	controlBindStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	controlBindStatusLabel.TextYAlignment = Enum.TextYAlignment.Top
	controlBindStatusLabel.Parent = controlFrame
end

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
local SpawnerSortMode = "default"
local SpawnerSortButton = nil
local RefreshSpawnerButtons = nil
local SpawnerCatalogUI = {
	cards = {},
	countLabel = nil,
	scrollFrame = nil,
}

local function GetSpawnerSortButtonText()
	if SpawnerSortMode == "value_desc" then
		return "Sort: Value high -> low"
	elseif SpawnerSortMode == "value_asc" then
		return "Sort: Value low -> high"
	end
	return "Sort: Normal"
end

do
	local spawnerFrame = tabFrames["Spawner"]
	SpawnerAmountBox = createInput(spawnerFrame, "Amount per click (0 = random):", "0")

	local openCatalogButton = createButton(spawnerFrame, "Open catalog", function() end)
	openCatalogButton.TextSize = 18

	local spawnerStatusLabel = Instance.new("TextLabel")
	spawnerStatusLabel.Size = UDim2.new(1, 0, 0, 38)
	spawnerStatusLabel.BackgroundTransparency = 1
	spawnerStatusLabel.Text = "Open the catalog and it will slide out as a right-side extension of the hub."
	spawnerStatusLabel.Font = Enum.Font.Gotham
	spawnerStatusLabel.TextSize = 13
	spawnerStatusLabel.TextWrapped = true
	spawnerStatusLabel.TextColor3 = WINDOW_THEME.mutedText
	spawnerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	spawnerStatusLabel.TextYAlignment = Enum.TextYAlignment.Top
	spawnerStatusLabel.Parent = spawnerFrame

	local catalogWindow = Instance.new("Frame")
	catalogWindow.Size = UDim2.new(0, CatalogPanelWidth, 1, 0)
	catalogWindow.Position = UDim2.new(1, CatalogPanelWidth + CatalogPanelGap + 20, 0, 0)
	catalogWindow.BackgroundColor3 = Color3.fromRGB(16, 14, 16)
	catalogWindow.BackgroundTransparency = 0.06
	catalogWindow.BorderSizePixel = 0
	catalogWindow.ClipsDescendants = true
	catalogWindow.Visible = false
	catalogWindow.Parent = frame
	SpawnerCatalogUI.panel = catalogWindow

	local catalogCorner = Instance.new("UICorner")
	catalogCorner.CornerRadius = UDim.new(0, 24)
	catalogCorner.Parent = catalogWindow

	local catalogStroke = Instance.new("UIStroke")
	catalogStroke.Color = WINDOW_THEME.panelEdge
	catalogStroke.Thickness = 1
	catalogStroke.Transparency = 0.88
	catalogStroke.Parent = catalogWindow

	local catalogGradient = Instance.new("UIGradient")
	catalogGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(42, 27, 29)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(25, 20, 22)),
		ColorSequenceKeypoint.new(0.68, Color3.fromRGB(15, 15, 17)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 12)),
	})
	catalogGradient.Rotation = 115
	catalogGradient.Parent = catalogWindow

	local catalogGlow = Instance.new("Frame")
	catalogGlow.Size = UDim2.new(1, -2, 0, 90)
	catalogGlow.Position = UDim2.new(0, 1, 0, 1)
	catalogGlow.BackgroundColor3 = Color3.fromRGB(255, 144, 102)
	catalogGlow.BackgroundTransparency = 0.94
	catalogGlow.BorderSizePixel = 0
	catalogGlow.Parent = catalogWindow

	local catalogGlowCorner = Instance.new("UICorner")
	catalogGlowCorner.CornerRadius = UDim.new(0, 24)
	catalogGlowCorner.Parent = catalogGlow

	local catalogOrbA = Instance.new("Frame")
	catalogOrbA.Size = UDim2.new(0, 220, 0, 220)
	catalogOrbA.Position = UDim2.new(1, -110, 0, -86)
	catalogOrbA.BackgroundColor3 = Color3.fromRGB(255, 102, 112)
	catalogOrbA.BackgroundTransparency = 0.955
	catalogOrbA.BorderSizePixel = 0
	catalogOrbA.Parent = catalogWindow

	local catalogOrbACorner = Instance.new("UICorner")
	catalogOrbACorner.CornerRadius = UDim.new(1, 0)
	catalogOrbACorner.Parent = catalogOrbA

	local catalogOrbB = Instance.new("Frame")
	catalogOrbB.Size = UDim2.new(0, 180, 0, 180)
	catalogOrbB.Position = UDim2.new(0, -70, 1, -90)
	catalogOrbB.BackgroundColor3 = Color3.fromRGB(196, 110, 82)
	catalogOrbB.BackgroundTransparency = 0.97
	catalogOrbB.BorderSizePixel = 0
	catalogOrbB.Parent = catalogWindow

	local catalogOrbBCorner = Instance.new("UICorner")
	catalogOrbBCorner.CornerRadius = UDim.new(1, 0)
	catalogOrbBCorner.Parent = catalogOrbB

	local catalogResizeHandle = Instance.new("Frame")
	catalogResizeHandle.Size = UDim2.new(0, 18, 0, 92)
	catalogResizeHandle.Position = UDim2.new(0, 0, 0.5, -46)
	catalogResizeHandle.BackgroundColor3 = Color3.fromRGB(255, 176, 136)
	catalogResizeHandle.BackgroundTransparency = 0.88
	catalogResizeHandle.ZIndex = 40
	catalogResizeHandle.Parent = catalogWindow

	local catalogResizeHandleCorner = Instance.new("UICorner")
	catalogResizeHandleCorner.CornerRadius = UDim.new(1, 0)
	catalogResizeHandleCorner.Parent = catalogResizeHandle

	local catalogResizeBar = Instance.new("Frame")
	catalogResizeBar.Size = UDim2.new(0, 4, 1, -18)
	catalogResizeBar.Position = UDim2.new(0.5, -2, 0, 9)
	catalogResizeBar.BackgroundColor3 = Color3.fromRGB(255, 233, 214)
	catalogResizeBar.BackgroundTransparency = 0.34
	catalogResizeBar.BorderSizePixel = 0
	catalogResizeBar.Parent = catalogResizeHandle

	local catalogResizeBarCorner = Instance.new("UICorner")
	catalogResizeBarCorner.CornerRadius = UDim.new(1, 0)
	catalogResizeBarCorner.Parent = catalogResizeBar

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -28, 0, 50)
	header.Position = UDim2.new(0, 14, 0, 12)
	header.BackgroundTransparency = 1
	header.Parent = catalogWindow

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -62, 0, 28)
	title.BackgroundTransparency = 1
	title.Text = "Spawn Catalog"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextColor3 = WINDOW_THEME.panelText
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, -62, 0, 18)
	subtitle.Position = UDim2.new(0, 0, 0, 26)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Slides out from the hub and keeps the same height."
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 12
	subtitle.TextColor3 = WINDOW_THEME.softText
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.Parent = header

	local closeCatalogButton = Instance.new("TextButton")
	closeCatalogButton.Size = UDim2.new(0, 32, 0, 32)
	closeCatalogButton.Position = UDim2.new(1, -32, 0, 2)
	closeCatalogButton.BackgroundColor3 = Color3.fromRGB(255, 98, 98)
	closeCatalogButton.BorderSizePixel = 0
	closeCatalogButton.Text = ">"
	closeCatalogButton.Font = Enum.Font.GothamBold
	closeCatalogButton.TextSize = 18
	closeCatalogButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeCatalogButton.AutoButtonColor = false
	closeCatalogButton.Parent = header

	local closeCatalogCorner = Instance.new("UICorner")
	closeCatalogCorner.CornerRadius = UDim.new(1, 0)
	closeCatalogCorner.Parent = closeCatalogButton

	local catalogBody = Instance.new("Frame")
	catalogBody.Size = UDim2.new(1, -28, 1, -74)
	catalogBody.Position = UDim2.new(0, 14, 0, 62)
	catalogBody.BackgroundTransparency = 1
	catalogBody.Parent = catalogWindow

	local controls = Instance.new("Frame")
	controls.Size = UDim2.new(1, 0, 0, 92)
	controls.BackgroundTransparency = 1
	controls.Parent = catalogBody

	local controlsPanel = Instance.new("Frame")
	controlsPanel.Size = UDim2.new(1, 0, 0, 66)
	controlsPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	controlsPanel.BackgroundTransparency = 0.9
	controlsPanel.BorderSizePixel = 0
	controlsPanel.Parent = controls

	local controlsPanelCorner = Instance.new("UICorner")
	controlsPanelCorner.CornerRadius = UDim.new(0, 18)
	controlsPanelCorner.Parent = controlsPanel

	local controlsPanelStroke = Instance.new("UIStroke")
	controlsPanelStroke.Color = WINDOW_THEME.panelEdge
	controlsPanelStroke.Thickness = 1
	controlsPanelStroke.Transparency = 0.9
	controlsPanelStroke.Parent = controlsPanel

	local controlsGlow = Instance.new("Frame")
	controlsGlow.Size = UDim2.new(0.36, 0, 1, 0)
	controlsGlow.BackgroundColor3 = Color3.fromRGB(255, 142, 104)
	controlsGlow.BackgroundTransparency = 0.94
	controlsGlow.BorderSizePixel = 0
	controlsGlow.Parent = controlsPanel

	local controlsGlowCorner = Instance.new("UICorner")
	controlsGlowCorner.CornerRadius = UDim.new(0, 18)
	controlsGlowCorner.Parent = controlsGlow

	local controlsRow = Instance.new("Frame")
	controlsRow.Size = UDim2.new(1, -18, 0, 54)
	controlsRow.Position = UDim2.new(0, 9, 0, 6)
	controlsRow.BackgroundTransparency = 1
	controlsRow.Parent = controlsPanel

	local searchWrap = Instance.new("Frame")
	searchWrap.Size = UDim2.new(1, -186, 1, 0)
	searchWrap.BackgroundTransparency = 1
	searchWrap.Parent = controlsRow

	local sortWrap = Instance.new("Frame")
	sortWrap.Size = UDim2.new(0, 176, 1, 0)
	sortWrap.Position = UDim2.new(1, -176, 0, 0)
	sortWrap.BackgroundTransparency = 1
	sortWrap.Parent = controlsRow

	SpawnerSearchBox = createInput(searchWrap, "Search weapon:", "")

	local searchContainer = SpawnerSearchBox.Parent and SpawnerSearchBox.Parent.Parent
	local searchHolder = SpawnerSearchBox.Parent
	if searchContainer then
		searchContainer.Size = UDim2.new(1, 0, 1, 0)
		for _, child in ipairs(searchContainer:GetChildren()) do
			if child:IsA("TextLabel") then
				child.Size = UDim2.new(1, 0, 0, 14)
				child.Font = Enum.Font.GothamMedium
				child.TextSize = 12
				child.TextColor3 = WINDOW_THEME.softText
			end
		end
	end
	if searchHolder then
		searchHolder.Size = UDim2.new(1, 0, 0, 36)
		searchHolder.Position = UDim2.new(0, 0, 1, -36)
		searchHolder.BackgroundTransparency = 0.9
	end
	SpawnerSearchBox.Size = UDim2.new(1, -20, 1, 0)
	SpawnerSearchBox.Position = UDim2.new(0, 10, 0, 0)
	SpawnerSearchBox.TextSize = 16
	SpawnerSearchBox.TextXAlignment = Enum.TextXAlignment.Left

	SpawnerSortButton = createButton(sortWrap, GetSpawnerSortButtonText(), function()
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
	SpawnerSortButton.TextSize = 13
	SpawnerSortButton.Size = UDim2.new(1, 0, 0, 36)
	SpawnerSortButton.Position = UDim2.new(0, 0, 1, -36)
	SpawnerSortButton.BackgroundTransparency = 0.78

	local countLabel = Instance.new("TextLabel")
	countLabel.Size = UDim2.new(0, 128, 0, 20)
	countLabel.Position = UDim2.new(0, 6, 0, 72)
	countLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	countLabel.BackgroundTransparency = 0.88
	countLabel.BorderSizePixel = 0
	countLabel.Text = "Loading items..."
	countLabel.Font = Enum.Font.GothamMedium
	countLabel.TextSize = 11
	countLabel.TextColor3 = WINDOW_THEME.mutedText
	countLabel.TextXAlignment = Enum.TextXAlignment.Center
	countLabel.Parent = controls
	SpawnerCatalogUI.countLabel = countLabel

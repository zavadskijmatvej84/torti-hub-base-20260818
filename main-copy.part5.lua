	if Values.cache then
		UpdateValuesStatus(valueSearchBox.Text)
	end
end)

task.spawn(function() LoadFullCatalog(false) end)

-- ===== CONFIG TAB =====
local configFrame = tabFrames["Config"]

local configNameBox = createInput(configFrame, "Config name:", "")

createButton(configFrame, "Save Config", function()
    local name = configNameBox.Text
    if name == "" then
        print("[mm2run/config] empty name")
        return
    end

    pcall(function()
        if not isfolder("mm2run_configs") then
            makefolder("mm2run_configs")
        end
        local snapshot = {}
        snapshot.Weapons = InventoryOverlay.BuildVisibleCounts("Weapons")
        snapshot.Pets = InventoryOverlay.BuildVisibleCounts("Pets")

        local json = game:GetService("HttpService"):JSONEncode(snapshot)
        writefile("mm2run_configs/" .. name .. ".json", json)
        print("[mm2run/config] saved: " .. name)
        RefreshConfigsList()
    end)
end)

local clearBtn = createButton(configFrame, "Clear Inventory", function()
    pcall(function()
        InventoryOverlay.SetVisibleOwnedSnapshot("Weapons", {}, false)
        InventoryOverlay.SetVisibleOwnedSnapshot("Pets", {}, false)
        InventoryOverlay.FireInventoryDataChanged()
        print("[mm2run/config] inventory cleared")
    end)
end)
clearBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
clearBtn.MouseEnter:Connect(function()
    TweenService:Create(clearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
end)
clearBtn.MouseLeave:Connect(function()
    TweenService:Create(clearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)

local configsStatus = Instance.new("TextLabel")
configsStatus.Size = UDim2.new(1, 0, 0, 15)
configsStatus.BackgroundTransparency = 1
configsStatus.Text = "Saved configs:"
configsStatus.Font = Enum.Font.SourceSansSemibold
configsStatus.TextSize = 12
configsStatus.TextColor3 = Color3.fromRGB(180, 183, 192)
configsStatus.TextXAlignment = Enum.TextXAlignment.Left
configsStatus.Parent = configFrame

local configsScroll = Instance.new("ScrollingFrame")
configsScroll.Size = UDim2.new(1, 0, 0, 160)
configsScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
configsScroll.BackgroundTransparency = 0.3
configsScroll.BorderSizePixel = 0
configsScroll.ScrollBarThickness = 6
configsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
configsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
configsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
configsScroll.Parent = configFrame

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = configsScroll
    local lay = Instance.new("UIListLayout")
    lay.FillDirection = Enum.FillDirection.Vertical
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Padding = UDim.new(0, 4)
    lay.Parent = configsScroll
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.Parent = configsScroll
end

local function _updateConfigsScrollHeight()
    local offsetY = configsScroll.AbsolutePosition.Y - configFrame.AbsolutePosition.Y
    local available = configFrame.AbsoluteSize.Y - offsetY - 4
    configsScroll.Size = UDim2.new(1, 0, 0, math.max(80, available))
end
configFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_updateConfigsScrollHeight)
task.defer(_updateConfigsScrollHeight)

local function RefreshConfigsList()
    for _, child in pairs(configsScroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end

    pcall(function()
        if not isfolder("mm2run_configs") then return end
        local files = listfiles("mm2run_configs")
        for _, filePath in ipairs(files) do
            if string.sub(filePath, -5) == ".json" then
                local name = string.match(filePath, "([^/\\]+)%.json$") or "unknown"

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -6, 0, 32)
                row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                row.BackgroundTransparency = 0.3
                row.Parent = configsScroll

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = row

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(0.5, -8, 1, 0)
                nameLbl.Position = UDim2.new(0, 8, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = name
                nameLbl.Font = Enum.Font.GothamSemibold
                nameLbl.TextSize = 12
                nameLbl.TextColor3 = Color3.fromRGB(240, 240, 250)
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.Parent = row

                local loadBtn = Instance.new("TextButton")
                loadBtn.Size = UDim2.new(0.22, -4, 0.75, 0)
                loadBtn.Position = UDim2.new(0.52, 2, 0.125, 0)
                loadBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
                loadBtn.Text = "Load"
                loadBtn.Font = Enum.Font.Gotham
                loadBtn.TextSize = 11
                loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                loadBtn.Parent = row

                local lc = Instance.new("UICorner")
                lc.CornerRadius = UDim.new(0, 4)
                lc.Parent = loadBtn

                local delBtn = Instance.new("TextButton")
                delBtn.Size = UDim2.new(0.22, -4, 0.75, 0)
                delBtn.Position = UDim2.new(0.76, 2, 0.125, 0)
                delBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
                delBtn.Text = "Del"
                delBtn.Font = Enum.Font.Gotham
                delBtn.TextSize = 11
                delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                delBtn.Parent = row

                local dc = Instance.new("UICorner")
                dc.CornerRadius = UDim.new(0, 4)
                dc.Parent = delBtn

                loadBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        local path = "mm2run_configs/" .. name .. ".json"
                        local data = game:GetService("HttpService"):JSONDecode(readfile(path))

                        InventoryOverlay.SetVisibleOwnedSnapshot("Weapons", data.Weapons or {}, false)
                        InventoryOverlay.SetVisibleOwnedSnapshot("Pets", data.Pets or {}, false)
                        InventoryOverlay.FireInventoryDataChanged()
                        print("[mm2run/config] loaded: " .. name)
                    end)
                end)

                delBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        delfile("mm2run_configs/" .. name .. ".json")
                        print("[mm2run/config] deleted: " .. name)
                        RefreshConfigsList()
                    end)
                end)
            end
        end
    end)
end

RefreshConfigsList()

-- ===== OTHER TAB =====
local otherFrame = tabFrames["Other"]

local otherIntro = Instance.new("TextLabel")
otherIntro.Size = UDim2.new(1, 0, 0, 34)
otherIntro.BackgroundTransparency = 1
otherIntro.Text = "Automation tools. Auto block waits until player values finish loading before counting low-value players."
otherIntro.Font = Enum.Font.Gotham
otherIntro.TextSize = 13
otherIntro.TextWrapped = true
otherIntro.TextColor3 = Color3.fromRGB(187, 198, 213)
otherIntro.TextXAlignment = Enum.TextXAlignment.Left
otherIntro.TextYAlignment = Enum.TextYAlignment.Top
otherIntro.Parent = otherFrame

AutoBlockToggleButton = createButton(otherFrame, "Auto block: OFF", function()
	syncAutoBlockSettingsFromInputs()
	AutoBlockState.enabled = not AutoBlockState.enabled
	AutoBlockState.progressByName = {}
	AutoBlockState.cooldownUntilByName = {}
	AutoBlockState.busy = false
	AutoBlockState.busyTargetName = nil
	AutoBlockState.busyStartedAt = 0
	updateAutoBlockButtonText()
	if AutoBlockState.enabled then
		setAutoBlockStatus(("Watching players below %s value, delay %ss"):format(FormatValue(AutoBlockState.minValue), AutoBlockState.delaySeconds), Color3.fromRGB(120, 255, 160))
	else
		setAutoBlockStatus("Auto block disabled", Color3.fromRGB(180, 183, 192))
	end
end)

AutoBlockDelayBox = createInput(otherFrame, "Block after detection (1-30 sec):", tostring(AutoBlockState.delaySeconds))
AutoBlockDelayBox.FocusLost:Connect(function()
	syncAutoBlockSettingsFromInputs()
	if AutoBlockState.enabled then
		setAutoBlockStatus(("Watching players below %s value, delay %ss"):format(FormatValue(AutoBlockState.minValue), AutoBlockState.delaySeconds), Color3.fromRGB(120, 255, 160))
	end
end)

AutoBlockMinValueBox = createInput(otherFrame, "Block if value is below (1-1000):", tostring(AutoBlockState.minValue))
AutoBlockMinValueBox.FocusLost:Connect(function()
	syncAutoBlockSettingsFromInputs()
	AutoBlockState.progressByName = {}
	AutoBlockState.cooldownUntilByName = {}
	if AutoBlockState.enabled then
		setAutoBlockStatus(("Watching players below %s value, delay %ss"):format(FormatValue(AutoBlockState.minValue), AutoBlockState.delaySeconds), Color3.fromRGB(120, 255, 160))
	end
end)

AutoBlockStatusLabel = Instance.new("TextLabel")
AutoBlockStatusLabel.Size = UDim2.new(1, 0, 0, 38)
AutoBlockStatusLabel.BackgroundTransparency = 1
AutoBlockStatusLabel.Text = "Auto block disabled"
AutoBlockStatusLabel.Font = Enum.Font.Gotham
AutoBlockStatusLabel.TextSize = 13
AutoBlockStatusLabel.TextWrapped = true
AutoBlockStatusLabel.TextColor3 = Color3.fromRGB(180, 183, 192)
AutoBlockStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoBlockStatusLabel.TextYAlignment = Enum.TextYAlignment.Top
AutoBlockStatusLabel.Parent = otherFrame

updateAutoBlockButtonText()

-- ===== RESIZE HANDLES & DRAGGING =====
local resizeData = nil

local function createResizeHandle(pos, anchor, rx, ry, mx, my)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(0, 16, 0, 16)
    h.Position = pos
    h.AnchorPoint = anchor
    h.BackgroundTransparency = 1
    h.ZIndex = 99
    h.Parent = frame

    h.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizeData = {
                start = input.Position,
                size = frame.Size,
                pos = frame.Position,
                rx = rx, ry = ry, mx = mx, my = my
            }
        end
    end)

    return h
end

createResizeHandle(UDim2.new(1, -10, 1, -10), Vector2.new(1, 1), 1, 1, 0, 0)
createResizeHandle(UDim2.new(0, 10, 1, -10), Vector2.new(0, 1), -1, 1, 1, 0)

UserInputService.InputChanged:Connect(function(input)
    if not resizeData then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

    local delta = input.Position - resizeData.start
    local newW = math.max(240, resizeData.size.X.Offset + delta.X * resizeData.rx)
    local newH = math.max(200, resizeData.size.Y.Offset + delta.Y * resizeData.ry)

    local dw = newW - resizeData.size.X.Offset
    local dh = newH - resizeData.size.Y.Offset

    frame.Size = UDim2.new(0, newW, 0, newH)
    frame.Position = UDim2.new(
        resizeData.pos.X.Scale, resizeData.pos.X.Offset - dw * resizeData.mx,
        resizeData.pos.Y.Scale, resizeData.pos.Y.Offset - dh * resizeData.my
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizeData = nil
    end
end)

local dragData = nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData = {
            start = input.Position,
            pos = frame.Position,
        }
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragData then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

    local delta = input.Position - dragData.start
    frame.Position = UDim2.new(
        dragData.pos.X.Scale, dragData.pos.X.Offset + delta.X,
        dragData.pos.Y.Scale, dragData.pos.Y.Offset + delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData = nil
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ===== POPULATE WEAPONS, PLAYERS & VALUES =====

local ItemsTabAllowedNames = {
    "Alienbeam", "America", "Amerilaser", "Bauble", "Bat", "BattleAxe", "BattleAxe II",
    "Batwing", "Beachy", "Bioblade", "Blaster", "Bloom", "Blue Seer", "Blizzard", "Boneblade",
    "Borealis", "Candleflame", "Candy", "Celestial", "Chill", "Chroma Alienbeam", "Chroma Bauble",
    "Chroma Beachy", "Chroma Blizzard", "Chroma Boneblade", "Chroma Candle", "Chroma Constellation",
    "Chroma Cookiecane", "Chroma Darkbringer", "Chroma Deathshard", "Chroma Elderwood Blade",
    "Chroma Evergreen", "Chroma Evergun", "Chroma Fang", "Chroma Gemstone", "Chroma Gingerblade",
    "Chroma Heat", "Chroma Icecream", "Chroma Icewing", "Chroma Laser", "Chroma Lightbringer",
    "Chroma Luger", "Chroma Ornament", "Chroma Raygun", "Chroma Sands", "Chroma Saw", "Chroma Seer",
    "Chroma Shark", "Chroma Slasher", "Chroma Snowcannon", "Chroma Snow Dagger", "Chroma Snowstorm",
    "Chroma Sunrise", "Chroma Sunset", "Chroma Sweet", "Chroma Swirlygun", "Chroma Tides",
    "Chroma Treat", "Chroma Vampire's Gun", "Chroma Watergun", "Clockwork", "Constellation",
    "Cookieblade", "Cookiecane", "Corrupt", "Darkbringer", "Darkshot", "Darksword", "Deathshard",
    "Eggblade", "Elderwood Blade", "Elderwood Revolver", "Elderwood Scythe", "Eternal", "Eternal II",
    "Eternal III", "Eternal IV", "Eternalcane", "Evergreen", "Evergun", "Fang", "Flames", "Flora",
    "Flowerwood", "Flowerwood Gun", "Frostbite", "Frostsaber", "Gemstone", "Ghostblade", "Gingerblade",
    "Ginger Luger", "Gingermint", "Gingerscope", "Green Luger", "Hallows Blade", "Hallows Edge",
    "Hallowscythe", "Hallowgun", "Handsaw", "Harvester", "Heart Wand", "Heat", "Iceblaster",
    "Icebreaker", "Icecream", "Ice Dragon", "Iceflake", "Icepiercer", "Ice Shard", "Icewing",
    "Jinglegun", "Laser", "Lightbringer", "Logchopper", "Luger", "Lugercane", "Makeshift", "Minty",
    "Nebula", "Nightblade", "Niks Scythe", "Ocean", "Old Glory", "Orange Seer", "Ornament", "Pearl",
    "Pearlshine", "Peppermint", "Phantom", "Pixel", "Plasma Beam", "Plasma Blade", "Prismatic",
    "Pumpking", "Purple Seer", "Rainbow", "Rainbow Gun", "Raygun", "Red Luger", "Red Seer", "Rune",
    "Sakura", "Sands", "Saw", "Seer", "Shark", "Slasher", "Snowcannon", "Snow Dagger", "Snowflake",
    "Snowstorm", "Spectre", "Spider", "Sugar", "Sunrise", "Sunset", "Sweet", "Swirly Axe",
    "Swirly Blade", "Swirlygun", "Tides", "Traveler's Axe", "Traveler's Gun", "Treat", "Turkey",
    "Vampire's Axe", "Vampire's Edge", "Vampire's Gun", "Virtual", "Watergun", "Waves", "Winter's Edge",
    "Xenoknife", "Xenoshot", "Xmas", "Yellow Seer"
}

local RarityTint = {
    Chroma    = Color3.fromRGB(70, 40, 95),
    Godly     = Color3.fromRGB(110, 70, 30),
    Ancient   = Color3.fromRGB(60, 25, 90),
    Unique    = Color3.fromRGB(140, 50, 90),
    Legendary = Color3.fromRGB(95, 55, 25),
    Classic   = Color3.fromRGB(70, 70, 90),
    Vintage   = Color3.fromRGB(80, 75, 30),
    Rare      = Color3.fromRGB(35, 60, 95),
    Uncommon  = Color3.fromRGB(35, 70, 50),
    Common    = Color3.fromRGB(50, 50, 70),
}

local _rarityRank = {
    Chroma = 10, Godly = 9, Ancient = 8, Unique = 7,
    Classic = 6, Legendary = 5, Vintage = 4,
    Rare = 3, Uncommon = 2, Common = 1,
}

local allWeaponsList = {}
local _seenKeys = {}
for _, name in ipairs(ItemsTabAllowedNames) do
    local target = _itemsTabNormalize(name)
    local wantsChroma = string.find(target, "^chroma ") ~= nil
    local targetStripped = string.gsub(target, "^chroma ", "")

    local best, bestRank = nil, -1
    for _, entry in ipairs(WeaponCatalog) do
        local entryName = _itemsTabNormalize(entry.name)
        local entryIsChroma = entry.chroma == true

        local nameOk = false
        if wantsChroma then
            if entryIsChroma and (entryName == target or entryName == targetStripped) then
                nameOk = true
            end
        else
            if (not entryIsChroma) and entryName == target then
                nameOk = true
            end
        end

        if nameOk then
            local rank = _rarityRank[entry.rarity] or 0
            if rank > bestRank then
                best, bestRank = entry, rank
            end
        end
    end

    if best and not _seenKeys[best.key] then
        table.insert(allWeaponsList, best)
        _seenKeys[best.key] = true
    end
end

for i, entry in ipairs(allWeaponsList) do
	local wKey = entry.key
	local wName = entry.name
	local baseColor = RarityTint[entry.rarity] or RarityTint.Common
	local label = wName .. (entry.chroma and " [Chroma]" or "") .. "   (" .. entry.rarity .. " " .. entry.type .. ")"

    local weaponBtn = Instance.new("TextButton")
    weaponBtn.Size = UDim2.new(1, -6, 0, 22)
    weaponBtn.BackgroundColor3 = baseColor
    weaponBtn.BackgroundTransparency = 0.2
    weaponBtn.Text = label
    weaponBtn.Font = Enum.Font.SourceSans
    weaponBtn.TextSize = 12
    weaponBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    weaponBtn.TextXAlignment = Enum.TextXAlignment.Left
    weaponBtn.TextTruncate = Enum.TextTruncate.AtEnd
    weaponBtn.Parent = weaponScrollFrame

    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 6)
    btnPadding.PaddingRight = UDim.new(0, 6)
    btnPadding.Parent = weaponBtn

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = weaponBtn

    weaponBtn.MouseButton1Click:Connect(function()
        OfferItemAnotherPlayer(wKey, "Weapons")
    end)

    weaponButtons[#weaponButtons + 1] = {button = weaponBtn, entry = entry}
end

local function GetSpawnerCatalogItem(entry)
	return findCatalogValueForInventoryItem({
		Name = entry.name,
		Key = entry.key,
		Type = entry.type,
		Rarity = entry.rarity,
		Chroma = entry.chroma,
	})
end

local function GetSpawnerValueText(entry)
	local item = GetSpawnerCatalogItem(entry)
	if not item then
		return "?"
	end
	return FormatCatalogValue(item.value)
end

local function GetSpawnerValueNumber(entry)
	local item = GetSpawnerCatalogItem(entry)
	if not item then
		return -1
	end
	return item._numericValue or tonumber(item.value) or -1
end

local function BuildSpawnerButtonLabel(entry, valueText)
	return entry.name .. (entry.chroma and " [Chroma]" or "")
		.. "   (" .. entry.rarity .. " " .. entry.type .. " | " .. tostring(valueText or GetSpawnerValueText(entry)) .. ")"
end

RefreshSpawnerButtons = function()
	local query = normalizeWeaponName(SpawnerSearchBox and SpawnerSearchBox.Text or "")
	local ordered = {}
	for _, info in ipairs(spawnerButtons) do
		info.valueText = GetSpawnerValueText(info.entry)
		info.sortValue = GetSpawnerValueNumber(info.entry)
		table.insert(ordered, info)
	end

	table.sort(ordered, function(a, b)
		if SpawnerSortMode == "value_desc" then
			if a.sortValue ~= b.sortValue then
				return a.sortValue > b.sortValue
			end
		elseif SpawnerSortMode == "value_asc" then
			local av = a.sortValue
			local bv = b.sortValue
			local aMissing = av < 0
			local bMissing = bv < 0
			if aMissing ~= bMissing then
				return not aMissing
			end
			if av ~= bv then
				return av < bv
			end
		else
			if a.defaultOrder ~= b.defaultOrder then
				return a.defaultOrder < b.defaultOrder
			end
		end
		return a.entry.name < b.entry.name
	end)

	local visibleOrder = 0
	for index, info in ipairs(ordered) do
		local btn = info.button
		btn.Text = BuildSpawnerButtonLabel(info.entry, info.valueText)
		local haystack = normalizeWeaponName(("%s %s %s %s"):format(
			tostring(info.entry.name or ""),
			tostring(info.entry.rarity or ""),
			tostring(info.entry.type or ""),
			tostring(info.valueText or "")
		))
		local visible = query == "" or string.find(haystack, query, 1, true) ~= nil
		btn.Visible = visible
		if visible then
			visibleOrder = visibleOrder + 1
			btn.LayoutOrder = visibleOrder
		else
			btn.LayoutOrder = #ordered + index
		end
	end
end

for _, entry in ipairs(WeaponCatalog) do
    local wKey = entry.key
    local wData = Sync.Weapons[wKey]
    if not _isSpawnerAllowed(entry.name) then continue end
    local baseColor = RarityTint[entry.rarity] or RarityTint.Common
    local tradable = _isTradable(wData)
    local label = BuildSpawnerButtonLabel(entry)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 22)
    btn.BackgroundColor3 = baseColor
    btn.BackgroundTransparency = tradable and 0.2 or 0.6
    btn.Text = label
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = spawnerScrollFrame

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 6)
    btnPad.PaddingRight = UDim.new(0, 6)
    btnPad.Parent = btn

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local typed = tonumber(SpawnerAmountBox.Text)
        local amt = (typed and typed > 0) and typed or _randomAmount(entry.rarity, false)
        SpawnItem(wKey, amt, "Weapons")
    end)

    spawnerButtons[#spawnerButtons + 1] = {
		button = btn,
		entry = entry,
		tradable = tradable,
		defaultOrder = #spawnerButtons + 1,
	}
end

SpawnerSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	if RefreshSpawnerButtons then
		RefreshSpawnerButtons()
	end
end)

if RefreshSpawnerButtons then
	RefreshSpawnerButtons()
end

-- === PLAYERS TAB VALUES ===
local playersStatusLabel = Instance.new("TextLabel")
playersStatusLabel.Size = UDim2.new(1, 0, 0, 16)
playersStatusLabel.BackgroundTransparency = 1
playersStatusLabel.Text = "Catalog loading..."
playersStatusLabel.Font = Enum.Font.Gotham
playersStatusLabel.TextSize = 12
playersStatusLabel.TextColor3 = Color3.fromRGB(187, 198, 213)
playersStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
playersStatusLabel.Parent = playersFrame

local playersListLabel = Instance.new("TextLabel")
playersListLabel.Size = UDim2.new(1, 0, 0, 18)
playersListLabel.BackgroundTransparency = 1
playersListLabel.Text = "Players in server"
playersListLabel.Font = Enum.Font.GothamMedium
playersListLabel.TextSize = 14
playersListLabel.TextColor3 = Color3.fromRGB(212, 220, 233)
playersListLabel.TextXAlignment = Enum.TextXAlignment.Left
playersListLabel.Parent = playersFrame

local playersScroll2 = Instance.new("ScrollingFrame")
playersScroll2.Size = UDim2.new(1, 0, 0, 220)
playersScroll2.BackgroundTransparency = 1
playersScroll2.BorderSizePixel = 0
playersScroll2.ScrollBarThickness = 6
playersScroll2.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
playersScroll2.CanvasSize = UDim2.new(0, 0, 0, 0)
playersScroll2.AutomaticCanvasSize = Enum.AutomaticSize.Y
playersScroll2.Parent = playersFrame

do
	local playersScrollLayout = Instance.new("UIListLayout")
	playersScrollLayout.FillDirection = Enum.FillDirection.Vertical
	playersScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
	playersScrollLayout.Padding = UDim.new(0, 4)
	playersScrollLayout.Parent = playersScroll2
end

local function ClearPlayerValueRows()
	for _, child in pairs(playersScroll2:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	playerValueRows = {}
end

local function SortPlayerValueRows()
	local rows = {}
	for _, row in pairs(playerValueRows) do
		table.insert(rows, row)
	end

	table.sort(rows, function(a, b)
		local at = a.total or -1
		local bt = b.total or -1
		if at ~= bt then
			return at > bt
		end
		return a.player.Name < b.player.Name
	end)

	for index, row in ipairs(rows) do
		row.frame.LayoutOrder = index
		row.nameLabel.Text = ("#%d  %s"):format(index, row.player.Name)
	end
end

local function CreatePlayerValueRow(player)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	row.BackgroundTransparency = 0.3
	row.Parent = playersScroll2

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = row

	local pName = Instance.new("TextLabel")
	pName.Size = UDim2.new(0.5, -10, 1, 0)
	pName.Position = UDim2.new(0, 10, 0, 0)
	pName.BackgroundTransparency = 1
	pName.Text = player.Name
	pName.Font = Enum.Font.GothamBold
	pName.TextSize = 12
	pName.TextColor3 = Color3.fromRGB(240, 240, 250)
	pName.TextXAlignment = Enum.TextXAlignment.Left
	pName.TextTruncate = Enum.TextTruncate.AtEnd
	pName.Parent = row

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(0.18, 0, 1, 0)
	valueLbl.Position = UDim2.new(0.5, 0, 0, 0)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = "..."
	valueLbl.Font = Enum.Font.GothamBold
	valueLbl.TextSize = 12
	valueLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.TextTruncate = Enum.TextTruncate.AtEnd
	valueLbl.Parent = row

	local pBtn = Instance.new("TextButton")
	pBtn.Size = UDim2.new(0, 74, 0, 24)
	pBtn.Position = UDim2.new(1, -80, 0.5, -12)
	pBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
	pBtn.Text = "Select"
	pBtn.Font = Enum.Font.Gotham
	pBtn.TextSize = 11
	pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	pBtn.Parent = row

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 4)
	bc.Parent = pBtn

	pBtn.MouseButton1Click:Connect(function()
		TradeTable.Player2.Player = player.Name
		PartnerUserBox.Text = player.Name
		setActiveTab("Control")
	end)

	return {
		player = player,
		frame = row,
		nameLabel = pName,
		valueLabel = valueLbl,
		total = -1,
	}
end

local function UpdatePlayerValueRow(row)
	if not Values or not Values.byName then
		row.total = -1
		row.valueLabel.Text = "catalog"
		row.valueLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
		return
	end

	row.valueLabel.Text = "..."
	row.valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

	local okFetch, invOrErr = pcall(FetchPlayerInventory, row.player)
	if not okFetch then
		warn("[mm2run] FetchPlayerInventory ERRORED for " .. row.player.Name .. ": " .. tostring(invOrErr))
		row.total = -1
		row.valueLabel.Text = "err"
		row.valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		return
	end

	if not invOrErr then
		row.total = -1
		row.valueLabel.Text = "?"
		row.valueLabel.TextColor3 = Color3.fromRGB(200, 150, 100)
		return
	end

	local okCalc, total = pcall(function()
		local sum = CalculateInventoryValue(invOrErr, nil)
		return sum
	end)
	if not okCalc then
		warn("[mm2run] CalculateInventoryValue ERRORED for " .. row.player.Name .. ": " .. tostring(total))
		row.total = -1
		row.valueLabel.Text = "err"
		row.valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		return
	end

	row.total = total
	row.valueLabel.Text = FormatValue(total)
	row.valueLabel.TextColor3 = (total > 0) and Color3.fromRGB(120, 255, 160) or Color3.fromRGB(180, 180, 180)
end

RefreshPlayerValues = function()
	PlayerValuesAutoRefreshState.lastRefreshAt = tick()
	local playersToShow = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer then
			table.insert(playersToShow, p)
		end
	end

	playerValuesRefreshInProgress = true
	ClearPlayerValueRows()
	for _, p in ipairs(playersToShow) do
		playerValueRows[p.Name] = CreatePlayerValueRow(p)
	end

	if #playersToShow == 0 then
		playerValuesRefreshInProgress = false
		playersStatusLabel.Text = "No other players in server"
		playersStatusLabel.TextColor3 = Color3.fromRGB(205, 171, 132)
		return
	end

	playersStatusLabel.Text = Values and Values.byName and "Refreshing values..." or "Catalog loading..."
	playersStatusLabel.TextColor3 = Color3.fromRGB(187, 198, 213)

	local pending = #playersToShow
	for _, row in pairs(playerValueRows) do
		task.spawn(function()
			UpdatePlayerValueRow(row)
			SortPlayerValueRows()
			pending = pending - 1
			if pending <= 0 then
				playerValuesRefreshInProgress = false
				local priced = 0
				local unknown = 0
				for _, finishedRow in pairs(playerValueRows) do
					if (finishedRow.total or -1) >= 0 then
						priced = priced + 1
					else
						unknown = unknown + 1
					end
				end
				playersStatusLabel.Text = ("Loaded %d player values, %d unknown"):format(priced, unknown)
				playersStatusLabel.TextColor3 = Color3.fromRGB(150, 220, 150)
			end
		end)
	end
end

createButton(playersFrame, "Refresh values", function()
	RefreshPlayerValues()
end)

PlayerAutoRefreshToggleButton = createButton(playersFrame, "Auto refresh: OFF", function()
	syncPlayerAutoRefreshSettingsFromInputs()
	PlayerValuesAutoRefreshState.enabled = not PlayerValuesAutoRefreshState.enabled
	PlayerValuesAutoRefreshState.lastRefreshAt = tick()
	updatePlayerAutoRefreshButtonText()
	if PlayerValuesAutoRefreshState.enabled then
		setPlayerAutoRefreshStatus(("Auto refresh every %ss"):format(PlayerValuesAutoRefreshState.intervalSeconds), Color3.fromRGB(180, 220, 255))
	else
		setPlayerAutoRefreshStatus("Auto refresh disabled", Color3.fromRGB(190, 194, 205))
	end
end)

PlayerAutoRefreshSecondsBox = createInput(playersFrame, "Auto refresh every (1-300 sec):", tostring(PlayerValuesAutoRefreshState.intervalSeconds))
PlayerAutoRefreshSecondsBox.FocusLost:Connect(function()
	syncPlayerAutoRefreshSettingsFromInputs()
	PlayerValuesAutoRefreshState.lastRefreshAt = tick()
	if PlayerValuesAutoRefreshState.enabled then
		setPlayerAutoRefreshStatus(("Auto refresh every %ss"):format(PlayerValuesAutoRefreshState.intervalSeconds), Color3.fromRGB(180, 220, 255))
	end
end)

PlayerAutoRefreshStatusLabel = Instance.new("TextLabel")
PlayerAutoRefreshStatusLabel.Size = UDim2.new(1, 0, 0, 18)
PlayerAutoRefreshStatusLabel.BackgroundTransparency = 1
PlayerAutoRefreshStatusLabel.Text = "Auto refresh disabled"
PlayerAutoRefreshStatusLabel.Font = Enum.Font.GothamMedium
PlayerAutoRefreshStatusLabel.TextSize = 13
PlayerAutoRefreshStatusLabel.TextColor3 = Color3.fromRGB(190, 194, 205)
PlayerAutoRefreshStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerAutoRefreshStatusLabel.Parent = playersFrame

updatePlayerAutoRefreshButtonText()

task.defer(function()
	RefreshPlayerValues()
end)

Players.PlayerAdded:Connect(function()
	task.defer(function()
		RefreshPlayerValues()
	end)
end)

Players.PlayerRemoving:Connect(function()
	task.defer(function()
		RefreshPlayerValues()
	end)
end)

task.spawn(function()
	while true do
		task.wait(0.2)

		if not PlayerValuesAutoRefreshState.enabled then
			continue
		end

		syncPlayerAutoRefreshSettingsFromInputs()

		if playerValuesRefreshInProgress then
			setPlayerAutoRefreshStatus("Auto refresh paused: table is updating", Color3.fromRGB(255, 220, 100))
			continue
		end

		if not Values or not Values.byName then
			setPlayerAutoRefreshStatus("Auto refresh paused: catalog is loading", Color3.fromRGB(255, 220, 100))
			continue
		end

		local now = tick()
		local elapsed = now - (PlayerValuesAutoRefreshState.lastRefreshAt or 0)
		local remaining = PlayerValuesAutoRefreshState.intervalSeconds - elapsed

		if remaining <= 0 then
			PlayerValuesAutoRefreshState.lastRefreshAt = now
			setPlayerAutoRefreshStatus("Auto refreshing player table...", Color3.fromRGB(180, 220, 255))
			task.defer(function()
				RefreshPlayerValues()
			end)
		else
			setPlayerAutoRefreshStatus(("Next auto refresh in %.1fs"):format(remaining), Color3.fromRGB(180, 220, 255))
		end
	end
end)

task.spawn(function()
	local lastTick = tick()
	while true do
		task.wait(0.2)

		local now = tick()
		local delta = now - lastTick
		lastTick = now

		if not AutoBlockState.enabled then
			AutoBlockState.progressByName = {}
			AutoBlockState.cooldownUntilByName = {}
			AutoBlockState.busy = false
			AutoBlockState.busyTargetName = nil
			AutoBlockState.busyStartedAt = 0
			continue
		end

		syncAutoBlockSettingsFromInputs()

		if playerValuesRefreshInProgress or not Values or not Values.byName then
			local suffix = playerValuesRefreshInProgress and "values are loading" or "catalog is loading"
			setAutoBlockStatus("Timer paused: " .. suffix, Color3.fromRGB(255, 220, 100))
			continue
		end

		local activeNames = {}
		local bestCandidate = nil
		local bestProgress = 0

		for playerName, row in pairs(playerValueRows) do
			local playerObject = row.player
			local total = row.total or -1
			local cooldownUntil = AutoBlockState.cooldownUntilByName[playerName] or 0
			local coolingDown = cooldownUntil > now
			local qualified = playerObject
				and playerObject.Parent == Players
				and total >= 0
				and total < AutoBlockState.minValue
				and not AutoBlockState.blockedByName[playerName]
				and not coolingDown

			if qualified then
				activeNames[playerName] = true
				local nextProgress = math.min(AutoBlockState.delaySeconds, (AutoBlockState.progressByName[playerName] or 0) + delta)
				AutoBlockState.progressByName[playerName] = nextProgress
				if (not bestCandidate) or total > (bestCandidate.total or -1) then
					bestCandidate = row
					bestProgress = nextProgress
				end
			end
		end

		for playerName, _ in pairs(AutoBlockState.progressByName) do
			if not activeNames[playerName] then
				AutoBlockState.progressByName[playerName] = nil
			end
		end

		for playerName, cooldownUntil in pairs(AutoBlockState.cooldownUntilByName) do
			if cooldownUntil <= now then
				AutoBlockState.cooldownUntilByName[playerName] = nil
			end
		end

		if AutoBlockState.busy then
			if (now - (AutoBlockState.busyStartedAt or 0)) >= AutoBlockState.busyTimeoutSeconds then
				local stuckName = AutoBlockState.busyTargetName
				if stuckName and stuckName ~= "" then
					AutoBlockState.cooldownUntilByName[stuckName] = now + 5
					AutoBlockState.progressByName[stuckName] = nil
				end
				AutoBlockState.busy = false
				AutoBlockState.busyTargetName = nil
				AutoBlockState.busyStartedAt = 0
				setAutoBlockStatus("Previous block timed out, resuming scan", Color3.fromRGB(255, 150, 100))
			else
				local targetLabel = AutoBlockState.busyTargetName or "player"
				setAutoBlockStatus(("Blocking %s..."):format(targetLabel), Color3.fromRGB(255, 160, 120))
			end
			continue
		end

		if not bestCandidate then
			setAutoBlockStatus(("Watching players below %s value, delay %ss"):format(FormatValue(AutoBlockState.minValue), AutoBlockState.delaySeconds), Color3.fromRGB(120, 255, 160))
			continue
		end

		local remaining = math.max(0, AutoBlockState.delaySeconds - bestProgress)
		setAutoBlockStatus(("Detected %s (%s). Blocking in %.1fs"):format(
			bestCandidate.player.Name,
			FormatValue(bestCandidate.total or 0),
			remaining
		), Color3.fromRGB(255, 220, 100))

		if bestProgress >= AutoBlockState.delaySeconds then
			local targetPlayer = bestCandidate.player
			if targetPlayer and targetPlayer.Parent == Players then
				AutoBlockState.busy = true
				AutoBlockState.busyTargetName = targetPlayer.Name
				AutoBlockState.busyStartedAt = now
				AutoBlockState.busyAttemptId = AutoBlockState.busyAttemptId + 1
				local attemptId = AutoBlockState.busyAttemptId
				AutoBlockState.progressByName[targetPlayer.Name] = nil
				setAutoBlockStatus(("Blocking %s..."):format(targetPlayer.Name), Color3.fromRGB(255, 160, 120))
				task.spawn(function()
					local ok, err = pcall(function()
						SilentBlockPlayer(targetPlayer)
					end)
					if attemptId ~= AutoBlockState.busyAttemptId then
						return
					end
					if ok then
						AutoBlockState.blockedByName[targetPlayer.Name] = true
						AutoBlockState.progressByName[targetPlayer.Name] = nil
						setAutoBlockStatus(("Blocked %s"):format(targetPlayer.Name), Color3.fromRGB(120, 255, 160))
					else
						AutoBlockState.cooldownUntilByName[targetPlayer.Name] = tick() + 5
						AutoBlockState.progressByName[targetPlayer.Name] = nil
						setAutoBlockStatus(("Block failed for %s"):format(targetPlayer.Name), Color3.fromRGB(255, 100, 100))
						warn("[mm2run/autoblock] failed to block " .. targetPlayer.Name .. ": " .. tostring(err))
					end
					AutoBlockState.busy = false
					AutoBlockState.busyTargetName = nil
					AutoBlockState.busyStartedAt = 0
				end)
			end
		end
	end
end)

print("[mm2run] System merged and running successfully!")



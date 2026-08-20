
	local countCorner = Instance.new("UICorner")
	countCorner.CornerRadius = UDim.new(1, 0)
	countCorner.Parent = countLabel

	local countStroke = Instance.new("UIStroke")
	countStroke.Color = WINDOW_THEME.panelEdge
	countStroke.Thickness = 1
	countStroke.Transparency = 0.92
	countStroke.Parent = countLabel

	local catalogScrollFrame = Instance.new("ScrollingFrame")
	catalogScrollFrame.Position = UDim2.new(0, 0, 0, 96)
	catalogScrollFrame.Size = UDim2.new(1, 0, 1, -96)
	catalogScrollFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	catalogScrollFrame.BackgroundTransparency = 0.955
	catalogScrollFrame.BorderSizePixel = 0
	catalogScrollFrame.ScrollBarThickness = 6
	catalogScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(205, 138, 118)
	catalogScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	catalogScrollFrame.Parent = catalogBody
	SpawnerCatalogUI.scrollFrame = catalogScrollFrame

	local catalogScrollCorner = Instance.new("UICorner")
	catalogScrollCorner.CornerRadius = UDim.new(0, 18)
	catalogScrollCorner.Parent = catalogScrollFrame

	local catalogScrollStroke = Instance.new("UIStroke")
	catalogScrollStroke.Color = WINDOW_THEME.panelEdge
	catalogScrollStroke.Thickness = 1
	catalogScrollStroke.Transparency = 0.9
	catalogScrollStroke.Parent = catalogScrollFrame

	local catalogGridPadding = Instance.new("UIPadding")
	catalogGridPadding.PaddingTop = UDim.new(0, 12)
	catalogGridPadding.PaddingBottom = UDim.new(0, 12)
	catalogGridPadding.PaddingLeft = UDim.new(0, 12)
	catalogGridPadding.PaddingRight = UDim.new(0, 12)
	catalogGridPadding.Parent = catalogScrollFrame

	local catalogGrid = Instance.new("UIGridLayout")
	catalogGrid.FillDirection = Enum.FillDirection.Horizontal
	catalogGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
	catalogGrid.SortOrder = Enum.SortOrder.LayoutOrder
	catalogGrid.CellPadding = UDim2.new(0, 10, 0, 10)
	catalogGrid.CellSize = UDim2.new(0, 136, 0, 180)
	catalogGrid.Parent = catalogScrollFrame

	local function updateCatalogGridCellSize()
		local width = math.max(240, catalogScrollFrame.AbsoluteSize.X - 24)
		local columns = 2
		if width >= 760 then
			columns = 4
		elseif width >= 520 then
			columns = 3
		end
		local spacing = 10 * (columns - 1)
		local cellWidth = math.max(118, math.floor((width - spacing) / columns))
		local cellHeight = math.max(172, math.floor(cellWidth * 1.18))
		catalogGrid.CellSize = UDim2.new(0, cellWidth, 0, cellHeight)
	end

	local function updateCatalogScrollHeight()
		local available = math.max(160, catalogBody.AbsoluteSize.Y - 96)
		catalogScrollFrame.Size = UDim2.new(1, 0, 0, available)
	end

	catalogBody:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateCatalogScrollHeight()
		updateCatalogGridCellSize()
	end)

	catalogScrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCatalogGridCellSize)

	catalogGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		catalogScrollFrame.CanvasSize = UDim2.new(0, 0, 0, catalogGrid.AbsoluteContentSize.Y + 24)
	end)

	local catalogIsVisible = false

	local function getCatalogShownPosition()
		return UDim2.new(1, CatalogPanelGap, 0, 0)
	end

	local function getCatalogHiddenPosition()
		return UDim2.new(1, CatalogPanelWidth + CatalogPanelGap + 20, 0, 0)
	end

	local function syncCatalogPanelWidth()
		catalogWindow.Size = UDim2.new(0, CatalogPanelWidth, 1, 0)
		if catalogIsVisible then
			catalogWindow.Position = getCatalogShownPosition()
		else
			catalogWindow.Position = getCatalogHiddenPosition()
		end
		updateCatalogGridCellSize()
	end

	local function setCatalogVisible(visible)
		if catalogIsVisible == visible then
			return
		end

		catalogIsVisible = visible
		SpawnerCatalogUI.isVisible = visible
		openCatalogButton.Text = visible and "Hide catalog" or "Open catalog"
		spawnerStatusLabel.Text = visible and "Catalog is docked to the right. Drag the thin handle to resize its width." or "Open the catalog and it will slide out as a right-side extension of the hub."

		if visible then
			catalogWindow.Visible = true
			TweenService:Create(catalogWindow, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = getCatalogShownPosition(),
			}):Play()
			if RefreshSpawnerButtons then
				RefreshSpawnerButtons()
			end
		else
			local tween = TweenService:Create(catalogWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = getCatalogHiddenPosition(),
			})
			local connection
			connection = tween.Completed:Connect(function()
				if connection then
					connection:Disconnect()
				end
				if not catalogIsVisible then
					catalogWindow.Visible = false
				end
			end)
			tween:Play()
		end
	end

	openCatalogButton.MouseButton1Click:Connect(function()
		setCatalogVisible(not catalogIsVisible)
	end)

	closeCatalogButton.MouseButton1Click:Connect(function()
		setCatalogVisible(false)
	end)

	closeCatalogButton.MouseEnter:Connect(function()
		TweenService:Create(closeCatalogButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 126, 126)}):Play()
	end)

	closeCatalogButton.MouseLeave:Connect(function()
		TweenService:Create(closeCatalogButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 98, 98)}):Play()
	end)

	catalogResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and catalogIsVisible then
			SpawnerCatalogUI.resizeState = {
				startX = input.Position.X,
				width = CatalogPanelWidth,
			}
		end
	end)

	task.defer(function()
		syncCatalogPanelWidth()
		updateCatalogScrollHeight()
		updateCatalogGridCellSize()
	end)
end

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


-- ===== FILL VALUES TAB =====
local RefreshPlayerValues = function() end

local Values
local FetchPlayerInventory = function() return nil end
local findCatalogValueForInventoryItem = function() return nil end
local CalculateInventoryValue = function() return 0, {} end
local indexValueAlias = function() end

do

local function resolveInventoryItemData(key)
	if key == nil then return nil end
	if Sync.Weapons and type(Sync.Weapons[key]) == "table" and Sync.Weapons[key].ItemName then
		return Sync.Weapons[key]
	end
	if Sync.Item and type(Sync.Item[key]) == "table" and Sync.Item[key].ItemName then
		return Sync.Item[key]
	end
	return nil
end

local function pushHarvestedEntry(out, key, amount)
	local data = resolveInventoryItemData(key)
	if not data then return end
	if data.ItemType ~= "Knife" and data.ItemType ~= "Gun" then return end

	local numericAmount = math.max(1, math.floor(tonumber(amount) or 1))
	local rarity = data.Rarity or "Common"
	if data.Chroma == true then rarity = "Chroma" end

	table.insert(out, {
		Key = key,
		Name = data.ItemName or key,
		Amount = numericAmount,
		Rarity = rarity,
		Type = data.ItemType,
	})
end

local function harvestOwnedEntries(out, owned)
	if type(owned) ~= "table" then return end
	for k, v in pairs(owned) do
		local key, amount = nil, 1
		if type(k) == "number" then
			if type(v) == "string" then
				key = v
			elseif type(v) == "table" then
				key = v.Name or v.ItemName or v.Key or v.Id
				amount = tonumber(v.Amount or v.Count or v.Quantity) or 1
			end
		else
			key = k
			if type(v) == "number" then
				amount = v
			elseif type(v) == "table" then
				amount = tonumber(v.Amount or v.Count or v.Quantity) or 1
			end
		end

		if key then
			pushHarvestedEntry(out, key, amount)
		end
	end
end

local function harvestProfile(raw)
	local out = {}
	if type(raw) ~= "table" then return out end

	if type(raw.Weapons) == "table" then
		harvestOwnedEntries(out, raw.Weapons.Owned or raw.Weapons)
	end

	if #out == 0 then
		for _, bucket in pairs(raw) do
			if type(bucket) == "table" and type(bucket.Owned) == "table" then
				harvestOwnedEntries(out, bucket.Owned)
			end
		end
	end

	return out
end

function FetchPlayerInventory(player)
	if not player then return nil end

	if player == game.Players.LocalPlayer then
		return harvestProfile(ProfileData)
	end

	local out = nil
	pcall(function()
		local remote = game.ReplicatedStorage.Remotes.Extras.GetFullInventory
		local raw = remote:InvokeServer(player)
		if type(raw) == "table" then
			out = harvestProfile(raw)
		end
	end)
	return out
end

local function normalizeWeaponName(s)
	s = string.lower(tostring(s or ""))

	s = string.gsub(s, "^c%.%s*", "chroma ")
	s = string.gsub(s, "(%s)c%.%s*", "%1chroma ")

	s = string.gsub(s, "['\u{2019}\"]", "")

	s = string.gsub(s, "%s+", " ")
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	return s
end

local CatalogLookupAliases = {
	["swirly gun"] = "Swirlygun",
	["swirlygun"] = "Swirly Gun",
	["ice beam"] = "Icebeam",
	["icebeam"] = "Ice Beam",
	["plasma beam"] = "Plasmabeam",
	["plasmabeam"] = "Plasma Beam",
	["plasma blade"] = "Plasmablade",
	["plasmablade"] = "Plasma Blade",
}

function indexValueAlias(index, alias, item)
	local key = normalizeWeaponName(alias)
	if key == "" then return end

	local existing = index[key]
	if not existing then
		index[key] = item
		return
	end

	local function sameCatalogEntry(a, b)
		return tostring(a and a.name or "") == tostring(b and b.name or "")
			and tostring(a and a.rarity or "") == tostring(b and b.rarity or "")
			and tostring(a and a.value or "") == tostring(b and b.value or "")
	end

	if type(existing) == "table" and existing.__bucket == true then
		for _, candidate in ipairs(existing) do
			if sameCatalogEntry(candidate, item) then
				return
			end
		end
		table.insert(existing, item)
		return
	end

	if sameCatalogEntry(existing, item) then
		return
	end

	index[key] = {existing, item, __bucket = true}
end

local function getCatalogItemsByAlias(index, alias)
	local entry = index[alias]
	if not entry then
		return nil
	end
	if type(entry) == "table" and entry.__bucket == true then
		return entry
	end
	return {entry}
end

local function catalogRarityMatchesInventory(item, inventoryItem)
	local itemRarity = string.lower(tostring(item and item.rarity or ""))
	local inventoryRarity = string.lower(tostring(inventoryItem and inventoryItem.Rarity or ""))
	if itemRarity == "" or inventoryRarity == "" then
		return true
	end
	return itemRarity == inventoryRarity
end

function findCatalogValueForInventoryItem(w)
	if not Values or not Values.byName then return nil end

	local candidates, seen = {}, {}
	local function addCandidate(name)
		local normalized = normalizeWeaponName(name)
		if normalized ~= "" and not seen[normalized] then
			seen[normalized] = true
			table.insert(candidates, normalized)
		end
	end

	local function addAliasVariants(name)
		local normalized = normalizeWeaponName(name)
		local alias = CatalogLookupAliases[normalized]
		if alias then
			addCandidate(alias)
		end
	end

	addCandidate(w.Name)
	addAliasVariants(w.Name)
	if w.Type == "Gun" or w.Type == "Knife" then
		addCandidate(("%s (%s)"):format(tostring(w.Name or ""), w.Type))
		addAliasVariants(("%s (%s)"):format(tostring(w.Name or ""), w.Type))
	end
	if w.Key and WeaponByKey[w.Key] and WeaponByKey[w.Key].name then
		addCandidate(WeaponByKey[w.Key].name)
		addAliasVariants(WeaponByKey[w.Key].name)
	end
	if w.Chroma == true then
		addCandidate(("Chroma %s"):format(tostring(w.Name or "")))
		addCandidate(("C. %s"):format(tostring(w.Name or "")))
		addAliasVariants(("Chroma %s"):format(tostring(w.Name or "")))
		addAliasVariants(("C. %s"):format(tostring(w.Name or "")))
	end

	local fallback = nil
	for _, key in ipairs(candidates) do
		local items = getCatalogItemsByAlias(Values.byName, key)
		if items then
			for _, item in ipairs(items) do
				if catalogRarityMatchesInventory(item, w) then
					return item
				end
				if not fallback then
					fallback = item
				end
			end
		end
	end
	if tostring(w.Rarity or "") == "" then
		return fallback
	end
	return nil
end

function CalculateInventoryValue(inv, playerNameForLog)
	if not inv then return 0, {} end
	if not Values or not Values.byName then
		if playerNameForLog then
			print(("[mm2run] %s: values catalog is not loaded yet"):format(playerNameForLog))
		end
		return 0, {}
	end
	local total = 0
	local priced = {}
	local skipped = 0

	if playerNameForLog then
		print(("[mm2run] ----- %s: %d inventory items -----"):format(playerNameForLog, #inv))
	end

	for _, w in ipairs(inv) do
		local entry = findCatalogValueForInventoryItem(w)
		local eachValue = entry and (entry._numericValue or tonumber(entry.value))
		if entry and eachValue and eachValue > 0 then
			local amt = w.Amount or 1
			local contribution = eachValue * amt
			total = total + contribution
			table.insert(priced, {
				name = tostring(entry.name or w.Name),
				amount = amt,
				value = eachValue,
			})
			if playerNameForLog then
				print(("[mm2run]   [+] %s x%d  =  %s  (each %s)"):format(
					tostring(entry.name or w.Name), amt, FormatValue(contribution), FormatValue(eachValue)))
			end
		else
			skipped = skipped + 1
			if playerNameForLog then
				local reason = entry and "no numeric catalog value" or "not in live catalog"
				print(("[mm2run]   [-] %s x%d  (%s)"):format(
					tostring(w.Name), w.Amount or 1, reason))
			end
		end
	end

	if playerNameForLog then
		print(("[mm2run] ----- %s TOTAL: %s  (%d counted, %d ignored) -----"):format(
			playerNameForLog, FormatValue(total), #priced, skipped))
	end

	table.sort(priced, function(a, b)
		return (a.value * a.amount) > (b.value * b.amount)
	end)
	return total, priced
end

Values = {
	cache = nil,
	byName = nil,
	fetchedAt = 0,
	fetching = false,
}
end

local BuiltInValuesCatalog = {
    {name='Chroma Ever Set', rarity='Set', value='136000', trend='Stable', demand=8},
    {name='Chroma Alien Set', rarity='Set', value='42500', trend='Underpaid For', demand=7},
    {name='Chroma Bauble Set', rarity='Set', value='39800', trend='Stable', demand=7},
    {name='Chroma Sun Set', rarity='Set', value='17750', trend='Stable', demand=6},
    {name='Chroma Snow Set', rarity='Set', value='13500', trend='Stable', demand=6},
    {name='Chroma Blizzard Set', rarity='Set', value='12250', trend='Stable', demand=5},
    {name='Chroma Sweet Set', rarity='Set', value='5000', trend='Fluctuating', demand=5},
    {name='Chroma Bringer Set', rarity='Set', value='135', trend='Stable', demand=1},
    {name='Chroma Slasher Set', rarity='Set', value='80', trend='Stable', demand=1},
    {name='Chroma Pet Set', rarity='Set', value='35', trend='Underpaid For', demand=1},
    {name='Traveler\'s Set', rarity='Set', value='14400', trend='Stable', demand=6},
    {name='Ever Set', rarity='Set', value='5775', trend='Stable', demand=5},
    {name='Celestial Set', rarity='Set', value='4650', trend='Doing Well', demand=6},
    {name='Alien Set', rarity='Set', value='3175', trend='Stable', demand=5},
    {name='Dark Set', rarity='Set', value='2980', trend='Stable', demand=6},
    {name='Vampire\'s Set', rarity='Set', value='2925', trend='Stable', demand=5},
    {name='Sakura Set', rarity='Set', value='2520', trend='Stable', demand=6},
    {name='Sun Set', rarity='Set', value='1550', trend='Receding', demand=5},
    {name='Soul Set', rarity='Set', value='990', trend='Stable', demand=5},
    {name='Snow Set', rarity='Set', value='980', trend='Doing Well', demand=5},
    {name='Bauble Set', rarity='Set', value='930', trend='Stable', demand=5},
    {name='Rainbow Set', rarity='Set', value='820', trend='Doing Well', demand=5},
    {name='Bloom Set', rarity='Set', value='810', trend='Stable', demand=5},
    {name='Ocean Set', rarity='Set', value='555', trend='Stable', demand=4},
    {name='Xeno Set', rarity='Set', value='540', trend='Stable', demand=4},
    {name='Corrupt Set', rarity='Set', value='530', trend='Stable', demand=4},
    {name='Flowerwood Set', rarity='Set', value='515', trend='Stable', demand=4},
    {name='Blizzard Set', rarity='Set', value='500', trend='Stable', demand=4},
    {name='Bow Set', rarity='Set', value='410', trend='Stable', demand=3},
    {name='Borealis Set', rarity='Set', value='295', trend='Doing Well', demand=4},
    {name='Sweet Set', rarity='Set', value='275', trend='Stable', demand=3},
    {name='Full Ice Set', rarity='Set', value='266', trend='Stable', demand=3},
    {name='Pearl Set', rarity='Set', value='195', trend='Stable', demand=2},
    {name='Bat Set', rarity='Set', value='158', trend='Stable', demand=2},
    {name='Full Elderwood Set', rarity='Set', value='118', trend='Stable', demand=1},
    {name='Candy Set', rarity='Set', value='117', trend='Stable', demand=1},
    {name='Ice Set', rarity='Set', value='106', trend='Stable', demand=1},
    {name='Elderwood Set', rarity='Set', value='80', trend='Stable', demand=1},
    {name='Full Swirly Set', rarity='Set', value='77', trend='Stable', demand=1},
    {name='Spectre Set', rarity='Set', value='76', trend='Stable', demand=1},
    {name='Bringer Set', rarity='Set', value='73', trend='Stable', demand=1},
    {name='Swirly Set', rarity='Set', value='62', trend='Stable', demand=1},
    {name='Hallow Set', rarity='Set', value='55', trend='Stable', demand=1},
    {name='Old Glory Set', rarity='Set', value='40', trend='Stable', demand=1},
    {name='Slasher Set', rarity='Set', value='40', trend='Stable', demand=1},
    {name='Iceflake Set', rarity='Set', value='38', trend='Stable', demand=1},
    {name='Plasma Set', rarity='Set', value='35', trend='Stable', demand=1},
    {name='Logchopper Set', rarity='Set', value='33', trend='Stable', demand=1},
    {name='Virtual Set', rarity='Set', value='33', trend='Stable', demand=1},
    {name='Ginger Set (Godly)', rarity='Set', value='32', trend='Stable', demand=1},
    {name='Cookie Set', rarity='Set', value='30', trend='Stable', demand=1},
    {name='Eternalcane Set', rarity='Set', value='30', trend='Stable', demand=1},
    {name='Pumpkin Set', rarity='Set', value='410', trend='Stable', demand=3},
    {name='Latte Set', rarity='Set', value='370', trend='Overpaid For', demand=4},
    {name='Bats Set', rarity='Set', value='146', trend='Stable', demand=3},
    {name='Zombified Set', rarity='Set', value='95', trend='Stable', demand=3},
    {name='Spectral Set', rarity='Set', value='83', trend='Doing Well', demand=3},
    {name='Traveler Set', rarity='Set', value='83', trend='Doing Well', demand=3},
    {name='Aurora Set (Legend.)', rarity='Set', value='73', trend='Doing Well', demand=3},
    {name='Vampire Set (Legend.)', rarity='Set', value='73', trend='Doing Well', demand=3},
    {name='Dark Set (Rare)', rarity='Set', value='71', trend='Doing Well', demand=3},
    {name='Gingerbread Set', rarity='Set', value='63', trend='Stable', demand=3},
    {name='Silent Night Set', rarity='Set', value='62', trend='Stable', demand=2},
    {name='Pumpkin Set (2020)', rarity='Set', value='27', trend='Stable', demand=2},
    {name='Pumpkin Set (2021)', rarity='Set', value='21', trend='Stable', demand=2},
    {name='Pumpkin Set (2019)', rarity='Set', value='16', trend='Underpaid For', demand=1},
    {name='Eye Set', rarity='Set', value='14', trend='Underpaid For', demand=1},
    {name='Aurora Set (Rare)', rarity='Set', value='13', trend='Stable', demand=2},
    {name='Zombie Set', rarity='Set', value='10', trend='Stable', demand=1},
    {name='Toxic Set', rarity='Set', value='9', trend='Stable', demand=2},
    {name='Cavern Set', rarity='Set', value='8', trend='Stable', demand=2},
    {name='Vampire Set (Rare)', rarity='Set', value='8', trend='Stable', demand=2},
    {name='Potion Set', rarity='Set', value='8', trend='Stable', demand=1},
    {name='Frozen Set', rarity='Set', value='7', trend='Stable', demand=1},
    {name='Ghost Set', rarity='Set', value='7', trend='Stable', demand=1},
    {name='Mummy Set', rarity='Set', value='7', trend='Stable', demand=1},
    {name='Slime Set', rarity='Set', value='7', trend='Stable', demand=1},
    {name='Candy Swirl Set', rarity='Set', value='6', trend='Stable', demand=2},
    {name='Icedriller Set', rarity='Set', value='6', trend='Stable', demand=2},
    {name='Full Elite Set', rarity='Set', value='6', trend='Stable', demand=1},
    {name='Lights Set', rarity='Set', value='6', trend='Stable', demand=1},
    {name='Santa\'s Set (Legend.)', rarity='Set', value='6', trend='Stable', demand=1},
    {name='Scratch Set', rarity='Set', value='6', trend='Stable', demand=1},
    {name='Grave Set', rarity='Set', value='5', trend='Stable', demand=1},
    {name='Snakebite Set', rarity='Set', value='4', trend='Stable', demand=2},
    {name='Marble Set', rarity='Set', value='4', trend='Stable', demand=1},
    {name='Wrap Set', rarity='Set', value='2', trend='Stable', demand=2},
    {name='Haunted Set', rarity='Set', value='2', trend='Stable', demand=1},
    {name='Full Bringer Set', rarity='Set', value='210', trend='Stable', demand=1},
    {name='Full Luger Set', rarity='Set', value='200', trend='Stable', demand=1},
    {name='Luger Set', rarity='Set', value='145', trend='Stable', demand=1},
    {name='Sparkle Set', rarity='Set', value='127', trend='Stable', demand=2},
    {name='Collectible Set', rarity='Set', value='71', trend='Stable', demand=2},
    {name='Vintage Set', rarity='Set', value='61', trend='Stable', demand=1},
    {name='Eternal Set', rarity='Set', value='51', trend='Stable', demand=1},
    {name='Full Colored Seer Set', rarity='Set', value='48', trend='Stable', demand=1},
    {name='Skate Set', rarity='Set', value='30', trend='Stable', demand=2},
    {name='Pals Set', rarity='Set', value='16', trend='Stable', demand=2},
    {name='Colored Seer Set', rarity='Set', value='16', trend='Stable', demand=1},
    {name='Wrapping Paper Set', rarity='Set', value='14', trend='Stable', demand=1},
    {name='Godly Pet Set', rarity='Set', value='10', trend='Underpaid For', demand=1},
    {name='Small Set (107)', rarity='Set', value='1435', trend='Fluctuating', demand=4},
    {name='Small Set (103)', rarity='Set', value='1365', trend='Fluctuating', demand=4},
    {name='Full Chroma Set', rarity='Set', value='615', trend='Underpaid For', demand=1},
    {name='Chroma Weapon Set', rarity='Set', value='580', trend='Stable', demand=1},
    {name='Corrupt', rarity='Unique', value='410', trend='Stable', demand=4},
    {name='Gingerscope', rarity='Ancient', value='17750', trend='Stable', demand=6},
    {name='Traveler\'s Axe', rarity='Ancient', value='8100', trend='Stable', demand=6},
    {name='Celestial', rarity='Ancient', value='2450', trend='Doing Well', demand=6},
    {name='Vampire\'s Axe', rarity='Ancient', value='1325', trend='Stable', demand=5},
    {name='Harvester', rarity='Ancient', value='250', trend='Stable', demand=3},
    {name='Icepiercer', rarity='Ancient', value='160', trend='Stable', demand=3},
    {name='Icebreaker', rarity='Ancient', value='65', trend='Stable', demand=1},
    {name='Batwing', rarity='Ancient', value='42', trend='Stable', demand=1},
    {name='Elderwood Scythe', rarity='Ancient', value='38', trend='Stable', demand=1},
    {name='Swirly Axe', rarity='Ancient', value='38', trend='Stable', demand=1},
    {name='Hallowscythe', rarity='Ancient', value='30', trend='Stable', demand=1},
    {name='Logchopper', rarity='Ancient', value='18', trend='Stable', demand=1},
    {name='Icewing', rarity='Ancient', value='13', trend='Fluctuating', demand=2},
    {name='Ghost', rarity='Vintage', value='8', trend='Stable', demand=1},
    {name='Blood', rarity='Vintage', value='8', trend='Stable', demand=1},
    {name='Laser', rarity='Vintage', value='8', trend='Stable', demand=1},
    {name='America', rarity='Vintage', value='7', trend='Stable', demand=1},
    {name='Prince', rarity='Vintage', value='6', trend='Stable', demand=1},
    {name='Shadow', rarity='Vintage', value='6', trend='Stable', demand=1},
    {name='Phaser', rarity='Vintage', value='5', trend='Stable', demand=1},
    {name='Cowboy', rarity='Vintage', value='4', trend='Stable', demand=1},
    {name='Golden', rarity='Vintage', value='4', trend='Stable', demand=1},
    {name='Splitter', rarity='Vintage', value='3', trend='Stable', demand=1},
    {name='C. Traveler\'s Gun', rarity='Chroma', value='220000', trend='Stable', demand=9},
    {name='Chroma Evergun', rarity='Chroma', value='75000', trend='Stable', demand=8},
    {name='Chroma Evergreen', rarity='Chroma', value='48000', trend='Stable', demand=7},
    {name='Chroma Bauble', rarity='Chroma', value='34000', trend='Stable', demand=7},
    {name='C. Vampire\'s Gun', rarity='Chroma', value='29000', trend='Underpaid For', demand=7},
    {name='C. Constellation', rarity='Chroma', value='27000', trend='Underpaid For', demand=7},
    {name='Chroma Alienbeam', rarity='Chroma', value='24000', trend='Underpaid For', demand=7},
    {name='Chroma Raygun', rarity='Chroma', value='13750', trend='Stable', demand=6},
    {name='Chroma Sunrise', rarity='Chroma', value='13250', trend='Stable', demand=6},
    {name='C. Snowcannon', rarity='Chroma', value='7750', trend='Stable', demand=6},
    {name='Chroma Blizzard', rarity='Chroma', value='7000', trend='Stable', demand=5},
    {name='Chroma Sunset', rarity='Chroma', value='9250', trend='Stable', demand=5},
    {name='C. Snow Dagger', rarity='Chroma', value='3250', trend='Stable', demand=5},
    {name='C. Heart Wand', rarity='Chroma', value='4250', trend='Stable', demand=5},
    {name='Chroma Snowstorm', rarity='Chroma', value='4250', trend='Stable', demand=5},
    {name='Chroma Watergun', rarity='Chroma', value='3400', trend='Stable', demand=5},
    {name='Chroma Treat', rarity='Chroma', value='2300', trend='Fluctuating', demand=5},
    {name='Chroma Sweet', rarity='Chroma', value='2150', trend='Fluctuating', demand=5},
    {name='Chroma Ornament', rarity='Chroma', value='1800', trend='Stable', demand=5},
    {name='C. Darkbringer', rarity='Chroma', value='65', trend='Stable', demand=1},
    {name='C. Lightbringer', rarity='Chroma', value='60', trend='Stable', demand=1},
    {name='Chroma Luger', rarity='Chroma', value='50', trend='Stable', demand=1},
    {name='C. Candleflame', rarity='Chroma', value='40', trend='Stable', demand=1},
    {name='C. Elderwood Blade', rarity='Chroma', value='37', trend='Stable', demand=1},
    {name='Chroma Laser', rarity='Chroma', value='40', trend='Stable', demand=1},
    {name='C. Swirly Gun', rarity='Chroma', value='38', trend='Stable', demand=1},
    {name='C. Cookiecane', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='Chroma Slasher', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='C. Deathshard', rarity='Chroma', value='35', trend='Stable', demand=1},
    {name='Chroma Fang', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='Chroma Gemstone', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='C. Gingerblade', rarity='Chroma', value='27', trend='Stable', demand=1},
    {name='Chroma Heat', rarity='Chroma', value='28', trend='Stable', demand=1},
    {name='Chroma Seer', rarity='Chroma', value='28', trend='Stable', demand=1},
    {name='Chroma Shark', rarity='Chroma', value='32', trend='Stable', demand=1},
    {name='Chroma Saw', rarity='Chroma', value='23', trend='Stable', demand=1},
    {name='Chroma Tides', rarity='Chroma', value='27', trend='Stable', demand=1},
    {name='Chroma Boneblade', rarity='Chroma', value='22', trend='Stable', demand=1},
    {name='Chroma Fire Bat', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Bear', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='C. Fire Bunny', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Cat', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Dog', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Fox', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Chroma Fire Pig', rarity='Chroma', value='3', trend='Underpaid For', demand=1},
    {name='Traveler\'s Gun', rarity='Godly', value='5600', trend='Stable', demand=5},
    {name='Evergun', rarity='Godly', value='3450', trend='Stable', demand=5},
    {name='Constellation', rarity='Godly', value='2700', trend='Doing Well', demand=5},
    {name='Evergreen', rarity='Godly', value='2500', trend='Stable', demand=5},
    {name='Turkey', rarity='Godly', value='2450', trend='Stable', demand=5},
    {name='Alienbeam', rarity='Godly', value='2100', trend='Stable', demand=5},
    {name='Vampire\'s Gun', rarity='Godly', value='1950', trend='Stable', demand=5},
    {name='Darkshot', rarity='Godly', value='1800', trend='Stable', demand=6},
    {name='Darksword', rarity='Godly', value='1775', trend='Stable', demand=6},
    {name='Blossom', rarity='Godly', value='1370', trend='Stable', demand=6},
    {name='Sakura', rarity='Godly', value='1360', trend='Stable', demand=6},
    {name='Raygun', rarity='Godly', value='1800', trend='Stable', demand=5},
    {name='Sunrise', rarity='Godly', value='1125', trend='Receding', demand=5},
    {name='Bauble', rarity='Godly', value='825', trend='Stable', demand=5},
    {name='Snowcannon', rarity='Godly', value='850', trend='Doing Well', demand=5},
    {name='Soul', rarity='Godly', value='615', trend='Stable', demand=5},
    {name='Sunset', rarity='Godly', value='625', trend='Stable', demand=4},
    {name='Spirit', rarity='Godly', value='605', trend='Stable', demand=5},
    {name='Rainbow Gun', rarity='Godly', value='420', trend='Doing Well', demand=5},
    {name='Flora', rarity='Godly', value='410', trend='Stable', demand=5},
    {name='Rainbow', rarity='Godly', value='410', trend='Doing Well', demand=5},
    {name='Bloom', rarity='Godly', value='400', trend='Stable', demand=5},
    {name='Heart Wand', rarity='Godly', value='340', trend='Stable', demand=4},
    {name='Ocean', rarity='Godly', value='285', trend='Stable', demand=4},
    {name='Waves', rarity='Godly', value='280', trend='Stable', demand=4},
    {name='Xenoknife', rarity='Godly', value='285', trend='Stable', demand=4},
    {name='Xenoshot', rarity='Godly', value='285', trend='Stable', demand=4},
    {name='Flowerwood Gun', rarity='Godly', value='265', trend='Stable', demand=4},
    {name='Flowerwood', rarity='Godly', value='260', trend='Stable', demand=4},
    {name='Blizzard', rarity='Godly', value='260', trend='Stable', demand=4},
    {name='Snowstorm', rarity='Godly', value='260', trend='Stable', demand=4},
    {name='Watergun', rarity='Godly', value='250', trend='Stable', demand=3},
    {name='Snow Dagger', rarity='Godly', value='250', trend='Stable', demand=3},
    {name='Borealis', rarity='Godly', value='145', trend='Doing Well', demand=4},
    {name='Australis', rarity='Godly', value='140', trend='Doing Well', demand=4},
    {name='Treat', rarity='Godly', value='155', trend='Stable', demand=3},
    {name='Sweet', rarity='Godly', value='150', trend='Stable', demand=3},
    {name='Bat', rarity='Godly', value='120', trend='Stable', demand=2},
    {name='Pearlshine', rarity='Godly', value='85', trend='Stable', demand=2},
    {name='Pearl', rarity='Godly', value='80', trend='Stable', demand=2},
    {name='Candy', rarity='Godly', value='80', trend='Stable', demand=1},
    {name='Heartblade', rarity='Godly', value='65', trend='Stable', demand=1},
    {name='Luger', rarity='Godly', value='37', trend='Stable', demand=1},
    {name='Red Luger', rarity='Godly', value='37', trend='Stable', demand=1},
    {name='Candleflame', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Darkbringer', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Elderwood Blade', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Elderwood Revolver', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Iceblaster', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Makeshift', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Phantom', rarity='Godly', value='35', trend='Stable', demand=1},
    {name='Spectre', rarity='Godly', value='35', trend='Stable', demand=1},
    {name='Sugar', rarity='Godly', value='32', trend='Stable', demand=1},
    {name='Lightbringer', rarity='Godly', value='33', trend='Stable', demand=1},
    {name='Ornament', rarity='Godly', value='35', trend='Stable', demand=1},
    {name='Green Luger', rarity='Godly', value='23', trend='Stable', demand=1},
    {name='Amerilaser', rarity='Godly', value='22', trend='Stable', demand=1},
    {name='Hallowgun', rarity='Godly', value='20', trend='Stable', demand=1},
    {name='Laser', rarity='Godly', value='22', trend='Stable', demand=1},
    {name='Icebeam', rarity='Godly', value='18', trend='Stable', demand=1},
    {name='Nightblade', rarity='Godly', value='20', trend='Stable', demand=1},
    {name='Shark', rarity='Godly', value='20', trend='Stable', demand=1},
    {name='Swirly Gun', rarity='Godly', value='18', trend='Stable', demand=1},
    {name='Blaster', rarity='Godly', value='17', trend='Stable', demand=1},
    {name='Iceflake', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Plasmabeam', rarity='Godly', value='18', trend='Stable', demand=1},
    {name='Battleaxe II', rarity='Godly', value='17', trend='Stable', demand=1},
    {name='Ginger Luger', rarity='Godly', value='17', trend='Stable', demand=1},
    {name='Old Glory', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Pixel', rarity='Godly', value='17', trend='Stable', demand=1},
    {name='Plasmablade', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Slasher', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Cookiecane', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Eternalcane', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Gemstone', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Gingerblade', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Gingermint', rarity='Godly', value='12', trend='Stable', demand=1},
    {name='Jinglegun', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Lugercane', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Minty', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Nebula', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Swirly Blade', rarity='Godly', value='12', trend='Stable', demand=1},
    {name='Vampire\'s Edge', rarity='Godly', value='15', trend='Stable', demand=1},
    {name='Virtual', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Deathshard', rarity='Godly', value='13', trend='Stable', demand=1},
    {name='Battleaxe', rarity='Godly', value='12', trend='Stable', demand=1},
    {name='Bioblade', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Chill', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Clockwork', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Eternal III', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Eternal IV', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Fang', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Frostsaber', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Heat', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Spider', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Tides', rarity='Godly', value='10', trend='Stable', demand=1},
    {name='Eternal', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Eternal II', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Hallow\'s Blade', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Hallow\'s Edge', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Handsaw', rarity='Godly', value='8', trend='Stable', demand=1},
    {name='Xmas', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Boneblade', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Frostbite', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Ghostblade', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Ice Dragon', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Ice Shard', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Prismatic', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Pumpking', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Saw', rarity='Godly', value='7', trend='Stable', demand=1},
    {name='Eggblade', rarity='Godly', value='5', trend='Stable', demand=1},
    {name='Flames', rarity='Godly', value='5', trend='Stable', demand=1},
    {name='Snowflake', rarity='Godly', value='5', trend='Stable', demand=1},
    {name='Winter\'s Edge', rarity='Godly', value='5', trend='Stable', demand=1},
    {name='Peppermint', rarity='Godly', value='4', trend='Stable', demand=1},
    {name='Cookieblade', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Blue Seer', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Purple Seer', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Red Seer', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Seer', rarity='Godly', value='3', trend='Stable', demand=1},
    {name='Orange Seer', rarity='Godly', value='2', trend='Stable', demand=1},
    {name='Yellow Seer', rarity='Godly', value='2', trend='Stable', demand=1},
    {name='JD', rarity='Legendary', value='28', trend='Stable', demand=2},
    {name='Latte (Gun)', rarity='Legendary', value='140', trend='Overpaid For', demand=4},
    {name='Latte (Knife)', rarity='Legendary', value='140', trend='Overpaid For', demand=4},
    {name='Spectral (Knife)', rarity='Legendary', value='50', trend='Doing Well', demand=3},
    {name='Traveler (Gun)', rarity='Legendary', value='50', trend='Doing Well', demand=3},
    {name='Aurora (Gun)', rarity='Legendary', value='45', trend='Doing Well', demand=3},
    {name='Vampire (Gun)', rarity='Legendary', value='45', trend='Doing Well', demand=3},
    {name='Cotton Candy', rarity='Legendary', value='35', trend='Stable', demand=2},
    {name='Beach', rarity='Legendary', value='35', trend='Stable', demand=2},
    {name='Arctic (Gun)', rarity='Legendary', value='10', trend='Stable', demand=2},
    {name='Cavern (Knife)', rarity='Legendary', value='7', trend='Stable', demand=2},
    {name='Broken', rarity='Legendary', value='7', trend='Stable', demand=2},
    {name='Icedriller', rarity='Legendary', value='5', trend='Stable', demand=2},
    {name='Nightsky', rarity='Legendary', value='5', trend='Stable', demand=2},
    {name='Ghost (Knife)', rarity='Legendary', value='5', trend='Stable', demand=1},
    {name='Ginger (Gun)', rarity='Legendary', value='5', trend='Stable', demand=1},
    {name='Bunnies', rarity='Legendary', value='4', trend='Stable', demand=2},
    {name='Red Scratch', rarity='Legendary', value='4', trend='Stable', demand=1},
    {name='Skulls', rarity='Legendary', value='4', trend='Stable', demand=1},
    {name='Aurora (Knife)', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Spectral (Gun)', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Traveler (Knife)', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Vampire (Knife)', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Witched', rarity='Legendary', value='3', trend='Stable', demand=2},
    {name='Blue Elite', rarity='Legendary', value='3', trend='Stable', demand=1},
    {name='Green Elite', rarity='Legendary', value='3', trend='Stable', demand=1},
    {name='Santa\'s Magic', rarity='Legendary', value='3', trend='Stable', demand=1},
    {name='Santa\'s Spirit', rarity='Legendary', value='3', trend='Stable', demand=1},
    {name='Energized (Gun)', rarity='Legendary', value='2', trend='Stable', demand=2},
    {name='Blue Scratch', rarity='Legendary', value='2', trend='Stable', demand=1},
    {name='Ghost (Gun)', rarity='Legendary', value='2', trend='Stable', demand=1},
    {name='Chromatic (Knife)', rarity='Legendary', value='1', trend='Stable', demand=2},
    {name='Frostfade (Knife)', rarity='Legendary', value='2', trend='Stable', demand=2},
    {name='Icecracker', rarity='Legendary', value='1', trend='Stable', demand=2},
    {name='Red Fire', rarity='Legendary', value='1', trend='Stable', demand=1},
    {name='Cavern (Gun)', rarity='Legendary', value='1', trend='Stable', demand=1},
    {name='Arctic (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Chromatic (Gun)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Cursed (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Emerald', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Energized (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Frozen (Gun)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Overseer (Gun)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Predator (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Ripper (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Rupture', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Tree (Gun)', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Tree (Knife)', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Web', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Green Fire', rarity='Legendary', value='0.6', trend='Stable', demand=1},
    {name='Aquarium (Gun)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Cupid', rarity='Legendary', value='0.3', trend='Stable', demand=2},
    {name='Cursed (Gun)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Frostfade (Gun)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Frozen (Knife)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Midnight', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Nightstar', rarity='Legendary', value='0.6', trend='Stable', demand=2},
    {name='Palms (Gun)', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Sparkle', rarity='Legendary', value='0.45', trend='Stable', demand=2},
    {name='Ripper (Gun)', rarity='Legendary', value='0.3', trend='Stable', demand=2},
    {name='Ginger (Knife)', rarity='Legendary', value='0.3', trend='Stable', demand=1},
    {name='Aquarium (Knife)', rarity='Legendary', value='0.3', trend='Stable', demand=1},
    {name='Palms (Knife)', rarity='Legendary', value='0.3', trend='Stable', demand=1},
    {name='Overseer (Knife)', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Predator (Gun)', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Rune', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Universe', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Viper', rarity='Legendary', value='0.12', trend='Stable', demand=2},
    {name='Fade', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Fusion', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Plasmite', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Shiny', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Splash (Knife)', rarity='Legendary', value='0.12', trend='Stable', demand=1},
    {name='Elite', rarity='Legendary', value='0.09', trend='Stable', demand=1},
    {name='Splash (Gun)', rarity='Legendary', value='0.09', trend='Stable', demand=1},
    {name='Cane Knife (2018)', rarity='Rare', value='750', trend='Receding', demand=4},
    {name='Dungeon', rarity='Rare', value='190', trend='Overpaid For', demand=4},
    {name='Darkknife', rarity='Rare', value='70', trend='Doing Well', demand=3},
    {name='Silent Night (Knife)', rarity='Rare', value='50', trend='Stable', demand=2},
    {name='Makeshift (Knife)', rarity='Rare', value='40', trend='Stable', demand=3},
    {name='Zombified', rarity='Rare', value='35', trend='Stable', demand=3},
    {name='Swirl', rarity='Rare', value='20', trend='Stable', demand=2},
    {name='Starry (Gun)', rarity='Rare', value='22', trend='Stable', demand=2},
    {name='Aurora (Knife)', rarity='Rare', value='7', trend='Stable', demand=2},
    {name='Floral (Knife)', rarity='Rare', value='10', trend='Stable', demand=2},
    {name='Silent Night (Gun)', rarity='Rare', value='12', trend='Stable', demand=2},
    {name='Magma (Gun)', rarity='Rare', value='13', trend='Stable', demand=2},
    {name='Watcher (Gun)', rarity='Rare', value='20', trend='Stable', demand=2},
    {name='Icicles (Gun)', rarity='Rare', value='3', trend='Stable', demand=2},
    {name='Toxic (Knife)', rarity='Rare', value='5', trend='Stable', demand=2},
    {name='Vampire (Gun)', rarity='Rare', value='3', trend='Stable', demand=2},
    {name='Ghastly (Gun)', rarity='Rare', value='7', trend='Stable', demand=2},
    {name='Candy Swirl (Gun)', rarity='Rare', value='2', trend='Stable', demand=2},
    {name='Sun', rarity='Rare', value='2', trend='Stable', demand=2},
    {name='Magma', rarity='Rare', value='3', trend='Stable', demand=1},
    {name='Ghostfire', rarity='Rare', value='10', trend='Stable', demand=2},
    {name='Jack', rarity='Rare', value='3', trend='Stable', demand=2},
    {name='Snakebite (Knife)', rarity='Rare', value='3', trend='Stable', demand=2},
    {name='Bats', rarity='Rare', value='2', trend='Stable', demand=1},
    {name='Monster', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Snowflakes', rarity='Rare', value='12', trend='Stable', demand=2},
    {name='Green Marble', rarity='Rare', value='2', trend='Stable', demand=1},
    {name='Orange Marble', rarity='Rare', value='2', trend='Stable', demand=1},
    {name='Toxic (Gun)', rarity='Rare', value='2', trend='Stable', demand=1},
    {name='Darkgun', rarity='Rare', value='1', trend='Stable', demand=2},
    {name='Gingerbread', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Aurora (Gun)', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Candy Swirl (Knife)', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Snakebite (Gun)', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Vampire (Knife)', rarity='Rare', value='1', trend='Stable', demand=1},
    {name='Starry (Knife)', rarity='Rare', value='0.6', trend='Stable', demand=2},
    {name='Wraith (Knife)', rarity='Rare', value='5', trend='Stable', demand=2},
    {name='Cane (Gun)', rarity='Rare', value='0.6', trend='Stable', demand=1},
    {name='Cane (Knife)', rarity='Rare', value='550', trend='Stable', demand=1},
    {name='Ginger (Gun)', rarity='Rare', value='0.6', trend='Stable', demand=1},
    {name='Ginger (Knife)', rarity='Rare', value='0.6', trend='Stable', demand=1},
    {name='Mummy', rarity='Rare', value='0.6', trend='Stable', demand=1},
    {name='Gingerbread (Gun)', rarity='Rare', value='0.6', trend='Stable', demand=2},
    {name='Nuke', rarity='Rare', value='0.45', trend='Stable', demand=2},
    {name='Cane 2018 (Gun)', rarity='Rare', value='0.45', trend='Stable', demand=2},
    {name='Magma (Knife)', rarity='Rare', value='0.45', trend='Stable', demand=2},
    {name='Molten (Gun)', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Molten (Knife)', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Watcher (Knife)', rarity='Rare', value='0.45', trend='Stable', demand=2},
    {name='Snowy', rarity='Rare', value='0.45', trend='Stable', demand=1},
    {name='Icicles (Knife)', rarity='Rare', value='0.45', trend='Stable', demand=1},
    {name='Ghastly (Knife)', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Ice Camo', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Logcutter', rarity='Rare', value='0.3', trend='Stable', demand=2},
    {name='Butterflies', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Heart', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Neon', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Painted (Knife)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Candleflame (Gun)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Damp', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Frostflame (Knife)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Nether', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Spitfire', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Wraith (Gun)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Storm', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Tree (2023)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Tree (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Bio', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Bones (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Curse', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Frostflame (Gun)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Ghosts (Gun)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Gingerbread (Knife)', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Gingercookie (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Gingercookie (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Hologram (Gun)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Pop Art (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Sharky', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Spearmint (Gun)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Spearmint (Knife)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Spring', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Sunny', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Tropical', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Xeno (Knife)', rarity='Rare', value='0.09', trend='Stable', demand=2},
    {name='Hologram (Knife)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Neon', rarity='Rare', value='0.15', trend='Stable', demand=2},
    {name='Pop Art (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Portal (Knife)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Robot', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Tree (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Xeno (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=2},
    {name='Heartbreak', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Kraken', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Ritual', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Snowflake', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Snowglobe', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Yummy', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Floral (Gun)', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Sleigh', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Waves', rarity='Rare', value='0.06', trend='Stable', demand=1},
    {name='Black', rarity='Rare', value='0.025', trend='Stable', demand=2},
    {name='Abstract', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Ace', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Bacon', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Galactic', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Galaxy', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Hacker', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Imbued', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='iRevolver', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Korblox', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Krypto', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Musical', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Nightfire', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Nova', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Purple', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Rainbow (Gun)', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Rainbow (Knife)', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Space', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Spectrum', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Squire', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Vortex', rarity='Rare', value='0.025', trend='Stable', demand=1},
    {name='Deep Sea', rarity='Rare', value='0.02', trend='Stable', demand=1},
    {name='Bones', rarity='Uncommon', value='220', trend='Doing Well', demand=3},
    {name='Zombified (Knife)', rarity='Uncommon', value='120', trend='Stable', demand=3},
    {name='Brains', rarity='Uncommon', value='135', trend='Stable', demand=3},
    {name='Gingerbread (Knife)', rarity='Uncommon', value='85', trend='Stable', demand=3},
    {name='Sweater (Knife)', rarity='Uncommon', value='60', trend='Stable', demand=3},
    {name='Branches', rarity='Uncommon', value='50', trend='Stable', demand=2},
    {name='Snowflake', rarity='Uncommon', value='20', trend='Stable', demand=2},
    {name='Skulls', rarity='Uncommon', value='15', trend='Stable', demand=3},
    {name='Zombified (Gun)', rarity='Uncommon', value='15', trend='Stable', demand=2},
    {name='Void', rarity='Uncommon', value='12', trend='Stable', demand=2},
    {name='Zombie (Gun)', rarity='Uncommon', value='5', trend='Stable', demand=1},
    {name='Frozen (Gun)', rarity='Uncommon', value='3', trend='Stable', demand=1},
    {name='Lights (Gun)', rarity='Uncommon', value='2', trend='Stable', demand=1},
    {name='Mummy 2018 (Gun)', rarity='Uncommon', value='5', trend='Stable', demand=1},
    {name='Potion (Knife)', rarity='Uncommon', value='2', trend='Stable', demand=1},
    {name='Gothic (Gun)', rarity='Uncommon', value='7', trend='Stable', demand=2},

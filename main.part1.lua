-- ============================================================
-- Torti Hub - MM2 Run (Full Script)
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LastTradePartner = nil

local function FormatValue(v)
	if v == nil then return "?" end
	if type(v) == "number" then
		if math.abs(v) < 1 then
			local text = string.format("%.3f", v)
			text = string.gsub(text, "0+$", "")
			text = string.gsub(text, "%.$", "")
			if text == "-0" then
				text = "0"
			end
			return text
		end
		if math.abs(v - math.floor(v)) > 0.000001 then
			local text = string.format("%.3f", v)
			text = string.gsub(text, "0+$", "")
			text = string.gsub(text, "%.$", "")
			return text
		end
		local s = tostring(math.floor(v))
		local k
		repeat s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1,%2") until k == 0
		return s
	end
	return tostring(v)
end

local function FormatCatalogValue(v)
	if v == nil then return "?" end
	local numeric = tonumber(v)
	if not numeric then
		return tostring(v)
	end
	if math.abs(numeric - math.floor(numeric)) < 0.000001 and numeric >= 1 then
		return FormatValue(numeric)
	end
	local text = string.format("%.3f", numeric)
	text = string.gsub(text, "0+$", "")
	text = string.gsub(text, "%.$", "")
	return text
end

local function NormalizeItemName(value)
	local s = string.lower(tostring(value or ""))
	s = string.gsub(s, "^c%.?%s*", "chroma ")
	s = string.gsub(s, "(%s)c%.?%s*", "%1chroma ")
	s = string.gsub(s, "[^%w%s]", "")
	s = string.gsub(s, "%s+", " ")
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	return s
end

local SupremeSnapshotLabel = "August 15, 2026 at 2:00 PM"
local SupremeValueRows = {
	{category = "Unique", name = "Corrupt", value = 410},
	{category = "Vintage", name = "Blood", value = 8},
	{category = "Vintage", name = "Ghost", value = 8},
	{category = "Vintage", name = "Laser", value = 8},
	{category = "Vintage", name = "America", value = 7},
	{category = "Vintage", name = "Prince", value = 6},
	{category = "Vintage", name = "Shadow", value = 6},
	{category = "Vintage", name = "Phaser", value = 5},
	{category = "Vintage", name = "Cowboy", value = 4},
	{category = "Vintage", name = "Golden", value = 4},
	{category = "Vintage", name = "Splitter", value = 3},
	{category = "Ancient", name = "Nik's Scythe", value = "Priceless"},
	{category = "Ancient", name = "Gingerscope", value = 17750},
	{category = "Ancient", name = "Traveler's Axe", value = 8100},
	{category = "Ancient", name = "Celestial", value = 2450},
	{category = "Ancient", name = "Vampire's Axe", value = 1325},
	{category = "Ancient", name = "Harvester", value = 250},
	{category = "Ancient", name = "Icepiercer", value = 160},
	{category = "Ancient", name = "Icebreaker", value = 65},
	{category = "Ancient", name = "Batwing", value = 42},
	{category = "Ancient", name = "Elderwood Scythe", value = 38},
	{category = "Ancient", name = "Swirly Axe", value = 38},
	{category = "Ancient", name = "Hallowscythe", value = 30},
	{category = "Ancient", name = "Logchopper", value = 18},
	{category = "Ancient", name = "Icewing", value = 13},
	{category = "Chroma", name = "Chroma Traveler's Gun", value = 220000},
	{category = "Chroma", name = "Chroma Evergun", value = 75000},
	{category = "Chroma", name = "Chroma Evergreen", value = 48000},
	{category = "Chroma", name = "Chroma Bauble", value = 34000},
	{category = "Chroma", name = "Chroma Vampire's Gun", value = 29000},
	{category = "Chroma", name = "Chroma Constellation", value = 27000},
	{category = "Chroma", name = "Chroma Alienbeam", value = 24000},
	{category = "Chroma", name = "Chroma Raygun", value = 13750},
	{category = "Chroma", name = "Chroma Sunrise", value = 13250},
	{category = "Chroma", name = "Chroma Sunset", value = 9250},
	{category = "Chroma", name = "Chroma Snowcannon", value = 7750},
	{category = "Chroma", name = "Chroma Blizzard", value = 7000},
	{category = "Chroma", name = "Chroma Snowstorm", value = 4250},
	{category = "Chroma", name = "Chroma Heart Wand", value = 4250},
	{category = "Chroma", name = "Chroma Snow Dagger", value = 3250},
	{category = "Chroma", name = "Chroma Watergun", value = 3400},
	{category = "Chroma", name = "Chroma Treat", value = 2300},
	{category = "Chroma", name = "Chroma Sweet", value = 2150},
	{category = "Chroma", name = "Chroma Icecream", value = 1800},
	{category = "Chroma", name = "Chroma Sands", value = 1750},
	{category = "Chroma", name = "Chroma Ornament", value = 1800},
	{category = "Chroma", name = "Chroma Beachy", value = 1650},
	{category = "Chroma", name = "Chroma Darkbringer", value = 65},
	{category = "Chroma", name = "Chroma Lightbringer", value = 60},
	{category = "Chroma", name = "Chroma Luger", value = 50},
	{category = "Chroma", name = "Chroma Candleflame", value = 40},
	{category = "Chroma", name = "Chroma Laser", value = 40},
	{category = "Chroma", name = "Chroma Swirly Gun", value = 38},
	{category = "Chroma", name = "Chroma Elderwood Blade", value = 37},
	{category = "Chroma", name = "Chroma Deathshard", value = 35},
	{category = "Chroma", name = "Chroma Cookiecane", value = 32},
	{category = "Chroma", name = "Chroma Fang", value = 32},
	{category = "Chroma", name = "Chroma Gemstone", value = 32},
	{category = "Chroma", name = "Chroma Shark", value = 32},
	{category = "Chroma", name = "Chroma Slasher", value = 32},
	{category = "Chroma", name = "Chroma Heat", value = 28},
	{category = "Chroma", name = "Chroma Seer", value = 28},
	{category = "Chroma", name = "Chroma Gingerblade", value = 27},
	{category = "Chroma", name = "Chroma Tides", value = 27},
	{category = "Chroma", name = "Chroma Saw", value = 23},
	{category = "Chroma", name = "Chroma Boneblade", value = 22},
	{category = "Godly", name = "Traveler's Gun", value = 5600},
	{category = "Godly", name = "Evergun", value = 3450},
	{category = "Godly", name = "Constellation", value = 2700},
	{category = "Godly", name = "Evergreen", value = 2500},
	{category = "Godly", name = "Turkey", value = 2450},
	{category = "Godly", name = "Alienbeam", value = 2100},
	{category = "Godly", name = "Vampire's Gun", value = 1950},
	{category = "Godly", name = "Darkshot", value = 1800},
	{category = "Godly", name = "Raygun", value = 1800},
	{category = "Godly", name = "Darksword", value = 1750},
	{category = "Godly", name = "Blossom", value = 1370},
	{category = "Godly", name = "Sakura", value = 1360},
	{category = "Godly", name = "Sunrise", value = 1125},
	{category = "Godly", name = "Snowcannon", value = 850},
	{category = "Godly", name = "Bauble", value = 825},
	{category = "Godly", name = "Sunset", value = 625},
	{category = "Godly", name = "Soul", value = 615},
	{category = "Godly", name = "Spirit", value = 605},
	{category = "Godly", name = "Rainbow Gun", value = 420},
	{category = "Godly", name = "Flora", value = 410},
	{category = "Godly", name = "Rainbow", value = 410},
	{category = "Godly", name = "Bloom", value = 400},
	{category = "Godly", name = "Heart Wand", value = 340},
	{category = "Godly", name = "Ocean", value = 285},
	{category = "Godly", name = "Waves", value = 280},
	{category = "Godly", name = "Xenoknife", value = 285},
	{category = "Godly", name = "Iceblaster", value = 33},
	{category = "Godly", name = "Frostbite", value = 7},
	{category = "Godly", name = "Icecream", value = 130},
	{category = "Common", name = "Bells", value = "x2 T1 Commons"},
	{category = "Common", name = "Snowfall", value = "x2 T1 Commons"},
	{category = "Uncommon", name = "Ghostly", value = "x2 T1 Uncommons"},
}

local SupremeAliases = {
	["c travelers gun"] = "Chroma Traveler's Gun",
	["c vampires gun"] = "Chroma Vampire's Gun",
	["c constellation"] = "Chroma Constellation",
	["c elderwood blade"] = "Chroma Elderwood Blade",
	["c swirly gun"] = "Chroma Swirly Gun",
	["chroma swirlygun"] = "Chroma Swirly Gun",
	["swirly gun"] = "Swirlygun",
	["niks scythe"] = "Nik's Scythe",
}

local SupremeValuesByKey = {}
for _, row in ipairs(SupremeValueRows) do
	SupremeValuesByKey[NormalizeItemName(row.name)] = row
end
for alias, targetName in pairs(SupremeAliases) do
	local target = SupremeValuesByKey[NormalizeItemName(targetName)]
	if target then
		SupremeValuesByKey[NormalizeItemName(alias)] = target
	end
end

local function GetSupremeValue(name)
	return SupremeValuesByKey[NormalizeItemName(name)]
end

pcall(function() setthreadidentity(2) end)
local ProfileData = require(game.ReplicatedStorage.Modules.ProfileData)
local InventoryModule = require(game.ReplicatedStorage.Modules.InventoryModule)
local ItemModule = require(game.ReplicatedStorage.Modules.ItemModule)
local Sync = require(game.ReplicatedStorage.Database.Sync)
local ItemPopupService = require(game.ReplicatedStorage.ClientServices.ItemPopupService)
pcall(function() setthreadidentity(8) end)

local TradeRemotes = game.ReplicatedStorage.Trade
local TradeGUI = game.Players.LocalPlayer.PlayerGui.TradeGUI
local TheirOffer = TradeGUI.Container.Trade.TheirOffer
local YourOffer = TradeGUI.Container.Trade.YourOffer

local SearchTextSignal
local TradeInventory
local functions = {}

local Config = {
	item = "",
	in_trade = false,
	player2 = nil
}

-- === Weapon Catalog ===
local WeaponCatalog = {}
local WeaponByKey = {}
local WeaponByName = {}
local RareWeaponKeys = {}
local RareRarities = { Godly = true, Ancient = true, Unique = true, Chroma = true, Legendary = true, Classic = true }

do
	local source = Sync.Weapons or Sync.Item
	for key, data in pairs(source) do
		if type(data) == "table" and (data.ItemType == "Knife" or data.ItemType == "Gun") then
			local rarity = data.Rarity or "Common"
			local isChroma = data.Chroma == true
			local effectiveRarity = isChroma and "Chroma" or rarity
			local entry = {
				key = key,
				name = data.ItemName or key,
				rarity = effectiveRarity,
				type = data.ItemType,
				chroma = isChroma,
			}
			table.insert(WeaponCatalog, entry)
			WeaponByKey[key] = entry
			WeaponByName[string.lower(entry.name)] = entry
			if RareRarities[effectiveRarity] then
				table.insert(RareWeaponKeys, key)
			end
		end
	end
	local rarityOrder = {
		Chroma = 1, Godly = 2, Ancient = 3, Unique = 4, Legendary = 5, Classic = 6,
		Vintage = 7, Rare = 8, Uncommon = 9, Common = 10,
	}
	table.sort(WeaponCatalog, function(a, b)
		local ra = rarityOrder[a.rarity] or 99
		local rb = rarityOrder[b.rarity] or 99
		if ra ~= rb then return ra < rb end
		if a.type ~= b.type then return a.type < b.type end
		return a.name < b.name
	end)
end

-- === Basic item checks ===
local InventoryOverlay = (function()
	local overlayTypes = {
		Weapons = true,
		Pets = true,
	}

	local state = {
		baseByType = {},
		deltaByType = {},
		shadowByType = {},
	}

	local function normalizeOwnedAmount(value)
		local numeric = tonumber(value)
		if numeric then
			return math.max(0, math.floor(numeric + 0.00001))
		end
		if value == nil then
			return 0
		end
		return 1
	end

	local function copyOwnedCounts(source)
		local copy = {}
		if type(source) ~= "table" then
			return copy
		end
		for key, value in pairs(source) do
			if type(key) == "string" then
				local amount = normalizeOwnedAmount(value)
				if amount > 0 then
					copy[key] = amount
				end
			end
		end
		return copy
	end

	local function getOwnedBucket(itemType)
		if not ProfileData[itemType] then
			ProfileData[itemType] = {}
		end
		if type(ProfileData[itemType].Owned) ~= "table" then
			ProfileData[itemType].Owned = {}
		end
		return ProfileData[itemType].Owned
	end

	local function analyzeOwnedCounts(itemType)
		local stringCounts = {}
		local listCounts = {}
		local owned = ProfileData[itemType] and ProfileData[itemType].Owned
		if type(owned) ~= "table" then
			return stringCounts, listCounts
		end

		for key, value in pairs(owned) do
			if type(key) == "string" then
				local amount = normalizeOwnedAmount(value)
				if amount > 0 then
					stringCounts[key] = (stringCounts[key] or 0) + amount
				end
			elseif type(value) == "string" and value ~= "" then
				listCounts[value] = (listCounts[value] or 0) + 1
			elseif type(value) == "table" then
				local itemName = value.Name or value.ItemName or value.Key or value.Id
				if type(itemName) == "string" and itemName ~= "" then
					local amount = normalizeOwnedAmount(value.Amount or value.Count or value.Quantity or 1)
					if amount > 0 then
						listCounts[itemName] = (listCounts[itemName] or 0) + amount
					end
				end
			end
		end

		return stringCounts, listCounts
	end

	local function buildBaseSnapshot(itemType)
		local base = {}
		local stringCounts, listCounts = analyzeOwnedCounts(itemType)

		for itemName, amount in pairs(stringCounts) do
			base[itemName] = {
				stringAmount = amount,
				listAmount = listCounts[itemName] or 0,
			}
		end

		for itemName, amount in pairs(listCounts) do
			if not base[itemName] then
				base[itemName] = {
					stringAmount = 0,
					listAmount = amount,
				}
			end
		end

		return base
	end

	local function getOverlayBase(itemType)
		if not state.baseByType[itemType] then
			state.baseByType[itemType] = buildBaseSnapshot(itemType)
		end
		return state.baseByType[itemType]
	end

	local function getOverlayDelta(itemType)
		if not state.deltaByType[itemType] then
			state.deltaByType[itemType] = {}
		end
		return state.deltaByType[itemType]
	end

	local function getOverlayShadow(itemType)
		if not state.shadowByType[itemType] then
			state.shadowByType[itemType] = {}
		end
		return state.shadowByType[itemType]
	end

	local function fireInventoryDataChanged()
		pcall(function()
			game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged:Fire()
		end)
	end

	local function getBaseEntryAmounts(itemType, itemName)
		local entry = getOverlayBase(itemType)[itemName]
		if not entry then
			return 0, 0
		end
		return entry.stringAmount or 0, entry.listAmount or 0
	end

	local function getVisibleAmountFromParts(baseStringAmount, baseListAmount, deltaAmount)
		return baseListAmount + math.max(0, baseStringAmount + (deltaAmount or 0))
	end

	local function applyOverlayForType(itemType)
		if not overlayTypes[itemType] then
			return
		end

		local owned = getOwnedBucket(itemType)
		local base = getOverlayBase(itemType)
		local delta = getOverlayDelta(itemType)
		local previousShadow = getOverlayShadow(itemType)
		local nextShadow = {}
		local seen = {}

		local function visit(itemName)
			if seen[itemName] then
				return
			end
			seen[itemName] = true

			local baseStringAmount = 0
			local entry = base[itemName]
			if entry then
				baseStringAmount = entry.stringAmount or 0
			end

			local targetStringAmount = math.max(0, baseStringAmount + (delta[itemName] or 0))
			if targetStringAmount > 0 then
				owned[itemName] = targetStringAmount
				nextShadow[itemName] = targetStringAmount
			else
				owned[itemName] = nil
			end
		end

		for itemName in pairs(base) do
			visit(itemName)
		end
		for itemName in pairs(delta) do
			visit(itemName)
		end
		for itemName in pairs(previousShadow) do
			visit(itemName)
		end

		state.shadowByType[itemType] = nextShadow
	end

	local function applyOverlayForAllTypes(shouldFire)
		for itemType in pairs(overlayTypes) do
			applyOverlayForType(itemType)
		end
		if shouldFire then
			fireInventoryDataChanged()
		end
	end

	local function syncOverlayBaseForType(itemType)
		if not overlayTypes[itemType] then
			return false
		end

		local currentString, currentList = analyzeOwnedCounts(itemType)
		local base = getOverlayBase(itemType)
		local delta = getOverlayDelta(itemType)
		local shadow = getOverlayShadow(itemType)
		local nextBase = {}
		local changed = false
		local seen = {}

		local function visit(map)
			for itemName in pairs(map) do
				if not seen[itemName] then
					seen[itemName] = true
					local currentStringAmount = currentString[itemName] or 0
					local currentListAmount = currentList[itemName] or 0
					local baseEntry = base[itemName] or {}
					local nextStringAmount = baseEntry.stringAmount or 0
					local nextListAmount = baseEntry.listAmount or 0
					local shadowStringAmount = shadow[itemName]
					if shadowStringAmount == nil then
						shadowStringAmount = nextStringAmount
					end

					if currentStringAmount ~= shadowStringAmount then
						nextStringAmount = currentStringAmount
					end
					if currentListAmount ~= nextListAmount then
						nextListAmount = currentListAmount
					end

					if nextStringAmount ~= (baseEntry.stringAmount or 0) or nextListAmount ~= (baseEntry.listAmount or 0) then
						changed = true
					end

					if nextStringAmount > 0 or nextListAmount > 0 or (delta[itemName] or 0) ~= 0 then
						nextBase[itemName] = {
							stringAmount = nextStringAmount,
							listAmount = nextListAmount,
						}
					end
				end
			end
		end

		visit(currentString)
		visit(currentList)
		visit(base)
		visit(delta)
		visit(shadow)

		state.baseByType[itemType] = nextBase

		return changed
	end

	local function syncOverlayBaseFromProfile()
		local changed = false
		for itemType in pairs(overlayTypes) do
			if syncOverlayBaseForType(itemType) then
				changed = true
			end
		end
		if changed then
			applyOverlayForAllTypes(true)
		end
		return changed
	end

	local overlay = {}

	function overlay.FireInventoryDataChanged()
		fireInventoryDataChanged()
	end

	function overlay.BuildVisibleCounts(itemType)
		local visible = {}
		local seen = {}
		local base = getOverlayBase(itemType)
		local delta = getOverlayDelta(itemType)

		local function visit(itemName)
			if seen[itemName] then
				return
			end
			seen[itemName] = true

			local baseStringAmount, baseListAmount = getBaseEntryAmounts(itemType, itemName)
			local visibleAmount = getVisibleAmountFromParts(baseStringAmount, baseListAmount, delta[itemName] or 0)
			if visibleAmount > 0 then
				visible[itemName] = visibleAmount
			end
		end

		for itemName in pairs(base) do
			visit(itemName)
		end
		for itemName in pairs(delta) do
			visit(itemName)
		end

		return visible
	end

	function overlay.GetVisibleOwnedAmount(itemType, itemName)
		syncOverlayBaseFromProfile()
		local baseStringAmount, baseListAmount = getBaseEntryAmounts(itemType, itemName)
		return getVisibleAmountFromParts(baseStringAmount, baseListAmount, getOverlayDelta(itemType)[itemName] or 0)
	end

	function overlay.AdjustVisibleOwnedAmount(itemName, amountDelta, itemType, shouldFire)
		itemType = itemType or "Weapons"
		amountDelta = math.floor(tonumber(amountDelta) or 0)
		if amountDelta == 0 then
			return overlay.GetVisibleOwnedAmount(itemType, itemName)
		end

		syncOverlayBaseFromProfile()

		local delta = getOverlayDelta(itemType)
		local baseStringAmount, baseListAmount = getBaseEntryAmounts(itemType, itemName)
		local currentVisible = getVisibleAmountFromParts(baseStringAmount, baseListAmount, delta[itemName] or 0)
		local nextVisible = math.max(0, currentVisible + amountDelta)
		local targetStringAmount = math.max(0, nextVisible - baseListAmount)
		local nextDelta = targetStringAmount - baseStringAmount

		if nextDelta ~= 0 then
			delta[itemName] = nextDelta
		else
			delta[itemName] = nil
		end

		applyOverlayForType(itemType)
		if shouldFire ~= false then
			fireInventoryDataChanged()
		end

		return nextVisible
	end

	function overlay.SetVisibleOwnedSnapshot(itemType, targetCounts, shouldFire)
		itemType = itemType or "Weapons"
		syncOverlayBaseFromProfile()

		local base = getOverlayBase(itemType)
		local nextDelta = {}
		local cleanTarget = copyOwnedCounts(targetCounts)
		local seen = {}

		for itemName, targetAmount in pairs(cleanTarget) do
			seen[itemName] = true
			local baseStringAmount, baseListAmount = getBaseEntryAmounts(itemType, itemName)
			local targetStringAmount = math.max(0, targetAmount - baseListAmount)
			local diff = targetStringAmount - baseStringAmount
			if diff ~= 0 then
				nextDelta[itemName] = math.floor(diff)
			end
		end

		for itemName in pairs(base) do
			if not seen[itemName] then
				local baseStringAmount = getBaseEntryAmounts(itemType, itemName)
				local diff = -baseStringAmount
				if diff ~= 0 then
					nextDelta[itemName] = diff
				end
			end
		end

		state.deltaByType[itemType] = nextDelta
		applyOverlayForType(itemType)
		if shouldFire ~= false then
			fireInventoryDataChanged()
		end
	end

	function overlay.CheckForItem(itemName, itemType)
		local amount = overlay.GetVisibleOwnedAmount(itemType, itemName)
		if amount > 0 then
			return true, amount
		end
		return false
	end

	for itemType in pairs(overlayTypes) do
		state.baseByType[itemType] = buildBaseSnapshot(itemType)
		state.deltaByType[itemType] = {}
		state.shadowByType[itemType] = {}
	end

	task.spawn(function()
		while task.wait(0.5) do
			pcall(syncOverlayBaseFromProfile)
		end
	end)

	return overlay
end)()

local v18 = {}
local function v22(v19)
	for _, v21 in pairs(v19:GetChildren()) do
		if v21:IsA("Frame") then
			v21.Visible = false
			if v18[v21] then
				v18[v21]:Disconnect()
				v18[v21] = nil
			end
		end
	end
end

local CurrencyScanBlockedBranches = {
	weapons = true,
	pets = true,
	effects = true,
	radios = true,
	emotes = true,
	powers = true,
	perks = true,
	crafting = true,
	inventory = true,
	trade = true,
	trading = true,
	settings = true,
	music = true,
}

local CurrencyStatKeys = {
	level = true,
	xp = true,
	experience = true,
	exp = true,
	prestige = true,
	tier = true,
	rank = true,
	index = true,
	id = true,
	chance = true,
	progress = true,
	timer = true,
	time = true,
	streak = true,
}

local CurrencyGenericAmountKeys = {
	amount = true,
	count = true,
	total = true,
	balance = true,
	owned = true,
	value = true,
}

local CurrencyKeywordFragments = {
	"currenc",
	"coin",
	"gem",
	"token",
	"candy",
	"candies",
	"shell",
	"beach",
	"pumpkin",
	"heart",
	"egg",
	"snow",
	"harvest",
	"star",
	"gingerbread",
	"gift",
	"shard",
	"flake",
	"crown",
	"key",
}

local function PathSegments(path)
	local parts = {}
	for segment in string.gmatch(tostring(path or ""), "[^ ]+") do
		table.insert(parts, segment)
	end
	return parts
end

local function PathContainsBlockedCurrencyBranch(path)
	for _, segment in ipairs(PathSegments(path)) do
		if CurrencyScanBlockedBranches[segment] then
			return true
		end
	end
	return false
end

local function PathLooksCurrencyLike(path)
	local text = NormalizeItemName(path)
	for _, fragment in ipairs(CurrencyKeywordFragments) do
		if string.find(text, fragment, 1, true) then
			return true
		end
	end
	return false
end

local function PrettifyCurrencyLabel(text)
	local normalized = NormalizeItemName(text)
	if normalized == "" then
		return "Unknown"
	end

	return (string.gsub(normalized, "(%a)([%w]*)", function(first, rest)
		return string.upper(first) .. rest
	end))
end

local function ResolveCurrencyLabel(rawKey, path)
	local keyText = NormalizeItemName(rawKey)
	if not CurrencyGenericAmountKeys[keyText] then
		return PrettifyCurrencyLabel(rawKey)
	end

	local parts = PathSegments(path)
	for i = #parts - 1, 1, -1 do
		local segment = parts[i]
		if not CurrencyGenericAmountKeys[segment] then
			return PrettifyCurrencyLabel(segment)
		end
	end

	return PrettifyCurrencyLabel(rawKey)
end

local function AddCurrencyRecord(out, rawKey, path, amount)
	if type(amount) ~= "number" or amount == 0 then
		return
	end

	local label = ResolveCurrencyLabel(rawKey, path)
	local key = NormalizeItemName(label)
	if key == "" then
		return
	end

	local existing = out[key]
	if not existing then
		existing = {
			label = label,
			amount = 0,
			path = path,
		}
		out[key] = existing
	end

	existing.amount = existing.amount + amount
end

local function ShouldTreatAsCurrency(path, rawKey)
	local keyText = NormalizeItemName(rawKey)
	local normalizedPath = NormalizeItemName(path)
	local pathParts = PathSegments(normalizedPath)
	local parentPath = table.concat(pathParts, " ", 1, math.max(#pathParts - 1, 0))

	if PathContainsBlockedCurrencyBranch(normalizedPath) then
		return false
	end

	if CurrencyStatKeys[keyText] and not PathLooksCurrencyLike(parentPath) then
		return false
	end

	if PathLooksCurrencyLike(normalizedPath) or PathLooksCurrencyLike(parentPath) then
		return true
	end

	if #pathParts <= 2 and not CurrencyStatKeys[keyText] then
		return true
	end

	return false
end

local function HarvestCurrenciesRecursive(node, out, seen, depth, path)
	if type(node) ~= "table" or seen[node] or depth > 6 then
		return
	end
	seen[node] = true

	for rawKey, value in pairs(node) do
		local keyText = NormalizeItemName(rawKey)
		local nextPath = path ~= "" and (path .. " " .. keyText) or keyText

		if type(value) == "number" then
			if ShouldTreatAsCurrency(nextPath, rawKey) then
				AddCurrencyRecord(out, rawKey, nextPath, value)
			end
		elseif type(value) == "table" then
			if not PathContainsBlockedCurrencyBranch(nextPath) then
				HarvestCurrenciesRecursive(value, out, seen, depth + 1, nextPath)
			end
		end
	end
end

local function ScanProfileCurrencies(profile)
	local out = {}
	HarvestCurrenciesRecursive(profile, out, {}, 0, "")
	return out
end

local VisiblePlayerCurrencyNames = {
	coins = true,
	coin = true,
	gems = true,

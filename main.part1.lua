-- ============================================================
-- Torti Hub - MM2 Run (Full Script)
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LastTradePartner = nil

function FormatValue(v)
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

function FormatCatalogValue(v)
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

function FormatRubleValue(v)
	if v == nil then return nil end
	local numeric = tonumber(v)
	if not numeric then
		return tostring(v)
	end
	return string.format("%.2f₽", numeric)
end

function NormalizeItemName(value)
	local s = string.lower(tostring(value or ""))
	s = string.gsub(s, "^c%.?%s*", "chroma ")
	s = string.gsub(s, "(%s)c%.?%s*", "%1chroma ")
	s = string.gsub(s, "[^%w%s]", "")
	s = string.gsub(s, "%s+", " ")
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	return s
end

local RubleValueRowsText = [=[
Passion,217729.38
Evergun,189891.63
Bauble,84603.57
Vampire's Gun,59375
Constellation,58750
Alienbeam,53750
Gingerscope,34250
Sunrise,34050
Raygun,31246.24
Sunset,28771.56
Snowcannon,23017.47
Traveler's Axe,17283.75
Blizzard,15029.43
Snowstorm,13047.99
Traveler's Gun,11996.25
Elderwood Scythe,11975
Heart Wand,10500
Watergun,10125
Alienbeam,8553.43
Snow Dagger,7425
Evergun,7221.25
Constellation,6498.75
Evergreen,6334.87
Turkey,5151.25
Celestial,5062.5
Treat,4800
Darksword,4571.25
Vampire's Gun,4500
Raygun,4500
Sweet,4497.5
Darkshot,4140
Beachy,3250
Vampire's Axe,3200
Icecream,3058.75
Sakura,2900
Blossom,2812.5
Sunrise,2625
Bauble,2125
Snowcannon,1955
Cane,1835
Soul,1491.25
Sunset,1437.5
Spirit,1356.25
Rainbow Gun,1161.25
Flora,1111.26
Rainbow,1073.75
Bloom,998.75
Corrupt,970.2
Heart Wand,900
Xenoknife,879.87
Spirit,1356.25
Rainbow Gun,1161.25
Flora,1111.26
Rainbow,1073.75
Bloom,998.75
Corrupt,970.2
Heart Wand,900
Xenoknife,879.87
Xenoshot,856.25
Bats,760.38
Blizzard,748.75
Ocean,722
Snowstorm,698.75
Flowerwood Gun,692.5
Waves,625
Snow Dagger,597.5
Harvester,575
Watergun,574.99
Mummified,562.49
Bones,562.39
Flowerwood Knife,556.86
Latte,540
Icepiercer,493.75
Brains,475
Sweet,435
Treat,425
Borealis,412.5
Glitch1,399.99
Australis,379.99
Latte,374.9
Snowflake,370.16
Bat,350
Gifts,347.5
Beachy,337.5
Ornament,337.5
Sands,337.5
Ghoulish,329.4
Icecream,318.75
Sweater,316.22
Pine,310.93
Dungeon,312.4
Candy,300
Darkknife,275
Gingerbread,260
Nether,250
Heartblade,250
Icebreaker,220
Pearlshine,218.75
Pearl,208.75
Silent Night,201.86
Elderwood Scythe,194.56
Darkbringer,193.75
Lightbringer,187.49
Pop Art,183.33
Luger,176.25
Elf,175
Batwing,171.25
Cats,156.25
Aurora,150
Laser,147.49
Iceblaster,139.99
Vampire,137.5
Branches,137.4
Candleflame,131.24
Cotton Candy,127.5
Alex,125
Traveler,124.9
Gemstone,120
Shark,116.24
Sugar,115
Elderwood Revolver,113.1
Spectre,112.49
Amerilaser,111.25
Sparkle9,111.25
Sparkle4,110
Elderwood Blade,78.6
Nightblade,78.11
Sparkle7,77.5
Apocalypse,77.5
Shark,76.25
Logchopper,75.1
Sparkle10,75
Korblox,75
BattleAxe II,75
Icebeam,74.97
Slasher,73.69
Tides,72.5
Green Luger,71.33
Prism,71.25
Icewing,71.25
Old Glory,71.25
Makeshift,68.75
JD,68.75
BattleAxe,67.5
Webbed,66.95
Pixel,66.25
Plasmablade,64.99
Sparkle6,63.75
Zombified,63.34
Blaster,62.5
Glitch2,62.5
Xmas,62.5
Pumpkin,109.76
Darkbringer,108.94
Hallowscythe,108.74
Heat,107.5
Swirly Gun,106.24
Ecto,106.14
Swirly Axe,104.98
Lightbringer,104.7
Phantom,99.99
Red Luger,97.5
Spectral,96.25
Vampire's Edge,93.75
Deathshard,92.44
Wrapped,90
Laser,88.75
Frosted,87.85
Makeshift,87.49
Candleflame,86.21
Makeshift,87.49
Candleflame,86.21
Cookiecane,82.49
Fang,81.25
Luger,80.63
Plasmabeam,80
Hallowgun,79.99
Beach,79.89
Gingerblade,62.5
Boneblade,62.5
Saw,60
Sparkle8,60
Jinglegun,60
Nebula,58
Swirly Gun,56.25
CandyCorn,56.25
Frosted,55
Gemstone,55
Monster,54.88
America,53.75
Ice Shard,53.63
Bioblade,53.2
Eternalcane,51.25
Sparkle5,50
Slimy,50
Starry,50
Lugercane,49.99
Ginger Luger,49.5
Eternal,48.75
Slasher,48.72
Starry,48.45
Snowflakes,47.75
Laser,47.5
Cookiecane,44.99
Deathshard,43.75
Elf,43.75
Minty,43.75
Prismatic,42.5
Spider,42.49
Hallow's Edge,42.49
Gingermint,42.37
Bioblade,38.75
Ice Shard,37.5
Gingerblade,36.25
Blood,36.17
Shadow,36.17
Swirl,36.14
Aurora,35
Bunnies,35
Eternalcane,35
Tides,35
Arctic,34.87
Candy Corn,34.66
Coal,33.75
Sparkle1,33.75
Spider,33.74
Virtual,33.74
Chill,32.5
Eternal III,32.5
Hallow's Edge,32.5
Swirly Blade,32.49
Watcher,31.6
RIP,31.25
Phaser,31.25
Eternal II,31.25
Seer,31.25
Fang,31.25
Handsaw,31.25
Broken,31.25
Flames,31.23
Silent Night,30.87
Purple Seer,30
Red Seer,30
Clockwork,30
Blue Seer,30
Peppermint,29.98
Sweetheart,29.62
Ice Dragon,28.75
Blue Elite,28.75
Frostsaber,28.75
Snowflakes,28.21
Boneblade,27.5
Winter's Edge,26.25
Cookieblade,26.25
Floral,26.15
Vampire,25
Aurora,25
Phantom,25
Orange Seer,25
Frostbite,25
Snowflake,25
Tailslide,24.9
Blue Elite,24.9
Zombie,24.9
Pumpkin,24.75
Golden,23.75
Skool,23.73
Starry,23.27
Prince,22.5
Ghost,22.5
Combat II,22.23
Sparkle2,21.24
Green Elite,20
Cowboy,20
Green Elite,20
Void,20
Gingerbread,19.97
Darkgun,18.75
Vampire,18.75
Candy Swirl,18.71
Paws,18.71
Witched,18.61
Wrap,18.25
Magma,17.5
Zombie,17.49
Xeno,16.92
Ginger,16.25
Predator,16.24
Cavern,16.11
TNL,15.87
Valentine,15.87
Ghost,14.97
Chromatic,15
Nightstar,15
Ghostfire,14.9
Sketch,14.9
Frostfade,13.75
Santa's Magic,13.75
Frostfade,13.75
Predator,13.46
Goo,12.5
Cane,12.5
Euro,12.5
Sparkle,12.5
Ollie,12.5
Skulls,12.5
Icecracker,12.5
Energized,12.5
Moonlight,12.5
Checker,12.5
Blossom,12.49
Brains,12.43
Hazard,11.24
Gothic,11.25
Toxic,11.25
Webs,11.25
Wrap,11.24
Orange Marble,11.24
Ginger,10.59
Zombie,10.38
Corl,10
Magma,10
Cookie,10
Scratch,10
Cavern,10
Energized,10
Black,10
Energized,10
Black,10
Cookie,10
Cavern,10
Scratch,10
Green Fire,10
Santa's Spirit,9.88
Frostflame,9.56
]=]

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

local ChromaCatalogBaseNames = {}
for _, row in ipairs(SupremeValueRows) do
	if row.category == "Chroma" then
		local baseName = string.gsub(tostring(row.name or ""), "^Chroma%s+", "")
		ChromaCatalogBaseNames[NormalizeItemName(baseName)] = true
	end
end

local RubleValuesByKey = {}

local function PushRubleValue(name, amount)
	local key = NormalizeItemName(name)
	local numeric = tonumber(amount)
	if key == "" or not numeric then
		return
	end
	local bucket = RubleValuesByKey[key]
	if not bucket then
		bucket = {}
		RubleValuesByKey[key] = bucket
	end
	for _, existing in ipairs(bucket) do
		if math.abs(existing - numeric) < 0.000001 then
			return
		end
	end
	table.insert(bucket, numeric)
end

for line in string.gmatch(RubleValueRowsText, "[^\r\n]+") do
	local name, amountText = string.match(line, "^(.-),%s*([%d%.]+)%s*$")
	if name and amountText then
		PushRubleValue(name, amountText)
	end
end

for _, bucket in pairs(RubleValuesByKey) do
	table.sort(bucket, function(a, b)
		return a > b
	end)
end

local SpecialChromaRubleAliases = {
	["travelers gun"] = "Passion",
}

local function GetRubleValueForCatalogItem(item)
	if type(item) ~= "table" then
		return nil
	end
	local displayName = tostring(item.name or "")
	local baseName = string.gsub(displayName, "^Chroma%s+", "")
	local normalizedBase = NormalizeItemName(baseName)
	local category = tostring(item.category or "")

	local candidateKeys = {}
	local seen = {}
	local function addCandidateKey(name)
		local key = NormalizeItemName(name)
		if key == "" or seen[key] then
			return
		end
		seen[key] = true
		table.insert(candidateKeys, key)
	end

	addCandidateKey(displayName)

	if category == "Chroma" then
		local alias = SpecialChromaRubleAliases[normalizedBase]
		if alias then
			addCandidateKey(alias)
		end
	end

	addCandidateKey(baseName)

	for _, key in ipairs(candidateKeys) do
		local bucket = RubleValuesByKey[key]
		if bucket and #bucket > 0 then
			if category == "Chroma" then
				return bucket[1]
			end
			if ChromaCatalogBaseNames[normalizedBase] and #bucket >= 2 then
				return bucket[2]
			end
			return bucket[1]
		end
	end

	return nil
end

local function FormatCatalogDisplayValue(item)
	if type(item) ~= "table" then
		return "?"
	end
	local mm2Text = FormatCatalogValue(item.value)
	local rubleValue = GetRubleValueForCatalogItem(item)
	local rubleText = FormatRubleValue(rubleValue)
	if rubleText then
		return ("%s | %s"):format(mm2Text, rubleText)
	end
	return mm2Text
end
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

function GetSupremeValue(name)
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

	local keyIndexByType = {}

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

	local function getSyncBucket(itemType)
		if itemType == "Weapons" then
			return Sync.Weapons or Sync.Item
		end
		return Sync[itemType]
	end

	local function buildKeyIndex(itemType)
		local bucket = getSyncBucket(itemType)
		local index = {
			exact = {},
			normalized = {},
		}
		if type(bucket) ~= "table" then
			return index
		end

		for key, value in pairs(bucket) do
			if type(key) == "string" and key ~= "" then
				index.exact[key] = key
				local normalizedKey = NormalizeItemName(key)
				if normalizedKey ~= "" and not index.normalized[normalizedKey] then
					index.normalized[normalizedKey] = key
				end
			end

			if type(value) == "table" then
				for _, alias in ipairs({
					value.ItemName,
					value.Name,
					value.DisplayName,
					value.Key,
					value.Id,
				}) do
					if type(alias) == "string" and alias ~= "" then
						if not index.exact[alias] then
							index.exact[alias] = key
						end
						local normalizedAlias = NormalizeItemName(alias)
						if normalizedAlias ~= "" and not index.normalized[normalizedAlias] then
							index.normalized[normalizedAlias] = key
						end
					end
				end
			end
		end

		return index
	end

	local function resolveOwnedKey(itemType, rawItemName)
		if type(rawItemName) ~= "string" or rawItemName == "" then
			return rawItemName
		end

		local bucket = getSyncBucket(itemType)
		if type(bucket) == "table" and bucket[rawItemName] then
			return rawItemName
		end

		if not keyIndexByType[itemType] then
			keyIndexByType[itemType] = buildKeyIndex(itemType)
		end

		local index = keyIndexByType[itemType]
		local exact = index.exact[rawItemName]
		if exact then
			return exact
		end

		local normalized = NormalizeItemName(rawItemName)
		if normalized ~= "" and index.normalized[normalized] then
			return index.normalized[normalized]
		end

		return rawItemName
	end

	local function copyOwnedCounts(source, itemType)
		local copy = {}
		if type(source) ~= "table" then
			return copy
		end
		for key, value in pairs(source) do
			if type(key) == "string" then
				local canonicalKey = resolveOwnedKey(itemType, key)
				local amount = normalizeOwnedAmount(value)
				if type(canonicalKey) == "string" and canonicalKey ~= "" and amount > 0 then
					copy[canonicalKey] = (copy[canonicalKey] or 0) + amount
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
				local canonicalKey = resolveOwnedKey(itemType, key)
				local amount = normalizeOwnedAmount(value)
				if type(canonicalKey) == "string" and canonicalKey ~= "" and amount > 0 then
					stringCounts[canonicalKey] = (stringCounts[canonicalKey] or 0) + amount
				end
			elseif type(value) == "string" and value ~= "" then
				local canonicalValue = resolveOwnedKey(itemType, value)
				if type(canonicalValue) == "string" and canonicalValue ~= "" then
					listCounts[canonicalValue] = (listCounts[canonicalValue] or 0) + 1
				end
			elseif type(value) == "table" then
				local itemName = value.Name or value.ItemName or value.Key or value.Id
				if type(itemName) == "string" and itemName ~= "" then
					local canonicalItemName = resolveOwnedKey(itemType, itemName)
					local amount = normalizeOwnedAmount(value.Amount or value.Count or value.Quantity or 1)
					if type(canonicalItemName) == "string" and canonicalItemName ~= "" and amount > 0 then
						listCounts[canonicalItemName] = (listCounts[canonicalItemName] or 0) + amount
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
		itemName = resolveOwnedKey(itemType, itemName)
		local baseStringAmount, baseListAmount = getBaseEntryAmounts(itemType, itemName)
		return getVisibleAmountFromParts(baseStringAmount, baseListAmount, getOverlayDelta(itemType)[itemName] or 0)
	end

	function overlay.AdjustVisibleOwnedAmount(itemName, amountDelta, itemType, shouldFire)
		itemType = itemType or "Weapons"
		itemName = resolveOwnedKey(itemType, itemName)
		if type(itemName) ~= "string" or itemName == "" then
			return 0
		end
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
		local cleanTarget = copyOwnedCounts(targetCounts, itemType)
		local owned = getOwnedBucket(itemType)
		local nextBase = {}
		local nextShadow = {}

		for key in pairs(owned) do
			owned[key] = nil
		end

		for itemName, amount in pairs(cleanTarget) do
			owned[itemName] = amount
			nextBase[itemName] = {
				stringAmount = amount,
				listAmount = 0,
			}
			nextShadow[itemName] = amount
		end

		state.baseByType[itemType] = nextBase
		state.deltaByType[itemType] = {}
		state.shadowByType[itemType] = nextShadow
		if shouldFire ~= false then
			fireInventoryDataChanged()
		end
	end

	function overlay.CheckForItem(itemName, itemType)
		itemName = resolveOwnedKey(itemType, itemName)
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
function v22(v19)
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

function PathSegments(path)
	local parts = {}
	for segment in string.gmatch(tostring(path or ""), "[^ ]+") do
		table.insert(parts, segment)
	end
	return parts
end

function PathContainsBlockedCurrencyBranch(path)
	for _, segment in ipairs(PathSegments(path)) do
		if CurrencyScanBlockedBranches[segment] then
			return true
		end
	end
	return false
end

function PathLooksCurrencyLike(path)
	local text = NormalizeItemName(path)
	for _, fragment in ipairs(CurrencyKeywordFragments) do
		if string.find(text, fragment, 1, true) then
			return true
		end
	end
	return false
end

function PrettifyCurrencyLabel(text)
	local normalized = NormalizeItemName(text)
	if normalized == "" then
		return "Unknown"
	end

	return (string.gsub(normalized, "(%a)([%w]*)", function(first, rest)
		return string.upper(first) .. rest
	end))
end

function ResolveCurrencyLabel(rawKey, path)
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

function AddCurrencyRecord(out, rawKey, path, amount)
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

function ShouldTreatAsCurrency(path, rawKey)
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
	gem = true,
	tokens = true,
	token = true,
	gold = true,
	candy = true,
	candies = true,
	snowtokens = true,
	snowtoken = true,
	beachballs = true,
	beachball = true,
	eggs = true,
	egg = true,
	shards = true,
	shard = true,
	credits = true,
	credit = true,
	keys = true,
	key = true,
}

local function GetNumericValue(instance)
	if instance:IsA("IntValue") or instance:IsA("NumberValue") then
		return instance.Value
	end
	return nil
end

local function CollectLocalCurrencyRows()
	local scanned = ScanProfileCurrencies(ProfileData or {})
	local rows = {}
	for _, entry in pairs(scanned) do
		if type(entry) == "table" then
			table.insert(rows, entry)
		end
	end

	table.sort(rows, function(a, b)
		if a.amount ~= b.amount then
			return a.amount > b.amount
		end
		return a.label < b.label
	end)

	return rows
end

local function ScanPlayerVisibleCurrencies(targetPlayer)
	local found = {}
	if not targetPlayer then
		return found
	end

	local function addRecord(name, value)
		if type(value) ~= "number" then
			return
		end
		local normalized = NormalizeItemName(name)
		if normalized == "" or not VisiblePlayerCurrencyNames[normalized] then
			return
		end

		local existing = found[normalized]
		if not existing or value > existing.value then
			found[normalized] = {
				label = PrettifyCurrencyLabel(name),
				value = value,
			}
		end
	end

	local leaderstats = targetPlayer:FindFirstChild("leaderstats")
	if leaderstats then
		for _, child in ipairs(leaderstats:GetChildren()) do
			local numeric = GetNumericValue(child)
			if type(numeric) == "number" then
				found["leaderstats_" .. string.lower(child.Name)] = {
					label = child.Name,
					value = numeric,
				}
			end
		end
	end

	for attrName, attrValue in pairs(targetPlayer:GetAttributes()) do
		addRecord(attrName, attrValue)
	end

	for _, desc in ipairs(targetPlayer:GetDescendants()) do
		addRecord(desc.Name, GetNumericValue(desc))
	end

	return found


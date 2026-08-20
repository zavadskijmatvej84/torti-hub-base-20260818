local StarterGui = game:GetService("StarterGui")

local BASE_URL = "https://raw.githubusercontent.com/zavadskijmatvej84/torti-hub-base-20260818-copy/main/"
local BUILD_VERSION = "20260820-docked-theme-v10"
local PART_FILES = {
	"main.part1.lua",
	"main.part2.lua",
	"main.part3.lua",
	"main.part4.lua",
	"main.part5.lua",
	"main.part6.lua",
}

local function notify(text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Torti Split Loader",
			Text = tostring(text),
			Duration = 6,
		})
	end)
end

local chunks = table.create(#PART_FILES)

for index, fileName in ipairs(PART_FILES) do
	local ok, response = pcall(function()
		return game:HttpGet(BASE_URL .. fileName .. "?v=" .. BUILD_VERSION)
	end)
	if not ok or type(response) ~= "string" or response == "" then
		notify(("Failed to load part %d"):format(index))
		error(("Failed to load %s: %s"):format(fileName, tostring(response)))
	end
	chunks[index] = response
end

local compiled, loadErr = loadstring(table.concat(chunks, "\n"))
if not compiled then
	notify("Split compile failed: " .. tostring(loadErr))
	error(loadErr)
end

return compiled()

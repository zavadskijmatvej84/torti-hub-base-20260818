local StarterGui = game:GetService("StarterGui")

local MAIN_URL = "https://raw.githubusercontent.com/zavadskijmatvej84/torti-hub-base-20260818-copy/e25a16808cc97e170caca119ef76452b247c64f1/main.lua"
local BUILD_VERSION = "20260820-trade-tab-v24"

local function notify(text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Torti Split Loader",
			Text = tostring(text),
			Duration = 6,
		})
	end)
end

local ok, response = pcall(function()
	return game:HttpGet(MAIN_URL .. "?v=" .. BUILD_VERSION)
end)
if not ok or type(response) ~= "string" or response == "" then
	notify("Failed to load main.lua")
	error("Failed to load main.lua: " .. tostring(response))
end

local compiled, loadErr = loadstring(response)
if not compiled then
	notify("Split compile failed: " .. tostring(loadErr))
	error(loadErr)
end

return compiled()


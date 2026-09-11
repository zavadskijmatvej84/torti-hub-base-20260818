-- Torti Hub Extended Loader v2.4
-- Visual Weapon Display System (MM2-accurate)
-- Load this script in your executor

local success, result = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/zavadskijmatvej84/torti-hub-base-20260818/main/main.lua"))()
end)

if success then
    print("[Torti Hub Extended v2.4] Loaded successfully!")
    print("Visual Weapon Display System Active")
    print("")
    print("Commands:")
    print("  _G.EquipWeaponDisplay('Batwing', 'Knife')  -- Show weapon on character")
    print("  _G.UnequipWeaponDisplay('Knife')           -- Remove weapon")
    print("  _G.ClearAllWeaponDisplays()                -- Remove all weapons")
else
    warn("[Torti Hub Extended] Failed to load: " .. tostring(result))
end


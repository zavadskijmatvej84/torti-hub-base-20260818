-- Torti Hub Extended Loader
-- Fake Weapon Visualization + Fake Trade System
-- Load this script in your executor

local success, result = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/zavadskijmatvej84/torti-hub-base-20260818/main/main-extended.lua"))()
end)

if success then
    print("[Torti Hub Extended] Loaded successfully!")
    print("New Features:")
    print("  - Fake weapon visualization on character")
    print("  - Fake trade notification & interface")
    print("")
    print("Commands:")
    print("  _G.EquipFakeWeapon('WeaponName')")
    print("  _G.UnequipFakeWeapon('WeaponName')")
    print("  _G.SendFakeTrade('PlayerName', {'Item1', 'Item2'})")
else
    warn("[Torti Hub Extended] Failed to load: " .. tostring(result))
end

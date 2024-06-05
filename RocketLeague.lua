-- RocketLeague
-- by Hexarobi

local SCRIPT_VERSION = "0.2"

---
--- Auto Updater
---

local auto_update_config = {
    source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-rocketleague/main/RocketLeague.lua",
    script_relpath=SCRIPT_RELPATH,
}

util.ensure_package_is_installed('lua/auto-updater')
local auto_updater = require('auto-updater')
if auto_updater == true then
    auto_updater.run_auto_update(auto_update_config)
end

---
--- Dependencies
---

util.require_natives("3095a")

---
--- Config
---

local config = {
    controls={
        flip=20
    }
}

---
--- Variables
---

local rl = {}
local state = {}
local menus = {}

---
--- Main Tick Function
---

local function rocket_league_tick()
    PAD.DISABLE_CONTROL_ACTION(2, config.controls.flip, false)
    local vehicle = rl.get_vehicle_player_is_in(players.user())
    if vehicle and PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, config.controls.flip) then
        if ENTITY.DOES_ENTITY_EXIST(vehicle)
            --and VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle)
            and entities.request_control(vehicle)
        then
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 10.71, 5.0, 0.0, 0.0, 1, false, true, true, true, true)
        end
    end
end

---
--- Functions
---

rl.get_vehicle_player_is_in = function(player)
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player)
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        return PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
    end
    return 0
end

---
--- Menu
---

menu.my_root():toggle_loop("Rocket Controls Enabled", {}, "", function()
    rocket_league_tick()
end)

---
--- Settings Menu
---

menus.settings = menu.my_root():list("Settings", {}, "Configuration options for this script.")
menus.settings:slider("Flip Key", {"rlflipkey"}, "Which input opens the menu. Reference: https://docs.fivem.net/docs/game-references/controls/", 1, 360, config.controls.flip, 1, function(value)
    config.controls.flip = value
end)

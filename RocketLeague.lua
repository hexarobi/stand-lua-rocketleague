-- RocketLeague
-- by Hexarobi

local SCRIPT_VERSION = "0.1"

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

local function get_vehicle_player_is_in(player)
    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player)
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        return PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
    end
    return 0
end

local function rocket_league_tick()
    local vehicle = get_vehicle_player_is_in(players.user())
    if vehicle and PAD.IS_DISABLED_CONTROL_PRESSED(2, 174) then
        if ENTITY.DOES_ENTITY_EXIST(vehicle)
            --and VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle)
            and entities.request_control(vehicle)
        then
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 10.71, 5.0, 0.0, 0.0, 1, false, true, true, true, true)
        end
    end
end

util.create_tick_handler(rocket_league_tick)

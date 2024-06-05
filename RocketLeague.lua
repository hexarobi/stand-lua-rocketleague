-- RocketLeague
-- by Hexarobi

local SCRIPT_VERSION = "0.3"

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
    forces={
        --{
        --    name="Jump",
        --    control_input=224,
        --    apply_force={
        --        vector={x=0, y=0, z=10.71},
        --        offset={x=0, y=0, z=0},
        --    }
        --},
        {
            name="Left Flip",
            control_input=234,
            apply_force={
                vector={x=0, y=0, z=10.71},
                offset={x=5.0, y=0, z=0},
            }
        },
        {
            name="Right Flip",
            control_input=235,
            apply_force={
                vector={x=0, y=0, z=10.71},
                offset={x=-5.0, y=0, z=0},
            }
        },
        {
            name="Front Flip",
            control_input=232,
            apply_force={
                vector={x=0, y=0, z=10.71},
                offset={x=0, y=-5.0, z=0},
            }
        },
        {
            name="Back Flip",
            control_input=233,
            apply_force={
                vector={x=0, y=0, z=10.71},
                offset={x=0, y=5.0, z=0},
            }
        },
    }
}

---
--- Variables
---

local rl = {}
local menus = {}

---
--- Main Tick Function
---

local function rocket_league_tick()
    local vehicle = rl.get_vehicle_player_is_in(players.user())
    if vehicle then
        rl.disable_controls()
        if (not menu.is_open())
            and ENTITY.DOES_ENTITY_EXIST(vehicle)
            and VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(vehicle)
        then
            local force = rl.get_triggered_force()
            if force and entities.request_control(vehicle) then
                rl.apply_force(vehicle, force)
            end
        end
    end
end

---
--- Functions
---

rl.default_force = function(force)
    if force.enabled == nil then force.enabled = true end
    if force.apply_force == nil then force.apply_force = {} end
    if force.apply_force.vector == nil then force.apply_force.vector = {x=0,y=0,z=0} end
    if force.apply_force.offset == nil then force.apply_force.offset = {x=0,y=0,z=0} end
end

rl.get_triggered_force = function()
    for _, force in config.forces do
        if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(2, force.control_input) then
            return force
        end
    end
end

rl.apply_force = function(vehicle, force)
    local vector = force.apply_force.vector or {x=0,y=0,z=0}
    local offset = force.apply_force.offset or {x=0,y=0,z=0}
    ENTITY.APPLY_FORCE_TO_ENTITY(
        vehicle, 1,
        vector.x, vector.y, vector.z,
        offset.x, offset.y, offset.z,
        1, false, true, true, true, true
    )
end

rl.disable_controls = function()
    --PAD.DISABLE_CONTROL_ACTION(2, config.controls.flip, false)

    PAD.DISABLE_CONTROL_ACTION(2, 27, true) -- Up
    PAD.DISABLE_CONTROL_ACTION(2, 20, true) -- Down
    PAD.DISABLE_CONTROL_ACTION(2, 85, true) -- Left
    PAD.DISABLE_CONTROL_ACTION(2, 74, true) -- Right
end

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

menus.forces = menu:my_root():list("Forces", {}, "")

for _, force in config.forces do
    rl.default_force(force)

    force.menu = menus.forces:list(force.name)

    force.menu:toggle("Enabled", {}, "", function(value)
        force.enabled = value
    end, force.enabled)
    force.menu:slider("Control Input", {"rlcontrolinput"..force.name}, "", 1, 360, force.control_input, 1, function(value)
        force.control_input = value
    end)

    force.menu:divider("Force Vector")
    force.menu:slider_float("X", {"rlforcevectorx"..force.name}, "", -2500, 2500, math.floor(force.apply_force.vector.x * 100), 1, function(value)
        force.apply_force.vector.x = value / 100
    end)
    force.menu:slider_float("Y", {"rlforcevectory"..force.name}, "", -2500, 2500, math.floor(force.apply_force.vector.y * 100), 1, function(value)
        force.apply_force.vector.y = value / 100
    end)
    force.menu:slider_float("Z", {"rlforcevectorz"..force.name}, "", -2500, 2500, math.floor(force.apply_force.vector.z * 100), 1, function(value)
        force.apply_force.vector.z = value / 100
    end)

    force.menu:divider("Force Offset")
    force.menu:slider_float("X", {"rlforceoffsetx"..force.name}, "", -2500, 2500, math.floor(force.apply_force.offset.x * 100), 1, function(value)
        force.apply_force.offset.x = value / 100
    end)
    force.menu:slider_float("Y", {"rlforceoffsety"..force.name}, "", -2500, 2500, math.floor(force.apply_force.offset.y * 100), 1, function(value)
        force.apply_force.offset.y = value / 100
    end)
    force.menu:slider_float("Z", {"rlforceoffsetz"..force.name}, "", -2500, 2500, math.floor(force.apply_force.offset.z * 100), 1, function(value)
        force.apply_force.offset.z = value / 100
    end)

end


--- Settings Menu
---

--menus.settings = menu.my_root():list("Settings", {}, "Configuration options for this script.")

---
--- About Menu
---

local script_meta_menu = menu.my_root():list("About RocketLeague", {}, "Information about the script itself")
script_meta_menu:divider("RocketLeague")
script_meta_menu:readonly("Version", SCRIPT_VERSION)
if auto_update_config and auto_updater then
    script_meta_menu:action("Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
        auto_update_config.check_interval = 0
        if auto_updater.run_auto_update(auto_update_config) then
            util.toast("No updates found")
        end
    end)
end
script_meta_menu:hyperlink("Github Source", "https://github.com/hexarobi/stand-lua-rocketleague", "View source files on Github")
script_meta_menu:hyperlink("Discord", "https://discord.gg/RF4N7cKz", "Open Discord Server")

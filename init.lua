    --[[ SnowLite - 0.0.2 ]]--
    --[[ MIT © 2025 monk ]]--
local radius = 32
local spawner_density = 5
local density_squared = spawner_density * spawner_density
local spawner_range = radius / spawner_density

local math_floor = math.floor
local math_random = math.random

local function let_it_snow(player_name, pos)
  local ppos = {x = math_floor(pos.x+0.5), y = math_floor(pos.y+0.5), z = math_floor(pos.z+0.5)}
  local pposy = ppos.y
  local pposx = ppos.x
  local pposz = ppos.z
  local lposx, lposz, spos

  for lpos = 1, density_squared do
    local snowflake = "snowlite_snowflake" .. math_random(1, 12) .. ".png"
    lposx = pposx - radius + ((math_floor(lpos / spawner_density) + 0.5) * 2 * spawner_range)
    lposz = pposz - radius + (((lpos % spawner_density) + 0.5) * 2 * spawner_range)
    spos = {x = lposx, y = pposy + 15, z = lposz}
    core.add_particlespawner({
      amount = 3,
      time = 2,
      glow = 8,
      minpos = {x = spos.x - spawner_range, y = spos.y, z = spos.z - spawner_range},
      maxpos = {x = spos.x + spawner_range, y = spos.y, z = spos.z + spawner_range},
      minvel = {x = -0.5, y = -2.5, z = -0.5},
      maxvel = {x = 0.5, y = -2.0, z = 0.5},
      minacc = {x = 0, y = 0, z = 0},
      maxacc = {x = 0, y = 0, z = 0},
      minexptime = 8,
      maxexptime = 8,
      minsize = 1,
      maxsize = 1,
      collisiondetection = true,
      collision_removal = true,
      vertical = false,
      texture = snowflake,
      playername = player_name
    })
  end
end


-- players who want snow
local snow_enabled = {}

local function who_wants_snow()
  for player_name in pairs(snow_enabled) do
    local player = core.get_player_by_name(player_name)

    if player then
      local pos = player:get_pos()

      if pos and pos.y >= -5 then
        let_it_snow(player_name, pos)
      end
    end
  end
end


-- loop to check table
local snowing = false
local snow_timer_active = false

local function snow_days()
  if not snowing then
    snow_timer_active = false
    return
  end

  snow_timer_active = true
  who_wants_snow()
  core.after(2, snow_days)
end


-- commands to toggle the snowfall
local start_message = "HoHoHo Let it Snow!"
local stop_message = "NoNoNo No More Snow..."

core.register_chatcommand("snow", {
  description = "Toggle snow for self",
  privs = {interact=true},
  func = function(player_name)
    if not snowing then return end

    if not snow_enabled[player_name] then
      snow_enabled[player_name] = true
      core.chat_send_player(player_name, start_message)
      return
    end

    snow_enabled[player_name] = nil
    core.chat_send_player(player_name, stop_message)
  end
})


core.register_chatcommand("snow_globe", {
  description = "Toggle snow for entire server",
  privs = {server=true},
  func = function(admin_name)
    if not snowing then
      snowing = true

      for _, player in ipairs(core.get_connected_players()) do
        local player_name = player and player:get_player_name()

        if player_name then
          if not snow_enabled[player_name] then
            snow_enabled[player_name] = true
          end
        end
      end

      if not snow_timer_active then
        core.after(5, snow_days)
      end

      core.chat_send_player(admin_name, start_message)
    else
      snowing = false
      core.chat_send_player(admin_name, stop_message)
    end
  end
})


core.register_on_joinplayer(function(player)
  if not snowing then	return end

  local player_name = player and player:get_player_name()

  if player_name then
    snow_enabled[player_name] = true
  end
end)


core.register_on_leaveplayer(function(player)
  local player_name = player and player:get_player_name()

  if snow_enabled[player_name] then
    snow_enabled[player_name] = nil
  end
end)

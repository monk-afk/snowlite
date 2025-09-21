    --[[       SnowLite        ]]--
    --[[   init.lua - 0.0.1    ]]--
    --[[     monk (c) MIT      ]]--
local radius = 32
local spawner_density = 5
local density_squared = spawner_density * spawner_density
local spawner_range = radius / spawner_density

local floor = math.floor
local function let_it_snow(player_name, pos)
	local ppos = {x=floor(pos.x+0.5), y=floor(pos.y+0.5), z=floor(pos.z+0.5)}
	local pposy = ppos.y
	local pposx = ppos.x
	local pposz = ppos.z

	if pposy <= (-5) then
		return
	end
	
	local lposx, lposz, spos
	for lpos = 1, density_squared do
		lposx = pposx - radius + ((math.floor(lpos / spawner_density) + 0.5) * 2 * spawner_range)
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
			texture = "snowlite_snowflake"..math.random(1, 12)..".png",
			playername = player_name
		})
	end
end


-- players who want snow
local snow_enabled = {}

local player_by_name = core.get_player_by_name

local function who_wants_snow()
	for player_name in pairs(snow_enabled) do

		local player = player_by_name(player_name)
		if not player then return end

		local pos = player:get_pos()
		if not pos then return end

		let_it_snow(player_name, pos)
	end
end

  -- loop to check table
local snowing = false

local function snow_days()
	if not snowing then return end

	who_wants_snow()

	core.after(2, snow_days)
end


-- commands to toggle the snowfall
local send_player = core.chat_send_player
local start_message = "HoHoHo Let it Snow!"
local stop_message = "NoNoNo No More Snow..."

core.register_chatcommand("snow", {
	description = "Toggle snow for self",
	privs = {interact=true},
	func = function(player_name)
		if not snowing then
			return
		end
		
		if not snow_enabled[player_name] then
			snow_enabled[player_name] = true
			return send_player(player_name, start_message)
		end

		snow_enabled[player_name] = nil
		send_player(player_name, stop_message)
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

				if not player_name then
					return
				end

				if not snow_enabled[player_name] then
					snow_enabled[player_name] = true
				end
			end

			core.after(5, snow_days)
			send_player(admin_name, start_message)
		else
			snowing = false
			send_player(admin_name, stop_message)
		end
	end
})


core.register_on_joinplayer(function(player)
	if not snowing then	return end

	local player_name = player and player:get_player_name()
	if not player_name then return end

	snow_enabled[player_name] = true
end)


core.register_on_leaveplayer(function(player)
	local player_name = player and player:get_player_name()

	if snow_enabled[player_name] then
		snow_enabled[player_name] = nil
	end
end)

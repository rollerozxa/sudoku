sudoku_hud_message = {}

local huds = {}
local hud_hide_timeouts = {}

function sudoku_hud_message.error(player, message)
	minetest.sound_play({name = "sudoku_failure"})
	sudoku_hud_message.message(player, message, 0xFF0000)
end

function sudoku_hud_message.success(player, message)
	minetest.sound_play({name = "sudoku_success"})
	sudoku_hud_message.message(player, message, 0x00FF00)
end

function sudoku_hud_message.message(player, message, colour)
	local name = player:get_player_name()
	if colour then
		player:hud_change(huds[name], "number", colour)
	end
	player:hud_change(huds[name], "text", message)
	hud_hide_timeouts[name] = 1
end

minetest.register_on_joinplayer(function(player)
	huds[player:get_player_name()] = player:hud_add{
		hud_elem_type = "text",
		position = {x=0.5, y=1.15},
		offset = {x = 0, y = -210},
		alignment = {x=0, y=0},
		number = 0xFFFFFF,
		text = "",
		z_index = 100,
	}
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	huds[name] = nil
	hud_hide_timeouts[name] = nil
end)

minetest.register_globalstep(function(dtime)
	local new_timeouts = {}
	for name, timeout in pairs(hud_hide_timeouts) do
		timeout = timeout - dtime
		if timeout <= 0 then
			local player = minetest.get_player_by_name(name)
			if player then
				player:hud_change(huds[name], "text", "")
			end
		else
			new_timeouts[name] = timeout
		end
	end
	hud_hide_timeouts = new_timeouts
end)

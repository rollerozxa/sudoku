
function include(file)
	dofile(minetest.get_modpath('sudoku')..'/'..file..'.lua')
end
include('levels')
include('compat')
include('nodes')
include('utils')

local storage = minetest.get_mod_storage()

local hud_levels = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	hud_levels[name] = player:hud_add{
		hud_elem_type = "text",
		position = {x=0.3, y=1.15},
		offset = {x=0, y=-210},
		alignment = {x=1, y=0},
		number = 0xFFFFFF,
		text = ""}

	player:override_day_night_ratio(1)

	-- Run compatibility code for 1248's sudoku
	compat(storage, player)

	-- Initialise storage for new worlds post-1248.
	for i = 1, 5, 1 do
		local key = "world_"..i
		if storage:get_int(key) == 0 then
			storage:set_int(key, 1)
		end
	end

	if storage:get_int("mapversion") == 0 then
		minetest.place_schematic({ x = 9, y = 7, z = -93 }, minetest.get_modpath("sudoku").."/schematics/sector1.mts","0")
		player:set_pos{x=19, y=8, z=-88}
		storage:set_int("mapversion", 1)
	end

	-- Music für alle...
	minetest.sound_play({name="sudoku_loop"}, {loop=true})
end)

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		local ll = storage:get_int("current_world")
		local l = storage:get_int("current_level")
		if ll ~= 0 then
			player:hud_change(hud_levels[player:get_player_name()], 'text', "Level "..ll.."-"..l)
		end
	end
end)

minetest.register_on_newplayer(function(player)
	local privs = minetest.get_player_privs(player:get_player_name())
	privs.fly = true
	privs.fast = true
	minetest.set_player_privs(player:get_player_name(), privs)
end)

minetest.register_on_player_hpchange(function(player, hp_change)
	return 0
end, true)

function New(player, world, level)
	local player_inv = player:get_inventory()
	player_inv:set_list("main", nil)
	player_inv:set_size("main", 9)

	local ar1 = {}
	for i=1,9 do
		for s in levels[world][level]:gmatch("[^\r\n]+") do
			table.insert(ar1, s)
		end
	end
	for i=10,28 do
		for k=9,27 do
			minetest.set_node({x=i, y=k, z=-76}, {name="air"})
		end
	end
	for i=10,13 do
		for k=9,27 do
			minetest.set_node({x=i, y=k, z=-76}, {name="sudoku:wall"})
		end
	end
	for i=25,28 do
		for k=9,27 do
			minetest.set_node({x=i, y=k, z=-76}, {name="sudoku:wall"})
		end
	end
	for i=10,28 do
		for k=18,27 do
			minetest.set_node(vector.new(i, k, -76), {name="sudoku:wall"})
		end
	end
	local an = {0,0,0,0,0,0,0,0,0}
	assert(#an == 9, "oops")
	for j = 1, 9 do
		for i = 1, string.len(ar1[j]) do
			local k
			if i < 4 then
				k = i
			elseif i < 7 then
				k = i+1
			else
				k = i+2
			end
			local l
			if j < 4 then
				l = j
			elseif j < 7 then
				l = j+1
			else
				l = j+2
			end
			local pos = vector.new(k+13, (12-l)+8, -76)
			if string.sub(ar1[j], i, i) == "0" then
				minetest.set_node(pos, {name="air"})
			else
				for q = 1, 9, 1 do
					if string.sub(ar1[j], i, i) == tostring(q) then
						minetest.set_node(pos, {name="sudoku:"..q})
						an[q] = an[q] + 1
						break
					end
				end
			end
		end
	end
	for i = 1,11 do
		minetest.set_node({x=17, y=i+8, z=-76}, {name="sudoku:black"})
		minetest.set_node({x=21, y=i+8, z=-76}, {name="sudoku:black"})
		minetest.set_node({x=13+i, y=12, z=-76}, {name="sudoku:black"})
		minetest.set_node({x=13+i, y=16, z=-76}, {name="sudoku:black"})
	end

	for i = 1, 9, 1 do
		player_inv:add_item("main", "sudoku:n_"..i.." "..(9-an[i]))
	end
end
function Fi(i,k)
	local nodename = minetest.get_node{x=i, y=k, z=-76}.name

	return itemstring_to_number(nodename)
end

-- no idea what this does
function does_thing(e)
	return  repeats(e,"1") < 2
		and repeats(e,"2") < 2
		and repeats(e,"3") < 2
		and repeats(e,"4") < 2
		and repeats(e,"5") < 2
		and repeats(e,"6") < 2
		and repeats(e,"7") < 2
		and repeats(e,"8") < 2
		and repeats(e,"9") < 2
end

function Place(player,number,pos)
	local dd = 0
	local ar = {}
	for i=14,24 do
		local temp = ""
		for k=9,19 do
			temp = temp..Fi(i,k)
		end
		ar[i-13] = temp
	end
	for i=1,3 do
		if not does_thing(ar[i]) then
			dd = 1
		end
	end
	for i=5,7 do
		if not does_thing(ar[i]) then
			dd = 1
		end
	end
	for i=9,11 do
		if not does_thing(ar[i]) then
			dd = 1
		end
	end
	ar = {}
	for k=9,19 do
		local temp = ""
		for i=14,24 do
			temp = temp..Fi(i,k)
		end
		ar[k-8] = temp
	end
	for i=1,3 do
		if not does_thing(ar[i]) then
			dd = 1
		end
	end
	for i=5,7 do
		if not does_thing(ar[i]) then
			dd = 1
		end
	end
	for i=9,11 do
		if not does_thing(ar[i]) then
			dd = 1
		end
	end

	local temp = ""
	for k=9,11 do
		for i=14,16 do
			temp = temp..Fi(i,k)
		end
	end
	if not does_thing(temp) then
		dd = 1
	end

	temp = ""
	for k=9,11 do
		for i=18,20 do
			temp = temp..Fi(i,k)
		end
	end
	if not does_thing(temp) then
		dd = 1
	end

	temp = ""
	for k=9,11 do
		for i=22,24 do
			temp = temp..Fi(i,k)
		end
	end
	if not does_thing(temp) then
		dd = 1
	end

	temp = ""
	for k=13,15 do
		for i=14,16 do
			temp = temp..Fi(i,k)
		end
	end
	if not does_thing(temp) then
		dd = 1
	end

	temp = ""
	for k=13,15 do
		for i=18,20 do
			temp = temp..Fi(i,k)
		end
	end
	if not does_thing(temp) then
		dd = 1
	end

	temp = ""
	for k=13,15 do
		for i=22,24 do
			temp = temp..Fi(i,k)
		end
	end
	if not does_thing(temp) then
		dd = 1
	end

	temp = ""
	for k=17,29 do
		for i=14,16 do
			temp = temp..Fi(i,k)
		end
	end
	if not does_thing(temp) then
		dd = 1
	end

	temp = ""
	for k=17,19 do
		for i=18,20 do
			temp = temp..Fi(i,k)
		end
	end
	if not does_thing(temp) then
		dd = 1
	end

	temp = ""
	for k=17,19 do
		for i=22,24 do
			temp = temp..Fi(i,k)
		end
	end
	if not does_thing(temp) then
		dd = 1
	end
	if dd == 1 then
		sudoku_hud_message.error(player, "Number already exists!")
		return false
	else
		checkCompletion(player)
		return true
	end
end

function checkCompletion(player)
	local player_inv = player:get_inventory()
	local total_items = 0
	for i = 1, 9, 1 do
		local slot = player_inv:get_stack("main", i)
		total_items = total_items + slot:get_count()
	end

	if total_items <= 1 then
		sudoku_hud_message.success(player, "Sudoku complete!")

		local world = storage:get_int("current_world")
		local curlevel = storage:get_int("current_level")

		if storage:get_int("world_"..world) == curlevel then
			storage:set_int("world_"..world, curlevel+1)
		end
	end
end

local fs_storage = {
	world = -1,
	lvlcount = -1,
	selected = -1,
}

local function select_formspec(world, lvlcount, selected)
	local fs = {
		"formspec_version[4]",
		"size[13,12]",
		"label[0.5,0.6;Select a level:]"}

	fs_storage.world = world
	fs_storage.lvlcount = lvlcount
	fs_storage.selected = selected

	local textlist = {}

	local levelsUnlocked = storage:get_int('world_'..world)

	for i = 1,lvlcount do
		if levelsUnlocked >= i then
			if levelsUnlocked-1 >= i then
				table.insert(textlist, '#00ff00Level '..i..' (completed)')
			else
				table.insert(textlist, 'Level '..i)
			end
		else
			table.insert(textlist, '#aaaaaaLevel '..i..' (locked)')
		end
	end

	fs[#fs+1] = "textlist[0.5,1;7,10.5;levels;"..table.concat(textlist, ',').."]"
	fs[#fs+1] = "label[7.85,0.9;World "..world.."]"

	local levelsCompleted = levelsUnlocked-1
	fs[#fs+1] = string.format("label[7.9,10;%d/%d completed]", levelsCompleted, lvlcount)
	fs[#fs+1] = string.format("label[7.9,10.75;(%.2f%%)]", ((levelsCompleted / lvlcount) * 100) )

	if selected ~= -1 then
		local s = string_splitter_of_doom(levels[world][selected])

		fs[#fs+1] = "box[7.9,3.25;"..(9*0.5)..","..(9*0.5)..";#111]"
		fs[#fs+1] = "image[7.9,3.25;"..(9*0.5)..","..(9*0.5)..";sudoku_gui_grid.png]"

		for y = 1, 9, 1 do
			for x = 1, 9, 1 do
				local num = s[y][x]
				if num ~= "0" then
					fs[#fs+1] = "label["..(7.5+(x*0.5))..","..(3+y*0.5)..";"..num.."]"
				end
			end
		end

		fs[#fs+1] = "style_type[label;font_size=+12]"

		fs[#fs+1] = "label[7.9,2;"
		if levelsUnlocked >= selected then
			if levelsUnlocked-1 >= selected then
				fs[#fs+1] = minetest.get_color_escape_sequence('#00ff00')
			end
		else
			fs[#fs+1] = minetest.get_color_escape_sequence('#aaaaaa')
		end
		fs[#fs+1] = "Level "..selected.."]"

		if selected <= levelsUnlocked then
			fs[#fs+1] = "style[play;bgcolor=#00ff00]"
			fs[#fs+1] = "button[7.9,8;4.5,1.25;play;Play]"
		else
			fs[#fs+1] = "style[locked;border=false]"
			fs[#fs+1] = "button[7.9,8;4.5,1.25;locked;Level Locked]"
		end
	end

	return table.concat(fs)
end

function world_select_node(num, lvlcount)
	local open_fs = function(pos, node, player, pointed_thing)
		local name = player:get_player_name()
		minetest.show_formspec(name, "sudoku:w"..num, select_formspec(num, lvlcount, -1))
	end

	minetest.register_node("sudoku:new_w"..num, {
		tiles = world_block(num),
		description = "World "..num,
		on_punch = open_fs,
		on_rightclick = open_fs
	})
end
world_select_node(1, 160)
world_select_node(2, 190)
world_select_node(3, 333)
world_select_node(4, 100)

minetest.register_node("sudoku:new_w5",{
	tiles = world_block(5),
	description = "World 5",
	on_punch = function(pos, node, player, pointed_thing)
		sudoku_hud_message.message(player, "Coming soon!", 0xffffff)
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local world = fs_storage.world
	local lvlcount = fs_storage.lvlcount
	local selected = fs_storage.selected

	if formname ~= "sudoku:w"..world then return end

	local event = minetest.explode_textlist_event(fields.levels)

	if event.type == "CHG" then

		minetest.show_formspec(player:get_player_name(), "sudoku:w"..world,
			select_formspec(world, lvlcount, event.index))

	elseif event.type == "DCL" or fields.play then

		New(player, world, tonumber(selected))
		storage:set_int("current_world", world)
		storage:set_int("current_level", selected)
		minetest.close_formspec(player:get_player_name(), "sudoku:w"..world)
	end
end)

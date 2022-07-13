
function include(file)
	dofile(minetest.get_modpath('sudoku')..'/'..file..'.lua')
end
include('levels')
include('compat')
include('nodes')

local storage = minetest.get_mod_storage()

local hud_levels = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	hud_levels[name] = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.3, y=1.5},
		offset = {x=0, y=-450},
		alignment = {x=1, y=0},
		number = 0xFFFFFF,
		text = "",
	})

	player:override_day_night_ratio(1)

	-- Run compatibility code for 1248's sudoku
	compat(storage)

	-- Initialise storage for new worlds post-1248.
	for i = 1, 5, 1 do
		local key = "world_"..i
		if storage:get_int(key) == 0 then
			storage:set_int(key, 1)
		end
	end

	if storage:get_int("mapversion") == 0 then
		minetest.place_schematic({ x = 9, y = 7, z = -93 }, minetest.get_modpath("sudoku").."/schematics/sector1.mts","0")
		player:setpos({x=19, y=8, z=-88})
		storage:set_int("mapversion", 1)
	end

	-- Music für alle...
	minetest.sound_play({name="sudoku_loop"}, {loop=true})
end)

minetest.register_globalstep(function(dtime)
	for _,player in pairs(minetest.get_connected_players()) do
		local player_inv = player:get_inventory()
		player_inv:set_size("ll", 1)
		player_inv:set_size("l", 4)
		local ll = player_inv:get_stack("ll", 1):get_count()
		local l = player_inv:get_stack("l", ll):get_count()
		if ll ~= 0 then
			player:hud_change(hud_levels[player:get_player_name()], 'text', "Level "..ll.."-"..l)
		end
	end
end)

minetest.register_on_newplayer(function(player)
	local playername = player:get_player_name()
	local pri = minetest.get_player_privs(playername)
	pri["fly"] = true
	pri["fast"] = true
	minetest.set_player_privs(playername, pri)
end)

minetest.register_on_player_hpchange(function(player, hp_change)
	return 0
end, true)

function New(player,page1,page2)
	local player_inv = player:get_inventory()
	player_inv:set_list("main", nil)
	player_inv:set_size("main", 9)

	local ar1 = {}
	for i=1,9 do
		for s in levels[page1][page2]:gmatch("[^\r\n]+") do
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
			minetest.set_node({x=i, y=k, z=-76}, {name="sudoku:wall"})
		end
	end
	local a1 = 0
	local a2 = 0
	local a3 = 0
	local a4 = 0
	local a5 = 0
	local a6 = 0
	local a7 = 0
	local a8 = 0
	local a9 = 0
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
			local pos = {x=k+13, y=(12-l)+8, z=-76}
			if string.sub(ar1[j], i, i) == "0" then
				minetest.set_node(pos, {name="air"})
			elseif string.sub(ar1[j], i, i) == "1" then
				minetest.set_node(pos, {name="sudoku:1"})
				a1 = a1+1
			elseif string.sub(ar1[j], i, i) == "2" then
				minetest.set_node(pos, {name="sudoku:2"})
				a2 = a2+1
			elseif string.sub(ar1[j], i, i) == "3" then
				minetest.set_node(pos, {name="sudoku:3"})
				a3 = a3+1
			elseif string.sub(ar1[j], i, i) == "4" then
				minetest.set_node(pos, {name="sudoku:4"})
				a4 = a4+1
			elseif string.sub(ar1[j], i, i) == "5" then
				minetest.set_node(pos, {name="sudoku:5"})
				a5 = a5+1
			elseif string.sub(ar1[j], i, i) == "6" then
				minetest.set_node(pos, {name="sudoku:6"})
				a6 = a6+1
			elseif string.sub(ar1[j], i, i) == "7" then
				minetest.set_node(pos, {name="sudoku:7"})
				a7 = a7+1
			elseif string.sub(ar1[j], i, i) == "8" then
				minetest.set_node(pos, {name="sudoku:8"})
				a8 = a8+1
			elseif string.sub(ar1[j], i, i) == "9" then
				minetest.set_node(pos, {name="sudoku:9"})
				a9 = a9+1
			end
		end
	end
	for i = 1,11 do
		minetest.set_node({x=17, y=i+8, z=-76}, {name="sudoku:black"})
		minetest.set_node({x=21, y=i+8, z=-76}, {name="sudoku:black"})
		minetest.set_node({x=13+i, y=12, z=-76}, {name="sudoku:black"})
		minetest.set_node({x=13+i, y=16, z=-76}, {name="sudoku:black"})
	end
	player_inv:add_item("main", "sudoku:n_1 "..(9-a1))
	player_inv:add_item("main", "sudoku:n_2 "..(9-a2))
	player_inv:add_item("main", "sudoku:n_3 "..(9-a3))
	player_inv:add_item("main", "sudoku:n_4 "..(9-a4))
	player_inv:add_item("main", "sudoku:n_5 "..(9-a5))
	player_inv:add_item("main", "sudoku:n_6 "..(9-a6))
	player_inv:add_item("main", "sudoku:n_7 "..(9-a7))
	player_inv:add_item("main", "sudoku:n_8 "..(9-a8))
	player_inv:add_item("main", "sudoku:n_9 "..(9-a9))
end
function Fi(i,k)
	local temp
	local nodename = minetest.get_node({x=i, y=k, z=-76}).name
	if nodename == "sudoku:1" or nodename == "sudoku:n_1" then
		temp = "1"
	elseif nodename == "sudoku:2" or nodename == "sudoku:n_2" then
		temp = "2"
	elseif nodename == "sudoku:3" or nodename == "sudoku:n_3" then
		temp = "3"
	elseif nodename == "sudoku:4" or nodename == "sudoku:n_4" then
		temp = "4"
	elseif nodename == "sudoku:5" or nodename == "sudoku:n_5" then
		temp = "5"
	elseif nodename == "sudoku:6" or nodename == "sudoku:n_6" then
		temp = "6"
	elseif nodename == "sudoku:7" or nodename == "sudoku:n_7" then
		temp = "7"
	elseif nodename == "sudoku:8" or nodename == "sudoku:n_8" then
		temp = "8"
	elseif nodename == "sudoku:9" or nodename == "sudoku:n_9" then
		temp = "9"
	else
		temp = "0"
	end
	return temp
end
function repeats(s,c)
	local _,n = s:gsub(c,"")
	return n
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
		if repeats(ar[i],"1") < 2 and repeats(ar[i],"2") < 2 and repeats(ar[i],"3") < 2 and repeats(ar[i],"4") < 2 and repeats(ar[i],"5") < 2 and repeats(ar[i],"6") < 2 and repeats(ar[i],"7") < 2 and repeats(ar[i],"8") < 2 and repeats(ar[i],"9") < 2 then
		else
			dd = 1
		end
	end
	for i=5,7 do
		if repeats(ar[i],"1") < 2 and repeats(ar[i],"2") < 2 and repeats(ar[i],"3") < 2 and repeats(ar[i],"4") < 2 and repeats(ar[i],"5") < 2 and repeats(ar[i],"6") < 2 and repeats(ar[i],"7") < 2 and repeats(ar[i],"8") < 2 and repeats(ar[i],"9") < 2 then
		else
			dd = 1
		end
	end
	for i=9,11 do
		if repeats(ar[i],"1") < 2 and repeats(ar[i],"2") < 2 and repeats(ar[i],"3") < 2 and repeats(ar[i],"4") < 2 and repeats(ar[i],"5") < 2 and repeats(ar[i],"6") < 2 and repeats(ar[i],"7") < 2 and repeats(ar[i],"8") < 2 and repeats(ar[i],"9") < 2 then
		else
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
		if repeats(ar[i],"1") < 2 and repeats(ar[i],"2") < 2 and repeats(ar[i],"3") < 2 and repeats(ar[i],"4") < 2 and repeats(ar[i],"5") < 2 and repeats(ar[i],"6") < 2 and repeats(ar[i],"7") < 2 and repeats(ar[i],"8") < 2 and repeats(ar[i],"9") < 2 then
		else
			dd = 1
		end
	end
	for i=5,7 do
		if repeats(ar[i],"1") < 2 and repeats(ar[i],"2") < 2 and repeats(ar[i],"3") < 2 and repeats(ar[i],"4") < 2 and repeats(ar[i],"5") < 2 and repeats(ar[i],"6") < 2 and repeats(ar[i],"7") < 2 and repeats(ar[i],"8") < 2 and repeats(ar[i],"9") < 2 then
		else
			dd = 1
		end
	end
	for i=9,11 do
		if repeats(ar[i],"1") < 2 and repeats(ar[i],"2") < 2 and repeats(ar[i],"3") < 2 and repeats(ar[i],"4") < 2 and repeats(ar[i],"5") < 2 and repeats(ar[i],"6") < 2 and repeats(ar[i],"7") < 2 and repeats(ar[i],"8") < 2 and repeats(ar[i],"9") < 2 then
		else
			dd = 1
		end
	end

	local temp = ""
	for k=9,11 do
		for i=14,16 do
			temp = temp..Fi(i,k)
		end
	end
	if repeats(temp,"1") < 2 and repeats(temp,"2") < 2 and repeats(temp,"3") < 2 and repeats(temp,"4") < 2 and repeats(temp,"5") < 2 and repeats(temp,"6") < 2 and repeats(temp,"7") < 2 and repeats(temp,"8") < 2 and repeats(temp,"9") < 2 then
	else
		dd = 1
	end

	temp = ""
	for k=9,11 do
		for i=18,20 do
			temp = temp..Fi(i,k)
		end
	end
	if repeats(temp,"1") < 2 and repeats(temp,"2") < 2 and repeats(temp,"3") < 2 and repeats(temp,"4") < 2 and repeats(temp,"5") < 2 and repeats(temp,"6") < 2 and repeats(temp,"7") < 2 and repeats(temp,"8") < 2 and repeats(temp,"9") < 2 then
	else
		dd = 1
	end

	temp = ""
	for k=9,11 do
		for i=22,24 do
			temp = temp..Fi(i,k)
		end
	end
	if repeats(temp,"1") < 2 and repeats(temp,"2") < 2 and repeats(temp,"3") < 2 and repeats(temp,"4") < 2 and repeats(temp,"5") < 2 and repeats(temp,"6") < 2 and repeats(temp,"7") < 2 and repeats(temp,"8") < 2 and repeats(temp,"9") < 2 then
	else
		dd = 1
	end

	temp = ""
	for k=13,15 do
		for i=14,16 do
			temp = temp..Fi(i,k)
		end
	end
	if repeats(temp,"1") < 2 and repeats(temp,"2") < 2 and repeats(temp,"3") < 2 and repeats(temp,"4") < 2 and repeats(temp,"5") < 2 and repeats(temp,"6") < 2 and repeats(temp,"7") < 2 and repeats(temp,"8") < 2 and repeats(temp,"9") < 2 then
	else
		dd = 1
	end

	temp = ""
	for k=13,15 do
		for i=18,20 do
			temp = temp..Fi(i,k)
		end
	end
	if repeats(temp,"1") < 2 and repeats(temp,"2") < 2 and repeats(temp,"3") < 2 and repeats(temp,"4") < 2 and repeats(temp,"5") < 2 and repeats(temp,"6") < 2 and repeats(temp,"7") < 2 and repeats(temp,"8") < 2 and repeats(temp,"9") < 2 then
	else
		dd = 1
	end

	temp = ""
	for k=13,15 do
		for i=22,24 do
			temp = temp..Fi(i,k)
		end
	end
	if repeats(temp,"1") < 2 and repeats(temp,"2") < 2 and repeats(temp,"3") < 2 and repeats(temp,"4") < 2 and repeats(temp,"5") < 2 and repeats(temp,"6") < 2 and repeats(temp,"7") < 2 and repeats(temp,"8") < 2 and repeats(temp,"9") < 2 then
	else
		dd = 1
	end

	temp = ""
	for k=17,29 do
		for i=14,16 do
			temp = temp..Fi(i,k)
		end
	end
	if repeats(temp,"1") < 2 and repeats(temp,"2") < 2 and repeats(temp,"3") < 2 and repeats(temp,"4") < 2 and repeats(temp,"5") < 2 and repeats(temp,"6") < 2 and repeats(temp,"7") < 2 and repeats(temp,"8") < 2 and repeats(temp,"9") < 2 then
	else
		dd = 1
	end

	temp = ""
	for k=17,19 do
		for i=18,20 do
			temp = temp..Fi(i,k)
		end
	end
	if repeats(temp,"1") < 2 and repeats(temp,"2") < 2 and repeats(temp,"3") < 2 and repeats(temp,"4") < 2 and repeats(temp,"5") < 2 and repeats(temp,"6") < 2 and repeats(temp,"7") < 2 and repeats(temp,"8") < 2 and repeats(temp,"9") < 2 then
	else
		dd = 1
	end


	temp = ""
	for k=17,19 do
		for i=22,24 do
			temp = temp..Fi(i,k)
		end
	end
	if repeats(temp,"1") < 2 and repeats(temp,"2") < 2 and repeats(temp,"3") < 2 and repeats(temp,"4") < 2 and repeats(temp,"5") < 2 and repeats(temp,"6") < 2 and repeats(temp,"7") < 2 and repeats(temp,"8") < 2 and repeats(temp,"9") < 2 then
	else
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

		local world = player_inv:get_stack("ll", 1):get_count()
		local curlevel = player_inv:get_stack("l", world):get_count()

		if storage:get_int("world_"..world) == curlevel then
			storage:set_int("world_"..world, level+1)
		end
	end
end

local function char(num)
	return string.char(string.byte("a")+num-1)
end

function lvbut(from,num,level2)
	local formspec = {
		"image_button[4.5,-0.3;0.8,0.8;;esc;X]"
	}

	for i = 0,24 do
		if tonumber(level2) > (from+i) and num > i then
			if tonumber(level2)-1 > (from+i) then
				table.insert(formspec,
					"style["..char(i+1)..";bgcolor=#008800]")
			end

			local x = i % 5
			local y = math.floor(i / 5)+1

			table.insert(formspec,
				"button["..x..","..y..";1,1;"..char(i+1)..";"..(from+(i+1)).."]")
		end
	end

	return table.concat(formspec, "")
end

function wldSelTitle(world, unlocked, total)
	return "label[0,0;World "..world.."     ("..(tonumber(unlocked)-1).."/"..total.." completed)]"
end

local w11 = {}
w11.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_1')

	local formspec = "size[5,6.5]"..wldSelTitle(1, level2, 160)
	formspec = formspec..lvbut(0,25,level2)
	if level2 > 25 then
		formspec = formspec.."button[2.5,6;1,1;wab;>]"
	end
	return formspec
end
local w12 = {}
w12.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_1')

	local formspec = "size[5,6.5]"..wldSelTitle(1, level2, 160)
	formspec = formspec.."button[1.5,6;1,1;waa;<]"
	formspec = formspec..lvbut(25,25,level2)
	if level2 > 50 then
		formspec = formspec.."button[2.5,6;1,1;wac;>]"
	end
	return formspec
end
local w13 = {}
w13.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_1')

	local formspec = "size[5,6.5]"..wldSelTitle(1, level2, 160)
	formspec = formspec.."button[1.5,6;1,1;wab;<]"
	formspec = formspec..lvbut(50,25,level2)
	if level2 > 75 then
		formspec = formspec.."button[2.5,6;1,1;wad;>]"
	end
	return formspec
end
local w14 = {}
w14.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_1')

	local formspec = "size[5,6.5]"..wldSelTitle(1, level2, 160)
	formspec = formspec.."button[1.5,6;1,1;wac;<]"
	formspec = formspec..lvbut(75,25,level2)
	if level2 > 100 then
		formspec = formspec.."button[2.5,6;1,1;wae;>]"
	end
	return formspec
end
local w15 = {}
w15.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_1')

	local formspec = "size[5,6.5]"..wldSelTitle(1, level2, 160)
	formspec = formspec.."button[1.5,6;1,1;wad;<]"
	formspec = formspec..lvbut(100,25,level2)
	if level2 > 125 then
		formspec = formspec.."button[2.5,6;1,1;waf;>]"
	end
	return formspec
end
local w16 = {}
w16.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_1')

	local formspec = "size[5,6.5]"..wldSelTitle(1, level2, 160)
	formspec = formspec.."button[1.5,6;1,1;wae;<]"
	formspec = formspec..lvbut(125,25,level2)
	if level2 > 150 then
		formspec = formspec.."button[2.5,6;1,1;wag;>]"
	end
	return formspec
end
local w17 = {}
w17.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_1')

	local formspec = "size[5,6.5]"..wldSelTitle(1, level2, 160)
	formspec = formspec.."button[1.5,6;1,1;waf;<]"
	formspec = formspec..lvbut(150,10,level2)
	if level2 > 160 then
		formspec = formspec.."label[0,3;play world 2 and 3]"
	end
	return formspec
end
local w21 = {}
w21.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_2')

	local formspec = "size[5,6.5]"..wldSelTitle(2, level2, 190)
	formspec = formspec..lvbut(0,25,level2)
	if level2 > 25 then
		formspec = formspec.."button[2.5,6;1,1;wbb;>]"
	end
	return formspec
end
local w22 = {}
w22.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_2')

	local formspec = "size[5,6.5]"..wldSelTitle(2, level2, 190)
	formspec = formspec.."button[1.5,6;1,1;wba;<]"
	formspec = formspec..lvbut(25,25,level2)
	if level2 > 50 then
		formspec = formspec.."button[2.5,6;1,1;wbc;>]"
	end
	return formspec
end
local w23 = {}
w23.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_2')

	local formspec = "size[5,6.5]"..wldSelTitle(2, level2, 190)
	formspec = formspec.."button[1.5,6;1,1;wbb;<]"
	formspec = formspec..lvbut(50,25,level2)
	if level2 > 75 then
		formspec = formspec.."button[2.5,6;1,1;wbd;>]"
	end
	return formspec
end
local w24 = {}
w24.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_2')

	local formspec = "size[5,6.5]"..wldSelTitle(2, level2, 190)
	formspec = formspec.."button[1.5,6;1,1;wbc;<]"
	formspec = formspec..lvbut(75,25,level2)
	if level2 > 100 then
		formspec = formspec.."button[2.5,6;1,1;wbe;>]"
	end
	return formspec
end
local w25 = {}
w25.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_2')

	local formspec = "size[5,6.5]"..wldSelTitle(2, level2, 190)
	formspec = formspec.."button[1.5,6;1,1;wbd;<]"
	formspec = formspec..lvbut(100,25,level2)
	if level2 > 125 then
		formspec = formspec.."button[2.5,6;1,1;wbf;>]"
	end
	return formspec
end
local w26 = {}
w26.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_2')

	local formspec = "size[5,6.5]"..wldSelTitle(2, level2, 190)
	formspec = formspec.."button[1.5,6;1,1;wbe;<]"
	formspec = formspec..lvbut(125,25,level2)
	if level2 > 150 then
		formspec = formspec.."button[2.5,6;1,1;wbg;>]"
	end
	return formspec
end
local w27 = {}
w27.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_2')

	local formspec = "size[5,6.5]"..wldSelTitle(2, level2, 190)
	formspec = formspec.."button[1.5,6;1,1;wbf;<]"
	formspec = formspec..lvbut(150,25,level2)
	if level2 > 175 then
		formspec = formspec.."button[2.5,6;1,1;wbh;>]"
	end
	return formspec
end
local w28 = {}
w28.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_2')

	local formspec = "size[5,6.5]"..wldSelTitle(2, level2, 190)
	formspec = formspec.."button[1.5,6;1,1;wbg;<]"
	formspec = formspec..lvbut(175,15,level2)
	if level2 > 190 then
		formspec = formspec.."label[0,4;play world 1 and 3]"
	end
	return formspec
end
local w31 = {}
w31.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec..lvbut(0,25,level2)
	if level2 > 25 then
		formspec = formspec.."button[2.5,6;1,1;wcb;>]"
	end
	return formspec
end
local w32 = {}
w32.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wca;<]"
	formspec = formspec..lvbut(25,25,level2)
	if level2 > 50 then
		formspec = formspec.."button[2.5,6;1,1;wcc;>]"
	end
	return formspec
end
local w33 = {}
w33.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wcb;<]"
	formspec = formspec..lvbut(50,25,level2)
	if level2 > 75 then
		formspec = formspec.."button[2.5,6;1,1;wcd;>]"
	end
	return formspec
end
local w34 = {}
w34.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wcc;<]"
	formspec = formspec..lvbut(75,25,level2)
	if level2 > 100 then
		formspec = formspec.."button[2.5,6;1,1;wce;>]"
	end
	return formspec
end
local w35 = {}
w35.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wcd;<]"
	formspec = formspec..lvbut(100,25,level2)
	if level2 > 125 then
		formspec = formspec.."button[2.5,6;1,1;wcf;>]"
	end
	return formspec
end
local w36 = {}
w36.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wce;<]"
	formspec = formspec..lvbut(125,25,level2)
	if level2 > 150 then
		formspec = formspec.."button[2.5,6;1,1;wcg;>]"
	end
	return formspec
end
local w37 = {}
w37.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wcf;<]"
	formspec = formspec..lvbut(150,25,level2)
	if level2 > 175 then
		formspec = formspec.."button[2.5,6;1,1;wch;>]"
	end
	return formspec
end
local w38 = {}
w38.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wcg;<]"
	formspec = formspec..lvbut(175,25,level2)
	if level2 > 200 then
		formspec = formspec.."button[2.5,6;1,1;wci;>]"
	end
	return formspec
end
local w39 = {}
w39.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wch;<]"
	formspec = formspec..lvbut(200,25,level2)
	if level2 > 225 then
		formspec = formspec.."button[2.5,6;1,1;wcj;>]"
	end
	return formspec
end
local w310 = {}
w310.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wci;<]"
	formspec = formspec..lvbut(225,25,level2)
	if level2 > 250 then
		formspec = formspec.."button[2.5,6;1,1;wck;>]"
	end
	return formspec
end
local w311 = {}
w311.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wcj;<]"
	formspec = formspec..lvbut(250,25,level2)
	if level2 > 275 then
		formspec = formspec.."button[2.5,6;1,1;wcl;>]"
	end
	return formspec
end
local w312 = {}
w312.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wck;<]"
	formspec = formspec..lvbut(275,25,level2)
	if level2 > 300 then
		formspec = formspec.."button[2.5,6;1,1;wcm;>]"
	end
	return formspec
end
local w313 = {}
w313.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wcl;<]"
	formspec = formspec..lvbut(300,25,level2)
	if level2 > 325 then
		formspec = formspec.."button[2.5,6;1,1;wcn;>]"
	end
	return formspec
end
local w314 = {}
w314.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_3')

	local formspec = "size[5,6.5]"..wldSelTitle(3, level2, 333)
	formspec = formspec.."button[1.5,6;1,1;wcm;<]"
	formspec = formspec..lvbut(325,8,level2)
	if level2 > 333 then
		formspec = formspec.."label[0,3;play world 1 and 2]"
	end
	return formspec
end
local w41 = {}
w41.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_4')

	local formspec = "size[5,6.5]"..wldSelTitle(4, level2, 100)
	formspec = formspec..lvbut(0,25,level2)
	if level2 > 25 then
		formspec = formspec.."button[2.5,6;1,1;wdb;>]"
	end
	return formspec
end
local w42 = {}
w42.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_4')

	local formspec = "size[5,6.5]"..wldSelTitle(4, level2, 100)
	formspec = formspec.."button[1.5,6;1,1;wda;<]"
	formspec = formspec..lvbut(25,25,level2)
	if level2 > 50 then
		formspec = formspec.."button[2.5,6;1,1;wdc;>]"
	end
	return formspec
end
local w43 = {}
w43.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_4')

	local formspec = "size[5,6.5]"..wldSelTitle(4, level2, 100)
	formspec = formspec.."button[1.5,6;1,1;wdb;<]"
	formspec = formspec..lvbut(50,25,level2)
	if level2 > 75 then
		formspec = formspec.."button[2.5,6;1,1;wdd;>]"
	end
	return formspec
end
local w44 = {}
w44.get_formspec = function(player, pos)
	if player == nil then return end
	local level2 = storage:get_int('world_4')

	local formspec = "size[5,6.5]"..wldSelTitle(4, level2, 100)
	formspec = formspec.."button[1.5,6;1,1;wdc;<]"
	formspec = formspec..lvbut(75,25,level2)
	if level2 > 100 then
		formspec = formspec.."label[0,6;more comming soon]"
	end
	return formspec
end

function worldBlock(world)
	local silver = "sudoku_silver_block.png"
	return {silver,silver,silver,silver,silver,silver.."^[resize:32x32^(sudoku_worlds.png^[sheet:5x1:"..(world-1)..",0)"}
end

minetest.register_node("sudoku:new_w1",{
	tiles = worldBlock(1),
	description = "World 1",
	on_punch = function(pos, node, player, pointed_thing)
		local player_inv = player:get_inventory()
		local name = player:get_player_name()
		local page = player_inv:get_stack("page1", 1):get_count()+1
		if page == 1 then
			minetest.show_formspec(name, "w11" , w11.get_formspec(player))
		elseif page == 2 then
			minetest.show_formspec(name, "w12" , w12.get_formspec(player))
		elseif page == 3 then
			minetest.show_formspec(name, "w13" , w13.get_formspec(player))
		elseif page == 4 then
			minetest.show_formspec(name, "w14" , w14.get_formspec(player))
		elseif page == 5 then
			minetest.show_formspec(name, "w15" , w15.get_formspec(player))
		elseif page == 6 then
			minetest.show_formspec(name, "w16" , w16.get_formspec(player))
		elseif page == 7 then
			minetest.show_formspec(name, "w17" , w17.get_formspec(player))
		end
	end,
})
minetest.register_node("sudoku:new_w2",{
	tiles = worldBlock(2),
	description = "World 2",
	on_punch = function(pos, node, player, pointed_thing)
		local player_inv = player:get_inventory()
		local name = player:get_player_name()
		local page = player_inv:get_stack("page2", 1):get_count()+1
		if page == 1 then
			minetest.show_formspec(name, "w21" , w21.get_formspec(player))
		elseif page == 2 then
			minetest.show_formspec(name, "w22" , w22.get_formspec(player))
		elseif page == 3 then
			minetest.show_formspec(name, "w23" , w23.get_formspec(player))
		elseif page == 4 then
			minetest.show_formspec(name, "w24" , w24.get_formspec(player))
		elseif page == 5 then
			minetest.show_formspec(name, "w25" , w25.get_formspec(player))
		elseif page == 6 then
			minetest.show_formspec(name, "w26" , w26.get_formspec(player))
		elseif page == 7 then
			minetest.show_formspec(name, "w27" , w27.get_formspec(player))
		elseif page == 8 then
			minetest.show_formspec(name, "w28" , w28.get_formspec(player))
		end
	end,
})
minetest.register_node("sudoku:new_w3",{
	tiles = worldBlock(3),
	description = "World 3",
	on_punch = function(pos, node, player, pointed_thing)
		local player_inv = player:get_inventory()
		local name = player:get_player_name()
		local page = player_inv:get_stack("page3", 1):get_count()+1
		if page == 1 then
			minetest.show_formspec(name, "w31" , w31.get_formspec(player))
		elseif page == 2 then
			minetest.show_formspec(name, "w32" , w32.get_formspec(player))
		elseif page == 3 then
			minetest.show_formspec(name, "w33" , w33.get_formspec(player))
		elseif page == 4 then
			minetest.show_formspec(name, "w34" , w34.get_formspec(player))
		elseif page == 5 then
			minetest.show_formspec(name, "w35" , w35.get_formspec(player))
		elseif page == 6 then
			minetest.show_formspec(name, "w36" , w36.get_formspec(player))
		elseif page == 7 then
			minetest.show_formspec(name, "w37" , w37.get_formspec(player))
		elseif page == 8 then
			minetest.show_formspec(name, "w38" , w38.get_formspec(player))
		elseif page == 9 then
			minetest.show_formspec(name, "w39" , w39.get_formspec(player))
		elseif page == 10 then
			minetest.show_formspec(name, "w310" , w310.get_formspec(player))
		elseif page == 11 then
			minetest.show_formspec(name, "w311" , w311.get_formspec(player))
		elseif page == 12 then
			minetest.show_formspec(name, "w312" , w312.get_formspec(player))
		elseif page == 13 then
			minetest.show_formspec(name, "w313" , w313.get_formspec(player))
		elseif page == 14 then
			minetest.show_formspec(name, "w314" , w314.get_formspec(player))
		end
	end,
})
minetest.register_node("sudoku:new_w4",{
	tiles = worldBlock(4),
	description = "World 4",
	on_punch = function(pos, node, player, pointed_thing)
		local player_inv = player:get_inventory()
		local name = player:get_player_name()
		local page = player_inv:get_stack("page4", 1):get_count()+1
		if page == 1 then
			minetest.show_formspec(name, "w41" , w41.get_formspec(player))
		elseif page == 2 then
			minetest.show_formspec(name, "w42" , w42.get_formspec(player))
		elseif page == 3 then
			minetest.show_formspec(name, "w43" , w43.get_formspec(player))
		elseif page == 4 then
			minetest.show_formspec(name, "w44" , w44.get_formspec(player))
		end
	end,
})
minetest.register_node("sudoku:new_w5",{
	tiles = worldBlock(5),
	description = "World 5",
	on_punch = function(pos, node, player, pointed_thing)
		sudoku_hud_message.message(player, "Coming soon!", 0xffffff)
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local player_inv = player:get_inventory()
	player_inv:set_size("ll", 1)
	player_inv:set_size("l", 6)
	player_inv:set_size("page1", 1)
	player_inv:set_size("page2", 1)
	player_inv:set_size("page3", 1)
	player_inv:set_size("page4", 1)
	if formname == "w11" or formname == "w12" or formname == "w13" or formname == "w14" or formname == "w15" or formname == "w16" or formname == "w17" then
		for k, v in pairs(fields) do
			if tonumber(v) ~= nil then
				New(player,1,tonumber(v))
				player_inv:set_stack("l",  1, "default:dirt "..v)
				player_inv:set_stack("ll", 1, "default:dirt 1")
			end
		end
	end
	if formname == "w21" or formname == "w22" or formname == "w23" or formname == "w24" or formname == "w25" or formname == "w26" or formname == "w27" or formname == "w28" then
		for k, v in pairs(fields) do
			if tonumber(v) ~= nil then
				New(player,2,tonumber(v))
				player_inv:set_stack("l",  2, "default:dirt "..v)
				player_inv:set_stack("ll", 1, "default:dirt 2")
			end
		end
	end
	if formname == "w31" or formname == "w32" or formname == "w33" or formname == "w34" or formname == "w35" or formname == "w36" or formname == "w37" or formname == "w38" or formname == "w39" or formname == "w310" or formname == "w311" or formname == "w312" or formname == "w313" or formname == "w314" then
		for k, v in pairs(fields) do
			if tonumber(v) ~= nil then
				New(player,3,tonumber(v))
				player_inv:set_stack("l",  3, "default:dirt "..v)
				player_inv:set_stack("ll", 1, "default:dirt 3")
			end
		end
	end
	if formname == "w41" or formname == "w42" or formname == "w43" or formname == "w44" then
		for k, v in pairs(fields) do
			if tonumber(v) ~= nil then
				New(player,4,tonumber(v))
				player_inv:set_stack("l",  4, "default:dirt "..v)
				player_inv:set_stack("ll", 1, "default:dirt 4")
			end
		end
	end
	local name = player:get_player_name()
	if fields.waa then
		player_inv:set_stack("page1",  1, nil)
		minetest.show_formspec(name, "w11" , w11.get_formspec(player))
	elseif fields.wab then
		player_inv:set_stack("page1",  1, "default:dirt")
		minetest.show_formspec(name, "w12" , w12.get_formspec(player))
	elseif fields.wac then
		player_inv:set_stack("page1",  1, "default:dirt 2")
		minetest.show_formspec(name, "w13" , w13.get_formspec(player))
	elseif fields.wad then
		player_inv:set_stack("page1",  1, "default:dirt 3")
		minetest.show_formspec(name, "w14" , w14.get_formspec(player))
	elseif fields.wae then
		player_inv:set_stack("page1",  1, "default:dirt 4")
		minetest.show_formspec(name, "w15" , w15.get_formspec(player))
	elseif fields.waf then
		player_inv:set_stack("page1",  1, "default:dirt 5")
		minetest.show_formspec(name, "w16" , w16.get_formspec(player))
	elseif fields.wag then
		player_inv:set_stack("page1",  1, "default:dirt 6")
		minetest.show_formspec(name, "w17" , w17.get_formspec(player))
	elseif fields.wba then
		player_inv:set_stack("page2",  1, nil)
		minetest.show_formspec(name, "w21" , w21.get_formspec(player))
	elseif fields.wbb then
		player_inv:set_stack("page2",  1, "default:dirt")
		minetest.show_formspec(name, "w22" , w22.get_formspec(player))
	elseif fields.wbc then
		player_inv:set_stack("page2",  1, "default:dirt 2")
		minetest.show_formspec(name, "w23" , w23.get_formspec(player))
	elseif fields.wbd then
		player_inv:set_stack("page2",  1, "default:dirt 3")
		minetest.show_formspec(name, "w24" , w24.get_formspec(player))
	elseif fields.wbe then
		player_inv:set_stack("page2",  1, "default:dirt 4")
		minetest.show_formspec(name, "w25" , w25.get_formspec(player))
	elseif fields.wbf then
		player_inv:set_stack("page2",  1, "default:dirt 5")
		minetest.show_formspec(name, "w26" , w26.get_formspec(player))
	elseif fields.wbg then
		player_inv:set_stack("page2",  1, "default:dirt 6")
		minetest.show_formspec(name, "w27" , w27.get_formspec(player))
	elseif fields.wbh then
		player_inv:set_stack("page2",  1, "default:dirt 7")
		minetest.show_formspec(name, "w28" , w28.get_formspec(player))
	elseif fields.wca then
		player_inv:set_stack("page3",  1, nil)
		minetest.show_formspec(name, "w31" , w31.get_formspec(player))
	elseif fields.wcb then
		player_inv:set_stack("page3",  1, "default:dirt")
		minetest.show_formspec(name, "w32" , w32.get_formspec(player))
	elseif fields.wcc then
		player_inv:set_stack("page3",  1, "default:dirt 2")
		minetest.show_formspec(name, "w33" , w33.get_formspec(player))
	elseif fields.wcd then
		player_inv:set_stack("page3",  1, "default:dirt 3")
		minetest.show_formspec(name, "w34" , w34.get_formspec(player))
	elseif fields.wce then
		player_inv:set_stack("page3",  1, "default:dirt 4")
		minetest.show_formspec(name, "w35" , w35.get_formspec(player))
	elseif fields.wcf then
		player_inv:set_stack("page3",  1, "default:dirt 5")
		minetest.show_formspec(name, "w36" , w36.get_formspec(player))
	elseif fields.wcg then
		player_inv:set_stack("page3",  1, "default:dirt 6")
		minetest.show_formspec(name, "w37" , w37.get_formspec(player))
	elseif fields.wch then
		player_inv:set_stack("page3",  1, "default:dirt 7")
		minetest.show_formspec(name, "w38" , w38.get_formspec(player))
	elseif fields.wci then
		player_inv:set_stack("page3",  1, "default:dirt 8")
		minetest.show_formspec(name, "w39" , w39.get_formspec(player))
	elseif fields.wcj then
		player_inv:set_stack("page3",  1, "default:dirt 9")
		minetest.show_formspec(name, "w310" , w310.get_formspec(player))
	elseif fields.wck then
		player_inv:set_stack("page3",  1, "default:dirt 10")
		minetest.show_formspec(name, "w311" , w311.get_formspec(player))
	elseif fields.wcl then
		player_inv:set_stack("page3",  1, "default:dirt 11")
		minetest.show_formspec(name, "w312" , w312.get_formspec(player))
	elseif fields.wcm then
		player_inv:set_stack("page3",  1, "default:dirt 12")
		minetest.show_formspec(name, "w313" , w313.get_formspec(player))
	elseif fields.wcn then
		player_inv:set_stack("page3",  1, "default:dirt 13")
		minetest.show_formspec(name, "w314" , w314.get_formspec(player))
	elseif fields.wda then
		player_inv:set_stack("page4",  1, "")
		minetest.show_formspec(name, "w41" , w41.get_formspec(player))
	elseif fields.wdb then
		player_inv:set_stack("page4",  1, "default:dirt")
		minetest.show_formspec(name, "w42" , w42.get_formspec(player))
	elseif fields.wdc then
		player_inv:set_stack("page4",  1, "default:dirt 2")
		minetest.show_formspec(name, "w43" , w43.get_formspec(player))
	elseif fields.wdd then
		player_inv:set_stack("page4",  1, "default:dirt 3")
		minetest.show_formspec(name, "w44" , w44.get_formspec(player))
	else
		minetest.show_formspec(name, "", "")
	end
end)


function file_check(file_name)
	local file_found=io.open(file_name, "r")
	if file_found==nil then
		file_found=false
	else
		file_found=true
	end
	return file_found
end

function compat(storage, player)
	for i = 1, 5, 1 do
		if file_check(minetest.get_worldpath().."/level"..i..".txt") then
			local lv = io.open(minetest.get_worldpath().."/level"..i..".txt", "r")
			local value = lv:read("*l")
			lv:close()
			storage:set_int("world_"..i, value)
			os.remove(minetest.get_worldpath().."/level"..i..".txt")
		end
	end

	local verfile = minetest.get_worldpath().."/Map_Version.txt"
	if file_check(verfile) then
		storage:set_int("mapversion", 1)
		os.remove(verfile)
	end

	local player_inv = player:get_inventory()
	local ll = player_inv:get_stack("ll", 1):get_count()
	local l = player_inv:get_stack("l", ll):get_count()
	if l ~= 0 and ll ~= 0 then
		storage:set_int("current_world", ll)
		storage:set_int("current_level", l)

		player_inv:set_size("ll", 0)
		player_inv:set_size("l", 0)
	end
end

-- Set world to singlenode if not already (umm yea)
minetest.set_mapgen_setting('mgname', 'singlenode', true)

-- Alias old "finisch" node to sudoku:desert
minetest.register_alias("sudoku:finisch", "sudoku:desert")

-- Alias some default nodes (because for some reason old sudoku had a flat mapgen outside the gated area)
for _, node in ipairs{
	'dirt_with_grass',
	--'dirt', we still use dirt to store player data, don't ask me about it
	'stone',
	'silver_sand',
	'stone_with_coal',
	'stone_with_iron',
	'stone_with_copper',
	'stone_with_tin',
	'stone_with_gold',
	'stone_with_mese',
	'stone_with_diamond',
	'gravel',
} do
	minetest.register_alias("default:"..node, "air")
end

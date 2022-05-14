
function file_check(file_name)
	local file_found=io.open(file_name, "r")
	if file_found==nil then
		file_found=false
	else
		file_found=true
	end
	return file_found
end

function compat(storage)
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
end

-- Alias old "finisch" node to sudoku:desert
minetest.register_alias("sudoku:finisch", "sudoku:desert")

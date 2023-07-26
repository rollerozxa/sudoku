
-- Unit tested
function string_splitter_of_doom(lol)
	local t = {}
	for line in lol:gmatch"[^\n]+" do
		local row = {}
		for i = 1, #line do
			row[i] = line:sub(i, i)
		end
		table.insert(t, row)
	end
	return t
end

function repeats(s,c)
	local _,n = s:gsub(c,"")
	return n
end

function itemstring_to_number(itemstring)
	local number = tonumber(itemstring:gsub('sudoku:n_', ''):gsub('sudoku:', ''), 10)

	if number and number >= 1 and number <= 9 then
		return number
	else
		return 0
	end
end

-- Not unit tested

function world_block(world)
	local silver = "sudoku_silver_block.png"
	return {silver,silver,silver,silver,silver,silver.."^[resize:32x32^(sudoku_worlds.png^[sheet:5x1:"..(world-1)..",0)"}
end

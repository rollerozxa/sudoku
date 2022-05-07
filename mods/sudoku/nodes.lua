
-- Basic nodes and number node registrations.

minetest.register_node("sudoku:desert",{
	description = "Desert Sand",
	tiles = {"sudoku_desert_sand.png"},
})
minetest.register_node("sudoku:black",{
	description = "Black Tile",
	tiles = {"sudoku_black_tile.png"},
})
minetest.register_node("sudoku:gray",{
	description = "Gray Tile",
	tiles = {"sudoku_gray_tile.png"},
})

minetest.register_node("sudoku:wall",{
	description = "Black Tile (Wall)",
	tiles = {"sudoku_black_tile.png"},
})
minetest.register_node("sudoku:meselamp", {
	description = "Mese Lamp",
	drawtype = "glasslike",
	tiles = {"sudoku_meselamp.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	light_source = 15,
})

for i=1,9 do
	minetest.register_node("sudoku:"..i,{
		description = ""..i,
		tiles = {"sudoku_digits.png^[sheet:9x2:"..(i-1)..",0"},
	})

	minetest.register_node("sudoku:n_"..i,{
		description = ""..i,
		tiles = {"sudoku_digits.png^[sheet:9x2:"..(i-1)..",1"},
		groups = {snappy=1},
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			if Place(placer,i,pos) == false or pos.z ~= -76 then
				minetest.set_node(pos, {name="air"})
				return itemstack
			end
		end,
		on_drop = function(itemstack, dropper, pos)
			return itemstack
		end
	})
end

-- Placeholder aliases to prevent errors
minetest.register_alias("mapgen_stone", "air")
minetest.register_alias("mapgen_water_source", "air")

-- Holy shit it's the hand
local digtime = 42
minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x = 1, y = 1, z = 2.5},
	range = 15,
	tool_capabilities = {
		max_drop_level = 3,
		groupcaps = {
			snappy  = {times = {digtime, digtime, digtime}, uses = 0, maxlevel = 256},
		},
	}
})

-- Needs to be kept due to hacks.
-- In specific, it makes use of dirt nodes in an invisible inventory to keep
-- track of the current level and world.
-- TODO: Replace it with normal mod storage.
minetest.register_node(":default:dirt", {
	description = "Hack node",
	tiles = {"logo.png"},
})

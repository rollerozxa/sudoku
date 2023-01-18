minetest.register_on_joinplayer(function(player)
	player:set_formspec_prepend([[
		bgcolor[#080808BB;true]
		listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
		background9[5,5;1,1;gui_formbg.png;true;10]
	]])

	-- Set hotbar textures
	player:hud_set_hotbar_image("sudoku_gui_hotbar.png")
	player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")

	player:hud_set_hotbar_itemcount(9)

	player:set_inventory_formspec("")
	if not minetest.is_singleplayer() then
		minetest.kick_player(player:get_player_name(), "Sudoku is a singleplayer-only game.")
	end
end)

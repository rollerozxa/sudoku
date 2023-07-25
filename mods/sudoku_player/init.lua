
-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	player:set_properties{
		mesh = "character.b3d",
		textures = {"character.png"},
		visual = "mesh",
		visual_size = {x = 1, y = 1},
		collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
		stepheight = 0.6,
		eye_height = 1.47,
	}

	player:set_local_animation(
		{x = 0,   y = 79},
		{x = 168, y = 187},
		{x = 189, y = 198},
		{x = 200, y = 219},
		30
	)
end)

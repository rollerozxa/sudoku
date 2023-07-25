unused_args = false
allow_defined_top = true
max_line_length = false

globals = {
    "minetest", "core"
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",
}

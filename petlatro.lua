if not petlatro then
    petlatro = {}
end
petlatro = {
    show_options_button = false,
}
petlatro = SMODS.current_mod
petlatro_config = petlatro.config
petlatro.enabled = copy_table(petlatro_config)

SMODS.Atlas({
    object_type = "Atlas",
    key = "PIMG", -- example of this can be found in Items/Jokers.lua on line 8
    path = "jokers.png",-- this is the name of the file that your sprites will use from your assets folder
    px = 71,
    py = 95,
})

assert(SMODS.load_file("Items/jokers.lua"))()
assert(SMODS.load_file("Lib/Utility.lua"))()
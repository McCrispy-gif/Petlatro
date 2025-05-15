if not petlatro then
    petlatro = {}
end
petlatro = {
    show_options_button = false,
}
petlatro = SMODS.current_mod

SMODS.Atlas({
    object_type = "Atlas",
    key = "PIMG", -- KEY for all joker images please use
    path = "jokers.png",-- this is the name of the file that your sprites will use from your assets folder
    px = 71,
    py = 95,
})

assert(SMODS.load_file("Items/jokers.lua"))()
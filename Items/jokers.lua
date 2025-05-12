SMODS.Joker{
    key = "Benzo",
    pos = {x = 0, y = 0},
    rarity = 4,
    atlas = "PIMG",
    config = {
         extra ={
            xmult = 1.0,
            mult =1.0,
            triggered = false
        } 
    },
    cost = 50,
    loc_txt = {
        name = "Benzo",
        text = {
            "When {C:attention}Blind{} is selected jokers to the left and right are {C:red,E:2}destroyed{}",
            "gains {C:attention}one-tenth{} of the jokers's combined {C:attention}$ value{} ",
            "are added to{X:mult,C:white}xMult{}",
            "and {C:attention}one-fourth{} is added to {X:mult,C:white}Mult{}",
            "Current {C:attention}xMult{}:{C:xmult}#1#{}",
            "{C:inactive}Triggers on end of shop{}",
        }
    },
    loc_vars = function (self, info_queue, center)
        return {
             vars = { 
                string.format("%.1f", center.ability.extra.xmult),
                string.format("%.2f", center.ability.extra.mult)
             }
        }

    end,

    calculate = function (self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            return {
                xmult = card.ability.extra.xmult,
                mult = card.ability.extra.mult
            }
        end
    end,

    on_post_shop = function (self, card)
        local index =  nil 
        for i, c in ipairs(G.jokers) do
            if c == card then
                index = i
                break
            end
        end
        
        local total_cost = 0
        local to_destroy = {}

        if index then
            local left = G.jokers[index - 1]
            local right = G.jokers[index + 1]
            if left and left.ability and not left.ability.eternal then
                table.insert(to_destroy, left)
                total_cost = total_cost + left.cost
            end
            if right and right.ability and not right.ability.eternal then
                table.insert(to_destroy, right)
                total_cost = total_cost + right.cost
            end
        end
        if #to_destroy > 0 then
            for _, c in ipairs(to_destroy) do
                G.jokers:remove_card(c)
                c:start_dissolve(nil, "slice")

            end
            play_sound("cat")

            local xmult = total_cost * 0.1
            card.ability.extra.xmult = card.ability.extra.xmult + xmult
            local mult = total_cost * 0.25
            card.ability.extra.mult = card.ability.extra.mult + mult
            card.ability.extra.triggered = true

            G.E_MANAGER:add_event(Event({
                func = function()
                    attention_text({
                        text = "+" .. string.format("%.2f", xmult) .. "x mult\n"
                             .. "+" .. string.format("%.2f", mult) .. " mult",
                        scale = 1.2,
                        hold = 1.5,
                        major = true,
                        color = G.C.Mult
                    }, card)
                    return true
                end
            }))
        end
    end,
}
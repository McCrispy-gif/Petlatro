  -- Benzo code, breaks adjacent jokers gains mult and xmult
SMODS.Joker{     -- Benzo code, breaks adjacent jokers gains mult and xmult
    key = "Benzo",
    pos = {x = 0, y = 0},
    rarity = "cry_epic",
    perishable_compat = false,
    blueprint_compat = true,
    eternal = true,
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
            "When {C:attention}Shop ends{} directly adjacent jokers are {C:red,E:2}destroyed{}",
            "and{C:attention}25%{} of the jokers's combined {C:attention}$ value{} ",
            "is added to {X:mult,C:white}xMult{}",
            "and {C:attention}50%{} is added to {X:mult,C:white}Mult{}",
            "Current {C:attention}xMult{}:{C:xmult}#1#{}",
            "Current {C:attention}Mult{}:{C:mult}#2#{}",
            "{C:inactive}Triggers on end of shop{}",
            "{C:attention}Eternal{}"
        }
    },
    loc_vars = function (self, info_queue, center)
        return {
             vars = { 
                string.format("%.2f", center.ability.extra.xmult),
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

        if index then -- check if card is present and what is next to it
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
        if #to_destroy > 0 then -- breaks other cards if they are adjacent
            for _, c in ipairs(to_destroy) do
                G.jokers:remove_card(c)
                c:start_dissolve(nil, "slice")

            end
            play_sound("cat")

            local xmult = total_cost * 0.25  -- calculates new values 
            card.ability.extra.xmult = card.ability.extra.xmult + xmult
            local mult = total_cost * 0.5
            card.ability.extra.mult = card.ability.extra.mult + mult
            card.ability.extra.triggered = true

            G.E_MANAGER:add_event(Event({      --- shows the text of updated values
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


 -- Tinkerbelle code, breaks all consumables and adds to mult and credits
SMODS.Joker{ 
    key = "Tinkerbelle",
    pos = {x = 1, y = 0},
    rarity = "cry_epic",
    atlas = "PIMG",
    config = {
        extra = {
            credits = 50,
            e_mult = 1.0,
            rounds_got = 0,
        }
    },
    cost = 50,
    loc_txt = {
        name = "Tinkerbelle",
        text = {
            "Every {C:attention}2{} rounds, {C:red}ALL{} consumables are destroyed",
            "25% the amount of consumables are added to {C:emult}^mult{}",
            "and 5x to {C:attention}credits{}",
            "Current {C:attention}mult{}:{C:e_mult,C:white}^#2#{}",
            "Current {C:attention}Credits{}:{C:credits,C:white}#1#{}",
            "{C:attention}#3#/2rounds{}"
        }
    },
    loc_vars = function (self, info_queue, center)  -- needed to add to text
        return {
            vars = {
                string.format("%.2f", center.ability.extra.credits),
                string.format("%.2f", center.ability.extra.e_mult),
                string.format("%.2f", center.ability.extra.rounds_got or 0)
            }
        }
    end,
    calculate = function (self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            return {
                credits = card.ability.extra.credits,
                mult = card.ability.extra.e_mult
            }
        end
    end,
    on_blind_start = function (self, card)
        card.ability.extra.rounds_got = card.ability.extra.rounds_got + 1
        local total_cards = 0
        local to_destroy = {}
        for i, c in ipairs(G.consumables) do
            if c.ability and not c.ability.eternal then
                table.insert(to_destroy, c)
                total_cards = total_cards + 1
            end
        end
        if #to_destroy >0 and card.ability.extra.rounds_got >= 2 then 
            for _, c in ipairs(to_destroy) do
                G.consumables:remove_card(c)
                c:start_dissolve(nil, "slice")
            end
            play_sound("cat")
            card.ability.extra.rounds_got = 0

            local mult = total_cards * 0.25
            local credits = total_cards * 5
            card.ability.extra.e_mult = card.ability.extra.e_mult + mult
            card.ability.extra.credits = card.ability.extra.credits + credits
            card.ability.extra.triggered = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    attention_text({
                        text = "+" .. string.format("%.2f", mult) .. "^mult\n"
                             .. "+" .. string.format("%.2f", credits) .. "credits",
                        scale = 1.2,
                        hold = 1.5,
                        major = true,
                        color = G.C.Mult
                    }, card)
                    return true
                end
            }))
        end
    end

}


SMODS.Joker{  --- Sage code, gains xmult based on the amount of tarot cards present in the consumables slot
    key = "Sage",
    pos = {x = 2, y = 0},
    rarity = "cry_epic",
    atlas = "PIMG",
    config = {
        extra = {
            xmult = 1.0,
            tarot_cards = 0
        }
    },
    cost = 50,
    blueprint_compat = true,
    perishable_compat = true,
    loc_text = {
        name = "Sage",
        text = {
            "Gains {C:xmult}xMult{} based on the amount of tarot cards",
            "present in the consumables slot, each card gives an additional",
            "{Cattention}0.2{} of {C:xmult}xMult{} value",
            "Current {C:attention}xMult{}:{C:xmult,C:white}#1#{}",
            "{C:inactive}Updates when any tarots are added or removed{}"
        }
    },
    loc_vars = function (self, info_queue, center)
        return {
            vars = {
                string.format("%.2f", center.ability.extra.xmult)
            }
        }
    end,
    calculate = function (self,card, context)
        if context.cardarea == G.jokers and context.joker_main then
                count =  0
                for i, c  in ipairs (G.consumables) do
                    if c.ability and c.ability.type == "tarot" then
                    count = count + 1
                    end
                end
                card.ability.extra.xmult = card.ability.extra.xmult  * count * 0.2
                return {xmult = card.ability.extra.xmult}
            end
        end
}

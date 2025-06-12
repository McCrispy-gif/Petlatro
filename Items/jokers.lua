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
        }
    },
    cost = 50,
    loc_txt = {
        name = "Benzo",
        text = {
            "On {C:attention}end of shop{} touching jokers are {C:red,E:2}destroyed{}",
            "and {C:attention}10%{} of the jokers's combined {C:attention}$ cash{} value",
            "is added to {X:mult,C:white}xMult{} and {C:attention}25%{} is added to {X:mult,C:white}Mult{}",
            "Current {C:attention}xMult value{}: {X:mult,C:white}x#1#{}",
            "Current {C:attention}Mult{}: {X:mult,C:white}+#2#{}",
            "{C:inactive}Triggers on end of shop{}"
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
        if context.ending_shop then
            print("Benzo triggered at end of shop")
            local index = nil
            for i, c in ipairs(G.jokers.cards) do
                if c == card then
                    index = i
                    break
                end
            end
            local total_cost = 0
            local to_destroy = {}
            if index then
                local left = G.jokers.cards[index - 1]
                local right = G.jokers.cards[index + 1]
                if left and left.ability and not left.ability.eternal then
                    print("Left card found")
                    table.insert(to_destroy, left)
                    total_cost = total_cost + (left.cost or 0)
                end
                if right and right.ability and not right.ability.eternal then
                    print("Right card found")
                    table.insert(to_destroy, right)
                    total_cost = total_cost + (right.cost or 0)
                end
            end
            if #to_destroy > 0 then
                for _, c in ipairs(to_destroy) do
                    G.jokers:remove_card(c)
                    c:start_dissolve({ HEX("57ecab") }, nil, 1.6)
                end
                play_sound("meow3") --- Sounds used from Cryptid https://github.com/SpectralPack/Cryptid
                card.ability.extra.xmult = card.ability.extra.xmult +(total_cost *0.1)
                card.ability.extra.mult = card.ability.extra.mult  +(total_cost * 0.25)
                card.ability.extra.triggered = true
                return {
                    message = (localize or function(data) return data end) { type = "variable", key = "a_mult", vars = {
                        string.format("%.2f", card.ability.extra.xmult),
                        string.format("%.2f", card.ability.extra.mult)
                    }},
                    color = G.C.mult,
                    no_juice = true
                }
            else
                print("No cards to destroy")
            end
        elseif context.joker_main then
            print("Benzo triggered on hand play")
            return{
                 xmult = card.ability.extra.xmult,
                 mult = card.ability.extra.mult
            }
        end
    end
}


SMODS.Joker{
    key = "Tinkerbelle",
    pos = {x = 1, y = 0},
    rarity = "cry_epic",
    atlas = "PIMG",
    config = {
        extra = {
            credits = 50,
            e_mult = 1,
            rounds_got = 0,
            rounds = 2
        }
    },
    cost = 50,
    loc_txt = {
        name = "Tinkerbelle",
        text = {
            "Every {C:attention}2{} rounds, {C:red}ALL{} consumables are destroyed",
            "5% the amount of consumables are added to {C:mult}^mult{}",
            "and 5x the cards are added to total {C:attention}credits{}",
            "Current {C:attention}mult{}: {C:mult,C:white}^#2#{}",
            "Current {C:attention}credits{}: {C:credits,C:white}#1#{}",
            "{C:attention}#3#/2rounds{}",
            "{C:inactive}Does not work on eternal or negative cards{}"
        }
    },
    loc_vars = function (self, info_queue, center)  -- needed to add to text
        return {
            vars = {
                string.format("%.2f", center.ability.extra.credits),
                string.format("%.2f", center.ability.extra.e_mult),
                string.format("%.0f", center.ability.extra.rounds_got or 0)
            }
        }
    end,
        calculate = function (self, card, context)
            if context.end_of_round
            and not context.individual
            and not context.repetition
            and not context.blueprint then
                card.ability.extra.rounds_got = card.ability.extra.rounds_got + 1
            end
            if card.ability.extra.rounds_got >= card.ability.extra.rounds then
                local total_cards = 0
                local to_destroy = {}
                for i, c in ipairs(G.consumeables.cards) do
                    if c.ability
                    and not c.ability.eternal
                    or c.ability.negative
                    and not c.to_desroy then
                        table.insert(to_destroy, c)
                        total_cards = total_cards + 1
                    end
                end
                if #to_destroy > 0 and card.ability.extra.rounds_got >= 2 then
                    for _, c in ipairs(to_destroy) do
                        G.consumeables:remove_card(c)
                        c:start_dissolve({HEX("57ecab")}, nil, 1.6)
                    end
                    play_sound("meow1") --- Sounds used from Cryptid https://github.com/SpectralPack/Cryptid
                    card.ability.extra.rounds_got = 0
                    local mult = total_cards * 0.05
                    local credits = total_cards * 5
                    card.ability.extra.e_mult = card.ability.extra.e_mult + mult
                    card.ability.extra.credits = card.ability.extra.credits + credits
                    card.ability.extra.triggered = true
                end
                return {
                    message = localize { type = "variable", key ="a_mult", vars = {
                        string.format("%.2f", card.ability.extra.e_mult),
                        string.format("%.2f", card.ability.extra.credits)
                    }},
                    color = G.C.mult,
                    no_juice = true
                }
            elseif context.joker_main then
                return {
                    mult = card.ability.extra.e_mult,
                    credits = card.ability.extra.credits
                }
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
    loc_txt = {
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

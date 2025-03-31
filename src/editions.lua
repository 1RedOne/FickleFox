sendInfoMessage("Processing editions", "editions.lua")

SMODS.Edition({
    key = "ghostRare",
    loc_txt = {
        name = "Ghost Rare",
        label = "ghostRare",
        text = {
            "When scored, earn {C:green}$#1#{}, applies {C:red}+#2#{} Mult",
            "{C:green}#3# in #4#{} chance to be destroyed when played"
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'glimmer',
    -- shader=false,
    config = {
        dollars = 2,
        mult = 10,
        odds = 6
    },
    in_shop = true,
    weight = 25,
    extra_cost = 4,
    -- disable_base_shader=true,
    apply_to_float = true, --false,
    loc_vars = function(self)
        return { vars = { self.config.dollars, self.config.mult, G.GAME.probabilities.normal, self.config.odds } }
    end,
    sound = {
        sound = "Fox_ghostRare",
        per = 1,
        vol = 0.3,
    },
    calculate = function(self, card, context)
        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            ease_dollars(card.edition.dollars)

            return {
                mult = 10,
                card = self
            }
        elseif context.destroying_card and card.ability.set == 'Joker' then
            if pseudorandom('ghostRare') < G.GAME.probabilities.normal / self.config.odds then
                local destroyed_cards = {}
                destroyed_cards[#destroyed_cards + 1] = card
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        play_sound('tarot1')
                        return true
                    end
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        if card.ability.name == 'Glass Card' then
                            card:shatter()
                        else
                            card:start_dissolve(nil, 1 == #G.hand.highlighted)
                        end

                        return true
                    end
                }))

                sendInfoMessage("we are going to destroy this joker", "ghostRare ")
            else
                sendInfoMessage("we are not going to destroy this joker", "ghostRare")
            end
        elseif context.destroying_card and card.ability.set ~= 'Joker' then
            if pseudorandom('ghostRare') < G.GAME.probabilities.normal / self.config.odds then
                --add destroy logic here
                sendInfoMessage("we are going to destroy this card", "ghostRare ")

                return { remove = true }
            else
                sendInfoMessage("we are not going to destroy this card", "ghostRare")
            end
        end
    end
})

SMODS.Edition({ --etherOverdrive
    key = "fragileRelic",
    loc_txt = {
        name = "Ether Overdrive",
        label = "EtherOverdrive",
        text = {
            "{X:mult,C:white}X#1#{} Mult",
            "{C:green}#2# in #3#{} chance to destroy card"
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'etherOverdrive',
    config = {
        x_mult = 3,
        Xmult = 3,
        odds = 3
    },
    in_shop = true,
    weight = 40,
    extra_cost = 4,
    apply_to_float = true, --false,
    loc_vars = function(self)
        return { vars = { self.config.x_mult, G.GAME.probabilities.normal, self.config.odds } }
    end,
    sound = {
        sound = "Fox_ghostRare",
        per = 1,
        vol = 0.3,
    },
    calculate = function(self, card, context)
        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            sendInfoMessage("we are counting this card", "etherOverdrive")
            return {
                x_mult = card.edition.x_mult,
                colour = G.C.RED
            }
        elseif context.destroying_card and card.ability.set == 'Joker' then
            if pseudorandom('fragileRelic') < G.GAME.probabilities.normal / self.config.odds then
                local destroyed_cards = {}
                destroyed_cards[#destroyed_cards + 1] = card
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        play_sound('tarot1')
                        return true
                    end
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        if card.ability.name == 'Glass Card' then
                            card:shatter()
                        else
                            card:start_dissolve(nil, 1 == #G.hand.highlighted)
                        end

                        return true
                    end
                }))

                sendInfoMessage("we are going to destroy this joker", self.key)
            else
                sendInfoMessage("we are not going to destroy this joker", self.key)
            end
        elseif context.destroying_card and card.ability.set ~= 'Joker' then
            if pseudorandom('fragileRelic') < G.GAME.probabilities.normal / self.config.odds then
                --add destroy logic here
                sendInfoMessage("we are going to destroy this card", self.key)

                return { remove = true }
            else
                sendInfoMessage("we are not going to destroy this card", self.key)
            end
        end
    end
})

SMODS.Edition({
    key = "secretRare",
    loc_txt = {
        name = "Secret Rare",
        label = "secretRare",
        text = {
            "Gains {X:chips,C:white}+ #1#{} chips when scored"
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'secretRare',
    config = {
        chipGrowthRateSelf = 5,
        chipGrowthRateOther = 2,
        chips = 5
    },
    in_shop = true,
    weight = 25,
    extra_cost = 4,
    apply_to_float = true,
    loc_vars = function(self)
        return {
            vars = {
                self.config.chipGrowthRateSelf }
        }
    end,
    sound = {
        sound = "Fox_secretRare",
        per = 1,
        vol = 0.3,
    },
    calculate = function(self, card, context)
        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            -- play_sound("Fox_secretRare", 0.95)
            sendInfoMessage("we are counting this as a played card", "secretRareOn_" .. card.label) -- .. card.base.id)
            card.ability.perma_bonus = card.ability.perma_bonus + self.config.chipGrowthRateSelf
            --self.edition.chips = self.edition.chips + 5
            if card.ability.set == 'Joker' then
                return {
                    chips = card.ability.perma_bonus,
                    colour = G.C.RED
                }
            end

            -- elseif context.cardarea == G.jokers and context.individual and context.scoring_hand then
            --     sendInfoMessage("this should be joker only", "secretRareOn_".. card.label)-- .. card.base.id)
            --     sendInfoMessage("perma bonus was: " .. card.ability.perma_bonus, "secretRare")-- .. card.base.id)
            --     card.ability.perma_bonus = card.ability.perma_bonus + #context.scoring_hand * self.config.chipGrowthRateOther

            --     sendInfoMessage("perma bonus now: " .. card.ability.perma_bonus, "secretRare")-- .. card.base.id)
        end --disabled other card played mechanic, too strong
    end
})


SMODS.Edition({ --akashic rare
    key = "akashic",
    loc_txt = {
        name = "Akashic",
        label = "akashic",
        text = {
            "Weakens then strengthens the afflicted card",
            "Applies {X:mult,C:white}x0.5{} mult to begin",
            "Increases by {c:attention}0.1{} when scored",
            '{s:0.9,C:inactive}Currently {X:mult,C:white} x#1#{}{}',
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'akashic',
    config = {
        chipGrowthRateSelf = .1,
        initialxmult = 0.4,
    },
    in_shop = true,
    weight = 20,
    extra_cost = 4,
    on_apply = function(self, card, context)
        sendInfoMessage("triggering on pickup logic for this card", self.key)
        self.ability.x_mult = 0.5
        -- self:set_edition('e_holo', false)
        -- card.cost = 10
    end,
    apply_to_float = true,
    loc_vars = function(self, info_queue, card)
        -- local thunk= inspectDepth(context)
        -- sendInfoMessage(thunk)
        if nil ~= card and nil ~= card.ability then
            return {
                vars = {
                    card.ability.x_mult }
            }
        else
            sendInfoMessage("card or card.ability was nil :(", self.key)
        end

        -- if nil ~= context and nil ~= context.ability then
        --     return {
        --         vars = {
        --             context.ability.x_mult }
        --     }
        -- end
    end,
    sound = {
        sound = "Fox_secretRare",
        per = 1,
        vol = 0.3,
    },
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            if card.ability.set ~= 'Joker' then
                -- play_sound("Fox_secretRare", 0.95)
                local t = card.base.id or card.label

                sendInfoMessage("we are counting this as a played card", "AkashicOn_" .. t) -- .. card.base.id)

                local prexXmult = card.ability.x_mult

                card.ability.x_mult = card.ability.x_mult + self.config.chipGrowthRateSelf
                sendInfoMessage("Base Card Mult was x" .. prexXmult .. " and is now x" .. card.ability.x_mult,
                    "AkashicOn_" .. t) -- .. card.base.id)
            end
        elseif context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            local t = card.base.id or card.label
            local prexXmult = card.ability.x_mult
            if card.ability.set == 'Joker' and context.post_joker then
                -- play_sound("Fox_secretRare", 0.95)
                card.ability.x_mult = card.ability.x_mult + self.config.chipGrowthRateSelf
                sendInfoMessage("Joker - Mult was x" .. prexXmult .. " and is now x" .. card.ability.x_mult, "AkashicOn_" .. t)
                
                if card.ability.x_mult < 1.0 then 
                    sendInfoMessage("Joker special case, ensuring diminuitive mult applied", "AkashicOn_" .. t)
                    return {
                        colour = G.C.RED,
                        x_mult = card.ability.x_mult
                    } -- .. card.base.id)
            end
        end

            -- if card.ability.set == 'Joker' then
            --     return {
            --         colour = G.C.RED,
            --         x_mult = card.ability.x_mult
            --     }
            -- end
            -- return {
            --     colour = G.C.RED,
            --     x_mult = card.ability.x_mult
            -- }



            -- elseif context.cardarea == G.jokers and context.individual and context.scoring_hand then
            --     sendInfoMessage("this should be joker only", "secretRareOn_".. card.label)-- .. card.base.id)
            --     sendInfoMessage("perma bonus was: " .. card.ability.perma_bonus, "secretRare")-- .. card.base.id)
            --     card.ability.perma_bonus = card.ability.perma_bonus + #context.scoring_hand * self.config.chipGrowthRateOther

            --     sendInfoMessage("perma bonus now: " .. card.ability.perma_bonus, "secretRare")-- .. card.base.id)
        end --disabled other card played mechanic, too strong
    end
})

SMODS.Enhancement({  -- grass
    key = "grass",
    name = "Grass Card",
    atlas = "FoxModMisc",
    pos = { x = 4, y = 0 },
    replace_base_card = true,
    no_suit = true,
    no_rank = true,
    always_scores = true,
    loc_txt = {
        name = "Grass Card",
        label = "Grass",
        text = {
            "Grows when held in hand",
            "Increases by {c:attention}+#2#{} when held",
            '{s:0.9,C:inactive}Currently {X:chips,C:white} +#1#{}{}',
        }
    },
    config = { extra = { h_x_chips = 5, chipsRate = 2 } },

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.h_x_chips, card.ability.extra.chipsRate }
        }
    end,

    calculate = function(self, card, context, ret)
        if context.cardarea == G.hand and context.before then
            card.ability.extra.h_x_chips = card.ability.extra.h_x_chips + card.ability.extra.chipsRate
            sendInfoMessage(
            "I am being held, currently " ..
            card.ability.extra.h_x_chips .. " and was " .. card.ability.extra.h_x_chips - card.ability.extra.chipsRate,
                "grassCard")
            return {
                chips = card.ability.extra.h_x_chips
            }
        end
        if context.cardarea == G.play and context.main_scoring then
            sendInfoMessage("I am being played", "grassCard")

            return {
                chips = card.ability.extra.h_x_chips
            }
        end
        if context.repetition then
            card.ability.extra.h_x_chips = card.ability.extra.h_x_chips + card.ability.extra.chipsRate
            sendInfoMessage(
            "I am being repeated, currently " ..
            card.ability.extra.h_x_chips .. " and was " .. card.ability.extra.h_x_chips - card.ability.extra.chipsRate,
                "grassCard")
            card:juice_up()
            return {
                chips = card.ability.extra.h_x_chips
            }
        end
        -- if context.individual then
        --     sendInfoMessage("I am individually being repeated")
        --     card.ability.extra.h_x_chips =  card.ability.extra.h_x_chips + card.ability.extra.chipsRate
        --     card:juice_up()
        -- end
    end
})

SMODS.Enhancement({
    key = "extra",
    name = "Extra Card",
    atlas = "FoxModMisc",
    pos = { x = 2, y = 1 },
    replace_base_card = true,
    no_suit = false,
    no_rank = false,
    always_scores = false,
    loc_txt = {
        name = "Extra Card",
        label = "Extra",
        text = { "Gives +30 chips and +4 mult", }
    },
    config = { perma_bonus = 30, mult = 4, x_mult = 2 }
})

-- SMODS.Enhancement({ --akashic rare
--     key = "grass",
--     loc_txt = {
--         name = "Grass card",
--         label = "Grass",
--         text = {
--             "Grows when played",
--             "Applies {X:mult,C:white}x0.5{} mult to begin",
--             "Increases by {c:attention}0.1{} when scored",
--             '{s:0.9,C:inactive}Currently {X:mult,C:white} x#1#{}{}',
--         }
--     },
--     discovered = true,
--     unlocked = true,

--     config = {
--         chipGrowthRateSelf = .1,
--         initialxmult = 0.4,
--     },
--     in_shop = true,
--     weight = 80,
--     extra_cost = 4,
--     on_apply = function(self, card, context)
--         sendInfoMessage("triggering on pickup logic for this card", self.key)
--         self.ability.x_mult = 0.5
--         -- self:set_edition('e_holo', false)
--         -- card.cost = 10
--     end,
--     apply_to_float = true,
--     loc_vars = function(self, info_queue, card)
--         -- local thunk= inspectDepth(context)
--         -- sendInfoMessage(thunk)
--         if nil ~= card and nil ~= card.ability then
--             return {
--                 vars = {
--                     card.ability.x_mult }
--             }
--         else
--             sendInfoMessage("card or card.ability was nil :(", self.key)
--         end

--         -- if nil ~= context and nil ~= context.ability then
--         --     return {
--         --         vars = {
--         --             context.ability.x_mult }
--         --     }
--         -- end
--     end,
--     sound = {
--         sound = "Fox_secretRare",
--         per = 1,
--         vol = 0.3,
--     },
--     calculate = function(self, card, context)
--         if context.main_scoring and context.cardarea == G.play then
--             if card.ability.set ~= 'Joker' then
--                 play_sound("Fox_secretRare", 0.95)
--                 local t = card.base.id or card.label

--                 sendInfoMessage("we are counting this as a played card", "AkashicOn_" .. t) -- .. card.base.id)

--                 local prexXmult = card.ability.x_mult

--                 card.ability.x_mult = card.ability.x_mult + self.config.chipGrowthRateSelf
--                 sendInfoMessage("Base Card Mult was x" .. prexXmult .. " and is now x" .. card.ability.x_mult,
--                     "AkashicOn_" .. t)                                                                                            -- .. card.base.id)
--             end
--         elseif context.post_joker or (context.main_scoring and context.cardarea == G.play) then
--             local t = card.base.id or card.label
--             local prexXmult = card.ability.x_mult
--             if card.ability.set == 'Joker' and context.post_joker then
--                 play_sound("Fox_secretRare", 0.95)
--                 card.ability.x_mult = card.ability.x_mult + self.config.chipGrowthRateSelf
--                 sendInfoMessage("Joker - Mult was x" .. prexXmult .. " and is now x" .. card.ability.x_mult,
--                     "AkashicOn_" .. t)                                                                                          -- .. card.base.id)
--             end
--             -- if card.ability.set == 'Joker' then
--             --     return {
--             --         colour = G.C.RED,
--             --         x_mult = card.ability.x_mult
--             --     }
--             -- end
--             -- return {
--             --     colour = G.C.RED,
--             --     x_mult = card.ability.x_mult
--             -- }



--             -- elseif context.cardarea == G.jokers and context.individual and context.scoring_hand then
--             --     sendInfoMessage("this should be joker only", "secretRareOn_".. card.label)-- .. card.base.id)
--             --     sendInfoMessage("perma bonus was: " .. card.ability.perma_bonus, "secretRare")-- .. card.base.id)
--             --     card.ability.perma_bonus = card.ability.perma_bonus + #context.scoring_hand * self.config.chipGrowthRateOther

--             --     sendInfoMessage("perma bonus now: " .. card.ability.perma_bonus, "secretRare")-- .. card.base.id)
--         end --disabled other card played mechanic, too strong
--     end
-- })

sendInfoMessage("Completed Processing editions", "editions.lua")

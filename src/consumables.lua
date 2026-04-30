sendInfoMessage("Processing consumables", "consumables.lua")

function flipAllCards(cards)
    local i = 0
    for _, playedCard in ipairs(cards) do
        i = i + 1
        local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                playedCard:flip(); play_sound('card1', percent);
                playedCard:juice_up(0.3, 0.3); return true
            end
        }))
    end
end

local function poll_ability(s)
    local randNo = math.random(10)
    if randNo > 1 and randNo < 5 then
        return G.P_CENTERS.m_gold
    elseif randNo > 4 and randNo < 9 then
        return G.P_CENTERS.m_steel
    else
        return G.P_CENTERS.m_glass
    end
end

local function poll_custom_editions()
    local randNo = math.random(12)
    if randNo > 0 and randNo < 4 then
        return "e_Fox_fragileRelic"
    elseif randNo > 3 and randNo < 6 then
        return "e_Fox_goldRare"
    elseif randNo > 5 and randNo < 8 then
        return "e_Fox_secretRare"
    else
        return "e_Fox_ghostRare"
    end
end

local function poll_with_custom_editions()
    local randNo = math.random(2)
    if randNo > 1 then
        local edition = poll_edition('aura', nil, true, true)
        if nil == edition then return poll_custom_editions() end
        return edition
    else
        local edition = poll_custom_editions()
        return edition
    end
end


    --region: Tarots
    SMODS.Consumable({ --Enfeeble
        set = "Tarot",
        key = "ficklefox_enfeeb",
        config = {
            maxSelected = 2
        },
        pos = {
            x = 2,
            y = 0
        },
        loc_txt = {
            name = "Enfeeble",
            text = {
                "Decreases the rank of",
                "up to {C:attention}#1#{} selected",
                "cards by {C:attention}1"
            }
        },
        loc_vars = function(self, info_queue, card)
            return { vars = { card.ability.maxSelected } }
        end,
        atlas = 'FoxModMisc',
        cost = 3,
        discovered = true,
        can_use = function(self, card)
            if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
                if #G.hand.highlighted > 1 + (card.area == G.hand and 1 or 0) then
                    return true
                else
                return false
                -- if next(SMODS.Edition:get_edition_cards(G.jokers, true)) then
                --     return true
                -- end
                end
            end
        end,
        use = function(card, area, copier)
            for i = 1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        local card = G.hand.highlighted[i]
                        local suit_prefix = string.sub(card.base.suit, 1, 1) .. '_'
                        local rank_suffix = card.base.id == 2 and 14 or math.max(card.base.id - 1, 2)

                        if rank_suffix < 10 then
                            rank_suffix = tostring(rank_suffix)
                        elseif rank_suffix == 10 then
                            rank_suffix = 'T'
                        elseif rank_suffix == 11 then
                            rank_suffix = 'J'
                        elseif rank_suffix == 12 then
                            rank_suffix = 'Q'
                        elseif rank_suffix == 13 then
                            rank_suffix = 'K'
                        elseif rank_suffix == 14 then
                            rank_suffix = 'A'
                        end
                        card:flip();
                        card:set_base(G.P_CARDS[suit_prefix .. rank_suffix])
                        return true
                    end
                }))
            end
            for i = 1, #G.hand.highlighted do
                local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(
                            0.3,
                            0.3); return true
                    end
                }))
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    G.hand:unhighlight_all(); return true
                end
            }))
            delay(0.5)
        end,
    })

    if FoxModConfig.customEditions then

    SMODS.Consumable({ --The Sword
        set = "Tarot",
        key = "ficklefox_sword",
        config = {
            maxSelected = 2
        },
        pos = {
            x = 0,
            y = 1
        },
        loc_txt = {
            name = "The Sword",
            text = {
                "Applies the legendary edition {C:dark_edition}Gold Rare{} to",
                "to {C:attention}two cards{}"
            }
        },
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue + 1] = G.P_CENTERS.e_Fox_goldRare
            return { vars = { card.ability.maxSelected } }
        end,
        atlas = 'FoxModMisc',
        cost = 4,
        discovered = true,
        can_use = function(self, card)
            if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
                if #G.hand.highlighted > 1 + (card.area == G.hand and 1 or 0) then
                    return true
                else
                return false
                -- if next(SMODS.Edition:get_edition_cards(G.jokers, true)) then
                --     return true
                -- end
                end
            end
        end,
        use = function(card, area, copier)
            for i = 1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        local card = G.hand.highlighted[i]

                        card:flip();
                        card:set_edition("e_Fox_goldRare", true)
                        -- card:set_edition('e_noire', true)
                        return true
                    end
                }))
            end
            for i = 1, #G.hand.highlighted do
                local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(
                            0.3,
                            0.3); return true
                    end
                }))
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    G.hand:unhighlight_all(); return true
                end
            }))
            delay(0.5)
        end,
    })

    SMODS.Consumable({ --The Ether
        set = "Tarot",
        key = "ficklefox_The Ether",
        config = {
            maxSelected = 2
        },
        pos = {
            x = 1,
            y = 0
        },
        loc_txt = {
            name = "Ether Overdrive",
            text = {
                "Applies the legendary edition {C:dark_edition}Ether Overdrive{}",
                "to {C:attention}two cards{}"
            }
        },
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue + 1] = G.P_CENTERS.e_Fox_fragileRelic
            return { vars = { card.ability.maxSelected } }
        end,
        atlas = 'FoxModMisc',
        cost = 3,
        discovered = true,
        can_use = function(self, card)
            if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
                if #G.hand.highlighted > 1 + (card.area == G.hand and 1 or 0) then
                    return true
                else
                return false
                -- if next(SMODS.Edition:get_edition_cards(G.jokers, true)) then
                --     return true
                -- end
                end
            end
        end,
        use = function(card, area, copier)
            for i = 1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        local card = G.hand.highlighted[i]

                        card:flip();
                        card:set_edition("e_Fox_fragileRelic", true)
                        -- card:set_edition('e_noire', true)
                        return true
                    end
                }))
            end
            for i = 1, #G.hand.highlighted do
                local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(
                            0.3,
                            0.3); return true
                    end
                }))
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    G.hand:unhighlight_all(); return true
                end
            }))
            delay(0.5)
        end,
    })

    SMODS.Consumable({ --bargain the crow / the raven
    set = "Tarot",
    key = "ficklefox_bargain",
    config = {
        maxSelected = 1
    },
    pos = {
        x = 3,
        y = 0
    },
    loc_txt = {
        name = "Bargainer",
        text = {
            "Select {C:attention}three{} cards",
            "Bargain away the first card to apply",
            "the enchantment {C:dark_edition}Secret Rare{} to the other cards"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_Fox_secretRare        
        return { vars = { card.ability.maxSelected } }
    end,
    atlas = 'FoxModMisc',
    cost = 3,
    discovered = true,
    can_use = function(self, card)
        if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
            if #G.hand.highlighted > 2 + (card.area == G.hand and 1 or 0) then
                return true
            else
            return false
            -- if next(SMODS.Edition:get_edition_cards(G.jokers, true)) then
            --     return true
            -- end
            end
        end
    end,
    use = function(card, area, copier)
        
        --handle other cards
        for i = 2, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    local card = G.hand.highlighted[i]
                    card:flip();
                    card:set_edition("e_Fox_secretRare", true)
                    -- card:set_edition('e_noire', true)
                    return true
                end
            }))
        end
        for i = 2, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(
                        0.3,
                        0.3); return true
                end
            }))
        end
        --destroy card one
        local destroyed_cards = {}
        destroyed_cards[#destroyed_cards+1] = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')                
            return true end }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function() 
                
                local card = G.hand.highlighted[1]
                if card.ability.name == 'Glass Card' then 
                    card:shatter()
                else
                    card:start_dissolve(nil, 1 == #G.hand.highlighted)
                end
                
                return true end }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all(); return true
            end
        }))
        delay(0.5)
    end,
})


SMODS.Consumable({ -- the sprout
    set = "Tarot",
    key = "ficklefox_sprout",
    config = {
        maxSelected = 1
    },
    pos = {
        x = 2,
        y = 1
    },
    loc_txt = {
        name = "The Sprout",
        text = {
            "Turns up to {C:attention}two{} cards",
            "into {C:attention}Grass{}",            
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_Fox_grass
        return { vars = { card.ability.maxSelected } }
    end,
    atlas = 'FoxModMisc',
    cost = 3,
    discovered = true,
    can_use = function(self, card)
        if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
            if #G.hand.highlighted > 2 + (card.area == G.hand and 1 or 0) then
                return true
            else
            return false
            -- if next(SMODS.Edition:get_edition_cards(G.jokers, true)) then
            --     return true
            -- end
            end
        end
    end,
    use = function(card, area, copier)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    local card = G.hand.highlighted[i]

                    card:flip();
                    card:set_ability("m_Fox_grass", true)                    
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(
                        0.3,
                        0.3); return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all(); return true
            end
        }))
        delay(0.5)
    end,
})
end --if customEdition check

SMODS.Consumable({ --Meteor Shower
set = "Spectral",
key = "ficklefox_meteorain",
pos = {
    x = 0,
    y = 0
},
loc_txt = {
    name = "Meteror Shower",
    text = {
        "Has a {C:green}#1# in #2#{} chance to improve a card",
        "Can apply {C:dark_edition}Foil{}, {C:dark_edition}Holographic{},",
        "or {C:dark_edition}Polychrome{} effect to any card held in hand",
        "will not overwrite current enhancements"
    }
},
config = {
    odds = 5,
    allHoloOdds = 10,
    extra = 1
},
loc_vars = function(self, info_queue, card)
    local safeodds = 5
    return { vars = { G.GAME.probabilities.normal, 5 } }
end,
atlas = 'FoxModMisc',
cost = 15,
discovered = true,
can_use = function(self, card)
    if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT or
        any_state then
        if next(SMODS.Edition:get_edition_cards(G.jokers, true)) then
            return true
        end
    end
end,
use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
            play_sound('tarot1')
            return true
        end
    }))
    
    local cards = G.hand.cards
    flipAllCards(cards)
    
    sendInfoMessage("Flipped all cards, need to implement adding a special boon")
    
    local boonApplied = false
    local cardsUpgradedCount = 0
    local allholoLucky = false
    delay(0.3)
    if pseudorandom('ficklefox_meteorain') < G.GAME.probabilities.normal / card.ability.allHoloOdds then
        allholoLucky = true
        card_eval_status_text(card, 'extra', nil, nil, nil,
            { message = " Oops!  All Holo!", colour = G.C.FILTER })
    end


    for i = 1, #G.hand.cards do
        if pseudorandom('ficklefox_meteorain') < G.GAME.probabilities.normal / card.ability.odds or allholoLucky then
            boonApplied = true
            cardsUpgradedCount = cardsUpgradedCount + 1
            sendInfoMessage("this card was lucky, adding a special boon")

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    local over = false
                    local edition = poll_edition('aura', nil, true, true)
                    local aura_card = G.hand.cards[i]

                    if allholoLucky then
                        sendInfoMessage("all holo lucky!", card.key)
                        aura_card:set_edition({ holo = true }, true)
                    else
                        aura_card:set_edition(edition, true)
                    end
                    -- used_tarot:juice_up(0.3, 0.5)
                    return {
                        message = { "Boon Granted" },
                        colour = G.C.FILTER,
                        card = card,
                    }
                end
            }))
        else
            sendInfoMessage("this card was unlucky, no boon")
        end
    end
    -- if self.ability.name == 'Sigil' then
    --     local _suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('sigil'))
    --     for i=1, #G.hand.cards do
    --         G.E_MANAGER:add_event(Event({func = function()
    --             local card = G.hand.cards[i]
    --             local suit_prefix = _suit..'_'
    --             local rank_suffix = card.base.id < 10 and tostring(card.base.id) or
    --                                 card.base.id == 10 and 'T' or card.base.id == 11 and 'J' or
    --                                 card.base.id == 12 and 'Q' or card.base.id == 13 and 'K' or
    --                                 card.base.id == 14 and 'A'
    --             card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
    --         return true end }))
    --     end
    -- end

    if boonApplied then
        card_eval_status_text(card, 'extra', nil, nil, nil,
            { message = cardsUpgradedCount .. " Cards Upgraded", colour = G.C.FILTER })
    else
        card_eval_status_text(card, 'extra', nil, nil, nil,
            { message = "Nope!", colour = G.C.FILTER })
    end
    for i = 1, #G.hand.cards do
        local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                G.hand.cards[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.cards[i]:juice_up(0.3, 0.3); return true
            end
        }))
    end
    delay(0.5)
    for i = 1, #G.hand.highlighted do
        local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(
                    0.3,
                    0.3); return true
            end
        }))
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
            G.hand:unhighlight_all(); return true
        end
    }))
    delay(0.5)
end
})

SMODS.Consumable({ --Coating Polymerization
        set = "Spectral",
        key = "ficklefox_coating",
        pos = {
            x = 3,
            y = 1
        },
        loc_txt = {
            name = "Coating",
            text = {
                "Has a {C:green}#1# in #2#{} chance to improve a card",
                "Can apply {C:dark_edition}Gold{}, {C:dark_edition}Steel{},",
                "or {C:dark_edition}Glass{} effect to any card held in hand",
                "will not overwrite current enhancements"
            }
        },
        config = {
            odds = 2,
            allHoloOdds = 10,
            --extra = 1,
            extra={odds=1}

        },
        loc_vars = function(self, info_queue, card)
            local safeodds = 5
            return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds } }

            -- return { vars = { G.GAME.probabilities.normal, 5 } }
        end,
        atlas = 'FoxModMisc',
        cost = 15,
        discovered = true,
        can_use = function(self, card)
            if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
                return true
                -- if next(SMODS.Edition:get_edition_cards(G.jokers, true)) then
                --     return true
                -- end
            end
        end,
        use = function(self, card, area, copier)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('tarot1')
                    return true
                end
            }))
            for i = 1, #G.hand.cards do
                local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip(); play_sound('card1', percent); G.hand.cards[i]:juice_up(0.3, 0.3); return true
                    end
                }))
            end
            sendInfoMessage("Flipped all cards, need to implement adding a special boon")
            local boonApplied = false
            local cardsUpgradedCount = 0
            local allholoLucky = false
            delay(0.3)
            if pseudorandom('ficklefox_meteorain') < G.GAME.probabilities.normal / card.ability.allHoloOdds then
                allholoLucky = true
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = " Oops!  All Holo!", colour = G.C.FILTER })
            end


            for i = 1, #G.hand.cards do
                if pseudorandom('ficklefox_meteorain') < G.GAME.probabilities.normal / card.ability.odds or allholoLucky then
                    boonApplied = true
                    cardsUpgradedCount = cardsUpgradedCount + 1
                    sendInfoMessage("this card was lucky, adding a special boon")
                    local over = false
                    local edition = poll_edition('aura', nil, true, true)
                    local aura_card = G.hand.cards[i]
                    if allholoLucky then
                        sendInfoMessage("all gold lucky!", card.key)
                        aura_card:set_ability(G.P_CENTERS.m_gold, nil, true)
                        -- aura_card:set_edition({ holo = true }, true)
                    else
                        local ability = poll_ability(aura_card, nil, true)
                        aura_card:set_ability(G.P_CENTERS.m_gold, nil, true)
                    end

                    aura_card:juice_up()

                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            return {
                                message = { "Boon Granted" },
                                colour = G.C.FILTER,
                                card = card,
                            }
                        end
                    }))
                else
                    sendInfoMessage("this card was unlucky, no boon")
                end
            end
            if boonApplied then
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = cardsUpgradedCount .. " Cards Upgraded", colour = G.C.FILTER })
            else
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = "Nope!", colour = G.C.FILTER })
            end
            for i = 1, #G.hand.cards do
                local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.cards[i]:juice_up(0.3, 0.3); return true
                    end
                }))
            end
            delay(0.5)
            for i = 1, #G.hand.highlighted do
                local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.highlighted[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.highlighted[i]:juice_up(
                            0.3,
                            0.3); return true
                    end
                }))
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    G.hand:unhighlight_all(); return true
                end
            }))
            delay(0.5)
        end
    })

    SMODS.Voucher({ --+1 card slot[s] and +1 booster pack slot[s] available in the shop	
        key = "fourfingerfox",
        config = { extra = 1 },
        atlas = "FoxModVouchers",
        order = 1,
        pos = { x = 0, y = 0 },
        loc_txt = {
            name = "Four fingered Voucher",
            text = {
                "Grants {C:attention}1{} {C:edition}Negative{} {C:attention}Four fingered Joker{}"
            },
        },
        redeem = function(self)
            --add negative four fingers joker
            local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_four_fingers")
            card:set_edition('e_negative', false)
            card:add_to_deck()
            G.jokers:emplace(card)
        end
    })

    SMODS.Consumable {
        object_type = "Consumable",
        set = "Planet",
        name = "Meteor",
        key = "Meteor",
        pos = { x = 1, y = 1 },
        config = { hand_type = "Fox_cosmocanyon"  },
        cost = 4,
        atlas = "FoxModMisc",
        order = 3,
    
        can_use = function(self, card)
            return true
        end,
    
        loc_txt = {
            name = "Cosmo Canyon",
            text = {
                "Level {C:attention}#1#{}",
                "Levels up the {C:attention}Cosmo Canyon{} hand",
                "{C:mult}+#2#{} Mult and",
                "{C:chips}+#3#{} Chips"
            }
        },
    
        loc_vars = function(self, info_queue, center)
            local hand_name = "Fox_cosmocanyon"
            local hand = G.GAME.hands[hand_name]
            local level = hand and hand.level or 1
            local mult = 2  -- Default mult increase
            local chips = 15 -- Default chips increase
    
            return { vars = { level, mult, chips } }
        end,
    
        use = function(self, card, area, copier)
            if self.config.hand_type and G.GAME.hands[self.config.hand_type] then
                local hand_name = self.config.hand_type
    
                -- **Show old values before level-up**
                update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
                    {
                        handname = localize(hand_name, 'poker_hands'),
                        chips = G.GAME.hands[hand_name].chips,
                        mult = G.GAME.hands[hand_name].mult,
                        level = G.GAME.hands[hand_name].level
                    }
                )
    
                -- **Apply the level-up**
                level_up_hand(card, hand_name)
    
                -- **Show new values after level-up**
                update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0.6 },
                    {
                        handname = localize(hand_name, 'poker_hands'),
                        chips = G.GAME.hands[hand_name].chips,
                        mult = G.GAME.hands[hand_name].mult,
                        level = G.GAME.hands[hand_name].level
                    }
                )
    
                -- **Reset UI immediately after**
                update_hand_text({ sound = 'button', volume = 0.5, pitch = 1.0, delay = 1.5 },
                    { mult = 0, chips = 0, handname = '', level = '' }
                )
            else
                print("Cosmo Canyon hand NOT found in G.GAME.hands!")
            end
        end,
    
        -- Only in shop if the Cosmo Canyon hand is visible
        in_pool = function(self)
            local hand_name = self.config.hand_type
            return G.GAME.hands[hand_name] and G.GAME.hands[hand_name].visible
        end,
    
        keep_on_use = function(self, card)
            return false
        end
    }

    SMODS.Consumable({--fullmoon
        object_type = "Consumable",
        set = "Planet",
        name = "Full Moon",
        key = "fullmoon",
        pos = { x = 0, y = 2 },
        config = { hand_type =  "Fox_fullmoon" },
        loc_txt = {
            name = "Full Moon",
            text = {
                "Level {C:attention}#1#{}",
                "Levels up the {C:attention}Full Moon{} hand",
                "{C:mult}+2{} Mult and",
                "{C:chips}+16{} chips",
            },
        },
        cost = 4,
        atlas = "FoxModMisc",
        order = 3,
        can_use = function(self, card)
            return true
        end,
        loc_vars = function(self, info_queue, center)
            local hand_name = self.config.hand_type
            return {                
                vars = {                    
                    G.GAME.hands[hand_name].level
                },
            }
        end,
        use = function(self, card, area, copier)
            local hand_name = card.ability.hand_type
    
            if G.GAME.hands[hand_name] then
                local hand_data = G.GAME.hands[hand_name]
    
                update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
                    {
                        handname = localize(hand_name, 'poker_hands'),
                        chips = hand_data.chips,
                        mult = hand_data.mult,
                        level = hand_data.level
                    }
                )
    
                level_up_hand(card, hand_name)
    
                update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
                    { mult = 0, chips = 0, handname = '', level = '' }
                )
            else
                print(card.ability.hand_type .. " NOT found in G.GAME.hands!")
            end
        end,
           -- Only in shop if the cosmo canyon  hand is visible
        in_pool = function(self)
            local hand_name = self.config.hand_type
            return G.GAME.hands[hand_name] and G.GAME.hands[hand_name].visible
        end
    })

    SMODS.Consumable(        
    {--shun goku satsu
    
    object_type = "Consumable",
    set = "Planet",
    name = "Shun Goku Satsu",
    key = "Shun Goku Satsu",
    pos = { x = 4, y = 1 },
    config = { hand_type = "Fox_shungokusatsu" },
    loc_txt = {
        name = "Shun Goku Satsu",
        text = {
            "Level {C:attention}#1#{}",
            "Levels up the {C:attention}Shun Goku Satsu{} hand",
            "{C:chips}+15{} chips and",
            "{C:edition_negative}+1{} Retriggers when equipped with an A Kuma Joker",
            
        },
    },
    cost = 4,
    atlas = "FoxModMisc",
    order = 3,
    can_use = function(self, card)
        return true
    end,
    loc_vars = function(self, info_queue, center)
        local hand_name = self.config.hand_type
        return {                
            vars = {                    
                G.GAME.hands[hand_name].level
            },
        }
    end,
    loc_vars = function(self, info_queue, center)
        local hand = G.GAME.hands[hand_name]
        local hand_name = hand
        local level = hand and hand.level or 1
        local mult = 0  -- Default mult increase
        local chips = 15 -- Default chips increase

        return { vars = { level, mult, chips } }
    end,

    use = function(self, card, area, copier)
        if self.config.hand_type and G.GAME.hands[self.config.hand_type] then
            local hand_name = self.config.hand_type

            -- **Show old values before level-up**
            update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
                {
                    handname = localize(hand_name, 'poker_hands'),
                    chips = G.GAME.hands[hand_name].chips,
                    mult = G.GAME.hands[hand_name].mult,
                    level = G.GAME.hands[hand_name].level
                }
            )

            -- **Apply the level-up**
            level_up_hand(card, hand_name)

            -- **Show new values after level-up**
            update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0.6 },
                {
                    handname = localize(hand_name, 'poker_hands'),
                    chips = G.GAME.hands[hand_name].chips,
                    mult = G.GAME.hands[hand_name].mult,
                    level = G.GAME.hands[hand_name].level
                }
            )

            -- **Reset UI immediately after**
            update_hand_text({ sound = 'button', volume = 0.5, pitch = 1.0, delay = 1.5 },
                { mult = 0, chips = 0, handname = '', level = '' }
            )
        else
            print("Shun Goku Satsu hand NOT found in G.GAME.hands!")
        end
    end,

    -- Only in shop if the Cosmo Canyon hand is visible
    in_pool = function(self)
        local hand_name = self.config.hand_type
        return G.GAME.hands[hand_name] and G.GAME.hands[hand_name].visible
    end,

    keep_on_use = function(self, card)
        return false
    end
})


sendInfoMessage("Completed Processing consumables", "consumables.lua")
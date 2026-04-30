-- git tag -a 0.3 -m "BETA now with more bug fixing!" master
-- git push --tags

-- format_ui_value(
-- #G.GAME.hands["Fox_shungokusatsu"].level

-- tonumber(format_ui_value(G.GAME.hands["Fox_shungokusatsu"].level))
-- function flipAllCards(cards)
--     for _, playedCard in ipairs(cards) do
--         local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
--         G.E_MANAGER:add_event(Event({
--             trigger = 'after',
--             delay = 0.15,
--             func = function()
--                 playedCard:flip(); play_sound('card1', percent); 
--                 playedCard:juice_up(0.3, 0.3); return true
--             end
--         }))
--     end
-- end

-- function applyBoonWithOdds(cards)
--     for _, playedCard in ipairs(cards) do
--         if pseudorandom('ficklefox_moogle') < G.GAME.probabilities.normal / card.ability.odds then
--             boonApplied = true
--             sendInfoMessage("this card was lucky, adding a special boon")

--             G.E_MANAGER:add_event(Event({
--                 trigger = 'after',
--                 delay = 0.4,
--                 func = function()
--                     local over = false
--                     local edition = poll_edition('aura', nil, true, true)
--                     playedCard:set_edition(edition, true)
                    
--                     -- used_tarot:juice_up(0.3, 0.5)
--                     return {
--                         message = { "Boon Granted" },
--                         colour = G.C.FILTER,
--                         card = playedCard,
--                     }
--                 end
--             }))
--         else
--             sendInfoMessage("this card was unlucky, no boon")
--         end
--     end
-- end



    -- flipAllCards(cards)

    -- sendInfoMessage("Flipped all cards, need to implement adding a special boon")

    -- delay(0.3)
    -- applyBoonWithOdds(odds, cards)
    
    -- flipAllCards(cards)
    
    -- delay(0.5)

    -- G.hand.highlighted

    -- G.jokers.highlighted[1].config.loc_vars

--@Winter, credit example
--     `info_queue[#info_queue+1] = {key = "csau_artistcredit", set = "Other", vars = { G.csau_team.gote }}
-- The localization string is this, under descriptions.Other
-- csau_artistcredit = {
--     name = "Artist",
--     text = {
--         "{E:1}#1#{}"
--     },
-- },
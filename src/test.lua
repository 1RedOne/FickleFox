FoxMod.GetHighlightedInfo = function() for k, v in pairs(G.hand.highlighted) do
    --print(inspect(v))
     local cardInfo = (v.base.suit:sub(1, 1) or 'D') .. v.base.id or 11
    print(cardInfo .. " my unique id is " .. v.ID)
    end
 end

 local enableTest = false
 if enableTest then
SMODS.Joker { --Pair Pear
    name = "Mult Joker",
    key = "testJoker",
    config = {
        chips = 1.0,
        pairChipGrowth = 2,
        threeChipGrowth = 3,
        fourChipGrowth = 4,
        fiveChipGrowth = 5
    },
    loc_txt = {
        ['name'] = 'Mult Joker',
        ['text'] = {
            'Gives mult equal to the current amount of money held',
            "{C:inactive}Currently + #1#s{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { format_ui_value(G.GAME.dollars)or 0 } }
    end,
    pos = {
        x = 7,
        y = 2
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = tonumber(format_ui_value(G.GAME.dollars)) or 0,
                card = card
            }
        end
    end
}

end
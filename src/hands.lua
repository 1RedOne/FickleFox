sendInfoMessage("Processing hands", "hands.lua")
FoxMod.PokerHandDummies = {}

FoxMod.PokerHandDummy = SMODS.Center:extend {
    set = 'FoxPokerHand',
    obj_buffer = {},
    obj_table = FoxMod.PokerHandDummies,
    class_prefix = 'phd',
    required_params = {
        'key',
    },
    pre_inject_class = function(self)
        G.P_CENTER_POOLS[self.set] = {}
    end,
    inject = function(self)
        SMODS.Center.inject(self)
    end,
    get_obj = function(self, key)
        if key == nil then
            return nil
        end
        return self.obj_table[key]
    end
}

SMODS.PokerHand({
    key = "cosmocanyon",
    chips = 40,
    mult = 5,
    l_chips = 15,
    l_mult = 2,
    visible = false,
    example = {        
        { 'S_3', true},
        { 'H_8', true},
        { 'C_2', true},
    },
    loc_txt = {
        name = "Cosmo Canyon",
        text = {
            "3 or more cards divisble by {C:attention}XIII{}",
        },
        description = {
            "3 or more cards divisble by XIII",
            "The ancestral home of Nanaki and those like him"
        }
    },
    evaluate = function(parts, hand)
        if next(SMODS.find_card("j_Fox_redxiii")) then
            if #hand > 2 then
            local counted = 0
                for _, card in ipairs(hand) do
                    counted = counted + card.base.id
                end
                -- sendInfoMessage("Hand was played, checking value " .. counted, "cosmo")
                if counted % 13 == 0 then
                    return { hand }
                end
            end
        end
        return {}
    end
})

SMODS.PokerHand({ --torgal
    key = "fullmoon",
    chips = 50,
    mult = 5,
    l_chips = 16,
    l_mult = 2,
    visible = false,
    example = {        
        { 'S_6', true},
        { 'H_5', true},
        { 'C_6', true},
    },
    loc_txt = {
        name = "Full Moon",
        text = {
            "3 or more cards divisble by {C:attention}XVI{}",
        },
        description = {
            "3 or more cards divisble by XVI",
            "The frost wolf is a loyal companion, devestating in battle"
        }
    },
    evaluate = function(parts, hand)
        if next(SMODS.find_card("j_Fox_torgal")) then
            if #hand > 2 then 
            local counted = 0
                for _, card in ipairs(hand) do
                    counted = counted + card.base.id
                end
                -- sendInfoMessage("Hand was played, checking value " .. counted, "cosmo")
                if counted % 16 == 0 then
                    return { hand }
                end
            end
        end
        return {}
    end
})

SMODS.PokerHand({ --Shun Goku Satsu
    key = "shungokusatsu",
    chips = 50,
    mult = 15,
    l_chips = 15,
    l_mult = 0,
    visible = false,
    above_hand =  "Flush Five" ,
    example = {        
        { 'S_T', true},
        { 'H_T', true},
        { 'C_T', true},
        { 'H_T', true},
        { 'H_3', false}
    },
    loc_txt = {
        name = "Shun Goku Satsu",
        text = {
            "4 or more cards of rank {C:attention}10{}",
        },
        description = {
            "4 or more cards of rank 10",
        }
    },
    evaluate = function(parts, hand)
        if next(SMODS.find_card("j_Fox_akuma")) then
            local counted = 0
            if next(parts._5) or next(parts._4) then
                for _, card in ipairs(hand) do
                    if card.base.id == 10 or card.base.id == "10" then
                        counted = counted + 1
                    end                
                end
            end

            if counted > 3 then
                -- play_sound("Fox_akumaClear", 1)
                return {hand}
            end
        end
        return {}
    end
})


-- FoxMod.PokerHandDummy {
--     key = "Shun Goku Satsu",
--     generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
--         SMODS.Center.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
--         if desc_nodes ~= full_UI_table.main then
--             local cards = {}
--             local card_w = G.CARD_W * 0.6
--             local card_h = G.CARD_H * 0.6            
--             table.insert(cards, Card(0, 0, card_w, card_h, G.P_CARDS['S_10'], G.P_CENTERS.m_gold))
--             table.insert(cards, Card(0, 0, card_w, card_h, G.P_CARDS['H_10'], G.P_CENTERS.m_steel))
--             table.insert(cards, Card(0, 0, card_w, card_h, G.P_CARDS['C_10']))
--             table.insert(cards, Card(0, 0, card_w, card_h, G.P_CARDS['H_10'], G.P_CENTERS.m_steel))            
            
--             G.joy_dummy_area = CardArea(
--                 0, 0,
--                 4.25 * card_w,
--                 0.95 * card_h,
--                 { card_limit = 5, type = 'title', highlight_limit = 0, collection = true }
--             )

--             for i, p_card in ipairs(cards) do
--                 G.joy_dummy_area:emplace(p_card)
--             end

--             desc_nodes[#desc_nodes + 1] = {
--                 {
--                     n = G.UIT.B,
--                     config = { w = 0, h = 0.1 },
--                 },
--             }

--             desc_nodes[#desc_nodes + 1] = {
--                 {
--                     n = G.UIT.R,
--                     config = { align = "cm", padding = 0.07, no_fill = true },
--                     nodes = {
--                         { n = G.UIT.O, config = { object = G.joy_dummy_area } }
--                     }
--                 },
--             }
--         end
--     end,
-- }
sendInfoMessage("Completed processing hands", "hands.lua")
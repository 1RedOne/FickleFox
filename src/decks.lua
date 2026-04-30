function StartsWith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

local function setContains(set, key)
    return set[key] ~= nil
end

local function poll_custom_editions()
    local editions = {
        "e_Fox_fragileRelic",
        "e_Fox_ghostRare",
        "e_Fox_secretRare",
        "e_Fox_akashic",
        "e_Fox_goldRare"
    }
    return editions[math.random(#editions)]
end

local function poll_with_custom_editions()
    if FoxModConfig.customEditions then 
        local randNo = math.random(2)
        if randNo > 1 then
            local edition = poll_edition('aura', nil, true, true)
            if nil == edition then return poll_custom_editions() end
            return edition
        else
            local edition = poll_custom_editions()
            return edition
        end
    else
        local edition = poll_edition('aura', nil, true, true)
        return edition
    end
end


local function getResourceWithPrefix(s)
    local results = {}
    for k, v in pairs(G.P_CENTERS) do
        if StartsWith(k, s) then
            print(k)
            table.insert(results, k)
        end
    end
    return results
end

local function getFoxJokers()
    --print("getting a random fox joker")
    local allFoxJokers = getResourceWithPrefix("j_Fox")
    return allFoxJokers
end

-- SMODS.Back{
--     name = "Absolute Deck",
--     key = "absolute",
--     pos = {x = 0, y = 3},
--     config = {polyglass = true},
--     loc_txt = {
--         name = "Absolute Deck",
--         text ={
--             "Start with a Deck",
--             "full of {C:attention,T:e_polychrome}Poly{}{C:red,T:m_glass}glass{} cards"
--         },
--     },
--     apply = function()
--         G.E_MANAGER:add_event(Event({
--             func = function()
--                 for i = #G.playing_cards, 1, -1 do
--                     G.playing_cards[i]:set_ability(G.P_CENTERS.m_glass)
--                     G.playing_cards[i]:set_edition({
--                         polychrome = true
--                     }, true, true)
--                 end
--                 return true
--             end
--         }))
--     end
-- }

SMODS.Back { --Maximum Gold
    name = "Maximum Gold Deck",
    key = "maximumGold",
    atlas = "FoxModDecks",
    unlocked = false,
    pos = { x = 4, y = 0 },
    config = { polyglass = true },
    loc_txt = {
        name = "Maximum Gold Deck",
        text = {
            "Start with a Deck",
            "full of {C:attention,T:m_gold}Gold{} cards",
            "and matching jokers"
        },
        unlock = {
            "Play an All-Gold Hand",
            "Of three or more",
            "{C:attention,T:m_gold}Gold{} cards"
        }
    },
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local tally = 0
            for j = 1, #args.cards do
                if args.cards[j].config.center == G.P_CENTERS.m_gold then
                    tally = tally + 1
                end
            end
            if tally >= 3 then
                unlock_card(self)
            end
        end
    end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.jokers then
                    --spawn eldlich and gold joker
                    local jokers = getFoxJokers()
                    
                    SMODS.add_card({ key = "j_Fox_LordOfGold" }) --, edition = "e_Fox_secretRare"})
                    SMODS.add_card({ key = "j_golden" })      --
                    SMODS.add_card({ key = "j_ticket" })      --
                    SMODS.add_card({ key = "j_Fox_goldretriever" }) --
                    SMODS.add_card({ key = jokers[1] }) --

                    return true
                end
            end,
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    G.playing_cards[i]:set_ability(G.P_CENTERS.m_gold, nil, true)
                end
                return true
            end
        }))
    end,
    init = function(self)
        SMODS.Edition:take_ownership("m_gold", {
            get_weight = function(self)
                return 90
            end,
        }, true)
    end
}

if FoxModConfig.customEditions then
    SMODS.Back { --Maximum Grass Rare
        name = "Maximum Grass Deck",
        key = "maximumGrass",
        atlas = "FoxModDecks",
        unlocked = false,
        pos = { x = 3, y = 0 },
        config = { polyglass = true },
        loc_txt = {
            name = "Maximum Grass Deck",
            text = {
                "Start with a Deck",
                "full of {C:attention,T:m_Fox_grass}Grass{} cards",
                "and matching jokers"
            },
            unlock = {
                "Win a round with",
                "all Grass Jokers in a single run"
            }
        },
        check_for_unlock = function(self, args)
            if args.type == 'round_win' then
                if G.P_CENTERS["j_Fox_gumoss"].discovered
                    and G.P_CENTERS["j_Fox_mammorest"].discovered
                    and G.P_CENTERS["j_Fox_teafant"].discovered then
                    unlock_card(self)
                end
            end
        end,
        apply = function(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.jokers then
                        SMODS.add_card({ key = "j_Fox_mammorest" })
                        SMODS.add_card({ key = "j_Fox_gumoss" })
                        return true
                    end
                end,
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = #G.playing_cards, 1, -1 do                                                
                        G.playing_cards[i]:set_ability("m_Fox_grass", true, true)
                    end
                    return true
                end
            }))
        end,
        init = function(self)
            SMODS.Edition:take_ownership("m_Fox_grass", {
                get_weight = function(self)
                    return 90
                end,
            }, true)
        end
    }

    SMODS.Back { --Gold Rare
        name = "Gold Rare Deck",
        key = "goldDeck",
        atlas = "FoxModDecks",
        pos = { x = 5, y = 0 },
        config = { polyglass = true },
        unlocked = false;
        loc_txt = {
            name = "Gold Rare Deck",
            text = {
                "Start with a Deck",
                "full of {C:attention,T:e_Fox_goldRare}Gold Rare{} cards"
            },
            unlock = {
                "Play a hand with",
                "Two or more ",
                "{C:attention,T:e_Fox_goldRare}Gold Rare{} cards"
            },
        },
        check_for_unlock = function(self, args)
            if args.type == 'hand_contents' then
                local tally = 0                
                for j = 1, #args.cards do
                    if args.cards[j].edition and args.cards[j].edition.key == "e_Fox_goldRare" then
                        tally = tally + 1
                        print("tally up")
                    end
                    print("checked for unlock")
                    --print ("card had center of " .. args.cards[j].config.center)
                end 
                if tally >= 2 then
                   unlock_card(self)
                end
            end
        end,
        apply = function(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.jokers then
                        --spawn eldlich and gold joker
                        SMODS.add_card({ key = "j_Fox_LordOfGold" }) --, edition = "e_Fox_secretRare"})
                        SMODS.add_card({ key = "j_ticket" })  --
                        SMODS.add_card({ key = "j_Fox_goldretriever" }) --

                        return true
                    end
                end,
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = #G.playing_cards, 1, -1 do
                        -- G.playing_cards[i]:set_ability(G.P_CENTERS.m_glass)
                        -- ("e_Fox_ghostRare", true)
                        G.playing_cards[i]:set_edition("e_Fox_goldRare", true, true)
                    end
                    return true
                end
            }))
        end,
        init = function(self)
            SMODS.Edition:take_ownership("e_Fox_goldRare", {
                get_weight = function(self)
                    return 90
                end,
            }, true)
        end
    }

    SMODS.Back { --ghost rare
        name = "Ghost Rare Deck",
        key = "GhostRareDeck",
        atlas = "FoxModDecks",
        pos = { x = 2, y = 0 },
        config = { polyglass = true },
        loc_txt = {
            name = "Ghost Rare Deck",
            text = {
                "Start with a Deck",
                "full of {C:attention,T:e_Fox_ghostRare}Ghost Rare{} cards"
            },
        },
        apply = function(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.add_card({ key = "j_hiker", edition = "e_Fox_secretRare" })
                    if G.jokers then
                        local card = create_card("Joker", G.jokers, nil, nil, true, true, nil, "foxsecretRare")
                        card:set_edition("e_Fox_ghostRare", true, true)
                        card:add_to_deck()
                        card:start_materialize()
                        G.jokers:emplace(card)
                        return true
                    end
                end,
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = #G.playing_cards, 1, -1 do
                        -- G.playing_cards[i]:set_ability(G.P_CENTERS.m_glass)
                        -- ("e_Fox_ghostRare", true)
                        G.playing_cards[i]:set_edition("e_Fox_ghostRare", true, true)
                    end
                    return true
                end
            }))
        end,
        init = function(self)
            SMODS.Edition:take_ownership("e_Fox_ghostRare", {
                get_weight = function(self)
                    return 95
                end,
            }, true)
        end
    }

    SMODS.Back { --secret rare
        name = "Secret Rare Deck", --secret rare deck",
        key = "secretRareDeck",
        atlas = "FoxModDecks",
        unlocked = false,
        pos = { x = 1, y = 0 },
        config = { polyglass = true },
        loc_txt = {
            name = "Secret Rare Deck",
            text = {
                "Start with a Deck",
                "full of {C:attention,T:e_Fox_secretRare}Secret Rare{} cards",
                "and two random supporting jokers"
            },
            ["unlock"] = {
                "Play a hand with",
                "Two or more {C:attention,T:e_Fox_secretRare}Secret Rare{} Cards",
                "While also holding The Hiker"
            }
        },
        check_for_unlock = function(self, args)
            if args.type == 'hand_contents' then
                local tally = 0
                for j = 1, #args.cards do                    
                    if args.cards[j].edition and args.cards[j].edition.key == "e_Fox_secretRare" then
                        tally = tally + 1
                        print("tally up")
                    end
                    print("checked for unlock")
                    --print ("card had center of " .. args.cards[j].config.center)
                end 
                if tally >= 2 then
                    if next(SMODS.find_card("j_hiker")) then
                        unlock_card(self)
                    end
                end
            end
        end,
        apply = function(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.jokers then
                        SMODS.add_card({ key = "j_hiker", edition = "e_Fox_secretRare" })
                        local card = create_card("Joker", G.jokers, nil, nil, true, true, nil, "foxsecretRare")
                        card:set_edition("e_Fox_secretRare", true, true)
                        card:add_to_deck()
                        card:start_materialize()
                        G.jokers:emplace(card)
                        return true
                    end
                end,
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = #G.playing_cards, 1, -1 do
                        -- G.playing_cards[i]:set_ability(G.P_CENTERS.m_glass)
                        -- ("e_Fox_ghostRare", true)
                        G.playing_cards[i]:set_edition("e_Fox_secretRare", true, true)
                    end
                    return true
                end
            }))
        end,
        init = function(self)
            SMODS.Edition:take_ownership("e_Fox_secretRare", {
                get_weight = function(self)
                    return 90
                end,
            }, true)
        end
    }



    SMODS.Back { --akashic
        name = "Akashic Deck",
        key = "akashic",
        atlas = "FoxModDecks",
        pos = { x = 2, y = 0 },
        config = { polyglass = true },
        loc_txt = {
            name = "Akashic Deck",
            text = {
                "Start with a Deck",
                "full of {C:attention,T:e_Fox_akashic}Akashic{} cards",
                "and a random starter joker"
            },
        },
        apply = function(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.jokers then
                        local card = create_card("Joker", G.jokers, nil, nil, true, true, nil, "foxakashic")
                        card:set_edition("e_Fox_akashic", true, true)
                        card:add_to_deck()
                        card:start_materialize()
                        G.jokers:emplace(card)
                        return true
                    end
                end,
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = #G.playing_cards, 1, -1 do
                        -- G.playing_cards[i]:set_ability(G.P_CENTERS.m_glass)
                        -- ("e_Fox_ghostRare", true)
                        G.playing_cards[i]:set_edition("e_Fox_akashic", true, true)
                    end
                    return true
                end
            }))
        end,
        init = function(self)
            SMODS.Edition:take_ownership("e_Fox_akashic", {
                get_weight = function(self)
                    return 90
                end,
            }, true)
        end
    }


    SMODS.Back { --ghost rare
        name = "Rarity Collection Deck",
        key = "RarityCollectionDeck",
        atlas = "FoxModDecks",
        pos = { x = 0, y = 0 },
        unlocked = false,
        loc_txt = {
            name = "Rarity Collection Deck",
            text = {
                "Start with a Deck",
                "full of {C:dark_edition}Special Edition{} cards"
            },
            unlock = {
                "Win a round with",
                "having 10 or more special",
                "edition cards"
            }
        },
        check_for_unlock = function(self, args)
            local editionsWeCareAbout = {
                G.P_CENTERS.m_glass,
                G.P_CENTERS.m_steel,
                G.P_CENTERS.e_foil,
                G.P_CENTERS.e_holo,
                G.P_CENTERS.e_polychrome,
                G.P_CENTERS.e_Fox_fragileRelic,
                G.P_CENTERS.e_Fox_ghostRare,
                G.P_CENTERS.e_Fox_goldRare,
                G.P_CENTERS.e_Fox_secretRare
            }

            local editionTally = 0
            if args.type == 'hand_contents' then                
                for _, card in ipairs(G.playing_cards) do
                    if card.edition ~= nil then
                        editionTally = editionTally + 1
                    end
                end
            end
            --print ("observered special edition card count of " ..editionTally)
            if editionTally > 9 then
                unlock_card(self) 
            end
        end,

        apply = function(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    SMODS.add_card({ key = "j_hiker", edition = "e_Fox_secretRare" })
                    if G.jokers then
                        local card = create_card("Joker", G.jokers, nil, nil, true, true, nil, "foxsecretRare")
                        card:set_edition("e_Fox_ghostRare", true, true)
                        card:add_to_deck()
                        card:start_materialize()
                        G.jokers:emplace(card)
                        return true
                    end
                end,
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = #G.playing_cards, 1, -1 do
                        -- G.playing_cards[i]:set_ability(G.P_CENTERS.m_glass)
                        -- ("e_Fox_ghostRare", true)
                        local edition = poll_with_custom_editions()


                        G.playing_cards[i]:set_edition(edition, true, true)
                    end
                    return true
                end
            }))
        end,
        init = function(self)
            SMODS.Edition:take_ownership("e_Fox_ghostRare", {
                get_weight = function(self)
                    return 95
                end,
            }, true)
        end
    }
end

local insanityText = {
    "Start with certain fun",
    "Fickle Fox Joker",
    "and a full set of",
    "{C:dark_edition}Special Edition{} cards"
}

if FoxModConfig.moreMystery then
    insanityText = {
        "Start with every",
        "Fickle Fox Joker",
        "and a full set of ",
        "{C:dark_edition}Special Edition{} cards"
    }
end

SMODS.Back { --Insanity Deck
    name = "Party Collection Deck",
    key = "InsanityDeck",
    atlas = "FoxModDecks",
    pos = { x = 5, y = 0 },
    unlocked = false,
    loc_txt = {
        name = "Insanity Deck",
        text = insanityText,
        unlock = {
            "Level both Legendary",
            "Fickle Fox Jokers",
            "to their maximum"
        }
    },
    check_for_unlock = function(self, args)
        if next(SMODS.find_card("j_Fox_joku")) then
            if next(SMODS.find_card("j_Fox_kirbo")) then

                local joku  = SMODS.find_card("j_Fox_joku")
                local kirbo = SMODS.find_card("j_Fox_kirbo")

                if joku[1].ability.legendaryUnlock then
                    if kirbo[1].ability.legendaryUnlock then
                        print("Unlocking Insanity")
                        unlock_card(self)
                    end                
                end
            end
        end
    end,

    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local needToSetup = false                
                if G.GAME.haveRunSetup == nil then
                    G.GAME.haveRunSetup = true
                    needToSetup = true
                    print("need to setup")
                else
                    print("setup already done")
                end
                if G.jokers and needToSetup then
                    if FoxModConfig.moreMystery then 
                        -- SMODS.add_card({ key = "j_hiker", edition = "e_Fox_secretRare" })
                        local jokers = getFoxJokers()
                        print ("found " .. #jokers)
                        
                        for index = 1, #jokers / 2, 1 do
                            local thisJoker = jokers[index]
                            print ("Adding joker index " .. index .. " who is " .. thisJoker)
                            local percent = 0.85 + (index - 0.999) / (#jokers - 0.998) * 0.3
                            delay(0.3)
                                local edition = poll_with_custom_editions()
                                SMODS.add_card({ key = thisJoker, edition = edition })
                            print ("added " .. thisJoker)
                        end
                        -- for index, thisJoker in ipairs(jokers) do
                            
                        -- end
                        return true
                    else
                        local jokers = {"j_blueprint", "j_Fox_cam", "j_Fox_ficklefox", "j_Fox_benevolence"}

                        for index = 1, #jokers, 1 do
                            local thisJoker = jokers[index]
                            print("adding " .. thisJoker)

                            if thisJoker == "j_Fox_cam" then 
                                SMODS.add_card({ key = thisJoker})
                            else
                                SMODS.add_card({ key = thisJoker, edition= "e_negative" })
                            end
                                                        
                        end
                        return true
                    end
            end
        end,
        }))
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    -- G.playing_cards[i]:set_ability(G.P_CENTERS.m_glass)
                    -- ("e_Fox_ghostRare", true)
                    local edition = poll_with_custom_editions()


                    G.playing_cards[i]:set_edition(edition, true, true)
                end
                return true
            end
        }))
    end,
    init = function(self)
        SMODS.Edition:take_ownership("e_Fox_ghostRare", {
            get_weight = function(self)
                return 95
            end,
        }, true)
    end
}


if FoxModConfig.animatedSpecialDecks then
    
    SMODS.DrawStep({
        key = "editiondecks",
        order = 5,
        func = function(self)

            local deckToShaderTable = {
                {
                    deckName = "b_Fox_goldDeck",
                    shader   = "Fox_glimmer",
                },
                {
                    deckName = "b_Fox_GhostRareDeck",
                    shader   = "Fox_ghostRare",
                },
                {
                    deckName = "b_Fox_RarityCollectionDeck",
                    shader   = "polychrome",
                },
                {
                    deckName = "b_Fox_secretRareDeck",
                    shader   = "Fox_secretRare",
                },
                {
                    deckName = "b_Fox_InsanityDeck",
                    shader   = "Fox_shadowChrome",
                },
            }                  
            
                    if self.area and self.area.config and self.area.config.type == "deck" then
                        local currentBack = (type(self.params.viewed_back) == "table" and self.params.viewed_back)
                                or (self.params.viewed_back and G.GAME.viewed_back or G.GAME.selected_back)
                            or Back(G.P_CENTERS["b_Fox_goldDeck"]) 
                            or Back(G.P_CENTERS["b_Fox_GhostRareDeck"])
                            or Back(G.P_CENTERS["b_Fox_RarityCollectionDeck"])
                            or Back(G.P_CENTERS["b_Fox_secretRareDeck"])
                            or Back(G.P_CENTERS["b_Fox_InsanityDeck"])
                local deckToShaderMapping = nil
            
                if currentBack and currentBack.effect.center.key then
                    for _, entry in ipairs(deckToShaderTable) do
                        if currentBack.effect.center.key == entry.deckName then
                            deckToShaderMapping = entry.shader
                            self.children.back:draw_shader(
                                deckToShaderMapping,
                                nil,
                                self.ARGS.send_to_shader,
                                true
                            )
                            break
                        end
                    end
                end
            end
        end
    })
end
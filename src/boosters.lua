-- FoxMod = {}
-- FoxMod.config = SMODS.current_mod.config
function StartsWith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function getResourceWithPrefix(s)
    local results = {}
    for k, v in pairs(G.P_CENTERS) do
        if StartsWith(k, s) then --and k.unlocked == true then
            print(k)
            table.insert(results, k)
        end
    end
    return results
end

function getRandomFoxJoker()
    --print("getting a random fox joker")
    local allFoxJokers = getResourceWithPrefix("j_Fox")    
    --print("received list of " .. #allFoxJokers)
    local randomJoker = allFoxJokers[math.random(#allFoxJokers)]

    --print("random joker shall be " .. randomJoker)

    return randomJoker
end

function forceEditionCollectionView(s)
    for _, jokerCard in ipairs(G.your_collection[1].cards) do
        jokerCard:set_edition(s, true)
    end

    for _, jokerCard in ipairs(G.your_collection[2].cards) do
        jokerCard:set_edition(s, true)
    end

    for _, jokerCard in ipairs(G.your_collection[3].cards) do
        jokerCard:set_edition(s, true)
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
    local randNo = math.random(9)
    if randNo > 0 and randNo < 4 then
        return "e_Fox_fragileRelic"
    elseif randNo > 3 and randNo < 6 then
        return "e_Fox_ghostRare"
    else
        return "e_Fox_secretRare"
    end
end

local function poll_with_custom_editions()
    local randNo = math.random(2)
    if randNo > 1 and FoxModConfig.customEditions then
        local edition = poll_edition('aura', nil, true, true)
        if nil == edition and FoxModConfig.customEditions then return poll_custom_editions() end
        return edition
    else
        local edition = nil
        if FoxModConfig.customEditions then
            edition = poll_custom_editions()
        else
            edition = poll_edition('aura', nil, true, true)
        end
        return edition
    end
end

if FoxModConfig.customBoosters then

    
    SMODS.Booster({
        object_type = "Booster",
        key = "RarityStandardCollection",
        kind = "Card",
        atlas = "FoxModBoosters",
        pos = { x = 0, y = 0 },
        config = { extra = 4, choose = 1 },
        cost = 10,
        order = 3,
        weight = 0.25,
        create_card = function(self, card)
            --function create_playing_card(card_init, area, skip_materialize, silent, colours)

            local getCard = create_playing_card(nil, G.pack_cards, true, true, nil)
            sendInfoMessage("creating cards for this pack")
            local jokerInfo = inspect(getCard)
            -- sendInfoMessage("created joker card of " .. jokerInfo.base.key, self.key)
            local edition = poll_with_custom_editions()
            getCard:set_edition(edition, false)
            return getCard
        end,
        ease_background_colour = function(self)
            ease_colour(G.C.DYN_UI.MAIN, G.C.BLUE)
            ease_background_colour({ new_colour = G.C.SET.PURPLE, special_colour = G.C.BLACK, contrast = 2 })
        end,
        loc_vars = function(self, info_queue, card)
            return { vars = { card.config.center.config.choose, card.ability.extra } }
        end,
        loc_txt = {
            name = "Standard Rarity Collection",
            text = {
                "Choose {C:attention}#1#{} of",
                "up to {C:attention}#2# Rare Edition Cards{}",
            },
        },
        group_key = "StandardRarity",
    })
end --customEditionCheck

    if FoxModConfig.customEditions then
        SMODS.Booster({
            object_type = "Booster",
            key = "RarityCollection",
            kind = "Jokers",
            atlas = "FoxModBoosters",
            pos = { x = 0, y = 0 },
            config = { extra = 4, choose = 1 },
            cost = 10,
            order = 3,
            weight = 0.20,
            create_card = function(self, card)
                -- function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
                local getCard = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, "foxNegation")
                -- sendInfoMessage("creating cards for this pack", self.key)

                local edition = poll_with_custom_editions()
                if nil == edition then
                    edition = poll_custom_editions()
                end
                getCard:set_edition(edition, false)

                local jokerInfo2 = inspect(getCard)
                local label = "unknown"
                local editInf = "none"

                if jokerInfo2.label then label = jokerInfo2.label end
                if jokerInfo2.edition then editInf = jokerInfo2.edition.key end

                sendInfoMessage("checking edition of created joker of " .. label .. " edition = " .. editInf, self.key)

                return getCard
            end,
            ease_background_colour = function(self)
                ease_colour(G.C.DYN_UI.MAIN, G.C.BLUE)
                ease_background_colour({ new_colour = G.C.SET.PURPLE, special_colour = G.C.BLACK, contrast = 2 })
            end,
            loc_vars = function(self, info_queue, card)
                info_queue[#info_queue + 1] = { key = "artistcredit", set = "Other", vars = { "Linzra" } }
                return { vars = { card.config.center.config.choose, card.ability.extra } }
            end,
            loc_txt = {
                name = "Rarity Collection",
                text = {
                    "Choose {C:attention}#1#{} of",
                    "up to {C:attention}#2# Special Edition Jokers{}",
                },
            },
            group_key = "RarityCollection",
        })

        SMODS.Booster({
            object_type = "Booster",
            key = "RarityMegaCollection",
            kind = "Jokers",
            atlas = "FoxModBoosters",
            pos = { x = 1, y = 1 },
            config = { extra = 7, choose = 2 },
            cost = 10,
            order = 3,
            weight = 0.10,
            create_card = function(self, card)
                local getCard = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, "foxNegation")
                -- sendInfoMessage("creating cards for this pack", self.key)

                local edition = poll_with_custom_editions()
                if nil == edition then
                    edition = poll_custom_editions()
                end
                getCard:set_edition(edition, false)

                local jokerInfo2 = inspect(getCard)
                local label = "unknown"
                local editInf = "none"

                if jokerInfo2.label then label = jokerInfo2.label end
                if jokerInfo2.edition then editInf = jokerInfo2.edition.key end

                sendInfoMessage("checking edition of created joker of " .. label .. " edition = " .. editInf, self.key)

                return getCard
            end,
            ease_background_colour = function(self)
                ease_colour(G.C.DYN_UI.MAIN, G.C.BLUE)
                ease_background_colour({ new_colour = G.C.SET.PURPLE, special_colour = G.C.BLACK, contrast = 2 })
            end,
            loc_vars = function(self, info_queue, card)
                return { vars = { card.config.center.config.choose, card.ability.extra } }
            end,
            loc_txt = {
                name = "Rarity Mega Collection",
                text = {
                    "Choose {C:attention}#1#{} of",
                    "up to {C:attention}#2# Special Edition Jokers{}",
                },
            },
            group_key = "RarityMegaCollection",
        })


    if FoxModConfig.modSpecificJokerBoosters then
        SMODS.Booster({
            object_type = "Booster",
            key = "FickleFoxCollection",
            kind = "Jokers",
            atlas = "FoxModBoosters",
            pos = { x = 2, y = 0 },
            config = { extra = 4, choose = 1 },
            cost = 10,
            order = 3,
            weight = 0.25,
            create_card = function(self, card)
                -- function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
                local randomFoxJoker = getRandomFoxJoker()
                --print(randomFoxJoker)
                local getCard = create_card("Joker", G.pack_cards, nil, nil, true, true, randomFoxJoker, "Fox")
                sendInfoMessage("creating cards for this pack", self.key)

                local edition = poll_with_custom_editions()
                if nil == edition then
                    edition = poll_custom_editions()
                end
                getCard:set_edition(edition, false)

                local jokerInfo2 = inspect(getCard)
                local label = "unknown"
                local editInf = "none"

                if jokerInfo2.label then label = jokerInfo2.label end
                if jokerInfo2.edition then editInf = jokerInfo2.edition.key end

                sendInfoMessage("checking edition of created joker of " .. label .. " edition = " .. editInf, self.key)

                return getCard
            end,
            ease_background_colour = function(self)
                ease_colour(G.C.DYN_UI.MAIN, G.C.BLUE)
                ease_background_colour({ new_colour = G.C.SET.PURPLE, special_colour = G.C.BLACK, contrast = 2 })
            end,
            loc_vars = function(self, info_queue, card)
                return { vars = { card.config.center.config.choose, card.ability.extra } }
            end,
            loc_txt = {
                name = "Fickle Fox Booster",
                text = {
                    "Choose {C:attention}#1#{} of",
                    "up to {C:attention}#2# Fickle Fox Jokers{}",
                },
            },
            group_key = "FickleFoxBooster",
        })
    end

    if FoxModConfig.negativeBooster then
        SMODS.Booster({
            object_type = "Booster",
            key = "negation",
            kind = "Jokers",
            atlas = "FoxModBoosters",
            pos = { x = 0, y = 1 },
            config = { extra = 5, choose = 1 },
            cost = 17,
            order = 3,
            weight = 0.10,
            create_card = function(self, card)
                -- function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
                local getCard = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, "foxNegation")
                sendInfoMessage("creating cards for this pack")
                local jokerInfo = inspect(getCard)
                sendInfoMessage("created joker card of " .. jokerInfo)

                getCard:set_edition('e_negative', false)
                return getCard
            end,
            ease_background_colour = function(self)
                ease_colour(G.C.DYN_UI.MAIN, G.C.BLUE)
                ease_background_colour({ new_colour = G.C.SET.PURPLE, special_colour = G.C.BLACK, contrast = 2 })
            end,
            loc_vars = function(self, info_queue, card)
                return { vars = { card.config.center.config.choose, card.ability.extra } }
            end,
            loc_txt = {
                name = "Negation Rarity Collection",
                text = {
                    "Choose {C:attention}#1#{} of",
                    "up to {C:attention}#2# Negative Jokers{}",
                },
            },
            group_key = "NegationPack",
        })
    end

    SMODS.Booster({
        object_type = "Booster",
        key = "hologramPACK",
        kind = "Jokers",
        atlas = "FoxMod2xOnlyBooster",
        pos = { x = 0, y = 0 },
        config = { extra = 5, choose = 1 },
        cost = 10,
        order = 2,
        weight = 0.25,
        set_ability = function(self, card, initial, delay_sprites)
            -- sendInfoMessage("triggering post injection logic for this pack", self.key)

            card:set_edition('e_holo', false)
            card.cost = 10
        end,
        -- draw = function(self, card, layer)
        --     self:draw_shader('holo' , nil, nil, true)
        -- end,
        create_card = function(self, card)
            -- function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
            local getCard = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, "foxholo")

            getCard:set_edition('e_holo', false)
            return getCard
        end,
        ease_background_colour = function(self) ease_background_colour { new_colour = HEX('62a1b4'), special_colour = HEX('fce1b6'), contrast = 2 } end,
        particles = function(self)
            G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
                timer = 0.015,
                scale = 0.3,
                initialize = true,
                lifespan = 3,
                speed = 0.1,
                padding = -1,
                attach = G.ROOM_ATTACH,
                colours = { G.C.BLACK, G.C.GOLD },
                fill = true
            })
            G.booster_pack_sparkles.fade_alpha = 1
            G.booster_pack_sparkles:fade(1, 0)
        end,
        loc_vars = function(self, info_queue, card)
            return { vars = { card.config.center.config.choose, card.ability.extra } }
        end,
        loc_txt = {
            name = "Holographic Pack",
            text = {
                "Choose {C:attention}#1#{} of",
                "up to {C:attention}#2# Holographic Jokers{}",
            },
        },
        group_key = "hologramPACK",
    })
else
    print("custom boosters disabled")
end

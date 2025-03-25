sendInfoMessage("Processing jokers", "essay.lua")
--todo
-- fix animnation for spectral to apply the affect before flip
-- figure out which one is wrong

--watch Mods/FoxMods/src/essay.lua
--utils
local function get_card_value(n)
    local face_cards = {
        [11] = "Jack",
        [12] = "Queen",
        [13] = "King",
        [14] = "Ace"
    }

    return face_cards[n] or n
end

local function getValueNilSafe(s)
    local retVal = ""
    if s == nil then
        return retVal
    else
        return s
    end
end

--credit
local function contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function getPolarity()
    local currentSuit = G.GAME.current_round.ancient_card.suit
    local polarity = {}

    if currentSuit == 'Spades' or currentSuit == 'Clubs' then
        polarity = { 'Spades', 'Clubs' }
    else
        polarity = { 'Hearts', 'Diamonds' }
    end

    return polarity
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
    if randNo > 1 then
        local edition = poll_edition('aura', nil, true, true)
        if nil == edition then return poll_custom_editions() end
        return edition
    else
        local edition = poll_custom_editions()
        return edition
    end
end

SMODS.current_mod.config_tab = function() --Config tab
    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            padding = 0.05,
            colour = G.C.CLEAR,
        },
        nodes = {
            create_toggle({
                label = "Page 1 Jokers (restart required)",
                ref_table = FoxModconfig,
                ref_value = "wave1",
            }),
            create_toggle({
                label = "Page 2 Jokers (restart required)",
                ref_table = FoxModconfig,
                ref_value = "wave2",
            })
        },
    }
end


SMODS.Joker { --Good Doggie
    name = "Golden Repeater",
    key = "goldretriever",
    config = {
        odds = 4,
        extra = 1
    },
    loc_txt = {
        ['name'] = 'Golden Repeater',
        ['text'] = {
            [1] = '{C:attention}Retrigger{} all {C:attention}Gold Cards{}, played or in hand',
            [2] = 'has a {C:green}#1# in #2#{} chance',
            [3] = 'to add copy of played {C:attention}Gold Cards{}',
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, 3 } } -- Fix for missing values
    end,
    pos = {
        x = 0,
        y = 0
    },
    enhancement_gate = 'm_gold',
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',


    calculate = function(self, card, context)
        --region :scoring the card when played
        if context.cardarea == G.play and context.individual and context.other_card and context.other_card.ability and context.other_card.ability.name == 'Gold Card' and not context.repetition then
            --card is golden, roll to see if we copy it
            if pseudorandom('goldretriever') < G.GAME.probabilities.normal / card.ability.odds then
                --we are copying it
                sendInfoMessage("LuckY! Copying this card", "goldenRepeater")
                --old logic, restored
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local _card = copy_card(context.other_card, nil, nil, G.playing_card)
                _card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                G.hand:emplace(_card)
                table.insert(G.playing_cards, _card)
                playing_card_joker_effects({ true })
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = localize('k_copied_ex'), colour = G.C.FILTER })
                _card.states.visible = nil

                G.E_MANAGER:add_event(Event({
                    func = function()
                        _card:start_materialize()
                        return true
                    end
                }))
            end --end check to copy
            --if we don't meet the odds, it's still a gold card so retrigger once
            sendInfoMessage("Not so lucky, only reproccing this gold card", "goldenRepeater")
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
        elseif context.cardarea == G.play and context.other_card and context.other_card.ability and context.other_card.ability.name == 'Gold Card' and context.repetition then
            --card is golden, roll to see if we copy it
            --if we don't meet the odds, it's still a gold card so retrigger once
            sendInfoMessage("Repeating!  This is the alst call for this gold card", "goldenRepeater")
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
            --reviewing card held in hand, if they're gold we retrigger them still
        elseif context.repetition and context.cardarea == G.hand and context.other_card.ability and context.other_card.ability.name == 'Gold Card' then
            sendInfoMessage("Reproccing this gold card held in hand!", "goldenRepeater")
            if (next(context.card_effects[1]) or #context.card_effects > 1) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    name = "Lucky Retriever",
    key = "luckyretriever",
    config = {
        odds = 4,
        extra = 1
    },
    loc_txt = {
        ['name'] = 'Lucky Retriever',
        ['text'] = {
            [1] = '{C:attention}Retrigger{} all {C:attention}Lucky Cards{}',
            [2] = 'Has a {C:green}#1# in #2#{} chance',
            [3] = 'to add a copy of played {C:attention}Lucky Cards{}',
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, 3 } }
    end,
    pos = {
        x = 1,
        y = 2
    },
    enhancement_gate = 'm_lucky',
    cost = 2,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    cry_credits = {
        colour = G.C.Blue,
        text = {
            "Credit:",
            "OhPahn!",
        },
    },

    calculate = function(self, card, context)
        --region :scoring the card when played
        if context.cardarea == G.play and context.other_card and context.other_card.ability and context.other_card.ability.name == 'Lucky Card' then
            --card is golden, roll to see if we copy it
            if pseudorandom('luckyretriever') < G.GAME.probabilities.normal / card.ability.odds then
                --we are copying it
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local _card = copy_card(context.other_card, nil, nil, G.playing_card)
                _card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                G.deck:emplace(_card)
                table.insert(G.playing_cards, _card)
                playing_card_joker_effects({ true })
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = localize('k_copied_ex'), colour = G.C.FILTER })
            end --end check to copy
            --if we don't meet the odds, it's still a gold card so retrigger once
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
            --reviewing card held in hand, if they're gold we retrigger them still
        elseif context.repetition and context.cardarea == G.hand and context.other_card.ability and context.other_card.ability.name == 'Lucky Card' then
            if (next(context.card_effects[1]) or #context.card_effects > 1) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker { --fickleFox
    name = "Fickle Fox",
    key = "ficklefox",
    config = {
        oddsToBless = 3,
        oddsToFlee = 12,
        extra = 1,
        remaining = 5
    },
    loc_txt = {
        ['name'] = 'Fickle Fox',
        ['text'] = {
            [1] = '{C:attention}Applies gold seal randomly to cards played',
            [2] = 'Has a {C:green}#1# in #2#{} chance to bless',
            [3] = 'Has a {C:green}#1# in #3#{} chance to vanish with the wind',
            [4] = 'Flees after 5 seals applied, {C:red}#4# seals remaining ',
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return { vars = { G.GAME.probabilities.normal, card.ability.oddsToBless, card.ability.oddsToFlee, card.ability.remaining } } -- Fix for missing values
    end,
    pos = {
        x = 6,
        y = 0
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    no_pool_flag = 'fickledfoxfled',

    calculate = function(self, card, context)
        -- handle end of round flee chance
        if
            context.end_of_round and not context.blueprint
            and not context.individual
            and not context.repetition
            and not context.retrigger_joker
        then
            --decide if card flees
            local goflee = false
            local reason = ""
            sendInfoMessage("deciding if we flee", "FickleFox")
            if pseudorandom("ficklefox") < G.GAME.probabilities.normal / card.ability.oddsToFlee then
                goflee = true
                reason = "unlucky"
            elseif card.ability.remaining < 1 then
                goflee = true
                reason = "exhausted"
            end
            if goflee then
                sendInfoMessage("We are going to flee because: " .. reason, "FickleFox")
                play_sound("tarot1")
                card.T.r = -0.2
                card:juice_up(0.3, 0.4)
                card.states.drag.is = true
                card.children.center.pinch.x = true
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.3,
                    blockable = false,
                    func = function()
                        G.jokers:remove_card(card)
                        card:remove()
                        card = nil
                        return true
                    end,
                }))

                --it's going to leave, it needs to set the no pool flag for itself to make sure it doesn't reappear
                G.GAME.pool_flags.fickledfoxfled = true
                return {
                    message = { reason },
                    colour = G.C.FILTER,
                }
            else
                return {
                    message = { "blessed" },
                    colour = G.C.FILTER,
                }
            end
            --not end of round, but instead main scoring time
            --need to fix so doesnot apply to other cards but instead to played cards

            --new logic if context.cardarea == G.play then
        elseif context.individual and context.cardarea == G.play and context.other_card then
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)
            local othercardSeal = getValueNilSafe(cardInfo.seal)

            sendInfoMessage("Card " .. cardInfo .. " has seal of " .. othercardSeal, "FickleFox ")
            if othercardSeal == "Gold" or "" ~= othercardSeal then
                sendInfoMessage("Other card has Gold seal already, skipping", "FickleFox")
                return
            elseif pseudorandom("ficklefox") < G.GAME.probabilities.normal / card.ability.oddsToBless then
                card:juice_up()
                sendInfoMessage("We are going to bless" .. cardInfo, "FickleFox")

                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.3,
                    blockable = false,
                    func = function()
                        otherCard:set_seal("Gold", true)
                        card.ability.remaining = card.ability.remaining - 1
                        if card.ability.remaining < 0 then
                            card.ability.remaining = 0
                        end
                        return {
                            message = { "blessed" },
                            colour = G.C.FILTER,
                            card = card,
                        }
                    end,
                }))
            else
                sendInfoMessage("We have decided to snub " .. cardInfo, "FickleFox")
                return {
                    message = { "snubbed" },
                    colour = G.C.FILTER,
                }
            end
        end
    end
}

SMODS.Joker { --benevolance
    name = "Benevolence",
    key = "benevolence",
    config = {
        oddsToBless = 3,
        extra = 1.8
    },
    loc_txt = {
        ['name'] = 'Benevolence',
        ['text'] = {
            [1] = 'Rewards your diligence and saving',
            [2] = 'applies {X:mult,C:white}X#2#{} Mult',
            [3] = 'to cards with {C:attention}gold seal in your hand',
            [4] = 'Will randomly {C:attention}spread gold seal{} in played flushes'
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'gold_seal', set = 'Other' }
        return { vars = { G.GAME.probabilities.normal, card.ability.extra, 3 } }
    end,
    pos = {
        x = 7,
        y = 0
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    yes_pool_flag = 'fickledfoxfled',

    --when scoring, check for presence of gold seal.  If present, apply xMult to that card
    calculate = function(self, card, context)
        if context.individual and context.after then
            if context.cardarea == G.hand then
                sendInfoMessage("We are reviewing cards in hand", "BenevloanceJoker")
                local otherCard = context.other_card
                local cardInfo = getValueNilSafe(otherCard.base.value)
                -- if card.seal then  --need to be sure it is a gold seal, not a blue or red
                if otherCard.seal == 'Gold' then
                    sendInfoMessage("Card" .. cardInfo .. " has GOLD seal, let's rock", "BenevloanceJoker ")

                    return {
                        x_mult = card.ability.extra,
                        colour = G.C.RED,
                        card = card,
                    }
                else
                    local sealinfo = getValueNilSafe(otherCard.seal)
                    sendInfoMessage("Card" .. cardInfo .. " has no seal, or seal of" .. sealinfo, "BenevloanceJoker ")
                end
            end
        elseif context.cardarea == G.play and not context.end_of_round then
            --review hand, see if any cards have gold seal and is a flush or flush house or five of a kind
            --if so, then 50% chance to apply goldseals on other cards (don't overwrite)
            local goldSealFound = 'false'
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].seal == 'Gold' then
                    goldSealFound = 'true'
                end
            end
            sendInfoMessage("Gold seal found: " .. goldSealFound, "BenevloanceJoker ")
            inspect(context.scoring_name)

            sendInfoMessage("hand played is  " .. G.GAME.current_round.current_hand.handname)
            if G.GAME.current_round.current_hand.handname == "Royal Flush" or
                G.GAME.current_round.current_hand.handname == "Flush" or
                G.GAME.current_round.current_hand.handname == "Flush Five" or
                G.GAME.current_round.current_hand.handname == "Five of a Kind" or
                G.GAME.current_round.current_hand.handname == "Four of a Kind" then
                for i = 1, #context.scoring_hand do
                    local otherCard = context.scoring_hand[i]
                    if otherCard.seal then
                        return
                    else
                        if pseudorandom("benevolence") < G.GAME.probabilities.normal / card.ability.oddsToBless then
                            card:juice_up()
                            sendInfoMessage("We are going to spread the blessing!", self.key)

                            G.E_MANAGER:add_event(Event({
                                trigger = "after",
                                delay = 0.3,
                                blockable = false,
                                func = function()
                                    otherCard:set_seal("Gold", true)
                                    otherCard:juice_up()
                                    return {
                                        message = { "blessed" },
                                        colour = G.C.FILTER,
                                        card = card,
                                    }
                                end,
                            }))
                        end
                    end
                end
            end
        end
    end
}

SMODS.Joker { --akuma
    name = "A Kuma",
    key = "akuma",
    config = {
        odds = 6,
        plusMult = 2,
        extra = 3.2,
        chips = 0,
        chipGrowthRate = 2
    },
    loc_txt = {
        ['name'] = 'A Kuma',
        ['text'] = {
            [1] = 'Gains {C:chips}+#1#{} chips when tens are scored',
            [2] = 'applies {C:red}+#2#{} Mult per ten played',
            [3] = 'increases to {C:red}+15{} if all tens',
            [4] = 'Currently {C:chips}+#3#{} chips'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.chipGrowthRate, card.ability.plusMult, card.ability.chips } }
    end,
    pos = {
        x = 5,
        y = 0
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',


    calculate = function(self, card, context)
        -- PHASE 1: During individual card scoring (applies +chips when scoring a TEN)
        if context.individual and not context.blueprint and context.cardarea == G.play and not context.before then
            sendInfoMessage("Reviewing cards in played area", self.key)
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            if cardInfo == 10 or cardInfo == "10" then
                sendInfoMessage(
                    "Card " ..
                    cardInfo ..
                    " is a TEN, adding +chips, was " .. card.ability.chips .. ", now " .. card.ability.chips + 4,
                    self.key)

                -- Increase chips
                card.ability.chips = (card.ability.chips or 0) + card.ability.chipGrowthRate

                return {
                    extra = { focus = card, message = localize('k_upgrade_ex') },
                    card = card,
                    colour = G.C.CHIPS,
                    sound = "Fox_metsu"
                }
                -- Show chip gain during scoring
            end


            -- PHASE 2: After all cards are scored (calculate METSU mult + total chips)
        elseif context.joker_main then
            local tenCounted = 0
            local messatsu = false
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:get_id() == 10 then
                    tenCounted = tenCounted + 1
                end
            end

            -- Calculate mult based on number of tens
            local thisMult = (tenCounted > 4) and 15 or (tenCounted * 2)
            local msg = (tenCounted > 0)
                and "+" .. thisMult .. " mult and +" .. (card.ability.chips or 0) .. " chips"
                or "+" .. (card.ability.chips or 0) .. " chips"

            -- Display METSU if conditions met
            if tenCounted > 3 then
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                    message = "METSU",
                    colour = G.C.FILTER
                })
                messatsu = true
            end

            sendInfoMessage("Counted " .. tenCounted .. " tens, mult: " .. thisMult, self.key)

            local thisMult = thisMult or 0

            sendInfoMessage("Accrued mult " .. thisMult, self.key)

            if messatsu then
                -- play_sound("Fox_metsu", 0.85)
                return {
                    x_mult = card.ability.extra,
                    chips = card.ability.chips,

                    colour = G.C.BLUE,
                    card = card,
                }
            end
            return {
                chips = card.ability.chips,
                mult = thisMult,
                card = card
            }
        elseif context.individual and context.cardarea == G.hand and context.other_card and not context.end_of_round then
            sendInfoMessage("Reviewing cards held in hand", "AKUMA")
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            if cardInfo == 10 or cardInfo == "10" then
                sendInfoMessage("Card " .. cardInfo .. " is a ten, applying xMult bonus", "Akuma")
                -- play_sound("Fox_metsu", 0.85)
                return {
                    x_mult = card.ability.extra,
                    colour = G.C.BLUE,
                    card = otherCard,
                    sound = "Fox_metsu"
                }
            end
        end
    end
}


SMODS.Joker { --Good Doggie
    name = "Shin A kuma",
    key = "shinAKuma",
    config = {
        odds = 4,
        extra = 1
    },
    loc_txt = {
        ['name'] = 'Shin A Kuma',
        ['text'] = {
            [1] = '{C:attention}Retriggers{} all {C:attention}10{}, played or in hand',
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, 3 } } -- Fix for missing values
    end,
    pos = {
        x = 8,
        y = 0
    },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',


    calculate = function(self, card, context)
        --region :scoring the card when played
        if context.cardarea == G.play and context.individual and context.other_card then
            sendInfoMessage("Card " .. context.other_card.base.id .. " is a ten, retriggering xMult bonus", "Akuma")

            if (context.other_card.base.id == 10 or context.other_card.base.id == "10") then
                -- play_sound("Fox_metsu", 0.85)
                return {
                    message = localize('k_again_ex'),
                    repetitions = 3,
                    card = card,
                    sound = "Fox_metsu"
                }
            elseif context.individual and context.cardarea == G.hand and context.other_card and not context.end_of_round then
                sendInfoMessage("Reviewing cards held in hand", "AKUMA")
                local otherCard = context.other_card
                local cardInfo = getValueNilSafe(otherCard.base.value)

                if cardInfo == 10 or cardInfo == "10" then
                    sendInfoMessage("Card " .. cardInfo .. " is a ten, applying xMult bonus", "Akuma")
                    -- play_sound("Fox_metsu", 0.85)
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 3,
                        card = card,
                        sound = "Fox_metsu"
                    }
                end
            end
        end
    end
}

SMODS.Joker { --Hachiko
    name = "Hachiko",
    key = "hachiko",
    config = {
        plusMult = 5,
        chips = 8
    },
    loc_txt = {
        ['name'] = 'Hachiko',
        ['text'] = {
            [1] = 'A faithful friend, still waiting for his master',
            [2] = 'Each played {C:attention}8{} or {C:attention}5{} gives {C:chips}8{}',
            [3] = 'and {C:red}5{} Mult when scored'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.chipGrowthRate, card.ability.plusMult, card.ability.chips } }
    end,
    pos = {
        x = 0,
        y = 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        -- PHASE 1: During individual card scoring (applies +chips when scoring a TEN)
        if context.individual and context.cardarea == G.play then --and not context .joker_main then
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            if cardInfo == 5 or cardInfo == "5" or cardInfo == 8 or cardInfo == "8" then
                return {
                    chips = card.ability.chips,
                    mult = card.ability.plusMult,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker { --Sun and Moon
    name = "Sun and Moon",
    key = "sunandmoon",
    config = {
        plusMult = 5,
        chips = 8
    },
    loc_txt = {
        ['name'] = 'Sun and Moon',
        ['text'] = {
            [1] = 'The eternal pair, Ninetailed fox and six toed cat',
            [2] = 'Each played {C:attention}9{} or {C:attention}6{} gives {C:chips}9{} chips',
            [3] = 'and {C:red}6{} Mult when scored'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.chipGrowthRate, card.ability.plusMult, card.ability.chips } }
    end,
    pos = {
        x = 3,
        y = 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            if cardInfo == 6 or cardInfo == "6" or cardInfo == 9 or cardInfo == "9" then
                return {
                    chips = card.ability.chips,
                    mult = card.ability.plusMult,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker { -- Felicette
    name = "Felicette",
    key = "felicette",
    config = {
        extra = 1.3
    },
    loc_txt = {
        ['name'] = 'Felicette',
        ['text'] = {
            [1] = 'Applies a {X:mult,C:white}X#1#{} Mult bonus',
            [2] = 'to any cards with a {C:attention}blue seal{} held in hand'
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'blue_seal', set = 'Other' }
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 7,
        y = 1
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    enhancement_gate = 'blue_seal',
    cry_credits = {
        colour = G.C.Blue,
        text = {
            "Credit:",
            "MarioFan597",
        },
    },

    -- When scoring, check for presence of blue seal. If present, apply xMult to that card
    calculate = function(self, card, context)
        if context.individual then
            if context.cardarea == G.hand then
                sendInfoMessage("Reviewing cards held in hand", "FelicetteJoker")
                local otherCard = context.other_card
                local cardInfo = getValueNilSafe(otherCard.base.value)

                if otherCard.seal == 'Blue' then
                    sendInfoMessage("Card " .. cardInfo .. " has BLUE seal, applying Mult bonus", "FelicetteJoker")

                    return {
                        x_mult = card.ability.extra,
                        colour = G.C.BLUE,
                        card = card,
                    }
                else
                    local sealinfo = getValueNilSafe(otherCard.seal)
                    sendInfoMessage("Card " .. cardInfo .. " has no seal, or seal of " .. sealinfo, "FelicetteJoker")
                end
            end
        end
    end
}

SMODS.Joker { -- Sonar Bat
    name = "Sonar Bat",
    key = "sonar_bat",
    config = {
        extra = 1.3
    },
    loc_txt = {
        ['name'] = 'Sonar Bat',
        ['text'] = {
            [1] = 'Reveals next card in deck',
            [2] = 'Next card: {X:mult,C:white}#1#{}'
        }
    },
    loc_vars = function(self, info_queue, card)
        local card0 = "#@" ..
            (G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.id or 11) ..
            (G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.suit:sub(1, 1) or 'D')

        return { vars = { card0 } }
    end,
    pos = {
        x = 8,
        y = 1
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    cry_credits = {
        colour = G.C.Blue,
        text = {
            "Credit:",
            "MarioFan597",
        },
    },

    -- When scoring, check for presence of blue seal. If present, apply xMult to that card
    calculate = function(self, card, context)
    end
}

SMODS.Joker { -- Bandit Loach
    name = "Bandit Loach",
    key = "bandit_loach",
    config = {
        odds = 5,
        cost = 2
    },
    loc_txt = {
        ['name'] = 'Bandit Loach',
        ['text'] = {
            'For $2, will upgrade the first hand played',
            "Has a {C:green}#1# in #2#{} chance to upgrade any played hand for free after that",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, 3 } }
    end,
    pos = {
        x = 5,
        y = 1
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and G.GAME.current_round.hands_played == 0 then
            ease_dollars(-card.ability.cost)
            return {
                card = self,
                level_up = true,
                message = localize('k_level_up_ex')
            }
        elseif context.cardarea == G.jokers and context.before and not G.GAME.current_round.hands_played == 0 then
            --prob check for free upgrade
            if pseudorandom('bandit_loach') < G.GAME.probabilities.normal / card.ability.odds then
                return {
                    card = self,
                    level_up = true,
                    message = "Free level up!"
                }
            end
        end
    end
}

SMODS.Joker { --Holowing Owl
    name = "Holowing Owl",
    key = "HolowingOwl",
    config = {
        odds = 6,
        extra = 1
    },
    loc_txt = {
        ['name'] = 'Holowing Owl',
        ['text'] = {
            [1] = '{C:attention}Retrigger{} all {C:attention}Holographic Cards{}, played or in hand',
            [2] = 'has a {C:green}#1# in #2#{} chance',
            [3] = 'to add copy of played {C:attention}Holographic Cards{}',
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
        return { vars = { G.GAME.probabilities.normal, card.ability.odds } }
    end,
    pos = {
        x = 4,
        y = 2
    },
    enhancement_gate = 'm_holo',
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    set_ability = function(self, card, initial, delay_sprites)
        sendInfoMessage("triggering on pickup logic for this card", self.key)

        card:set_edition('e_holo', false)
        card.cost = 10
    end,
    atlas = 'FoxModJokers',
    calculate = function(self, card, context)
        if context.retrigger_joker_check and context.other_card ~= card and context.other_card.edition then
            sendInfoMessage("other joker has edition of " .. context.other_card.edition.key, self.key)

            if context.other_card.edition.key == "e_holo" then
                -- joker card retriggers using .retrigger_joker_check
                sendInfoMessage("other joker has holo!", self.key)
                -- if context.other_ret and context.other_ret.jokers and context.other_ret.jokers.was_blueprinted then
                --     -- don't retrigger copied instances of self wiehter
                -- else
                return {
                    message = localize("k_again_ex"),
                    repetitions = card.ability.extra,
                    message_card = context.blueprint_card or card,
                    was_blueprinted = context.blueprint,
                }
            end
        elseif context.repetition and not context.repetition_only and
            context.other_card and context.other_card.edition and context.other_card.edition.key == "e_holo" then
            -- playing card retriggers using .repetition
            return {
                message = localize("k_again_ex"),
                repetitions = card.ability.extra,
                card = card,
                was_blueprinted = context.blueprint,
            }
        elseif context.cardarea == G.play and context.other_card and context.other_card.edition and context.other_card.edition.holo == true and not context.repetition then
            --card is holo, roll to see if we copy it
            if pseudorandom('HolowingOwl') < G.GAME.probabilities.normal / card.ability.odds then
                --we are copying it


                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local _card = copy_card(context.other_card, nil, nil, G.playing_card)
                _card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1

                G.hand:emplace(_card)
                table.insert(G.playing_cards, _card)
                playing_card_joker_effects({ true })
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = localize('k_copied_ex'), colour = G.C.FILTER })
                _card.states.visible = nil

                G.E_MANAGER:add_event(Event({
                    func = function()
                        _card:start_materialize()
                        return true
                    end
                }))

                table.insert(G.playing_cards, _card)
                playing_card_joker_effects({ true })
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = localize('k_copied_ex'), colour = G.C.FILTER })
            end --end check to copy
            --if we don't meet the odds, it's still a holo card so retrigger once
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
            -- elseif context.cardarea == G.play and context.other_card and context.other_card.edition and context.other_card.edition.holo == true and context.repetition then
            --     return {
            --         message = localize('k_again_ex'),
            --         repetitions = 1,
            --         card = card
            --     }
            --reviewing card held in hand, if they're holo we retrigger them still
        elseif context.repetition and context.cardarea == G.hand and context.other_card.edition and context.other_card.edition.holo == true then
            if (next(context.card_effects[1]) or #context.card_effects > 1) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker { --Lord of Gold
    name = "Lord of Gold",
    key = "LordOfGold",
    config = {
        odds = 2,
        extra = 1.5,
        earnedPlusmult = 0,
        multGrowthRate = 1,
        goldTally = 0
    },
    loc_txt = {
        ['name'] = 'Lord of Gold',
        ['text'] = {
            [1] = '{C:attention}Golden Cards{} in hand now have a {C:green}#1# in #2#{} chance',
            [2] = 'To apply a {X:mult,C:white}x1.5{} Mult bonus',
            [3] = 'Accrues plus mult per gold card in deck, currently {X:mult,C:white}+#3#{} Mult bonus',
            '{s:0.9,C:inactive}Eldlich is the Lord of all that is Golden{}',

        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_gold
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, card.ability.goldTally } }
    end,
    pos = {
        x = 0,
        y = 0
    },
    enhancement_gate = 'm_gold',
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxMod2xOnly',

    calculate = function(self, card, context)
        -- region : increasing mult per gold held
        if context.individual then
            card.ability.goldTally = 0
            for k, v in pairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_gold then card.ability.goldTally = card.ability.goldTally + 1 end
            end
        end
        if context.individual and not context.blueprint and context.other_card and context.cardarea == G.play and not context.before and not context.end_of_round then
            local roundInfo = G.GAME.current_round

            local l         = G.GAME.round

            sendInfoMessage("It is round-" .. l .. "-Reviewing cards in played area", self.key)
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)
            if context.other_card.ability and context.other_card.ability.name == 'Gold Card' then
                card.ability.earnedPlusmult = (card.ability.earnedPlusmult or 0) + card.ability.multGrowthRate
                sendInfoMessage(
                    "Card " ..
                    cardInfo ..
                    " is a gold card adding +mult, was " ..
                    card.ability.earnedPlusmult .. ", now " .. card.ability.earnedPlusmult + 1,
                    self.key)

                return {
                    message = "UPGRADE",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
        if context.cardarea == G.play and context.other_card and context.other_card.ability and context.other_card.ability.name == 'Gold Card' and not context.end_of_round then
            --card is golden, roll to see if we grant mult
            if pseudorandom('LordOfGold') < G.GAME.probabilities.normal / card.ability.odds then
                card.ability.earnedPlusmult = (card.ability.earnedPlusmult or 0) + card.ability.multGrowthRate

                sendInfoMessage("Lucky, granting mult for played gold card", "LordOfGold")

                return {
                    x_mult = card.ability.extra,
                    colour = G.C.RED,
                    card = card,
                }
            else
                sendInfoMessage("unlucky,, no mult for played gold card", "LordOfGold")
            end
        elseif context.individual and context.cardarea == G.hand and not context.after and not context.end_of_round then
            sendInfoMessage("Reviewing cards held in hand", "LordOfGold")
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            if otherCard.ability and otherCard.ability.name == 'Gold Card' then
                if pseudorandom('LordOfGold') < G.GAME.probabilities.normal / card.ability.odds then
                    sendInfoMessage("Card " .. cardInfo .. " is gold card and we were lucky, applying xMult bonus",
                        "LordOfGold")
                    card.ability.earnedPlusmult = (card.ability.earnedPlusmult or 0) + card.ability.multGrowthRate


                    return {
                        x_mult = card.ability.extra,
                        colour = G.C.BLUE,
                        card = card,
                    }
                else
                    sendInfoMessage("Card " .. cardInfo .. " is gold card but we were unlucky", "LordOfGold")
                end
            end
        elseif context.joker_main then
            local thisMult = card.ability.earnedPlusmult or 0

            sendInfoMessage("Accrued mult " .. thisMult, self.key)

            return {
                msg = "+" .. thisMult,
                colour = G.C.RED,
                mult = thisMult
            }
        end
    end
}

SMODS.Joker { --Pair Pear
    name = "Pair Pair",
    key = "pairPair",
    config = {
        chips = 1.0,
        pairChipGrowth = 2,
        threeChipGrowth = 3,
        fourChipGrowth = 4,
        fiveChipGrowth = 5
    },
    loc_txt = {
        ['name'] = 'Pair Pear',
        ['text'] = {
            'Gains {X:chips,C:white}chips{} per pair in played hands',
            "{C:inactive}Currently + #1#s{}",
            '{s:0.9,C:inactive}A pair of pear parrots{}',
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.chips } }
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
                chips = card.ability.chips,
                card = card
            }
        elseif context.cardarea == G.jokers and context.before and not context.blueprint then
            local cardsCounted = #context.scoring_hand
            local rankCounts = {}

            for _, playedCard in ipairs(context.scoring_hand) do
                local rank = playedCard:get_id()
                rankCounts[rank] = (rankCounts[rank] or 0) + 1
            end

            -- Debug: Print out rank counts
            for rank, count in pairs(rankCounts) do
                sendInfoMessage("Rank " .. rank .. " appeared " .. count .. " times.", self.key)
            end

            sendInfoMessage("Chips were " .. card.ability.chips .. ", calculating increase", self.key)
            local previousChip = card.ability.chips

            for _, count in pairs(rankCounts) do
                if count == 2 then
                    card.ability.chips = card.ability.chips + card.ability.pairChipGrowth
                elseif count == 3 then
                    card.ability.chips = card.ability.chips + card.ability.threeChipGrowth
                elseif count == 4 then
                    card.ability.chips = card.ability.chips + card.ability.fourChipGrowth
                elseif count == 5 then
                    card.ability.chips = card.ability.chips + card.ability.fiveChipGrowth
                end
            end

            local chipChange = card.ability.chips - previousChip
            sendInfoMessage("Chips are now " .. card.ability.chips .. " chip change = " .. chipChange, self.key)

            if chipChange ~= 0 then
                return {
                    message = "UPGRADE",
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker { --rat of death
    name = "The Death of Rats",
    key = "deathOfRats",
    config = {
        ready = false,
        handsTillReady = 2,
        remainingDefault = 2,
        multBounty = 0,
        multBountyGrowthRate = 3,
        obliterate = false
    },
    loc_txt = {
        ['name'] = 'The Death of Rats',
        ['text'] = {
            [1] = 'Every 5 hands played, destroys the next card played, if hand is a High Card',
            [2] = 'Hands Remaining, {C:red}#1#, adds +5 mult per card slain',
            [3] = "{C:inactive}(Currently {X:mult,C:white} +#2# {C:inactive} Mult)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.handsTillReady, card.ability.multBounty } }
    end,
    pos = {
        x = 5,
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
        if context.after and not context.blueprint and not card.ability.ready then
            sendInfoMessage("Hand was played, decrementing ready counter!", "ratofDeath")

            card.ability.handsTillReady = card.ability.handsTillReady - 1
            if card.ability.handsTillReady <= 0 then
                card.ability.handsTillReady = 0
                card.ability.ready = true
                sendInfoMessage("Joker is now READY!", "ratofDeath")

                local eval = function(card) return (card.ability.ready == true) end
                juice_card_until(card, eval, true)
            else
                sendInfoMessage("Joker already ready?!", "ratofDeath")
            end
        elseif card.ability.ready and context.full_hand and context.after and context.cardarea == G.jokers then
            -- local played_ids = {}
            -- for i = 1, #context.full_hand do
            --     played_ids[i] = context.full_hand[i]:get_id()
            -- end

            -- local hand_size = #played_ids
            -- if hand_size ~= 1 then
            --     --not a high card, need to reset
            --     sendInfoMessage("Not a high card played! Played hand was " .. hand_size, "ratofDeath")
            --     card.ability.ready = false
            --     card.ability.handsTillReady = card.ability.remainingDefault

            --     return {
            --         message = "Resetting",
            --         colour = G.C.RED,
            --         mult_mod = card.ability.multBounty
            --     }
            -- end
            -- local playedCard = context.full_hand[1]

            -- card.ability.multBounty = card.ability.multBounty + card.ability.multBountyGrowthRate
            -- -- Apply multiplier to the hand
            -- sendInfoMessage("Single card played! Applying " .. card.ability.multBounty .. "x Mult", "ratofDeath")

            -- card.ability.ready = false
            -- card.ability.handsTillReady = card.ability.remainingDefault

            -- card.ability.obliterate = true
            -- -- Destroy the scored card

            -- sendInfoMessage("Joker is now destroying!", "ratofDeath")

            -- G.E_MANAGER:add_event(Event({
            --     trigger = 'after',
            --     delay = 0.3,
            --     func = function()
            --         local card = playedCard --context.other_card
            --         if card.ability.name == 'Glass Card' then
            --             card:shatter()
            --         else
            --             card:start_dissolve({ HEX("57ecab") }, nil, 1.6)
            --         end
            --         return true
            --     end
            -- }))
        elseif context.joker_main then
            return {
                colour = G.C.RED,
                mult = card.ability.multBounty
            }
        elseif context.destroying_card and context.cardarea == G.play and card.ability.ready then
            local played_ids = {}
            for i = 1, #context.full_hand do
                played_ids[i] = context.full_hand[i]:get_id()
            end

            local hand_size = #played_ids
            if hand_size ~= 1 then
                --not a high card, need to reset
                sendInfoMessage("Not a high card played! Played hand was " .. hand_size, "ratofDeath")
                card.ability.ready = false
                card.ability.handsTillReady = card.ability.remainingDefault

                return {
                    message = "Resetting",
                    colour = G.C.RED,
                    mult_mod = card.ability.multBounty
                }
            end
            local playedCard = context.full_hand[1]

            card.ability.multBounty = card.ability.multBounty + card.ability.multBountyGrowthRate
            -- Apply multiplier to the hand
            sendInfoMessage("Single card played! Applying " .. card.ability.multBounty .. "x Mult", "ratofDeath")

            card.ability.ready = false
            card.ability.handsTillReady = card.ability.remainingDefault

            card.ability.obliterate = true
            -- Destroy the scored card
            sendInfoMessage("we are going to destroy this card", "ratofDeath ")
            return { remove = true }
        end
    end
}

SMODS.Joker { --Tacocat
    name = "Tacocat",
    key = "tacocat",
    config = {
        extraGrowthRate = 0.1,
        extra = 1.0
    },
    loc_txt = {
        ['name'] = 'Tacocat',
        ['text'] = {
            [1] = 'Gains {X:mult,C:white}x#1#{} when played hand is a palindrome',
            [2] = 'Compares rank only and ignores suit or enhancements',
            [3] = "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",

        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extraGrowthRate, card.ability.extra } }
    end,
    pos = {
        x = 3,
        y = 2
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and card.ability.needToReview then
            local played_ids = {}
            for i = 1, #context.full_hand do
                played_ids[i] = context.full_hand[i]:get_id()
            end

            local hand_size = #played_ids
            local is_palindrome = false

            if hand_size < 2 then
                sendInfoMessage("Case is invalid because less than 2 cards were played.", "TacoCat")
                return
            end

            if hand_size == 2 then
                if played_ids[1] == played_ids[2] then
                    is_palindrome = true
                end
            elseif hand_size == 3 then
                if played_ids[1] == played_ids[3] then
                    is_palindrome = true
                end
            elseif hand_size == 4 then
                if played_ids[1] == played_ids[4] and played_ids[2] == played_ids[3] then
                    is_palindrome = true
                end
            elseif hand_size == 5 then
                -- Five-card palindrome (A-B-C-B-A), middle card doesn't matter
                if played_ids[1] == played_ids[5] and played_ids[2] == played_ids[4] then
                    is_palindrome = true
                end
            end

            if is_palindrome then
                card.ability.needToReview = false
                if not context.blueprint_card then
                    -- card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                    card.ability.extra = card.ability.extra + card.ability.extraGrowthRate
                    sendInfoMessage(
                        "Palindrome detected and original, upgrading! Earned extra now: " .. card.ability.extra,
                        "TacoCatPalindromeJoker")
                    return {
                        message = "PALINDROME",
                        colour = G.C.MULT,
                        card = card
                    }
                else
                    sendInfoMessage(
                        "Palindrome detected but we are in repetition or blueprint, not upgrading: " ..
                        card.ability.extra, "TacoCatPalindromeJoker")
                end
                -- return {
                --     x_mult = card.ability.extra,
                --     colour = G.C.RED,
                --     card = card,
                -- }
            else
                sendInfoMessage("Not a palindrome. Hand size: " .. hand_size, "TacoCatPalindromeJoker")
            end
        elseif context.joker_main then
            card.ability.needToReview = true
            return {
                x_mult = card.ability.extra,
                colour = G.C.RED,
                card = card,
            }
        end
    end
}

SMODS.Joker { --incremental hermie
    name = "Incremental Hermie",
    key = "IncrementalHermie",
    config = {
        x_mult = 1.0,
        x_mult_growth_rate = .25,
        requiredRank = 2,
        requiredRankStr = 2
    },
    loc_txt = {
        ['name'] = 'Incremental Hermie',
        ['text'] = {
            'Gains {X:mult,C:white}X#1#{} Mult if played hand contains three scoring {C:attention}#2#s{}',
            "Required rank increases after each upgrade",
            "{C:inactive}(Currently {X:mult,C:white}X#3#{} Mult)",
            '{s:0.9,C:inactive}This little hermit crab needs a bigger shell{}',
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.x_mult_growth_rate, card.ability.requiredRankStr, card.ability.x_mult } }
    end,
    pos = {
        x = 4,
        y = 1
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local thisRankCounted = 0
            for i = 1, #context.scoring_hand do
                local thisCard = context.scoring_hand[i]:get_id()

                sendInfoMessage("We need " .. card.ability.requiredRank .. " and played card was  " .. thisCard,
                    self.key)
                if thisCard == card.ability.requiredRank then
                    thisRankCounted = thisRankCounted + 1
                end
            end

            if thisRankCounted >= 3 then
                card.ability.requiredRank = card.ability.requiredRank + 1
                if card.ability.requiredRank >= 14 then card.ability.requiredRank = 2 end
                card.ability.requiredRankStr = get_card_value(card.ability.requiredRank)
                card.ability.x_mult = card.ability.x_mult + card.ability.x_mult_growth_rate
                sendInfoMessage("Would be upgrading xmult.  Changing requiredRank to " .. card.ability.requiredRank,
                    self.key)
                return {
                    delay = 0.2,
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.x_mult } },
                    colour = G.C.RED
                }
            end
        end
    end
}

SMODS.Joker { --Polecat
    name = "Pole Cat",
    key = "Polecat",
    config = {
        mult = 5,
        polarity = {},
        polarityStr = "suit and suit"
    },
    loc_txt = {
        ['name'] = 'Pole Cat',
        ['text'] = {
            [1] = 'Changes Polarity Every Round',
            [2] = 'Grants {C:red}+5{} Mult if played card suit is of matching Polarity',
            -- [3] = "{C:inactive}(Currently rewarding {X:mult,C:white}#1#{} and {X:mult,C:white}#2#{})", --"--{V:1}#1#{} and {V:2}#2#{} " --{X:mult,C:white}#1#{} and {X:mult,C:white}#2#{})",
            [3] = "{C:inactive}(Currently rewarding {V:1}#1#{} and {V:2}#2#{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        card.ability.polarity = getPolarity()
        card.ability.polarityStr = card.ability.polarity[1] .. " and " .. card.ability.polarity[2]
        local color1 = G.C.SUITS[card.ability.polarity[1]]
        local color2 = G.C.SUITS[card.ability.polarity[2]]
        local suit1 = localize(card.ability.polarity[1], 'suits_singular')
        local suit2 = localize(card.ability.polarity[2], 'suits_singular')
        sendInfoMessage(
            "suit1 is " .. suit1 .. "and suit2 is " .. suit2,
            self.key)

        inspect(color1)
        inspect(color2)

        return { vars = { suit1, suit2, colours = { color1, color2 } } }
    end,
    pos = {
        x = 2,
        y = 1
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            sendInfoMessage("We are reviewing played cards", self.key)
            local otherCard = context.other_card
            if otherCard:is_suit(card.ability.polarity[1]) or otherCard:is_suit(card.ability.polarity[2]) then
                sendInfoMessage("Other card is in [" .. card.ability.polarityStr .. "], let's rock", self.key)

                return {
                    mult = card.ability.mult,
                    colour = G.C.RED,
                    card = card,
                }
            end
        end
    end
}

SMODS.Joker { --Hanging Cat
    name = "Hanging Cat",
    key = "hangingCat",
    config = {
        extra = 2,
    },
    loc_txt = {
        ['name'] = 'Hanging Cat',
        ['text'] = {
            "Retrigger {C:attention}last{} played",
            "card used in scoring",
            "{C:attention}#1#{} additional times",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 6,
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
        if context.repetition and context.cardarea == G.play then
            local played_ids = {}
            local lastCard = context.scoring_hand[1]
            for i = 1, #context.scoring_hand do
                played_ids[i] = context.full_hand[i]:get_id()
                lastCard = context.scoring_hand[i]
            end
            local hand_size = #played_ids

            sendInfoMessage("Played hand was size:" .. hand_size, self.key)

            if context.other_card == lastCard then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra
                }
            end
        end
    end
}

SMODS.Joker { --redxiii
    name = "Red XIII",
    key = "redxiii",
    config = {
        extra = 2,
    },
    loc_txt = {
        ['name'] = 'Red XIII',
        ['text'] = {
            "Retriggers scored cards for played {C:attention}Cosmo Canyons{}",
            "{C:attention}#1#{} additional times",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 2,
        y = 0
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.poker_hands ~= nil and context.cardarea == G.play and next(context.poker_hands["Fox_cosmocanyon"]) then
            return {
                message = "Awooo",
                repetitions = card.ability.extra,
            }
        end
    end
}


SMODS.Joker { --Torgal  - boosts played flushes
    name = "Torgal",
    key = "torgal",
    config = {
        extra = 2,
    },
    loc_txt = {
        ['name'] = 'Torgal',
        ['text'] = {
            "Retriggers scored cards for played {C:attention}Cosmo Canyons{}",
            "{C:attention}#1#{} additional times",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 2,
        y = 0
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.poker_hands ~= nil and context.cardarea == G.play and next(context.poker_hands["Fox_cosmocanyon"]) then
            return {
                message = "Awooo",
                repetitions = card.ability.extra,
            }
        end
    end
}

SMODS.Joker { --flush tailed fox - boosts played flushes
    name = "Flush Tailed Fox",
    key = "flushFox",
    config = {
        extra = 2,
    },
    loc_txt = {
        ['name'] = 'Flush Tailed Fox',
        ['text'] = {
            "Retriggers scored cards for played {C:attention}Cosmo Canyons{}",
            "{C:attention}#1#{} additional times",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 2,
        y = 0
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.poker_hands ~= nil and context.cardarea == G.play and next(context.poker_hands["Fox_cosmocanyon"]) then
            return {
                message = "Awooo",
                repetitions = card.ability.extra,
            }
        end
    end
}




SMODS.Joker { --glass card 1
    name = "Become Unto Glass",
    key = "glass1",
    config = {
        extra = 2,
    },
    loc_txt = {
        ['name'] = 'Become Unto Glass',
        ['text'] = {
            "Played cards of {c:attention}#1#{} Rank become glass when played",            
            "{s:0.9}rank changes every round{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
        return { vars = { G.GAME.current_round.idol_card.rank, card.ability.extra } }
    end,
    pos = {
        x = 3,
        y = 0
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before then
            sendInfoMessage(" checking for played " .. G.GAME.current_round.idol_card.id .. "s", self.key)
            for _, playedCard in ipairs(context.scoring_hand) do
                if playedCard:get_id() == G.GAME.current_round.idol_card.id then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            playedCard:flip(); play_sound('card1'); playedCard:juice_up(0.3, 0.3); return true
                        end
                    }))

                    card:juice_up()
                    playedCard:set_ability(G.P_CENTERS.m_glass, nil, true)

                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            return {
                                message = { "Glassed" },
                                colour = G.C.FILTER,
                                card = playedCard,
                            }
                        end
                    }))

                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            playedCard:flip(); play_sound('tarot2',0.6); playedCard:juice_up(
                            0.3, 0.3); return true
                        end
                    }))
                end
            end
        end
            --and context.other_card and context.other_card:get_id() == G.GAME.current_round.idol_card.id then
            --sendInfoMessage(" other card was " .. context.other_card:get_id() .. " and required rank was " .. G.GAME.current_round.idol_card.id ,self.key)
            -- G.E_MANAGER:add_event(Event({
            --     trigger = 'after',
            --     delay = 0.15,
            --     func = function()
            --         context.other_card:flip(); play_sound('card1', percent); context.other_card:juice_up(0.3, 0.3); return true
            --     end
            -- }))



            -- G.E_MANAGER:add_event(Event({
            --     trigger = 'after',
            --     delay = 0.15,
            --     func = function()
            --         context.other_card:flip(); play_sound('tarot2', percent, 0.6); context.other_card:juice_up(0.3, 0.3); return true
            --     end
            -- }))
        -- else
        --     if context.repetition and context.cardarea == G.play and context.other_card:get_id() == G.GAME.current_round.idol_card.id then
        --         return {
        --             message = "Echo of creation",
        --             repetitions = card.ability.extra,
        --         }
        --     end
        -- end
    end
}


SMODS.Joker { --Echoes of glass
    name = "Echoes of Glass",
    key = "glass2",
    config = {
        extra = 2,
    },
    loc_txt = {
        ['name'] = 'Echoes of Glass',
        ['text'] = {
            "Retriggers glass cards cards",
            "{C:attention}#1#{} additional times",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 4,
        y = 0
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.repetition and context.other_card and context.other_card.ability.name == 'Glass Card' then
            return {
                message = "Reflect",
                repetitions = card.ability.extra,
            }
        end
    end
}


SMODS.Joker { --glass card 3 gains +mult when glass cards do not break
    name = "Glass Card III",
    key = "glass3",
    config = {
        extraGrowthRate = 2,
        shatteredObserved = 0,
        extra = 0
    },
    loc_txt = {
        ['name'] = 'Shatter Resisstant',
        ['text'] = {
            "Gains {C:red}+#1#{} mult when played glass cards do not break",
            "loses {C:red}1{} mult when glass breaks",
            "{s:0.9,C:inactive}Currently {c:red}+#2#{} mult{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
        return { vars = { card.ability.extraGrowthRate, card.ability.extra } }
    end,
    pos = {
        x = 8,
        y = 0
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
                mult = card.ability.extra,
                card = card
            }
        elseif context.cardarea == G.play and context.individual and context.other_card and context.other_card.ability.name == 'Glass Card' then
            sendInfoMessage(
            "observed played glass, mult was " ..
            card.ability.extra .. " now increasing to " .. card.ability.extra + card.ability.extraGrowthRate, self.key)
            card.ability.extra = card.ability.extra + card.ability.extraGrowthRate
  
            return {
                delay = 0.2,
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extraGrowthRate } },
                colour = G.C.RED, card = card
            }
        elseif context.remove_playing_cards and not context.blueprint then --and nil ~= context.not_broken would work but we need to patch smods
            sendInfoMessage("checking broken glass", self.key)

            local glass_cards = 0
            for k, val in ipairs(context.removed) do
                if val.shattered then glass_cards = glass_cards + 1 end
            end
            if glass_cards > 0 then
                card.ability.extra = card.ability.extra - 1
                return {
                    delay = 0.2,
                    message = localize { type = 'variable', key = 'a_mult_minus', vars = { 1 } },
                    colour = G.C.RED,
                    card = card
                }
            end
            return
        elseif context.remove_playing_cards then
            sendInfoMessage("would handle this case but not_broken is nil", self.key)
        end
    end
}
SMODS.Joker { --Joku
    name = "Joku",
    key = "joku",
    config = {
        extra = 1.7,
    },
    loc_txt = {
        ['name'] = 'Joku',
        ['text'] = {
            "Played cards with",
            "{C:attention}Super Sayan{} rank give",
            "{X:mult,C:white}X#1#{} Mult when scored",
            "{C:inactive}(2, 3, 4)",
            '{s:0.9,C:inactive}The Legendary Super Joker{}',
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 0,
        y = 0
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModEpicJokers',
    soul_pos = { x = 1, y = 0 },

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then --and not context .joker_main then
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)
            if cardInfo == 2 or cardInfo == "2"
                or cardInfo == 3 or cardInfo == "3"
                or cardInfo == 4 or cardInfo == "4" then
                return {
                    x_mult = card.ability.extra,
                    colour = G.C.RED,
                    card = card,
                }
            end
        end
    end
}

SMODS.Joker { --Kirbo
    name = "Kirbo",
    key = "kirbo",
    config = {
        extra = 1.0,
        extraGrowthRate = 0.3
    },
    loc_txt = {
        ['name'] = 'Kirbo',
        ['text'] = {
            "Eats ranks of non-face cards",
            "Decreases ranks of unscored cards by {C:attention}1{} for first hand",
            "Scored {c:attention}2's{} are destroyed, increasing xMult by {X:mult,C:white}#1#{}",
            "{C:inactive}Currently {X:mult,C:white}X#2#{}",
            '{s:0.9,C:inactive}Kirby was very hungry{}',
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extraGrowthRate, card.ability.extra } }
    end,
    pos = {
        x = 0,
        y = 1
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModEpicJokers',
    soul_pos = { x = 1, y = 1 },

    calculate = function(self, card, context)
        if context.after then
            local unscoredCards = {}

            -- for i = 1, #context.full_hand do
            --     played_ids[i] = context.full_hand[i]:get_id()
            -- end


            for i = 1, #context.full_hand do
                local thisCard = context.full_hand[i]
                if has_value(context.scoring_hand, thisCard) then
                    sendInfoMessage("card " .. thisCard:get_id() .. " was played and scored", self.key)

                    goldSealFound = 'true'
                else
                    sendInfoMessage("card " .. thisCard:get_id() .. " was played but not scored", self.key)
                    local cardINdex = #unscoredCards + 1
                    unscoredCards[cardINdex] = thisCard
                end
            end

            sendInfoMessage("count of unscored cards " .. #unscoredCards, self.key)
            local scoringSet = {}
            for _, card in ipairs(context.scoring_hand) do
                scoringSet[card] = true
            end

            local unscoredCards = {}

            for _, thisCard in ipairs(context.full_hand) do
                if scoringSet[thisCard] then
                    sendInfoMessage("card " .. thisCard:get_id() .. " was played and scored", self.key)
                else
                    sendInfoMessage("card " .. thisCard:get_id() .. " was played but not scored", self.key)
                    table.insert(unscoredCards, thisCard)
                end
            end

            sendInfoMessage("count of unscored cards " .. #unscoredCards, self.key)

            for _, thisUnscoredCard in ipairs(unscoredCards) do
                sendInfoMessage("confirming would be modifying card " .. thisUnscoredCard:get_id(), self.key)
                if thisUnscoredCard:get_id() > 10 or thisUnscoredCard:get_id() == 2 then
                    sendInfoMessage("This card is too high or a 2, skipping " .. thisUnscoredCard:get_id(), self.key)
                else
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            local suit_prefix = string.sub(thisUnscoredCard.base.suit, 1, 1) .. '_'
                            local rank_suffix = card.base.id == 2 and 14 or math.max(thisUnscoredCard.base.id - 1, 2)
                            rank_suffix = tostring(rank_suffix)
                            thisUnscoredCard:flip();
                            thisUnscoredCard:set_base(G.P_CARDS[suit_prefix .. rank_suffix])
                            return true
                        end
                    }))

                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            thisUnscoredCard:flip(); play_sound('tarot2', 0.6);
                            thisUnscoredCard:juice_up(0.3, 0.3);
                            return true
                        end
                    }))
                end
            end
            local played_ids = {}


            for i = 1, #context.full_hand do
                played_ids[i] = context.full_hand[i]:get_id()
            end

            --old logic, was based on the played hand
            -- local hand_size = #played_ids
            -- if hand_size ~= 1 then
            --     --not a high card, need to reset
            --     sendInfoMessage("Not a high card played! Played hand was " .. hand_size, self.key)
            --     return {remove = false}
            -- end
        elseif context.destroy_card and context.cardarea == G.play then
            --it was a  high card, we will eat 2's

            if context.destroy_card:get_id() == 2 then
                sendInfoMessage("This is a 2 " .. context.destroy_card:get_id(), self.key)

                card.ability.extra = card.ability.extra + card.ability.extraGrowthRate
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.45,
                    func = function()
                        play_sound("Fox_yoshiEat", 1.05)
                        context.destroy_card:juice_up(0.3, 0.3);
                        return { remove = true, card = context.destroy_card }
                    end
                }))
                sendInfoMessage("we are going to destroy this card", self.key)

                return { remove = true, card = context.destroy_card }
            end
        end
    end
}

SMODS.Booster({
    object_type = "Booster",
    key = "RarityCollection",
    kind = "Jokers",
    atlas = "FoxModBoosters",
    pos = { x = 0, y = 0 },
    config = { extra = 4, choose = 1 },
    cost = 10,
    order = 3,
    weight = 0.96,
    create_card = function(self, card)
        -- function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        local getCard = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, "foxNegation")
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
        name = "Rarity Collection",
        text = {
            "Choose {C:attention}#1#{} of",
            "up to {C:attention}#2# Special Edition Jokers{}",
        },
    },
    group_key = "Negation Pack",
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
    weight = 0.96,
    create_card = function(self, card)
        local getCard = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, "foxNegation")
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
        name = "Rarity Mega Collection",
        text = {
            "Choose {C:attention}#1#{} of",
            "up to {C:attention}#2# Special Edition Jokers{}",
        },
    },
    group_key = "Negation Pack",
})

SMODS.Booster({
    object_type = "Booster",
    key = "negation",
    kind = "Jokers",
    atlas = "FoxModBoosters",
    pos = { x = 0, y = 1 },
    config = { extra = 5, choose = 1 },
    cost = 15,
    order = 3,
    weight = 0.96,
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
    group_key = "Negation Pack",
})

SMODS.Booster({
    object_type = "Booster",
    key = "RarityStandardCollection",
    kind = "Card",
    atlas = "FoxModBoosters",
    pos = { x = 2, y = 0 },
    config = { extra = 4, choose = 1 },
    cost = 10,
    order = 3,
    weight = 0.96,
    create_card = function(self, card)
        --function create_playing_card(card_init, area, skip_materialize, silent, colours)

        local getCard = create_playing_card(nil, G.pack_cards, true, true, nil)
        sendInfoMessage("creating cards for this pack")
        local jokerInfo = inspect(getCard)
        sendInfoMessage("created joker card of " .. jokerInfo, self.key)
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
    group_key = "Negation Pack",
})

-- SMODS.Booster({
--     object_type = "Booster",
--     key = "negationOld",
--     kind = "Jokers",
--     atlas = "FoxModBoosters",
--     pos = { x = 0, y = 0 },
--     config = { extra = 4, choose = 1 },
--     cost = 15,
--     order = 1,
--     weight = 0.96,
--     create_card = function(self, card)
--         -- function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
--         local getCard = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, "foxNegation")
--         sendInfoMessage("creating cards for this pack")
--         local jokerInfo = inspect(getCard)
--         sendInfoMessage("created joker card of " .. jokerInfo)

--         getCard:set_edition('e_negative', false)
--         return getCard
--     end,
--     ease_background_colour = function(self)
--         ease_colour(G.C.DYN_UI.MAIN, G.C.BLUE)
--         ease_background_colour({ new_colour = G.C.SET.PURPLE, special_colour = G.C.BLACK, contrast = 2 })
--     end,
--     loc_vars = function(self, info_queue, card)
--         return { vars = { card.config.center.config.choose, card.ability.extra } }
--     end,
--     loc_txt = {
--         name = "Negation Pack Old",
--         text = {
--             "Choose {C:attention}#1#{} of",
--             "up to {C:attention}#2# Negative Jokers{}",
--         },
--     },
--     group_key = "Negation Pack",
-- })

SMODS.Booster({
    object_type = "Booster",
    key = "hologramPACK",
    kind = "Jokers",
    atlas = "FoxMod2xOnlyBooster",
    pos = { x = 0, y = 0 },
    config = { extra = 5, choose = 1 },
    cost = 10,
    order = 2,
    weight = 0.97,
    set_ability = function(self, card, initial, delay_sprites)
        sendInfoMessage("triggering post injection logic for this pack", self.key)

        card:set_edition('e_holo', false)
        card.cost = 10
    end,
    -- draw = function(self, card, layer)
    --     self:draw_shader('holo' , nil, nil, true)
    -- end,
    create_card = function(self, card)
        -- function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        local getCard = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, "foxholo")
        sendInfoMessage("creating cards for this pack")
        local jokerInfo = inspect(getCard)
        sendInfoMessage("created joker card of " .. jokerInfo, self.key)

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
    group_key = "Negation Pack",
})

sendInfoMessage("Completed processing jokers", "essay.lua")

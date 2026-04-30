sendInfoMessage("Processing jokers", "essay.lua")

sendInfoMessage("State of config", "essay.lua")

if FoxModConfig.playSounds then
    sendInfoMessage("FoxMod.config.playSounds enabled")
else
    sendInfoMessage("FoxMod.config.playSounds disabled")
end

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

local function poll_pseudorandom_customEditions()
    local edition_poll = pseudorandom(pseudoseed(_key or 'edition_generic'))

    if edition_poll > 1 - 0.006 * 25 then
        return "e_Fox_fragileRelic"
    elseif edition_poll > 1 - 0.02 * 25 then
        return "e_Fox_goldRare"
    elseif edition_poll > 1 - 0.04 * 25 then
        return "e_Fox_secretRare"
    end
end

local function poll_with_custom_editions()
    local edition = poll_edition('aura', nil, true, true)

    if nil == edition then
        return poll_pseudorandom_customEditions()
    else
        return edition
    end
end

function applyAbilityWithStyle(ability, card, trigger)
    --flip card
    if nil == trigger then
        trigger = 'after'
    end
    G.E_MANAGER:add_event(Event({
        trigger = trigger,
        delay = 0.35,
        func = function()
            card:flip(); play_sound('card1', percent);
            card:juice_up(0.3, 0.3); return true
        end
    }))

    --apply
    if ability == "fail" then
    elseif ability == "GoldSeal" then
        card:set_seal("Gold", true)
    else
        card:set_ability(ability)
    end


    --juice

    G.E_MANAGER:add_event(Event({
        trigger = trigger,
        delay = 0.35,
        func = function()
            card:flip(); play_sound('card1', percent);
            return true
        end
    }))
    --flip back
end

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

function applyBoonWithOdds(odds, cards)
    for _, playedCard in ipairs(cards) do
        if pseudorandom('ficklefox_moogle') < G.GAME.probabilities.normal / odds then
            boonApplied = true
            sendInfoMessage("this card was lucky, adding a special boon")

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    local over = false
                    local edition = poll_with_custom_editions()

                    if playedCard.ability.effect == "Base" or
                        nil == playedCard.edition then
                        sendInfoMessage("this card was a base, adding a special boon")
                        playedCard:set_edition(edition, true)
                    end

                    return {
                        message = { "Boon Granted" },
                        colour = G.C.FILTER,
                        card = playedCard,
                    }
                end
            }))
        else
            sendInfoMessage("this card was unlucky, no boon")
        end
    end
end

SMODS.Joker { --Good Doggie
    name = "Golden Repeater",
    key = "goldretriever",
    config = {
        odds = 15,
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
        info_queue[#info_queue + 1] = { key = "artistcredit", set = "Other", vars = { "Linzra" } }
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, 3 } } -- Fix for missing values
    end,
    pos = {
        x = 0,
        y = 0
    },
    enhancement_gate = 'm_gold',
    cost = 5,
    rarity = 3,
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
                --sendInfoMessage("LuckY! Copying this card", "goldenRepeater")
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
                    trigger = 'after',
                    delay = 0.2,                    
                    func = function()
                        _card:start_materialize()
                        return true
                    end
                }))
            end --end check to copy
            --if we don't meet the odds, it's still a gold card so retrigger once
            -- sendInfoMessage("Not so lucky, only reproccing this gold card", "goldenRepeater")
            return {
                message = localize('k_again_ex'),
                repetitions = 1
            }

        elseif context.cardarea == G.play and context.other_card and context.other_card.ability and context.other_card.ability.name == 'Gold Card' and context.repetition or
            context.cardarea == G.play and context.other_card and context.other_card.edition and context.other_card.edition.key == "e_Fox_goldRare" and context.repetition then
            --card is golden, roll to see if we copy it
            --if we don't meet the odds, it's still a gold card so retrigger once
            sendInfoMessage("Repeating!  This is the alst call for this gold card", "goldenRepeater")

            return {
                message = localize('k_again_ex'),
                repetitions = 1
            }
            --reviewing card held in hand, if they're gold we retrigger them still
        elseif context.repetition and context.cardarea == G.hand and context.other_card.ability and context.other_card.ability.name == 'Gold Card' or
            context.repetition and context.cardarea == G.hand and context.other_card and context.other_card.edition and context.other_card.edition.key == "e_Fox_goldRare" then
            sendInfoMessage("Reproccing this gold card held in hand!", "goldenRepeater")

            if (next(context.card_effects[1]) or #context.card_effects > 1) then

                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra
                }
            end
        end
    end
}

SMODS.Joker {
    name = "Lucky Retriever",
    key = "luckyretriever",
    config = {
        odds = 15,
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
        info_queue[#info_queue + 1] = { key = "artistcredit", set = "Other", vars = { "OhPahn!" } }
        info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, 3 } }
    end,
    pos = {
        x = 1,
        y = 2
    },
    enhancement_gate = 'm_lucky',
    cost = 6,
    rarity = 3,
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
        if context.cardarea == G.play and context.other_card and context.other_card.ability 
            and context.other_card.ability.name == 'Lucky Card' then
            
            if pseudorandom('luckyretriever') < G.GAME.probabilities.normal / card.ability.odds then
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
            end --end check to copy
            --if we don't meet the odds, it's still a gold card so retrigger once
            return {
                message = localize('k_again_ex'),
                repetitions = 1
            }

            --reviewing card held in hand, if they're gold we retrigger them still
        elseif context.repetition and context.cardarea == G.hand and context.other_card.ability and context.other_card.ability.name == 'Lucky Card' then
            if (next(context.card_effects[1]) or #context.card_effects > 1) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra
                }
            end
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
        info_queue[#info_queue + 1] = { key = "artistcredit", set = "Other", vars = { "Linzra" } }
        return { vars = { card.ability.chips } }
    end,
    pos = {
        x = 7,
        y = 2
    },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
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
            
            --sendInfoMessage("Chips are now " .. card.ability.chips .. " chip change = " .. chipChange, self.key)

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

SMODS.Joker { --fickleFox
    name = "Fickle Fox",
    key = "ficklefox",
    config = {
        oddsToBless = 3,
        oddsToFlee = 12,
        extra = 1,
        remaining = 7
    },
    loc_txt = {
        ['name'] = 'Fickle Fox',
        ['text'] = {
            [1] = '{C:attention}Applies gold seal randomly to cards played',
            [2] = 'Has a {C:green}#1# in #2#{} chance to bless',
            [3] = 'Has a {C:green}#1# in #3#{} chance to vanish with the wind',
            [4] = 'Flees after 6 seals applied, {C:red}#4# seals remaining ',
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = "artistcredit", set = "Other", vars = { "Linzra" } }
        info_queue[#info_queue + 1] = { key = 'gold_seal', set = 'Other' }
        return { vars = { G.GAME.probabilities.normal, card.ability.oddsToBless, card.ability.oddsToFlee, card.ability.remaining } }
    end,
    pos = {
        x = 6,
        y = 0
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    no_pool_flag = 'fickledfoxfled',
    set_ability = function(self, card, initial, delay_sprites)
        G.GAME.pool_flags.fickledfoxHeld = true
    end,

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
            --sendInfoMessage("deciding if we flee", "FickleFox")
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

            if othercardSeal == "Gold" or "" ~= othercardSeal then
                --sendInfoMessage("Other card has Gold seal already, skipping", "FickleFox")
                return
            elseif pseudorandom("ficklefox") < G.GAME.probabilities.normal / card.ability.oddsToBless then
                card:juice_up()

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
            [3] = 'to cards with {C:attention}gold seals{} in your hand',
            [4] = "Has a {C:green}#1# in #3#{} chance to {C:attention}spread gold seals{} in played flushes",
            '{s:0.9,C:inactive}The big brother to Fickle Fox{}',
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
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    yes_pool_flag = 'fickledfoxHeld',

    --when scoring, check for presence of gold seal.  If present, apply xMult to that card
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and context.other_card and context.other_card.seal and context.other_card.seal == 'Gold' and not context.end_of_round then
            -- if context.individual and context.after then
            -- if context.cardarea == G.hand then
            --sendInfoMessage("We are reviewing cards in hand", "BenevloanceJoker")
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)
            -- if card.seal then  --need to be sure it is a gold seal, not a blue or red
            if otherCard.seal == 'Gold' then
                sendInfoMessage("Card" .. cardInfo .. " has GOLD seal, let's rock", self.key)

                return {
                    x_mult = card.ability.extra,
                    colour = G.C.RED,
                    card = card,
                }
            else
                local sealinfo = getValueNilSafe(otherCard.seal)
                sendInfoMessage("Card" .. cardInfo .. " has no seal, or seal of" .. sealinfo, self.key)
            end
            -- end
            --context.cardarea == G.play and context.other_card and context.other_card.ability and context.other_card.ability.name == 'Gold Card' and not context.end_of_round then
        elseif context.cardarea == G.jokers and context.before then
            --review played  hand, see if any cards have gold seal and is a flush or flush house or five of a kind
            --if so, then 50% chance to apply goldseals on other cards (don't overwrite)
            local goldSealFound = 'false'
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].seal == 'Gold' then
                    goldSealFound = 'true'
                end
            end
            sendInfoMessage(
                "Gold seal found: " ..
                goldSealFound .. " & hand played is " .. G.GAME.current_round.current_hand.handname,
                self.key)

            if G.GAME.current_round.current_hand.handname == "Royal Flush" or
                G.GAME.current_round.current_hand.handname == "Flush" or
                G.GAME.current_round.current_hand.handname == "Flush House" or
                G.GAME.current_round.current_hand.handname == "Flush Five" or
                G.GAME.current_round.current_hand.handname == "Five of a Kind" or
                G.GAME.current_round.current_hand.handname == "Four of a Kind" then

                    local needToDisplayToast = true
                for i = 1, #context.scoring_hand do
                    local otherCard = context.scoring_hand[i]
                    if otherCard.seal then --exit early is already sealed
                    else
                        if pseudorandom("benevolence") < G.GAME.probabilities.normal / card.ability.oddsToBless then
                            card:juice_up()

                            if needToDisplayToast then 
                                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                                    message = "Spreading the Blessing",
                                    colour = G.C.FILTER
                                })
                                needToDisplayToast = false
                            end
                            
                            applyAbilityWithStyle("GoldSeal", otherCard, before)
                            
                        else
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
            "Unlocks the {C:dark_edition}Shun Goku Satsu{} hand",
            'Gains {C:chips}+#1#{} chips when tens are scored',
            'applies {C:red}+#2#{} Mult per ten played',
            'Currently {C:chips}+#3#{} chips'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.chipGrowthRate, card.ability.plusMult, card.ability.chips } }
    end,
    pos = {
        x = 5,
        y = 0
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    set_ability = function(self, card, initial, delay_sprites)
        G.GAME.pool_flags.akumaHeld = true
    end,


    calculate = function(self, card, context)
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

                if FoxModConfig.playSounds then
                    return {
                        extra = { focus = card, message = localize('k_upgrade_ex') },
                        card = card,
                        colour = G.C.CHIPS,
                        sound = "Fox_metsu"
                    }
                else
                    return {
                        extra = { focus = card, message = localize('k_upgrade_ex') },
                        card = card,
                        colour = G.C.CHIPS
                    }
                end

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
                    -- x_mult = card.ability.extra,
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
                if FoxModConfig.playSounds then
                    return {
                        x_mult = card.ability.extra,
                        colour = G.C.BLUE,
                        card = otherCard,
                        sound = "Fox_metsu"
                    }
                else
                    return {
                        x_mult = card.ability.extra,
                        colour = G.C.BLUE,
                        card = otherCard,
                    }
                end
            end
        end
    end
}


SMODS.Joker { --Shin Akuma
    name = "Shin A kuma",
    key = "shinAKuma",
    config = {
        odds = 4,
        extra = 1
    },
    loc_txt = {
        ['name'] = 'Shin A Kuma',
        ['text'] = {
            '{C:attention}Retriggers{} all {C:attention}10{}, played or in hand',
            "Per level of the {C:dark_edition}Shun Goku Satsu{} hand",
            "{c:inactive}Currently Retriggering {c:attention}#1#{} additional times"
        },
        ['unlock'] = {
            "Play a hand made of all 10's",
            "While holding {c:attention}A Kuma{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = "artistcredit", set = "Other", vars = { "Akravator" } }

        local hand_name = "Fox_shungokusatsu"
        local retrigger = G.GAME.hands[hand_name].level or 1
        return { vars = { retrigger } }
    end,
    pos = {
        x = 9,
        y = 0
    },
    cost = 8,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    yes_pool_flag = 'akumaHeld',
    check_for_unlock = function(self, args)
        if next(SMODS.find_card("j_Fox_akuma")) then
            if G.GAME.hands["Fox_shungokusatsu"].played ~= 0 then
                unlock_card(self)
            end
        end
    end,


    calculate = function(self, card, context)
        --region :scoring the card when played
        --        if context.individual and context.cardarea == G.play then

        -- if context.individual and context.cardarea == G.play and context.repetition then
        if context.cardarea == G.play and context.repetition and context.other_card then
            -- if context.individual and context.cardarea == G.play and context.repetition then
            local hand_name = "Fox_shungokusatsu"
            local retrigger = tonumber(format_ui_value(G.GAME.hands[hand_name].level))
            card.ability.extra = retrigger

            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)
            sendInfoMessage("Played Card " .. cardInfo .. " as joker we have retriggers " .. retrigger .. " retrigger",
                self.key)

            if cardInfo == 10 or cardInfo == "10" then
                sendInfoMessage("Played Card " .. cardInfo .. " is a ten, retriggering " .. retrigger .. " times",
                    card.key)
                if FoxModConfig.playSounds then
                    return {
                        repetitions = card.ability.extra,
                        card = card,
                        sound = "Fox_metsu"
                    }
                else
                    return {
                        repetitions = card.ability.extra,
                        card = card
                    }
                end
            end
        elseif context.individual and context.cardarea == G.hand and context.other_card and context.repetition and not context.end_of_round then
            local hand_name = "Fox_shungokusatsu"
            local retrigger = G.GAME.hands[hand_name].level or 1
            card.ability.extra = retrigger
            sendInfoMessage("Reviewing cards held in hand", "AKUMA")
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            if cardInfo == 10 or cardInfo == "10" then
                sendInfoMessage("Held Card " .. cardInfo .. " is a ten, retriggering " .. retrigger .. " times", card
                    .key)
                -- play_sound("Fox_metsu", 0.85)
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra,
                    card = card,
                    sound = "Fox_metsu"
                }
            end
        end
        if nil ~= context.poker_hands and next(context.poker_hands["Fox_shungokusatsu"]) and context.after then
            play_sound("Fox_akumaClear", 1)
            local getCard = create_playing_card(nil, G.pack_cards, true, true, nil)
            getCard.base.id = 10
            sendInfoMessage("adding a  " .. getCard.base.id .. " ", "ShinAkuma")

            getCard:add_to_deck()
            G.deck.config.card_limit = G.deck.config.card_limit + 1

            G.hand:emplace(getCard)
            table.insert(G.playing_cards, getCard)
            playing_card_joker_effects({ true })
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                { message = "METSU", colour = G.C.FILTER })
            getCard.states.visible = nil

            G.E_MANAGER:add_event(Event({
                func = function()
                    getCard:start_materialize()
                    return true
                end
            }))
        end
        --if hand was shun_goku_satsu, and score is winning, then add another ten to the deck and
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
        },
        ["unlock"] = {
            "Play a hand with",
            "Three or more Holographic cards"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal, card.ability.odds } }
    end,
    pos = {
        x = 4,
        y = 2
    },
    enhancement_gate = 'm_holo',
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local tally = 0
            for j = 1, #args.cards do
                if args.cards[j].edition and args.cards[j].edition.key == "e_holo" then
                    tally = tally + 1
                end
            end
            if tally >= 3 then
                unlock_card(self)
            end
        end
    end,
    set_ability = function(self, card, initial, delay_sprites)
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

SMODS.Joker { --Sun and Moon
    name = "Sun and Moon",
    key = "sunandmoon",
    config = {
        plusMult = 6,
        chips = 9
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
    cost = 5,
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
        info_queue[#info_queue + 1] = { key = "artistcredit", set = "Other", vars = { "MarioFan597" } }
        info_queue[#info_queue + 1] = { key = 'blue_seal', set = 'Other' }
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 7,
        y = 1
    },
    cost = 6,
    rarity = 2,
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
        if context.individual and not context.after then
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
        info_queue[#info_queue + 1] = { key = "artistcredit", set = "Other", vars = { "MarioFan597" } }
        local card0 = "#@" ..
            (G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.id or 11) ..
            (G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.suit:sub(1, 1) or 'D')

        return { vars = { card0 } }
    end,
    pos = {
        x = 8,
        y = 1
    },
    cost = 5,
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
    cost = 8,
    rarity = 2,
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
        elseif context.cardarea == G.jokers and context.before and G.GAME.current_round.hands_played > 0 then
            --prob check for free upgrade
            sendInfoMessage("checking for freebie")
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

SMODS.Joker { --rat of death
    name = "The Death of Rats",
    key = "deathOfRats",
    config = {
        ready = false,
        handsTillReady = 4,
        remainingDefault = 4,
        multBounty = 0,
        multBountyGrowthRate = 5,
        obliterate = false
    },
    loc_txt = {
        ['name'] = 'The Death of Rats',
        ['text'] = {
            [1] = 'Every 4 hands played, destroys the next card played, if hand is a High Card',
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
    cost = 10,
    rarity = 2,
    blueprint_compat = true,
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

            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                message = "Death comes",
                colour = G.C.FILTER
            })
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
        extra = 1.0,
        needToReview = true

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
    cost = 7,
    rarity = 3,
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
        requiredRankStr = 2,
        freeCrunchWrap = false
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
    cost = 7,
    rarity = 2,
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
                if card.ability.requiredRank >= 14 then
                        card.ability.requiredRank = 2 
                        card.ability.freeCrunchWrap = true
                end
                card.ability.requiredRankStr = get_card_value(card.ability.requiredRank)
                card.ability.x_mult = card.ability.x_mult + card.ability.x_mult_growth_rate
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                    message = "Level up!",
                    colour = G.C.FILTER
                })

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
        mult = 7,
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
        },
        ['unlock'] = {
            "Must Obtain",
            "The Ancient Joker",
            "To Unlock the",
            "Cute One"
        }
    },
    check_for_unlock = function(self, args)
        if next(SMODS.find_card("j_ancient")) then
            unlock_card(self)
        end
    end,
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
    cost = 8,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
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


--enhancement_gatr
SMODS.Joker { --Thwomp
    name = "Thwomp",
    key = "thwomp",
    config = {
        chips = 0,
        chips_rate = 10,
    },
    loc_txt = {
        ['name'] = 'Thwomp',
        ['text'] = {
            "Gains {C:chips}+#1#{} chips when Stone cards trigger",
            "{C:attention}Currently {C:chips}+ #2#{} chips",
        },
        ["unlock"] = {
            "Play a hand with",
            "Three or more Stone Cards"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
        return { vars = { card.ability.chips_rate, card.ability.chips } }
    end,
    pos = {
        x = 2,
        y = 3
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    enhancement_gate = 'm_stone',
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local tally = 0
            for j = 1, #args.cards do
                if args.cards[j].config.center == G.P_CENTERS.m_stone then
                    tally = tally + 1
                end
            end
            if tally >= 3 then
                unlock_card(self)
            end
        end
    end,

    calculate = function(self, card, context) --context.other_card.ability and context.other_card.ability.name == 'Gold Card'
        if context.individual and context.cardarea == G.play and context.other_card.ability and context.other_card.ability.name == 'Stone Card' then
            sendInfoMessage("1849, new method for held stone", self.key)

            card.ability.chips = card.ability.chips + card.ability.chips_rate
            card:juice_up()
            return {
                message = localize('k_upgrade_ex'),
                card = card
            }
        elseif context.joker_main then
            return {
                chips = card.ability.chips,
                card = card
            }
        end
    end
}


SMODS.Joker { --Hanging Cat
    name = "Hang in there",
    key = "hanginthere",
    config = {
        extra = 2,
    },
    loc_txt = {
        ['name'] = 'Hang in There',
        ['text'] = {
            "Retrigger {C:attention}last{} played",
            "card used in scoring",
            "{C:attention}#1#{} additional times",
        },
        ["unlock"] = {
            "Play a hand while",
            "Holding the Hanging Chad"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 6,
        y = 2
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    check_for_unlock = function(self, args)
        if next(SMODS.find_card("j_hanging_chad")) then
            unlock_card(self)
        end
    end,

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


SMODS.Joker { --flushTailed fox - boosts played flushes
    name = "Flush Tailed Fox",
    key = "flushFox",
    config = {
        extra = 2,
        ready = false
    },
    loc_txt = {
        ['name'] = 'Flush Tailed Fox',
        ['text'] = {
            "Retriggers scored cards for played {C:attention}Flush{} or Flush House Hands",
            "{C:attention}#1#{} additional times",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 0,
        y = 3
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.after then
            card.ability.ready = false
        elseif nil == context.poker_hands then
            card.ability.ready = false
        elseif context.cardarea == G.play and context.repetition then
            if card.ability.ready then
                sendInfoMessage("hand is scoring and we are ready", self.key)

                return {
                    message = "Awooo",
                    repetitions = card.ability.extra                    
                }
                -- else
                --     sendInfoMessage("Somehow we are here and is wasnt a flush family", self.key)
            end
        end
        if nil ~= context.poker_hands and next(context.poker_hands["Flush"]) or
            nil ~= context.poker_hands and next(context.poker_hands["Flush Five"]) or
            nil ~= context.poker_hands and next(context.poker_hands["Flush House"]) then
            if false == card.ability.ready then
                sendInfoMessage("Joker is now READY!", self.ket)
                card.ability.ready = true;
            end

            local eval = function(card) return (nil ~= context.poker_hands and card.ability.ready == true) end
            juice_card_until(card, eval, true)
        end
    end
}

SMODS.Joker { --chocobo
    name = "Chocobo Straightaway",
    key = "chocobo",
    config = {
        extraGrowthRate = 5,
        extra = 0
    },
    loc_txt = {
        ['name'] = 'Chocobo Straightaway',
        ['text'] = {
            "Gains {C:mult}#1#{} mult when a scored hand contains a {C:attention}Straight{}",
            "{C:inactive}(Currently{} {C:mult}+#2#{} {C:inactive}Mult){}"
        },
        ["unlock"] = {
            "Level the Straight Hand",
            "To level Five or more"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extraGrowthRate, card.ability.extra } }
    end,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local straightLevel = tonumber(format_ui_value(G.GAME.hands["Straight"].level))
            if straightLevel > 4 then
                unlock_card(self)
            end
        end
    end,
    pos = {
        x = 8,
        y = 2
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra,
                card = card
            }
        elseif context.cardarea == G.jokers and context.before and nil ~= context.poker_hands and next(context.poker_hands['Straight']) and not context.blueprint then
            card.ability.extra = card.ability.extra + card.ability.extraGrowthRate
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = self
            }
        end
    end
}

if FoxModConfig.customHands then
    SMODS.Joker { --redxiii
        name = "Red XIII",
        key = "redxiii",
        config = {
            extra = 2,
            ready = false,
        },
        loc_txt = {
            ['name'] = 'Red XIII',
            ['text'] = {
                "Unlocks the {C:attention}Cosmo Canyon{} hand",
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
        cost = 5,
        rarity = 2,
        blueprint_compat = false,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = 'FoxModJokers',
        calculate = function(self, card, context)
            if context.after or context.end_of_round then
                card.ability.ready = false
            elseif context.cardarea == G.play and context.repetition then
                if card.ability.ready then
                    sendInfoMessage("hand is scoring and we are ready", "redXiii")

                    return {
                        message = "Awooo",
                        repetitions = card.ability.extra
                    }
                else
                    sendInfoMessage("Somehow we are here and is wasnt a cosmo canyon", "redXiii")
                end
            end
            if nil ~= context.poker_hands and not next(context.poker_hands["Fox_cosmocanyon"]) then
                card.ability.ready = false
            end
            if nil ~= context.poker_hands and next(context.poker_hands["Fox_cosmocanyon"]) then
                if false == card.ability.ready then
                    sendInfoMessage("Joker is now READY!", "redXiii")
                    card.ability.ready = true;
                end

                local eval = function(card) return (card.ability.ready == true) end
                juice_card_until(card, eval, true)
            end
        end
    }


    SMODS.Joker { --Torgal  - boosts played flushes
        name = "Torgal",
        key = "torgal",
        config = {
            extra = 2,
            ready = false
        },
        loc_txt = {
            ['name'] = 'Torgal',
            ['text'] = {
                "Unlocks the {C:attention}Full Moon{} hand",
                "Retriggers scored cards for played {C:attention}Full Moons{}",
                "{C:attention}#1#{} additional times",
            }
        },
        loc_vars = function(self, info_queue, card)
            return { vars = { card.ability.extra } }
        end,
        pos = {
            x = 0,
            y = 2
        },
        cost = 5,
        rarity = 2,
        blueprint_compat = false,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = 'FoxModJokers',

        calculate = function(self, card, context)
            if context.after then
                card.ability.ready = false
            elseif context.cardarea == G.play then
                if card.ability.ready then
                    sendInfoMessage("hand is scoring and we are ready", self.key)

                    return {
                        message = "Awooo",
                        repetitions = card.ability.extra                        
                    }
                else
                    sendInfoMessage("Somehow we are here and is wasnt a cosmo canyon", self.key)
                end
            end
            if nil ~= context.poker_hands and next(context.poker_hands["Fox_fullmoon"]) then
                if false == card.ability.ready then
                    sendInfoMessage("Joker is now READY!", self.ket)
                    card.ability.ready = true;
                end

                local eval = function(card) return (card.ability.ready == true) end
                juice_card_until(card, eval, true)
                -- elseif nil ~= context.poker_hands and !next(context.poker_hands["Fox_cosmocanyon"]) then
                -- elseif nil ~= context.poker_hands then
                --     if next(context.poker_hands["Fox_cosmocanyon"]) then else card.ability.ready = false end
                --context.individual
                --seif context.individual and context.cardarea == G.hand and context.other_card.ability and context.other_card.ability.name == 'Grass Card' and not context.after then
                --if context.repetition and context.cardarea == G.play
            end
        end,
        -- calculate = function(self, card, context)
        --     if context.after then card.ability.ready = false end
        --     if nil ~= context.poker_hands and next(context.poker_hands["Fox_fullmoon"]) then
        --         card.ability.ready = true;
        --         local eval = function(card) return (card.ability.ready == true) end
        --         juice_card_until(card, eval, true)
        --     -- elseif nil ~= context.poker_hands and !next(context.poker_hands["Fox_cosmocanyon"]) then
        --     elseif nil ~= context.poker_hands then
        --         if next(context.poker_hands["Fox_fullmoon"]) then else card.ability.ready = false end
        --     if context.poker_hands ~= nil and context.cardarea == G.play and next(context.poker_hands["Fox_fullmoon"]) then
        --         return {
        --             message = "Awooo",
        --             repetitions = card.ability.extra,
        --         }
        --         end
        --     end
        -- end
    }
end

SMODS.Joker { --Cait Sith
    name = "Cait Sith",
    key = "caitSith",
    config = {
        extraGrowthRate = 5,
        extra = 0,
        odds = 3
    },
    loc_txt = {
        ['name'] = 'Cait Sith',
        ['text'] = {
            "Played {c:attention}7{} cards",
            "have a {C:green}#1# in #2#{} chance to become {c:green}Lucky{} when scored",
            "{c:inactive}{s:0.8}Cait Sith seemed to have suspiciously good luck and is no longer welcome in Golden Saucer{}{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        return { vars = { G.GAME.probabilities.normal, card.ability.odds } }
    end,
    pos = {
        x = 5,
        y = 3
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    add_to_deck = function(self, card, from_debuff)
        sendInfoMessage("added to deck, altering reality", self.key)
        for k, v in pairs(G.GAME.probabilities) do
            local old = G.GAME.probabilities[k]
            G.GAME.probabilities[k] = v * 1.25
            local new = G.GAME.probabilities[k]
            sendInfoMessage("odds were " .. old .. " and now became " .. new, self.key)
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            sendInfoMessage("Reviewing cards in played area", self.key)

            for _, playedCard in ipairs(context.scoring_hand) do
                local rank = playedCard:get_id()
                if rank == 7 or rank == "7" then
                    if pseudorandom('caitSith') < G.GAME.probabilities.normal / card.ability.odds then
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                            message = "LUCKY 7",
                            colour = G.C.FILTER
                        })
                        applyAbilityWithStyle("m_lucky", playedCard)
                        playedCard:juice_up()
                    else
                        applyAbilityWithStyle("fail", playedCard)
                    end
                end
            end
        end
    end
}

SMODS.Joker { --moogle
    name = "Moogle Dance",
    key = "mog",
    config = {
        extraGrowthRate = 5,
        extra = 0,
        odds = 3,
        to_do_poker_hand = "Flush"
    },
    loc_txt = {
        ['name'] = 'Moogle Dance',
        ['text'] = {
            "Played cards have a {C:green}#1# in #2#{} chance",
            "to recieve a {c:attention}random enhancement{} or {c:dark_edition}edition{} when scored",
            "if {C:attention}poker hand{} is a {C:attention}#3#{}",
        },
        ["unlock"] = {
            "Obtain 10 or more",
            "Enhanced Cards"
        }

    },
    loc_vars = function(self, info_queue, card)
        -- local safeHand = card.ability.to_do_poker_hand or "SomeHand"
        if nil == card.ability.to_do_poker_hand then reset_todoList() end
        card.ability.to_do_poker_hand = G.GAME.current_round.to_do_poker_hand
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, localize(card.ability.to_do_poker_hand, 'poker_hands') } }
    end,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local enhancedTally = 0
            for k, v in pairs(G.playing_cards) do
                if v.config.center ~= G.P_CENTERS.c_base then enhancedTally = enhancedTally + 1 end
            end
            if enhancedTally >= 10 then
                unlock_card(self)
            end
        end
    end,
    pos = {
        x = 4,
        y = 3
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    set_ability = function(self, card, initial, delay_sprites)
        print("checking for previous todo list joker, we will respect its hand")
        local foundTodo = false
        if nil == G.jokers then
            print("no jokers, resetting todo")
            reset_todoList()
            card.ability.to_do_poker_hand = G.GAME.current_round.to_do_poker_hand
            return
        end
        print("other jokers existed, iterating")
        for _, joker in ipairs(G.jokers.cards) do
            if joker.label == "To Do List" or joker.label == "To Do list" then
                foundTodo = true
                print("respecting present todo list hand which is " .. joker.ability.to_do_poker_hand, "Moog")
                card.ability.to_do_poker_hand = joker.ability.to_do_poker_hand
            end
        end

        if (false == foundTodo) then
            print("no to do list joker, resetting todo")
            reset_todoList()
            card.ability.to_do_poker_hand = G.GAME.current_round.to_do_poker_hand
        end
    end,
    calculate = function(self, card, context)
        if context.ending_shop then
            sendInfoMessage("leaving shop, resetting", self.key)
            card:set_ability(self, card)
        end
        if context.cardarea == G.jokers and context.before and context.scoring_name == card.ability.to_do_poker_hand then
            local cards = context.scoring_hand
            flipAllCards(cards)

            sendInfoMessage("Flipped all cards, need to implement adding a special boon")

            delay(0.3)

            applyBoonWithOdds(card.ability.odds, cards)

            flipAllCards(cards)

            delay(0.5)
        end
        if context.joker_main then
            return {
                mult = card.ability.extra,
                card = card
            }
        elseif context.cardarea == G.jokers and context.before and nil ~= context.poker_hands and next(context.poker_hands['Straight']) and not context.blueprint then
            card.ability.extra = card.ability.extra + card.ability.extraGrowthRate
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = self
            }
        end
    end
}

SMODS.Joker { --Mochicat
    name = "Mochicat",
    key = "mochiCat",
    config = {
        extra = 2,
        affected_cards = {
            2, 4, 7, 8
        }
    },
    loc_txt = {
        ['name'] = 'Mochicat',
        ['text'] = {
            "A Chocolate Mochi Cat",
            "Retrigger each played",
            "{C:attention}7{}, {C:attention}8{}, {C:attention}4{}, or {C:attention}2{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 3,
        y = 3
    },
    cost = 7,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            for _, affectedCard in ipairs(card.ability.affected_cards) do
                if cardInfo == affectedCard then 
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra,
                    }
                end
            end
        end
        if context.cardarea == G.play and context.repetition and context.other_card then            
            print ("in second block")
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            for _, affectedCard in ipairs(card.ability.affected_cards) do
                --print ("comparing " .. affectedCard  .. " to played card of " .. cardInfo .. " type =" ..type(cardInfo))

                if cardInfo == affectedCard or cardInfo == tostring(affectedCard) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra,
                    }
                end
            end
        end
    end
}

SMODS.Joker { --Teafant
    name = "Teafant",
    key = "teafant",
    config = {
        extra = 2,
    },
    loc_txt = {
        ['name'] = 'Teafant',
        ['text'] = {
            "Retriggers scored or held grass cards",
            "{C:attention}#1#{} additional times",
        },
        ["unlock"] = {
            "Play a hand containing one or more",
            "{C:dark_edition}Grass Cards{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_Fox_grass
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 6,
        y = 3
    },
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local tally = 0
            for j = 1, #args.cards do
                if args.cards[j].config.center == G.P_CENTERS.m_Fox_grass then
                    tally = tally + 1
                end
            end
            if tally >= 1 then
                unlock_card(self)
            end
        end
    end,
    cost = 7,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    enhancement_gate = 'm_Fox_grass',

    calculate = function(self, card, context) --context.other_card.ability and context.other_card.ability.name == 'Gold Card'
        -- if context.repetition and not context.repetition_only and context.other_card and context.other_card.ability and context.other_card.ability.name == "Grass Card" then
        -- -- playing card retriggers using .repetition
        -- return {
        --     message = localize("k_again_ex"),
        --     repetitions = card.ability.extra,
        --     card = card,
        --     was_blueprinted = context.blueprint,
        -- }
        if context.cardarea == G.play and context.repetition and context.other_card and context.other_card.ability and context.other_card.ability.name == "Grass Card" and not context.after then
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra,
                card = card
            }
            --context.individual and context.cardarea == G.hand and not context.after
        elseif context.individual and context.cardarea == G.hand and context.other_card.ability and context.other_card.ability.name == 'Grass Card' and not context.after then
            sendInfoMessage("1849, new method for held grass", self.key)

            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra,
                card = heldCard
            }
        elseif context.joker_main and context.repetition and not context.after then
            sendInfoMessage(" checking for held grass", self.key)
            for _, heldCard in ipairs(G.hand.cards) do
                local cardAbility = heldCard.ability.name or "nil"
                if cardAbility == "Grass Card" then
                    sendInfoMessage(heldCard.base.id .. " has ability of " .. cardAbility)
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra,
                        card = heldCard
                    }
                end
            end
        end
    end
}

SMODS.Joker { --Gumoss
    name = "Gumoss",
    key = "gumoss",
    config = {
        mult = 0,
        multGrowthRate = 0.1
    },
    loc_txt = {
        ['name'] = 'Gumoss',
        ['text'] = {
            "Gains {C:red}+#1#{} Mult when {c:attention}Grass Cards{} trigger",
            "{s:0.9,C:inactive}Currently {c:red}+#2#{} Mult{}"
        },
        ['unlock'] = {
            [1] = 'Play a card hand',
            [2] = 'that contains only',
            [3] = '{C:attention,E:1}Grass{} cards'
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_Fox_grass
        return { vars = { card.ability.multGrowthRate, card.ability.mult } }
    end,
    pos = {
        x = 1,
        y = 1
    },
    cost = 7,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local tally = 0
            for j = 1, #args.cards do
                if args.cards[j].config.center == G.P_CENTERS.m_Fox_grass then
                    tally = tally + 1
                end
            end
            if tally >= 1 then
                unlock_card(self)
            end
        end
    end,
    atlas = 'FoxModJokers',
    enhancement_gate = 'm_Fox_grass',

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.mult,
                card = card
            }
        end
        --context.other_card.ability and context.other_card.ability.name == 'Gold Card'
        -- if context.repetition and not context.repetition_only and context.other_card and context.other_card.ability and context.other_card.ability.name == "Grass Card" then
        -- -- playing card retriggers using .repetition
        -- return {
        --     message = localize("k_again_ex"),
        --     repetitions = card.ability.extra,
        --     card = card,
        --     was_blueprinted = context.blueprint,
        -- }
        if context.individual and context.cardarea == G.play and context.other_card.ability and context.other_card.ability.name == 'Grass Card' and not context.after then
            sendInfoMessage("Upgrading for played grass card", self.key)

            card.ability.mult = card.ability.mult + card.ability.multGrowthRate
            card:juice_up()
            return {
                message = localize('k_upgrade_ex'),
                card = card
            }
        end
        if context.cardarea == G.play and context.repetition and context.other_card and context.other_card.ability and context.other_card.ability.name == "Grass Card" and not context.after then
            sendInfoMessage("Upgrading for some reason", self.key)
            card.ability.mult = card.ability.mult + card.ability.multGrowthRate
            card:juice_up()
            return {
                message = localize('k_upgrade_ex'),
                card = card
            }
            --context.individual and context.cardarea == G.hand and not context.after
        elseif context.individual and context.cardarea == G.hand and context.other_card.ability and context.other_card.ability.name == 'Grass Card' and not context.after then
            sendInfoMessage("1849, new method for held grass", self.key)
            card.ability.mult = card.ability.mult + card.ability.multGrowthRate
            card:juice_up()
            return {
                message = localize('k_upgrade_ex'),
                card = card
            }
            -- return {
            --     message = localize('k_again_ex'),
            --     repetitions = card.ability.extra,
            --     card = heldCard
            -- }
        elseif context.joker_main and context.repetition and not context.after then
            sendInfoMessage(" checking for held grass", self.key)
            for _, heldCard in ipairs(G.hand.cards) do
                local cardAbility = heldCard.ability.name or "nil"
                if cardAbility == "Grass Card" then
                    sendInfoMessage(heldCard.base.id .. " has ability of " .. cardAbility)
                    card.ability.mult = card.ability.mult + card.ability.multGrowthRate
                    card:juice_up()
                    return {
                        message = localize('k_upgrade_ex'),
                        card = card
                    }
                    -- return {
                    --     message = localize('k_again_ex'),
                    --     repetitions = card.ability.extra,
                    --     card = heldCard
                    -- }
                end
            end
        end
    end
}


SMODS.Joker { --Mammorest
    name = "Mammorest",
    key = "mammorest",
    config = {
        x_mult = 1,
        x_mult_rate = 0.01,
    },
    loc_txt = {
        ['name'] = 'Mammorest',
        ['text'] = {
            "Gains {X:mult,C:white}#1#{} xMult when grass cards trigger",
            "{C:attention}Currently {X:mult,C:white}#2#{}",
        },
        ["unlock"] = {
            "Play a hand while having both",
            "{C:dark_edition}Grass Cards{} Jokers"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_Fox_grass --e_Fox_ghostRare
        return { vars = { card.ability.x_mult_rate, card.ability.x_mult } }
    end,
    check_for_unlock = function(self, args)
        if next(SMODS.find_card("j_Fox_teafant")) and
            next(SMODS.find_card("j_Fox_gumoss")) then
            unlock_card(self)
        end
    end,
    pos = {
        x = 1,
        y = 0
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    enhancement_gate = 'm_Fox_grass',

    calculate = function(self, card, context) --context.other_card.ability and context.other_card.ability.name == 'Gold Card'
        -- if context.repetition and not context.repetition_only and context.other_card and context.other_card.ability and context.other_card.ability.name == "Grass Card" then
        -- -- playing card retriggers using .repetition
        -- return {
        --     message = localize("k_again_ex"),
        --     repetitions = card.ability.extra,
        --     card = card,
        --     was_blueprinted = context.blueprint,
        -- }
        if context.before and context.other_card and context.other_card.ability and context.other_card.ability.name == "Grass Card" then
            sendInfoMessage("mammorest observed the other card proccing from being held", self.key)
            card.ability.x_mult = card.ability.x_mult + card.ability.x_mult_rate
            card:juice_up()
            return {
                message = localize('k_upgrade_ex'),
                card = card
            }
        end
        -- if context.repetition and context.other_card and context.other_card.ability and context.other_card.ability.name == "Grass Card"  and not context.after  then
        --     sendInfoMessage("mammorest observed the other card repeating", self.key)
        --     card.ability.x_mult = card.ability.x_mult + card.ability.x_mult_rate
        --     card:juice_up()
        --     return {
        --         message = localize('k_upgrade_ex'),
        --         card = card
        --     }
        --context.individual and context.cardarea == G.hand and not context.after
        if context.individual and context.cardarea == G.hand and context.other_card.ability and context.other_card.ability.name == 'Grass Card' then
            sendInfoMessage("1849, new method for held grass", self.key)

            card.ability.x_mult = card.ability.x_mult + card.ability.x_mult_rate
            card:juice_up()
            return {
                message = localize('k_upgrade_ex'),
                card = card
            }
        end

        if context.individual and context.cardarea == G.play and context.other_card.ability and context.other_card.ability.name == 'Grass Card' then
            sendInfoMessage("Upgrading for played grass card", self.key)

            card.ability.x_mult = card.ability.x_mult + card.ability.x_mult_rate
            card:juice_up()
            return {
                message = localize('k_upgrade_ex'),
                card = card
            }
        end
    end
}

local caffinatedText = {
    "A Caffinated Boba Cat",
    "Retrigger each played",
    "{C:attention}10{}, {C:attention}8{}, {C:attention}4{}, or {C:attention}2{}"
}

if FoxModConfig.moreMystery then
    caffinatedText = {
        "Grants a mysterious boon",
        "{C:attention}???{} ????",
    }
end

SMODS.Joker { --Boba
    name = "Caffinated",
    key = "caffinated",
    config = {
        extra = 2,
        affected_cards = {
            2, 4, 8, 10
        }
    },
    loc_txt = {
        ['name'] = 'Caffinated',

        ['text'] = caffinatedText
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 9,
        y = 3
    },
    cost = 7,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',    

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and context.other_card then
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            for _, affectedCard in ipairs(card.ability.affected_cards) do
                --print ("comparing " .. affectedCard  .. " to played card of " .. cardInfo .. " type =" ..type(cardInfo))

                if cardInfo == affectedCard or cardInfo == tostring(affectedCard) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra,
                    }
                end
            end
        end
    end
}

SMODS.Joker { --Cam
    name = "Squish Squad Cam",
    key = "cam",
    config = {
        extra = 1,
    },
    loc_txt = {
        ['name'] = 'Squish Squad Cam',
        ['text'] = {
            "Retriggers all enhanced or special edition cards",
            "a Random number of times, between one to four",
            "{C:attention}#1#{} additional times this round",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
        info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
        info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
        info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
        info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
        info_queue[#info_queue + 1] = G.P_CENTERS.e_Fox_fragileRelic
        info_queue[#info_queue + 1] = G.P_CENTERS.e_Fox_ghostRare
        info_queue[#info_queue + 1] = G.P_CENTERS.e_Fox_goldRare
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 7,
        y = 3
    },
    cost = 15,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    set_ability = function(self, card, initial, delay_sprites)
        local repeats = pseudorandom('cam', 1, 5)
        sendInfoMessage("repeats set to " .. repeats, self.key)
        card.ability.extra = repeats
    end,
    calculate = function(self, card, context)
        if context.ending_shop then
            sendInfoMessage("leaving shop, resetting", self.key)
            card:set_ability(self, card)
        end
        if context.repetition and context.other_card and context.other_card.ability.effect ~= "Base"
            or context.repetition and context.other_card and context.other_card.edition
            or context.retrigger_joker_check and context.other_card ~= card and context.other_card.edition then
            return {
                message = "Party!",
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
        },
        ["unlock"] = {
            "Play a hand with",
            "Three or more Glass Cards"
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
    cost = 6,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    enhancement_gate = 'm_glass',
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local tally = 0
            for j = 1, #args.cards do
                if args.cards[j].config.center == G.P_CENTERS.m_glass then
                    tally = tally + 1
                end
            end
            if tally >= 3 then
                unlock_card(self)
            end
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
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
                            playedCard:flip(); play_sound('tarot2', 0.6); playedCard:juice_up(
                                0.3, 0.3); return true
                        end
                    }))
                end
            end
        end
    end
}


SMODS.Joker { --Echoes of glass
    name = "Echoes of Glass",
    key = "glass2",
    config = {
        extra = 1,
    },
    loc_txt = {
        ['name'] = 'Echoes of Glass',
        ['text'] = {
            "Retriggers glass cards cards",
            "{C:attention}#1#{} additional times",
        },
        ["unlock"] = {
            "Have more than",
            "Ten Glass Cards in your deck"
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
    cost = 9,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    enhancement_gate = 'm_glass',
    check_for_unlock = function(self, args)
        if args.type == 'hand_contents' then
            local enhancedTally = 0
            for k, v in pairs(G.playing_cards) do
                if v.config.center == G.P_CENTERS.m_glass then enhancedTally = enhancedTally + 1 end
            end
            if enhancedTally >= 10 then
                unlock_card(self)
            end
        end
    end,

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
        extraGrowthRate = 0.1,
        shatteredObserved = 0,
        x_mult = 1
    },
    loc_txt = {
        ['name'] = 'Shatter Resisstant',
        ['text'] = {
            "Gains {X:mult,C:white}x#1#{} Mult when played glass cards do not break",
            "resets to {X:mult,C:white}x0.5{} Mult when glass breaks",
            "{s:0.9,C:inactive}Currently {X:mult,C:white}x#2#{} mult{}"
        },
        ["unlock"] = {
            "Play an All-Glass Hand",
            "Of four or more Glass Cards",
            "While holding both Glass Jokers",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
        return { vars = { card.ability.extraGrowthRate, card.ability.x_mult } }
    end,
    pos = {
        x = 8,
        y = 0
    },
    cost = 7,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    enhancement_gate = 'm_glass',
    check_for_unlock = function(self, args)
        local bothJokers = false
        local metTally = false

        if args.type == 'hand_contents' then
            local tally = 0
            for j = 1, #args.cards do
                if args.cards[j].config.center == G.P_CENTERS.m_glass then
                    tally = tally + 1
                end
            end
            if tally >= 4 then
                metTally = true
            end
        end
        -- if next(SMODS.find_card("j_Fox_glass2")) and
        --     next(SMODS.find_card("j_Fox_glass1")) then
        --     bothJokers = true
        -- end

        if metTally then
            unlock_card(self)
        end
    end,
    calculate = function(self, card, context)
        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            local t = card.base.id or card.label
            local prexXmult = card.ability.x_mult
            if card.ability.set == 'Joker' and context.post_joker then
                sendInfoMessage("Joker - Mult was x" .. prexXmult .. " and is now x" .. card.ability.x_mult, t)

                if card.ability.x_mult < 1.0 then
                    sendInfoMessage("Special Case, ensuring adverse xmult applied", t)
                    return {
                        colour = G.C.RED,
                        x_mult = card.ability.x_mult
                    } -- .. card.base.id)
                end
            end
        elseif context.cardarea == G.play and context.individual and context.other_card and context.other_card.ability.name == 'Glass Card' then
            sendInfoMessage(
                "observed played glass, mult was " ..
                card.ability.x_mult,
                self.key)
            card.ability.x_mult = card.ability.x_mult + card.ability.extraGrowthRate

            return {
                delay = 0.2,
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extraGrowthRate } },
                colour = G.C.RED,
                card = card
            }
        elseif context.remove_playing_cards and not context.blueprint then --and nil ~= context.not_broken would work but we need to patch smods
            sendInfoMessage("checking broken glass", self.key)

            local glass_cards = 0
            for k, val in ipairs(context.removed) do
                if val.shattered then glass_cards = glass_cards + 1 end
            end
            if glass_cards > 0 then
                card.ability.x_mult = 0.5

                if card.ability.x_mult < 1.0 then
                    sendInfoMessage("Special Case, ensuring adverse xmult applied", t)
                    return {
                        delay = 0.2,
                        colour = G.C.RED,
                        message = "SHATTERED",
                        x_mult = card.ability.x_mult,
                        card = card
                    } -- .. card.base.id)
                end
                -- return {
                --     delay = 0.2,
                --     message = "SHATTERED",
                --     colour = G.C.RED,
                --     card = card
                -- }
            end
            return
        elseif context.remove_playing_cards then
            sendInfoMessage("would handle this case but not_broken is nil", self.key)
        end
    end
}

SMODS.Joker { --Dragon Princess Zelda
    name = "Dragon Princess",
    key = "Dragon Princess",
    config = {
        odds = 3, Xmult = 2.5
    },
    loc_txt = {
        ['name'] = 'Dragon Princess',
        ['text'] = {
            "{C:green}#1# in #2#{} chance for",
            "played cards with",
            "{C:diamonds}Diamond{} suit to give",
            "{X:mult,C:white} X#3# {} Mult when scored",
        } },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, card.ability.Xmult } }
    end,
    pos = {
        x = 1,
        y = 3
    },
    cost = 2,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit("Diamonds") and pseudorandom('Dragon Princess') < G.GAME.probabilities.normal / card.ability.odds then
                return {
                    x_mult = card.ability.Xmult,
                    card = card
                }
            end
        end
    end

}

SMODS.Joker { --Creeper
    name = "Creeper",
    key = "creeper",
    config = {
        extra = 1,
    },
    loc_txt = {
        ['name'] = 'Creeper',
        ['text'] = {
            "Prevents Death if chips scored are at least {C:attention}25%{}",
            "of required chips",
            "{S:1.1,C:red,E:2}self destructs and destroys cards for last played hand{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    pos = {
        x = 8,
        y = 3
    },
    cost = 9,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModJokers',
    enhancement_gate = 'm_glass',

    calculate = function(self, card, context)
        if context.game_over and
            tonumber(format_ui_value(G.GAME.chips / G.GAME.blind.chips)) >= 0.25 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand_text_area.blind_chips:juice_up()
                    G.hand_text_area.game_chips:juice_up()
                    play_sound('tarot1')
                    card:start_dissolve()
                    return true
                end
            }))
            return {
                message = localize('k_saved_ex'),
                saved = true,
                colour = G.C.RED
            }
        end
    end
}



SMODS.Joker { --Yugi Moto
    name = "King of Games",
    key = "yugi",
    config = {
        mult_mod = 1.0,
        extraGrowthRate = 0.3,
        to_do_poker_hand = "Flush",
        basecoord = 6,
        activecoord = 9,
        active = true
    },
    loc_txt = {
        ['name'] = 'King of Games',
        ['text'] = {
            "Scored cards give {X:mult,C:white}X#1#{} Mult",
            "if {C:attention}poker hand{} is a {C:attention}#2#{}",
            "increases xMult by {X:mult,C:white}X#3#{} each activation",
            "{C:inactive}(Currently applying {C:mult}+#1#{} {C:inactive}Mult){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if nil == card.ability.to_do_poker_hand then reset_todoList() end
        card.ability.to_do_poker_hand = G.GAME.current_round.to_do_poker_hand
        return { vars = { card.ability.mult_mod, localize(card.ability.to_do_poker_hand, 'poker_hands'), card.ability.extraGrowthRate, } }
    end,
    pos = {
        x = 6,
        y = 1
    },
    atlas = 'FoxModJokers',
    cost = 2,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    set_ability = function(self, card, initial, delay_sprites)
        print("checking for previous todo list joker, we will respect its hand")
        local foundTodo = false
        if nil == G.jokers then
            print("no jokers, resetting todo")
            reset_todoList()
            card.ability.to_do_poker_hand = G.GAME.current_round.to_do_poker_hand
            return
        end
        print("other jokers existed, iterating")
        for _, joker in ipairs(G.jokers.cards) do
            if joker.label == "To Do List" or joker.label == "To Do list" or joker.label == "Moogle Dance" then
                foundTodo = true
                print("respecting present todo list hand which is " .. joker.ability.to_do_poker_hand, self.key)
                card.ability.to_do_poker_hand = joker.ability.to_do_poker_hand
            end
        end

        if (false == foundTodo) then
            print("no to do list joker, resetting todo")
            reset_todoList()
            card.ability.to_do_poker_hand = G.GAME.current_round.to_do_poker_hand
        end
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual and context.other_card and card.ability.active then
            return {
                x_mult = card.ability.mult_mod,
                card = context.other_card
            }
        end
        if context.ending_shop then
            sendInfoMessage("leaving shop, resetting", self.key)
            card:set_ability(self, card)

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    card:flip(); play_sound('card1', percent);
                    card.config.center.pos.x = card.ability.basecoord
                    card:juice_up(0.3, 0.3); return true
                end
            }))
            delay(0.3)

            card.ability.mult_mod = card.ability.mult_mod + card.ability.extraGrowthRate

            card.ability.active = false

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    card:flip(); play_sound('card1', percent);
                    card:juice_up(0.3, 0.3); return true
                end
            }))
        end
        if context.cardarea == G.jokers and context.before and context.scoring_name == card.ability.to_do_poker_hand then
            local cards = context.scoring_hand

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    card:flip(); play_sound('card1', percent);
                    card.config.center.pos.x = card.ability.activecoord
                    card:juice_up(0.3, 0.3); return true
                end
            }))
            if FoxModConfig.playSounds then
                play_sound('Fox_yourMove', 1);
            end

            delay(0.3)
            card.ability.active = true

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    card:flip(); play_sound('card1', percent);
                    card:juice_up(0.3, 0.3); return true
                end
            }))
            delay(0.5)
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
            '{C:attention}Golden Cards{} in hand now have a {C:green}#1# in #2#{} chance',
            'To apply a {X:mult,C:white}x1.5{} Mult bonus',
            'Accrues plus mult for every {c:attention}Gold Card{} activation, currently {X:mult,C:white}+#3#{} Mult bonus',
            '{s:0.9,C:inactive}Eldlich is the Lord of all that is Golden{}',

        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return { vars = { G.GAME.probabilities.normal, card.ability.odds, card.ability.goldTally } }
    end,
    pos = {
        x = 0,
        y = 0
    },
    enhancement_gate = 'm_gold',
    cost = 10,
    rarity = 3,
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
            if context.other_card.ability and context.other_card.ability.name == 'Gold Card' or context.other_card.edition and context.other_card.edition.key == "e_Fox_goldRare" then
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
        if context.cardarea == G.play and context.other_card and context.other_card.ability and context.other_card.ability.name == 'Gold Card' and not context.end_of_round or
            context.cardarea == G.play and context.other_card and context.other_card.edition and context.other_card.edition.key == "e_Fox_goldRare" and not context.end_of_round then
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

            if otherCard.ability and otherCard.ability.name == 'Gold Card' or
                otherCard.edition and otherCard.edition.key == "e_Fox_goldRare" then
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


SMODS.Joker { --Joku
    name = "Joku",
    key = "joku",
    config = {
        x_mult = 1.5,
        x_mult_growth_rate = 0.5,
        legendaryUnlock = false
    },
    loc_txt = {
        ['name'] = 'Joku',
        ['text'] = {
            "Played cards with {C:attention}Super Sayan{} rank give",
            "{X:mult,C:white}X#1#{} Mult when scored",
            "Increases xMult by {C:attention}0.5{} when Three of a Kind or better",
            "Hands are played comprised of SSJ Ranks",
            '{s:0.9,C:inactive}The Legendary Super Joker, reach Level 4 and something marvelous will happen{}',
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = "ssjToast", set = "Other", vars = { "2's, 3's or 4's" }}
        return { vars = { card.ability.x_mult } }
    end,
    pos = {
        x = 0,
        y = 0
    },
    cost = 12,
    rarity = 4,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModEpicJokers',
    soul_pos = { x = 1, y = 0 },

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local thisRankCounted = 0
            for i = 1, #context.scoring_hand do
                local thisCard = context.scoring_hand[i]:get_id()
                
                if thisCard == 2  or thisCard == 3 or thisCard == 4 then
                    thisRankCounted = thisRankCounted + 1
                end
            end

            if thisRankCounted >= 3 then
                if 
                    G.GAME.current_round.current_hand.handname == "Flush House" or
                    G.GAME.current_round.current_hand.handname == "Full House" or
                    G.GAME.current_round.current_hand.handname == "Flush Five" or
                    G.GAME.current_round.current_hand.handname == "Five of a Kind" or
                    G.GAME.current_round.current_hand.handname == "Four of a Kind" or
                    G.GAME.current_round.current_hand.handname == "Three of a Kind" then
                        card.ability.x_mult = card.ability.x_mult + card.ability.x_mult_growth_rate
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                            message = "Level up!",
                            colour = G.C.FILTER
                        })                
                end            
            end
        end
    
        if context.individual and context.cardarea == G.play then --and not context .joker_main then
            local otherCard = context.other_card
            local cardInfo = getValueNilSafe(otherCard.base.value)

            if card.ability.x_mult > 3.9 then 
                print("legendary unlocked!")
                card.ability.legendaryUnlock = true
            end

            if cardInfo == 2 or cardInfo == "2"
                or cardInfo == 3 or cardInfo == "3"
                or cardInfo == 4 or cardInfo == "4" then
                return {
                    x_mult = card.ability.x_mult,
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
        mult_mod = 1.0,
        extraGrowthRate = 0.3,
        legendaryUnlock = false
    },
    loc_txt = {
        ['name'] = 'Kirbo',
        ['text'] = {
            "Eats ranks of non-face cards",
            "Decreases ranks of unscored cards by {C:attention}1{}",
            "Scored {c:attention}2's{} are destroyed, increasing xMult by {X:mult,C:white}#1#{}",
            "{C:inactive}Currently {X:mult,C:white}X#2#{}",
            '{s:0.9,C:inactive}Kirby was very hungry{}',
            '{s:0.9,C:inactive}Something marvelous will happen when he reaches {X:mult,C:white}x3{}',
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extraGrowthRate, card.ability.mult_mod } }
    end,
    pos = {
        x = 0,
        y = 1
    },
    cost = 2,
    rarity = 4,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'FoxModEpicJokers',
    soul_pos = { x = 1, y = 1 },

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = card.ability.mult_mod
            }
        end
        if context.after then
            local unscoredCards = {}
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
                            if FoxModConfig.playSounds then
                                play_sound("Fox_yoshiEat", 1.05)
                            end
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

                card.ability.mult_mod = card.ability.mult_mod + card.ability.extraGrowthRate

                if card.ability.mult_mod > 2.9 then
                    card.ability.legendaryUnlock = true
                end
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = "POYO!", colour = G.C.FILTER })
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.45,
                    func = function()
                        if FoxModConfig.playSounds then
                            play_sound("Fox_kirby_poyo", 1.05)
                        end
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


SMODS.Joker { --Crunchwrap Supreme
    name = "Crunchwrap Supreme",
    key = "crunchWrap",
    config = {
        extra = 2,
    },
    loc_txt = {
        ['name'] = 'Crunchwrap Supreme',
        ['text'] = {
            'Retriggers played {c:attention}Three of a Kind{} or better hands',
            "{C:inactive}(Currently {X:mult,C:white}X#3#{} Mult)",
            '{s:0.9,C:inactive}His friend is Shaq-eel{}',
        },
        ["unlock"] = {
            "Level Incremental Hermie",
            "To 4x Mult",
            "{s:0.9,C:inactive}Feed him 2's, then 3's, then...{}"
        }

    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.x_mult_growth_rate, card.ability.requiredRankStr, card.ability.x_mult } }
    end,
    pos = {
        x = 4,
        y = 1
    },
    cost = 7,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    atlas = 'FoxModJokers',
    check_for_unlock = function(self, args)
        if next(SMODS.find_card("j_Fox_IncrementalHermie")) then
            local hermie = SMODS.find_card("j_Fox_IncrementalHermie")
                if hermie[1].ability.freeCrunchWrap then 
                    print("freeing crunchwrap")
                    unlock_card(self)
                else
                    print("crunchwrap is not yet freed")
                end
            end
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.repetition then
            
            if 
            G.GAME.current_round.current_hand.handname == "Flush House" or
            G.GAME.current_round.current_hand.handname == "Full House" or
            G.GAME.current_round.current_hand.handname == "Flush Five" or
            G.GAME.current_round.current_hand.handname == "Five of a Kind" or
            G.GAME.current_round.current_hand.handname == "Four of a Kind" or
            G.GAME.current_round.current_hand.handname == "Three of a Kind" then
                return {
                    message = "Awooo",
                    repetitions = card.ability.extra
                }
            end                       
        end
    end
}

sendInfoMessage("Completed processing jokers", "essay.lua")

SMODS.current_mod.description_loc_vars = function()
    return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
end

SMODS.current_mod.custom_ui = function(modNodes)    

    G.Fox_description_area = CardArea(
        G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
        4.25 * G.CARD_W,
        0.95 * G.CARD_H,
        { card_limit = 5, type = 'title', highlight_limit = 0, collection = true }
    )
    G.Fox_description_area.demo_area = true
    -- for i, key in ipairs({ "j_Fox_flushfox" }) do
    --     local card = Card(G.Fox_description_area.T.x + G.Fox_description_area.T.w / 2, G.Fox_description_area.T.y,
    --         G.CARD_W, G.CARD_H, G.P_CARDS.empty,
    --         G.P_CENTERS[key])

    --     -- card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["FoxModDecks"], { x = 0, y = 0 })
    --     card.children.back.states.hover = card.states.hover
    --     card.children.back.states.click = card.states.click
    --     card.children.back.states.drag = card.states.drag
    --     card.children.back.states.collide.can = false
    --     card.children.back:set_role({ major = card, role_type = 'Glued', draw_major = card })
    --     G.Fox_description_area:emplace(card)
    --     card:flip()
    --     G.E_MANAGER:add_event(Event({
    --         blocking = false,
    --         trigger = "after",
    --         delay = 0.4 * i,
    --         func = function()
    --             play_sound("card1")
    --             card:flip()
    --             return true
    --         end,
    --     }))
    -- end

    modNodes[#modNodes + 1] = {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.07, no_fill = true },
        nodes = {
            { n = G.UIT.O, config = { object = G.Fox_description_area } }
        }
    }

    modNodes[#modNodes + 1] = {
        n = G.UIT.R,
        config = {
            padding = 0.2,
            align = "cm",
        },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    padding = 0.2,
                    align = "cm",
                },
                nodes = {
                    UIBox_button({
                        colour = G.C.GREEN,
                        minw = 3.85,
                        button = "Fox_discord",
                        label = { localize('k_Fox_discord') }
                    })
                }
            },
            {
                n = G.UIT.C,
                config = {
                    padding = 0.2,
                    align = "cm",
                },
                nodes = {
                    UIBox_button({
                        colour = G.C.RED,
                        minw = 3.85,
                        button = "Fox_github",
                        label = { localize('k_Fox_github') }
                    })
                }
            },
        }
    }
end

function G.FUNCS.Fox_discord(e)
    love.system.openURL("https://discord.com/channels/1116389027176787968/1343279563563597854")
end

function G.FUNCS.Fox_github(e)
    love.system.openURL("https://github.com/1RedOne/FickleFox")
end

SMODS.current_mod.extra_tabs = function()
    return {
        {
            label = "Credits",
            tab_definition_function = function()
                local modNodes = {}

                modNodes[#modNodes + 1] = {}
                local loc_vars = { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.4 }
                localize { type = 'descriptions', key = "config_credits", set = 'Other', nodes = modNodes[#modNodes], vars = loc_vars.vars, scale = loc_vars.scale, text_colour = loc_vars.text_colour, shadow = loc_vars.shadow }
                modNodes[#modNodes] = desc_from_rows(modNodes[#modNodes])
                modNodes[#modNodes].config.colour = loc_vars.background_colour or modNodes[#modNodes].config.colour

                return {
                    n = G.UIT.ROOT,
                    config = {
                        emboss = 0.05,
                        minh = 6,
                        r = 0.1,
                        minw = 6,
                        align = "tm",
                        padding = 0.2,
                        colour = G.C.BLACK
                    },
                    nodes = modNodes
                }
            end
        },
    }
end

--- STEAMODDED HEADER
--- MOD_NAME: FoxMods
--- MOD_ID: FoxMods
--- PREFIX: fox
--- MOD_AUTHOR: FoxDeploy
--- MOD_DESCRIPTION: Adds unbalanced ideas to Balatro.
--- BADGE_COLOUR: ffaa33
--- DEPENDENCIES: [Talisman>=2.0.0-beta8, Steamodded>=1.0.0~ALPHA-0917a]
--- VERSION: 0.0.2
local mod = SMODS.current_mod
sendInfoMessage("Loading config.lua", "FoxMods-config.lua")
FoxMod = {}
FoxModConfig = SMODS.current_mod.config


SMODS.current_mod.config_tab = function() 
    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            padding = 0.05,
            colour = G.C.CLEAR,
        },
        nodes = {
            create_toggle({
                label = "Allow Custom Boosters?",
                ref_table = FoxModConfig,
                ref_value = "customBoosters",
            }),
            create_toggle({
                label = "Allow Custom Editions?",
                ref_table = FoxModConfig,
                ref_value = "customEditions",
            }),
            create_toggle({
                label = "Allow Custom Hands?",
                ref_table = FoxModConfig,
                ref_value = "customHands",
            }),
            create_toggle({
                label = "Allow Negative Boosters",
                ref_table = FoxModConfig,
                ref_value = "negativeBooster",
            }),
            create_toggle({
                label = "Allow Mod Specific Boosters",
                ref_table = FoxModConfig,
                ref_value = "modSpecificJokerBoosters",
            }),
            create_toggle({
                label = "Play Sounds",
                ref_table = FoxModConfig,
                ref_value = "playSounds",
            }),
            create_toggle({
                label = "More Mystery?",
                ref_table = FoxModConfig,
                ref_value = "moreMystery",
            }),
            create_toggle({
                label = "Allow Edition Effects on Mod Specific Decks? (May cause slowdown)",
                ref_table = FoxModConfig,
                ref_value = "animatedSpecialDecks",
            }),
        },
    }
end

SMODS.Atlas {key = "modicon", path = "modlogo.png", px = 34,  py = 34,}

SMODS.Sound({key = "metsu",path = "metsu.ogg"})
SMODS.Sound({key = "ghostRare",	path = "woosh.mp3",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "secretRare",	path = "secretRare.mp3",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "kirby_poyo",	path = "kirby-poyo-time-d.mp3",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "kirby_suction",	path = "kirby-suction.mp3",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "dbz_punch",	path = "dbz_punch.mp3",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "redxiii",	path = "redxiii_2.wav",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "ether",	path = "etherOverdrive.ogg",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "yoshiEat",	path = "yoshi-tongue.mp3",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "akumaClear",	path = "akuma_clear.mp3",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "yourMove",	path = "yourmove.ogg",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "grass",	path = "grass.ogg",atlas_table = "ASSET_ATLAS"})
SMODS.Sound({key = "goldRare",	path = "diablo-gold.mp3",atlas_table = "ASSET_ATLAS"})
--redxiii_2.wav
--dbz_punch.mp3
SMODS.current_mod.optional_features = {retrigger_joker = true}

SMODS.Atlas{ key = "FoxModJokers", path = "foxModJokers.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }
SMODS.Atlas{ key = "FoxModBoosters", path = "boosters.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }
SMODS.Atlas{ key = "FoxModVouchers", path = "vouchers.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }
SMODS.Atlas{ key = "FoxModMisc", path = "misc.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }
SMODS.Atlas{ key = "FoxMod2xOnly", path = "2xOnly.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }
SMODS.Atlas{ key = "FoxMod2xOnlyBooster", path = "fox_mod_booster_2x_only.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }
SMODS.Atlas{ key = "FoxModEpicJokers", path = "FoxModEpicJokers.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }
SMODS.Atlas{ key = "FoxModDecks", path = "decks.png", px = 71, py = 95, atlas_table = "ASSET_ATLAS" }

SMODS.Shader({ key = 'glimmer', path = 'glimmer3.fs' })
SMODS.Shader({ key = 'etherOverdrive', path = 'etherOverdrive.fs' })
SMODS.Shader({ key = 'akashic', path = 'akashic.fs' })
SMODS.Shader({ key = 'ghostRare', path = 'ghostRare.fs' })
SMODS.Shader({ key = 'secretRare', path = 'secretRare.fs' })
SMODS.Shader({ key = 'shadowChrome', path = 'shadowChrome.fs' })

sendInfoMessage("Loading all subfiles", "FoxMods-config.lua")

--loads individual lua files 
local subdir = "src"
local cards = NFS.getDirectoryItems(SMODS.current_mod.path .. subdir)
for _, filename in pairs(cards) do
    assert(SMODS.load_file(subdir .. "/" .. filename))()
end

sendInfoMessage("finished loading all subfiles", "FoxMods-config.lua")
sendInfoMessage("finished processing", "FoxMods-config.lua")
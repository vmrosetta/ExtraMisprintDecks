---------- DECKS ----------

-- The deck atlas
SMODS.Atlas({
    key = "deck_atlas",
    path = "deckatlas.png",
    px = 71,
    py = 95
})

-- Cryptid exclusive decks

-- Extreme Misprint Deck
-- Code lifted/adapted from Cryptid source code
SMODS.Back({
    dependencies = {
        "Cryptid",
        items = {
            "set_cry_deck",
        },
    },
    key = "extreme",
    order = 1,
    config = { cry_misprint_min = 0.005, cry_misprint_max = 200 },
    pos = { x = 0, y = 0 },
    atlas = "deck_atlas",
    apply = function(self)
        G.GAME.modifiers.cry_misprint_min = (G.GAME.modifiers.cry_misprint_min or 1) * self.config.cry_misprint_min
        G.GAME.modifiers.cry_misprint_max = (G.GAME.modifiers.cry_misprint_max or 1) * self.config.cry_misprint_max
    end
})

-- Maxima Misprint Deck. This is stupid lol
-- Code lifted/adapted from Cryptid source code
SMODS.Back({
    dependencies = {
        "Cryptid",
        items = {
            "set_cry_deck",
        },
    },
    key = "maxima",
    order = 2,
    config = { cry_misprint_min = 0.0000005, cry_misprint_max = 2000000 },
    pos = { x = 2, y = 0 },
    atlas = "deck_atlas",
    apply = function(self)
        G.GAME.modifiers.cry_misprint_min = (G.GAME.modifiers.cry_misprint_min or 1) * self.config.cry_misprint_min
        G.GAME.modifiers.cry_misprint_max = (G.GAME.modifiers.cry_misprint_max or 1) * self.config.cry_misprint_max
    end
})

-- Misprint Red Deck
SMODS.Back({
    key = "red",
    order = 3,
    pos = { x = 0, y = 1 },
    atlas = "deck_atlas",
    calculate = function(self, card, context)
        if context.setting_blind then
            pseudoseed("exmis_red".. G.GAME.round_resets.ante)
            local delta = math.random(-1,1)
            if G.GAME.round_resets.discards <= 0 and delta == -1 then delta = 0 end
            G.GAME.round_resets.discards = G.GAME.round_resets.discards + delta
            ease_discard(delta)
        end
    end
})

-- Misprint Blue Deck
SMODS.Back({
    key = "blue",
    order = 4,
    pos = { x = 1, y = 1 },
    atlas = "deck_atlas",
    calculate = function(self, card, context)
        if context.setting_blind then
            pseudoseed("exmis_blue".. G.GAME.round_resets.ante)
            local delta = math.random(-1,1)
            if G.GAME.round_resets.hands <= 1 and delta == -1 then delta = 0 end
            G.GAME.round_resets.hands = G.GAME.round_resets.hands + delta
            ease_hands_played(delta)
        end
    end
})

-- Sound for Misprint Plasma
SMODS.Sound({
    key = "disgong",
    path = 'disgong.ogg'
})

-- Misprint Plasma Deck
SMODS.Back({
    key = "plasma",
    order = 5,
    pos = { x = 2, y = 1 },
    atlas = "deck_atlas",
    calculate = function(self, card, context)
        if context.context == "final_scoring_step" then
            -- copy-paste from plasma deck
            local tot = context.chips + context.mult
            pseudoseed("exmis_plasma".. G.GAME.round_resets.ante)
            local rand = math.random()
            context.chips = tot * rand
            context.mult = tot * (1 - rand)
            update_hand_text({delay = 0}, {mult = context.mult, chips = context.chips})

            G.E_MANAGER:add_event(Event({
                func = (function()
                play_sound('exmis_disgong', 0.94, 0.3)
                play_sound('exmis_disgong', 0.94*1.5, 0.2)
                play_sound('tarot1', 1.5)
                ease_colour(G.C.UI_CHIPS, {0.8, 0.45, 0.85, 1})
                ease_colour(G.C.UI_MULT, {0.8, 0.45, 0.85, 1})
                attention_text({
                    scale = 1.4, text = "Balanced...?", hold = 2, align = 'cm', offset = {x = 0,y = -2.7},major = G.play
                })
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    blocking = false,
                    delay =  4.3,
                    func = (function()
                    ease_colour(G.C.UI_CHIPS, G.C.BLUE, 2)
                    ease_colour(G.C.UI_MULT, G.C.RED, 2)
                    return true
                    end)
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    blocking = false,
                    no_delete = true,
                    delay =  6.3,
                    func = (function()
                    G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] = G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
                    G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] = G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
                    return true
                    end)
                }))
                return true
                end)
            }))

            delay(0.6)
            return context.chips, context.mult
        end
    end
})

-- Misprint Erratic Deck
SMODS.Back({
    key = "erratic",
    order = 6,
    pos = { x = 2, y = 1 },
    atlas = "deck_atlas",
    apply = function(self)
        G.GAME.starting_params.erratic_suits_and_ranks = true
    end,
    calculate = function(self, card, context)
        if context.context == "eval" then
            if G.GAME.last_blind and G.GAME.last_blind.boss then
                for i = 1, #G.playing_cards, 1 do
                    local suit = pseudorandom_element(SMODS.Suits, pseudoseed("exmis_erratic"))
                    local rank = pseudorandom_element(SMODS.Ranks, pseudoseed("exmis_erratic"))
                    G.playing_cards[i] = assert(SMODS.change_base(G.playing_cards[i], suit.key, rank.key))
                end
            end
        end
    end
})

---------- SLEEVES ----------
if CardSleeves then
    -- The sleeves atlas
    SMODS.Atlas({
        key = "sleeve_atlas",
        path = "sleeveatlas.png",
        px = 71,
        py = 95
    })

    -- Cryptid exclusive sleeves

    -- Extreme Misprint sleeve
    -- Code lifted/adapted from Cryptid source code
    CardSleeves.Sleeve({
        key = "extreme_sleeve",
        dependencies = {
            "Cryptid"
        },
        atlas = "sleeve_atlas",
        pos = { x = 0, y = 0 },
        config = { cry_misprint_min = 0.005, cry_misprint_max = 200 },
        apply = function(self)
            G.GAME.modifiers.cry_misprint_min = (G.GAME.modifiers.cry_misprint_min or 1) * self.config.cry_misprint_min
            G.GAME.modifiers.cry_misprint_max = (G.GAME.modifiers.cry_misprint_max or 1) * self.config.cry_misprint_max
        end
    })
    -- Maxima Misprint sleeve
    -- Code lifted/adapted from Cryptid source code
    CardSleeves.Sleeve({
        key = "maxima_sleeve",
        dependencies = {
            "Cryptid"
        },
        atlas = "sleeve_atlas",
        pos = { x = 0, y = 1 },
        config = { cry_misprint_min = 0.0000005, cry_misprint_max = 2000000 },
        apply = function(self)
        G.GAME.modifiers.cry_misprint_min = (G.GAME.modifiers.cry_misprint_min or 1) * self.config.cry_misprint_min
        G.GAME.modifiers.cry_misprint_max = (G.GAME.modifiers.cry_misprint_max or 1) * self.config.cry_misprint_max
        end
    })

    -- Erratic Sleeve
    CardSleeves.Sleeve({
        key = "erratic_sleeve",
        atlas = "sleeve_atlas",
        pos = { x = 0, y = 1 },
        loc_vars = function(self)
            local key
            if self.get_current_deck_key() == "b_exmis_erratic" then
                key = self.key .. "_alt"
                return { key = key, vars = {} }
            end
            return { vars = {} }
        end,
        apply = function(self)
            G.GAME.starting_params.erratic_suits_and_ranks = true
        end,
        calculate = function(self, card, context)
            if context.context == "eval" then
                if G.GAME.last_blind and G.GAME.last_blind.boss then
                    for i = 1, #G.playing_cards, 1 do
                        local suit = pseudorandom_element(SMODS.Suits, pseudoseed("exmis_erratic"))
                        local rank = pseudorandom_element(SMODS.Ranks, pseudoseed("exmis_erratic"))
                        G.playing_cards[i] = assert(SMODS.change_base(G.playing_cards[i], suit.key, rank.key))
                        if self.get_current_deck_key() == "b_exmis_erratic" then
                            local enhancement = pseudorandom_element(G.P_CENTER_POOLS["Enhanced"], pseudoseed("exmis_erratic")).key
                            local edition = pseudorandom_element(G.P_CENTER_POOLS["Edition"], pseudoseed("exmis_erratic")).key
                            local seal = pseudorandom_element(G.P_CENTER_POOLS.Seal, pseudoseed("exmis_erratic")).key
                            G.playing_cards[i]:set_ability(enhancement, true, true)
                            G.playing_cards[i]:set_edition(edition, true, true)
                            G.playing_cards[i]:set_seal(seal, true, true)
                        end
                    end
                end
            end
        end
    })
end

-- Run after tests/test.lua in the same Lua interpreter.
local M = MarketMod
G.shop_jokers = {cards = {}}
G.GAME.banned_keys = {}
local S = M.shop
local function card(id) return {config = {center = {key = id}}} end
assert(M.request('Triboulet'))
assert(S.key_for({}) == nil)
assert(S.key_for(G.shop_jokers) == 'j_triboulet')
G.GAME.banned_keys.j_triboulet = true
assert(S.key_for(G.shop_jokers) == nil and M.peek_request() == 'j_triboulet')
G.GAME.banned_keys.j_triboulet = nil
local c = card('j_triboulet')
S.track(c, 'j_triboulet')
assert(S.key_for(G.shop_jokers) == nil) -- reserve exactly one slot
assert(M.peek_request() == 'j_triboulet') -- creation alone does not consume
local a, b, d = CardArea.emplace(G.shop_jokers, c)
assert(a == 'placed' and b == nil and d == 3)
assert(M.peek_request() == nil)
assert(M.request('Perkeo'))
c = card('j_joker')
S.track(c, 'j_perkeo') -- another mod substituted the card
CardArea.emplace(G.shop_jokers, c)
assert(M.peek_request() == 'j_perkeo')
c = card('j_perkeo')
S.track(c, 'j_perkeo')
assert(M.request('Chicot'))
CardArea.emplace(G.shop_jokers, c)
assert(M.peek_request() == 'j_chicot') -- never clear newer selection
local wrapped = CardArea.emplace
S.install()
assert(CardArea.emplace == wrapped)
print('PASS: shop area isolation, bans, one-slot reservation, placement, replacement, hook chaining')

-- The validation harness loads the installed game's patched factory when available.
if create_card_for_shop then
    G.GAME.tags = {}
    G.GAME.round_resets = {ante = 1}
    G.GAME.used_vouchers = {v_illusion = true}
    G.GAME.joker_rate, G.GAME.tarot_rate, G.GAME.planet_rate = 0, 0, 0
    G.GAME.playing_card_rate, G.GAME.spectral_rate = 1, 0
    G.E_MANAGER = {add_event = function(self, e) e.func() end}
    function Event(e) return e end
    function pseudoseed(x) return x end
    function pseudorandom() return 0.95 end
    local created_type, shop_type, modifications
    function create_card(kind, area, legendary, rarity, skip, soul, key)
        created_type = kind
        return card(key or 'c_base')
    end
    function create_shop_card_ui(c, kind) shop_type = kind end
    G.GAME.tags = {{apply_to_run = function(self, context)
        if context.type == 'store_joker_modify' then modifications = true end
    end}}
    assert(M.request('Triboulet'))
    local generated = create_card_for_shop(G.shop_jokers)
    assert(generated.config.center.key == 'j_triboulet')
    assert(created_type == 'Joker' and shop_type == 'Joker' and modifications)
    CardArea.emplace(G.shop_jokers, generated)
    assert(M.peek_request() == nil)
    -- Tag-created cards bypass the patched ordinary slot and preserve requests.
    assert(M.request('Perkeo'))
    G.GAME.tags = {{apply_to_run = function(self, context)
        if context.type == 'store_joker_create' then return card('j_joker') end
    end}}
    generated = create_card_for_shop(G.shop_jokers)
    CardArea.emplace(G.shop_jokers, generated)
    assert(generated.config.center.key == 'j_joker' and M.peek_request() == 'j_perkeo')
    -- Tutorial forced-shop branch also preserves requests.
    G.SETTINGS.tutorial_progress = {forced_shop = {'j_joker'}}
    G.shop_jokers.T = {x = 0, y = 0, w = 1}
    G.P_CARDS = {empty = {}}
    G.P_CENTERS.j_joker.key = 'j_joker'
    function Card(x, y, w, h, front, center) return card(center.key) end
    generated = create_card_for_shop(G.shop_jokers)
    CardArea.emplace(G.shop_jokers, generated)
    assert(M.peek_request() == 'j_perkeo')
    print('PASS: installed shop factory, Legendary forcing, playing-card conversion, Tags, tutorial')
end

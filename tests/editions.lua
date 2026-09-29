-- Run after test.lua and shop.lua. Uses the real Card:set_edition when the
-- installed-game validation harness supplies it; otherwise a small test double.
local real_setter = type(Card) == 'table' and Card.set_edition
local M = MarketMod
G.SETTINGS.tutorial_progress = nil
G.GAME.tags = {}
for _, key in ipairs({'foil', 'holo', 'polychrome', 'negative'}) do
    G.P_CENTERS['e_' .. key] = {config = {extra = 10}}
end
local function make_card(id)
    local c = {config = {center = {key = id}}, ability = {}, cost_updates = 0}
    function c:set_cost() self.cost_updates = self.cost_updates + 1 end
    c.set_edition = real_setter or function(self, e)
        self.edition = next(e) and e or nil
        self:set_cost()
    end
    return c
end
for _, edition in ipairs(M.editions) do
    assert(M.request('Perkeo', edition))
    local creation = M.shop.creation_edition(G.shop_jokers, 'j_perkeo', 'sho')
    if edition == 'random' then assert(creation == nil)
    elseif edition == 'normal' then assert(next(creation) == nil)
    else assert(creation[edition]) end
    assert(M.shop.creation_edition({}, 'j_perkeo', 'sho') == nil)
    local c = make_card('j_perkeo')
    c.edition = {foil = true}
    M.shop.track(c, 'j_perkeo')
    if edition == 'random' then
        assert(c.edition.foil and c.cost_updates == 0)
        assert(not M.shop.has_explicit_edition(c))
    else
        assert(c.cost_updates == 1 and M.shop.has_explicit_edition(c))
        if edition == 'normal' then assert(c.edition == nil)
        else assert(c.edition[edition]) end
    end
    CardArea.emplace(G.shop_jokers, c)
    assert(M.peek_request() == nil)
end
assert(M.request('Perkeo', 'negative'))
assert(not M.request('Perkeo', 'invalid'))
assert(M.peek_edition() == 'negative')
local c = make_card('j_perkeo')
M.shop.track(c, 'j_perkeo')
assert(M.request('Perkeo', 'holo'))
CardArea.emplace(G.shop_jokers, c)
assert(M.peek_request() == 'j_perkeo' and M.peek_edition() == 'holo')
M.clear_request()
M.ui.edition = 'polychrome'
G.FUNCS.market_catalog_edition()
assert(M.ui.edition == 'negative')
G.FUNCS.market_catalog_select_j_perkeo()
assert(M.peek_edition() == 'negative')
G.FUNCS.market_catalog_edition()
assert(M.peek_edition() == 'random')
if create_card_for_shop then
    local tag_calls = 0
    G.GAME.tags = {{apply_to_run = function(self, context)
        if context.type == 'store_joker_modify' then tag_calls = tag_calls + 1 end
    end}}
    create_card = function(kind, area, legendary, rarity, skip, soul, key)
        return make_card(key or 'j_joker')
    end
    assert(M.request('Triboulet', 'negative'))
    c = create_card_for_shop(G.shop_jokers)
    assert(c.edition.negative and tag_calls == 0)
    CardArea.emplace(G.shop_jokers, c)
    assert(M.request('Triboulet', 'random'))
    c = create_card_for_shop(G.shop_jokers)
    assert(tag_calls == 1)
end
print('PASS: all editions, cost recalculation, UI selection, edition acknowledgement, Tag preservation')

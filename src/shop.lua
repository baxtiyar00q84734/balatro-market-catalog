return function(M)
    local S = { pending_cards = setmetatable({}, {__mode = 'k'}) }
    S.explicit_cards = setmetatable({}, {__mode = 'k'})
    function S.has_explicit_edition(card)
        return S.explicit_cards[card] == true
    end
    function S.creation_edition(area, key, key_append)
        if key_append == 'sho' and key and area == G.shop_jokers
            and key == M.peek_request() and M.peek_edition() ~= 'random' then
            local edition = M.peek_edition()
            return edition == 'normal' and {} or {[edition] = true}
        end
    end
    function S.key_for(area)
        if not M.in_run() or not G.shop_jokers or area ~= G.shop_jokers then return nil end
        local id = M.peek_request()
        if not id or not M.registry.available(id) then return nil end
        -- create_card ignores banned forced keys; never silently consume one.
        if G.GAME.banned_keys and G.GAME.banned_keys[id] then return nil end
        for _, pending in pairs(S.pending_cards) do
            if pending.run == G.GAME and pending.id == id then return nil end
        end
        return id
    end
    function S.track(card, id)
        if id and card and card.config and card.config.center
            and card.config.center.key == id then
            local edition = M.peek_edition()
            if edition ~= 'random' then
                -- An empty table clears any rolled edition and recalculates cost.
                card:set_edition(edition == 'normal' and {} or {[edition] = true}, true, true)
                S.explicit_cards[card] = true
            end
            S.pending_cards[card] = {id = id, edition = edition, run = G.GAME}
        end
    end
    function S.install()
        if S.installed then return end
        local previous = CardArea.emplace
        local function pack(...) return {n = select('#', ...), ...} end
        CardArea.emplace = function(self, card, ...)
            local result = pack(previous(self, card, ...))
            local pending = card and S.pending_cards[card]
            if pending and self == G.shop_jokers and pending.run == G.GAME
                and card.config.center.key == pending.id then
                for _, placed in ipairs(self.cards) do
                    if placed == card then
                        M.acknowledge_request(pending.id, pending.edition)
                        S.pending_cards[card] = nil
                        break
                    end
                end
            end
            return unpack(result, 1, result.n)
        end
        S.installed = true
    end
    return S
end

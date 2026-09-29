local M = {
    version = '0.3.0',
    registry = require('market_catalog.registry'),
    config = require('market_catalog.config'),
}

function M.in_run()
    return G and G.STAGES and G.STAGE == G.STAGES.RUN and G.GAME ~= nil
end

-- Run-owned state prevents leaking a request into a different run. Balatro's
-- ordinary run serialization can preserve this simple string field.
function M.peek_request()
    return M.in_run() and G.GAME.market_catalog_requested_joker or nil
end

M.editions = {'normal', 'foil', 'holo', 'polychrome', 'negative', 'random'}
M.edition_names = {normal = 'Normal', foil = 'Foil', holo = 'Holographic',
    polychrome = 'Polychrome', negative = 'Negative', random = 'Random'}
function M.peek_edition()
    return M.in_run() and G.GAME.market_catalog_requested_edition or 'random'
end

function M.request(value, edition)
    if not M.in_run() then return false, 'Start a run first.' end
    local id = M.registry.resolve(value)
    if not id or not M.registry.available(id) then return false, 'Joker unavailable.' end
    edition = edition or 'random'
    if not M.edition_names[edition] then return false, 'Invalid edition.' end
    G.GAME.market_catalog_requested_joker = id
    G.GAME.market_catalog_requested_edition = edition
    return true
end

function M.clear_request()
    if M.in_run() then
        G.GAME.market_catalog_requested_joker = nil
        G.GAME.market_catalog_requested_edition = nil
    end
end

-- The shop adapter calls this only AFTER successful insertion.
-- Compare-and-clear avoids consuming a newer request accidentally.
function M.acknowledge_request(id, edition)
    if id and M.peek_request() == id and (not edition or edition == M.peek_edition()) then
        M.clear_request(); return true
    end
    return false
end

return M

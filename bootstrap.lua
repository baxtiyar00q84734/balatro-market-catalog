-- Appended once to main.lua by Lovely. No game file edits and no SMODS dependency.
if not rawget(_G, 'MarketMod') then
    local M = require('market_catalog.core')
    _G.MarketMod = M
    M.ui = require('market_catalog.ui')(M)
    M.shop = require('market_catalog.shop')(M)
    local previous_keypressed = love.keypressed
    love.keypressed = function(key, scancode, isrepeat, ...)
        if not M.ready and G and G.FUNCS and G.P_CENTERS and G.SETTINGS then
            M.config.load()
            M.ui.install()
            M.shop.install()
            M.ready = true
        end
        if M.ready and key == M.config.hotkey then
            if isrepeat and M.ui.is_open() then return end
            if not isrepeat and M.ui.toggle() then return end
        end
        if previous_keypressed then return previous_keypressed(key, scancode, isrepeat, ...) end
    end
end

-- Run from the MarketCatalog directory with Lua 5.1 or LuaJIT.
for _, name in ipairs({'data', 'registry', 'config', 'core', 'ui', 'shop'}) do
    package.preload['market_catalog.' .. name] = assert(loadfile('src/' .. name .. '.lua'))
end
local R = require('market_catalog.registry')
local counts = {0, 0, 0, 0}
assert(#R.entries == 150)
for _, e in ipairs(R.entries) do counts[e.rarity] = counts[e.rarity] + 1 end
assert(counts[1] == 61 and counts[2] == 64 and counts[3] == 20 and counts[4] == 5)
assert(R.resolve('Perkeo') == 'j_perkeo')
assert(R.resolve('Gluttonous Joker') == 'j_gluttenous_joker')
assert(R.resolve('Seltzer') == 'j_selzer')
assert(R.resolve('unknown') == nil)
local C = require('market_catalog.config')
assert(C.parse('hotkey = F12 # comment') == 'f12')
assert(C.parse('hotkey = f13') == 'f1')
assert(C.parse('hotkey = f01') == 'f1')
assert(C.parse('os.execute("bad")') == 'f1')
G = {STAGES = {RUN = 1}, STAGE = 1, GAME = {}, P_CENTERS = {},
    FUNCS = {}, SETTINGS = {paused = false}, CONTROLLER = {},
    UIT = {R = 1, T = 2, C = 3}, C = {BLUE = {}, RED = {},
    UI = {TEXT_LIGHT = {}, BACKGROUND_INACTIVE = {}}}}
for _, e in ipairs(R.entries) do G.P_CENTERS[e.id] = {set = 'Joker'} end
function UIBox_button(args) return {button = args.button, label = args.label} end
function create_UIBox_generic_options(args) return args end
G.FUNCS.overlay_menu = function(args) G.OVERLAY_MENU = {definition = args.definition} end
G.FUNCS.exit_overlay_menu = function() G.OVERLAY_MENU = nil; G.SETTINGS.paused = false end
local M = require('market_catalog.core')
assert(M.request('Perkeo'))
assert(M.peek_request() == 'j_perkeo')
assert(not M.acknowledge_request('j_joker'))
assert(M.peek_request() == 'j_perkeo')
assert(M.acknowledge_request('j_perkeo'))
G.P_CENTERS.j_perkeo = nil
assert(not M.request('Perkeo'))
G.P_CENTERS.j_perkeo = {set = 'Joker'}
assert(M.request('Perkeo'))
G.GAME = {}
assert(M.peek_request() == nil)
local U = require('market_catalog.ui')(M)
U.install()
assert(U.toggle() and U.is_open() and G.SETTINGS.paused)
G.FUNCS.market_catalog_filter_4()
assert(U.rarity == 4 and U.pages == 1)
G.FUNCS.market_catalog_select_j_perkeo()
assert(M.peek_request() == 'j_perkeo')
G.FUNCS.market_catalog_filter_0()
for i = 1, 30 do G.FUNCS.market_catalog_next() end
assert(U.page == 15)
for i = 1, 30 do G.FUNCS.market_catalog_previous() end
assert(U.page == 1)
-- Native Escape dismissal must not leave stale ownership or close other menus.
G.FUNCS.exit_overlay_menu()
assert(not U.is_open())
G.OVERLAY_MENU = {foreign = true}
assert(not U.toggle())
U.close()
assert(G.OVERLAY_MENU.foreign)
G.OVERLAY_MENU = nil
G.STAGE = 0
assert(not U.toggle() and not M.request('Joker'))
G.STAGE = 1
local delegated, reads = 0, 0
CardArea = {emplace = function(self, card) self.cards[#self.cards + 1] = card; return 'placed', nil, 3 end}
love = {filesystem = {
    getInfo = function() return true end,
    read = function() reads = reads + 1; return 'hotkey = f2' end,
}, keypressed = function() delegated = delegated + 1; return 'original', nil, 7 end}
assert(loadfile('bootstrap.lua'))()
local wrapped = love.keypressed
assert(loadfile('bootstrap.lua'))()
assert(love.keypressed == wrapped)
local a, b, c = love.keypressed('a', 'a', false)
assert(a == 'original' and b == nil and c == 7 and delegated == 1)
love.keypressed('f2', 'f2', false)
assert(MarketMod.ui.is_open())
love.keypressed('f2', 'f2', true)
assert(MarketMod.ui.is_open() and delegated == 1)
love.keypressed('f2', 'f2', false)
assert(not MarketMod.ui.is_open() and reads == 1)
print('PASS: registry, config, request lifecycle, UI navigation/ownership, hotkey chaining')

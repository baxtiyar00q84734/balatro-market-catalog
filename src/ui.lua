return function(M)
    local U = { page = 1, rarity = 0, page_size = 10, overlay = nil, edition = 'normal' }
    local function text(value, scale)
        return {n = G.UIT.R, config = {align = 'cm', padding = 0.04}, nodes = {
            {n = G.UIT.T, config = {text = value, scale = scale or 0.32, colour = G.C.UI.TEXT_LIGHT}}
        }}
    end
    local function button(label, callback, width, colour)
        return UIBox_button{label = {label}, button = callback, minw = width or 2.5,
            minh = 0.42, scale = 0.3, colour = colour or G.C.BLUE}
    end
    local function row(nodes)
        return {n = G.UIT.R, config = {align = 'cm', padding = 0.06}, nodes = nodes}
    end
    local function column(node)
        return {n = G.UIT.C, config = {align = 'cm', padding = 0.05}, nodes = {node}}
    end
    function U.is_open()
        return U.overlay ~= nil and G.OVERLAY_MENU == U.overlay
    end
    function U.close(e)
        if not U.is_open() then return end
        G.FUNCS.exit_overlay_menu(e)
        U.overlay = nil
    end
    function U.definition()
        local entries = M.registry.list(U.rarity)
        U.pages = math.max(1, math.ceil(#entries / U.page_size))
        U.page = math.max(1, math.min(U.page, U.pages))
        local contents = {text('Market Catalog', 0.55)}
        contents[#contents + 1] = button('Edition: ' .. M.edition_names[U.edition] .. ' (change)',
            'market_catalog_edition', 5, G.C.RED)
        local filters = {}
        for rarity = 0, 4 do
            filters[#filters + 1] = column(button(rarity == 0 and 'All' or M.registry.rarities[rarity],
                'market_catalog_filter_' .. rarity, 1.65, rarity == U.rarity and G.C.RED or G.C.BLUE))
        end
        contents[#contents + 1] = row(filters)
        for offset = 0, U.page_size - 1, 2 do
            local cells = {}
            for col = 0, 1 do
                local entry = entries[(U.page - 1) * U.page_size + offset + col + 1]
                if entry then
                    local available = M.registry.available(entry.id)
                    cells[#cells + 1] = column(button(M.registry.name(entry),
                        available and ('market_catalog_select_' .. entry.id) or nil, 4.3,
                        available and G.C.BLUE or G.C.UI.BACKGROUND_INACTIVE))
                end
            end
            contents[#contents + 1] = row(cells)
        end
        contents[#contents + 1] = row({column(button('Previous', 'market_catalog_previous', 2)),
            column(text(U.page .. ' / ' .. U.pages)), column(button('Next', 'market_catalog_next', 2))})
        local id = M.peek_request()
        local entry = id and M.registry.by_id[id]
        contents[#contents + 1] = text('Queued: ' .. (entry and M.registry.name(entry) or id or 'None')
            .. (id and (' / ' .. (M.edition_names[M.peek_edition()] or 'Random')) or ''), 0.29)
        contents[#contents + 1] = text('Delivery: next shop or reroll. Normal prices apply.', 0.27)
        if id and G.GAME.banned_keys and G.GAME.banned_keys[id] then
            contents[#contents + 1] = text('Blocked by this run: choose another Joker.', 0.27)
        end
        contents[#contents + 1] = button('Clear request', 'market_catalog_clear', 3, G.C.RED)
        return create_UIBox_generic_options{back_func = 'market_catalog_close', contents = contents}
    end
    function U.refresh()
        if not U.is_open() then return end
        G.FUNCS.overlay_menu{definition = U.definition()}
        U.overlay = G.OVERLAY_MENU
    end
    function U.toggle()
        if U.is_open() then U.close(); return true end
        if not M.in_run() or G.OVERLAY_MENU or G.SETTINGS.paused
            or (G.CONTROLLER and G.CONTROLLER.locked) then return false end
        U.page = 1
        if M.peek_request() then U.edition = M.peek_edition() end
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{definition = U.definition()}
        U.overlay = G.OVERLAY_MENU
        return true
    end
    function U.install()
        G.FUNCS.market_catalog_close = U.close
        G.FUNCS.market_catalog_previous = function() U.page = math.max(1, U.page - 1); U.refresh() end
        G.FUNCS.market_catalog_next = function() U.page = math.min(U.pages, U.page + 1); U.refresh() end
        G.FUNCS.market_catalog_clear = function() M.clear_request(); U.refresh() end
        G.FUNCS.market_catalog_edition = function()
            for index, edition in ipairs(M.editions) do
                if edition == U.edition then
                    U.edition = M.editions[index % #M.editions + 1]; break
                end
            end
            local id = M.peek_request()
            if id then M.request(id, U.edition) end
            U.refresh()
        end
        for rarity = 0, 4 do
            local selected = rarity
            G.FUNCS['market_catalog_filter_' .. selected] = function()
                U.rarity = selected; U.page = 1; U.refresh()
            end
        end
        for _, entry in ipairs(M.registry.entries) do
            local id = entry.id
            G.FUNCS['market_catalog_select_' .. id] = function()
                M.request(id, U.edition); U.refresh()
            end
        end
    end
    return U
end

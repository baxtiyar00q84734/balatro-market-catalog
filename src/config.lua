local C = { path = 'market_catalog.cfg', hotkey = 'f1' }
local function valid(key)
    local number = key:match('^f(%d+)$')
    return number and tonumber(number) >= 1 and tonumber(number) <= 12
        and key == 'f' .. tostring(tonumber(number))
end

function C.parse(text)
    local key = 'f1'
    for line in text:gmatch('[^\r\n]+') do
        line = line:gsub('#.*$', '')
        local field, value = line:match('^%s*([%w_]+)%s*=%s*([%w_]+)%s*$')
        if field == 'hotkey' and valid(value:lower()) then key = value:lower() end
    end
    return key
end

function C.load()
    if not love.filesystem.getInfo(C.path) then
        local ok, err = love.filesystem.write(C.path,
            '# Market Catalog: f1 through f12; restart after editing.\nhotkey = f1\n')
        if not ok then print('[MarketCatalog] Could not create config: ' .. tostring(err)) end
    end
    local text = love.filesystem.read(C.path)
    C.hotkey = C.parse(text or '')
end
return C

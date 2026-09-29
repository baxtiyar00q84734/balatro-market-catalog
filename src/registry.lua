local R = { entries = require('market_catalog.data'), by_id = {}, by_name = {} }
R.rarities = {'Common', 'Uncommon', 'Rare', 'Legendary'}
for _, entry in ipairs(R.entries) do
    assert(not R.by_id[entry.id], 'Duplicate catalog ID: ' .. entry.id)
    R.by_id[entry.id] = entry
    R.by_name[entry.name:lower()] = entry.id
end

function R.resolve(value)
    if type(value) ~= 'string' then return nil end
    return R.by_id[value] and value or R.by_name[value:lower()]
end

function R.available(id)
    local center = G and G.P_CENTERS and G.P_CENTERS[id]
    return center and center.set == 'Joker' or false
end

function R.name(entry)
    local names = G and G.localization and G.localization.descriptions
    local loc = names and names.Joker and names.Joker[entry.id]
    return loc and loc.name or entry.name
end

function R.list(rarity)
    local result = {}
    for _, entry in ipairs(R.entries) do
        if rarity == 0 or entry.rarity == rarity then result[#result + 1] = entry end
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end
return R

--- Pop the first key from the list and return a copy of the keylist with that value removed
---@param key LuaX.Key
local function key_first(key)
    -- hehe
    local copy = { table.unpack(key) }

    table.remove(copy, 1)
    
    return key[1], copy
end

return key_first
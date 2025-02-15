local table_unpack = require("src.util.polyfill.table.unpack")

--- Pop the first key from the list and return a copy of the keylist with that value removed
---@param key LuaX.Key
local function key_first(key)
    -- hehe
    local copy = { table_unpack(key) }
    
    return table.remove(copy, 1), copy
end

return key_first
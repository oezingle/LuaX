
local concat = table.concat

---@param key LuaX.Key
---@return string
local function key_to_string (key)
    if #key == 0 then
        return "<empty key>"
    end

    return concat(key, ".")
end

return key_to_string
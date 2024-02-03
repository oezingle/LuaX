
-- TODO gets newline as indent (wtf!)

--- Get the indent of some given XML/HTML/React/LuaX, assuming it is correctly formatted
--- This function is allowed to break for unformatted xml, because LuaX helps formatting if you do formatting.
---@param str string
local function get_indent (str)
    local indent = str:match("%S\n(%s-)%S")

    return indent or ""
end

return get_indent
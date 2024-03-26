
-- TODO gets newline as indent (wtf!)

--- Get the indent of some given XML/HTML/React/LuaX, assuming it is correctly formatted
--- This function is allowed to break for unformatted code, 
--- because then the onus is on the user to format text blocks
---@param str string
local function get_indent (str)
    local indent = str:match(">\n(%s-)%S")

    return indent or ""
end

return get_indent

local LuaXParser = require("src.util.parser.LuaXParser")

---@param tag string
local function parse (tag)
    local parser = LuaXParser()

    local no_whitespace = tag:gsub("^%s*<", "<")

    return parser:parse_tag(no_whitespace, 0)
end

return parse
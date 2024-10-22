local LuaXParser = require("src.util.parser.LuaXParser")

---@param tag string
local function parse(tag)
    local parser = LuaXParser()
        :set_text(tag)

    ---@diagnostic disable-next-line:invisible
    return parser:parse_tag(0)
end

return parse

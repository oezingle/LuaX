local LuaXParser = require("src.util.parser.LuaXParser")

---@param path string
---@return string
local function parse_file(path)
    local transpiled = LuaXParser
        .from_file_path(path)
        :transpile()

    return transpiled
end

return parse_file

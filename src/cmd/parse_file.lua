
local LuaXParser = require("src.util.parser.LuaXParser")

---@param path string
---@return string
local function parse_file(path)
    local file = io.open(path, "r")

    if not file then
        error(string.format("File %s not found", path))
    end

    local content = file:read("a")

    local transpiled = LuaXParser(content):parse_file()

    return transpiled
end

return parse_file


local stringify_table = require("src.util.parser.transpile.stringify_table")

--- Return a string of a call to create_element for transpiling XML
--- Strings here for everything, as they're interpreted as Lua literals
--- 
---@param type string 
---@param props table
local function transpile_create_element (type, props)
    local prop_str = stringify_table(props)

    return string.format("create_element(%s, %s)", type, prop_str)
end

return transpile_create_element
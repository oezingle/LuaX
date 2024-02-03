
local stringify_table = require("src.util.parser.transpile.stringify_table")

--- Return a string of a call to create_element for transpiling XML
--- Strings here for everything, as they're interpreted as Lua literals
--- 
---@param create_element string? the local name for create_element
---@param type string 
---@param props table
local function transpile_create_element (create_element, type, props)
    create_element = create_element or "create_element"

    local prop_str = stringify_table(props)

    return string.format("%s(%s, %s)", create_element, type, prop_str)
end

return transpile_create_element
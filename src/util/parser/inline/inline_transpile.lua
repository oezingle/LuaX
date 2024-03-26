
local inline_transpile_string = require("src.util.parser.inline.string")
local inline_transpile_decorator = require("src.util.parser.inline.decorator")

--- Inline transpiler, taking either a LuaX string or a Component.
--- Components preferred as locals can be looked up better.
---
-- ---@overload fun (input: string): LuaX.ElementNode
---@overload fun (input: function): LuaX.Component
---@param input string
---@return LuaX.ElementNode
local function inline_transpile (input)
    local t = type(input)

    if t == "function" then
        return inline_transpile_decorator(input, 0)
    else
        return inline_transpile_string(input, 0)
    end
end

return inline_transpile
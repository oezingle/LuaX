local LuaXParser      = require("src.util.parser.LuaXParser")
local get_locals      = require("src.util.parser.inline.get_locals")
local transpile_cache = require("src.util.parser.inline.transpile_cache")
local load_cache      = require("src.util.parser.inline.load_cache")

local Fragment        = require("src.components.Fragment")
local create_element  = require("src.create_element")

-- TODO handle as decorator too - get_locals(3) returns locals for that chunk.
--[[
    local function inline_decorator (fn)
        return function (...)
            -- this needs to act as a stack for safety - maybe LinkedList?
            -- do i even still have LinkedList kicking around?
            _LuaX._decorator_locals = get_locals(3)

            fn(...)

            _LuaX._decorator_locals = nil
        end
    end
]]

---@param tag string
---@param stackoffset number?
---@return LuaX.ElementNode
local function inline_transpile_string(tag, stackoffset)
    local stackoffset = stackoffset or 0

    -- 3 is a value from trial and error
    local locals = get_locals(3 + stackoffset)
    ---@diagnostic disable-next-line:invisible
    locals[LuaXParser.vars.CREATE_ELEMENT.name] = create_element
    ---@diagnostic disable-next-line:invisible
    locals[LuaXParser.vars.FRAGMENT.name] = Fragment
    ---@diagnostic disable-next-line:invisible
    locals[LuaXParser.vars.IS_COMPILED.name] = true

    local element_str = transpile_cache.get(tag, locals)

    local env = setmetatable(locals, {
        __index = _G
    })

    local node = load_cache.get(element_str, env)

    return node
end

return inline_transpile_string

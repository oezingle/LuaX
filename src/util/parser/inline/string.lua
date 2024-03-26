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
    locals[LuaXParser.imports.required.CREATE_ELEMENT.name] = create_element
    locals[LuaXParser.imports.auto.FRAGMENT.name] = Fragment

    local element_str = transpile_cache.get(tag, locals)

    local env = setmetatable(locals, {
        __index = _G
    })

    --[[
    -- TODO FIXME no. maybe?
    local ok, node = pcall(function()
        return load_cache.get(element_str, env)
    end)

    -- TODO this better.
    if not ok then
        error(node .. "\n" .. element_str)
    end
    ]]

    local node = load_cache.get(element_str, env)

    return node
end

return inline_transpile_string

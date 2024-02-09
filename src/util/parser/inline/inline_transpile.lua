local LuaXParser      = require("src.util.parser.LuaXParser")
local get_locals      = require("src.util.parser.inline.get_locals")
local transpile_cache = require("src.util.parser.inline.transpile_cache")
local load_cache      = require("src.util.parser.inline.load_cache")

local Fragment        = require("src.components.Fragment")
local LuaBlock        = require("src.components.LuaBlock")
local create_element  = require("src.create_element")

---@param tag string
---@return LuaX.ElementNode
local function inline_transpile(tag)
    -- 3 is a value from trial and error
    local locals = get_locals(3)
    locals[LuaXParser.CREATE_ELEMENT_IMPORT_NAME] = create_element
    locals[LuaXParser.FRAGMENT_AUTO_IMPORT_NAME] = Fragment
    locals[LuaXParser.LUA_BLOCK_AUTO_IMPORT_NAME] = LuaBlock

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

return inline_transpile

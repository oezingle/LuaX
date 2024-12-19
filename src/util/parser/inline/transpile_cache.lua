local LuaXParser      = require("src.util.parser.LuaXParser")
-- local node_to_element = require("src.util.parser.transpile.node_to_element")

local transpile_cache = {}

local cache           = {}

---@param tag string
function cache.find(tag)
    return transpile_cache[tag]
end

---@param tag string
---@param output string
function cache.set(tag, output)
    transpile_cache[tag] = output
end

-- parser.verbose = true

--- Get a value from either parsing or the cache, depending on if tag is saved.
---
--- Locals' values don't need to be tracked - the parser
--- only needs to know which variables are local, not their content.
---@param tag string
---@param locals table<string, any>
---@return string
function cache.get(tag, locals)
    -- fix for LuaX(function () return nil end)
    if not tag then
        return "return nil"
    end

    local cached = cache.find(tag)

    if cached then
        return cached
    end

    local transpiled = LuaXParser.from_inline_string("return " .. tag)
        :handle_variables_as_table(locals)
        :set_components(locals, "local")
        :transpile()

    cache.set(tag, transpiled)

    return transpiled
end

---@param tag string?
function cache.clear(tag)
    if tag then
        transpile_cache[tag] = nil
    else
        transpile_cache = {}
    end
end

return cache

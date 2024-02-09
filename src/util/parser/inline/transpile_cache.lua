local LuaXParser      = require("src.util.parser.LuaXParser")
local node_to_element = require("src.util.parser.transpile.node_to_element")

local transpile_cache = {}

local cache = {}

---@param tag string
function cache.find(tag)
    return transpile_cache[tag]
end

---@param tag string
---@param output string
function cache.set(tag, output)
    transpile_cache[tag] = output
end

---@param tag string
---@param locals table<string, any>
function cache.get(tag, locals)
    local cached = cache.find(tag)

    if cached then
        return cached
    end

    local parser = LuaXParser(tag)

    local start = parser:skip_whitespace()

    local node = parser:parse_tag(start)

    -- return here removes the task of string concat from future calls
    local transpiled = "return " .. node_to_element(node, locals, "local", LuaXParser.CREATE_ELEMENT_IMPORT_NAME)
    
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

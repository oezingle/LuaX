
local table_equals = require "src.util.table_equals"

---@type table<string, { env: table<string, any>, old: any }>
local load_cache = {}

local cache = {}

---@param code string
---@param env table<string, any>
function cache.find (code, env)
    local cached = load_cache[code]

    if not cached then
        return nil
    end

    for k, v in pairs(env) do
        if not table_equals(v, cached.env[k]) then
            return nil
        end
    end

    return cached.old
end

---@param code string
---@param env table<string, any>
---@param output any
function cache.set(code, env, output)
    load_cache[code] = {
        env = env,
        old = output
    }
end

---@param code string
---@param env table<string, any>
function cache.get (code, env)
    local cached = cache.find(code, env)

    if cached then
        return cached
    end

    -- TODO FIXME provide ... global
    local get_output, err = load(code, "inline LuaX code", nil, env)

    if not get_output then
        error(err)
    end

    local output = get_output()

    cache.set(code, env, output)

    return output
end

---@param code string?
function cache.clear(code)
    if code then
        load_cache[code] = nil
    else
        load_cache = {}
    end
end

return cache
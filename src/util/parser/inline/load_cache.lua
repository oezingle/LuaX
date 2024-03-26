
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

    -- TODO because this is slow as fuck we should 
    -- - check inner, then outer locals
    -- - (probably) ignore _G - load_cache.get() should just build a new table which inherits inner, outer, then _G
    for k, v in pairs(env) do
        -- TODO FIXME this seems slow. maybe take locals not env?
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
        warn("Code passed in:")
        print(code)
        
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
local pairs = pairs
local next = next
local type = type
local getmetatable = getmetatable

---@type fun(a: table, b: table, traversed: table): boolean, table
local fchk_table_keys

---@type fun(a: function, b: function, level: number, traversed: table): boolean
local fchk_functions

--- Check if a value is a primitive
---@param value any
---@return boolean
local function is_primitive(value)
    local t = type(value)
    return t == "nil" or t == "string" or t == "number" or t == "boolean"
end

---@param a any first object to check
---@param b any second object to check
---@param level number? to what degree objects should be checked for equality:
--- - 0 - don't delve into tables or userdata metatables. ignore functions, threads
--- - 1 - ignore functions, threads
--- - 2 - return false for functions (if missing debug), threads
--- - 3 - error for function / thread / userdata values that cannot be checked
---@param traversed table<any, any[]>? Internally used to track objects that are accounted for
local function deep_equals(a, b, level, traversed)
    level = level or 3

    traversed = traversed or {}

    -- Check if both values have been traversed with respect to each other already
    do
        local traversed_a = traversed[a]
        local traversed_b = traversed[b]
        if traversed_a and traversed_b and traversed_a[b] and traversed_b[a] then
            return true
        end
    end

    if a == b then
        return true
    end
    local t = type(a)
    -- Type mismatch
    if t ~= type(b) then
        return false
    end

    if t == "function" then
        return fchk_functions(a, b, level, traversed)
    end

    if t == "userdata" then
        if level < 1 then
            return true
        end

        if not deep_equals(getmetatable(a), getmetatable(b), nil, traversed) then
            return false
        end

        -- make sure we have pairs
        if getmetatable(a).__pairs then
            if not fchk_table_keys(a, b, traversed) then
                return false
            end

            for k, value_a in pairs(a) do
                local value_b = b[k]

                if not deep_equals(value_a, value_b, nil, traversed) then
                    return false
                end
            end
        elseif getmetatable(a).__ipairs and getmetatable(a).__len then
            if #a ~= #b then
                return false
            end

            for i, value_a in ipairs(a) do
                local value_b = b[i]

                if not deep_equals(value_a, value_b, nil, traversed) then
                    return false
                end
            end
        end

        return true
    end

    if t == "thread" then
        return level < 2 or
            (level == 3 and error("Cannot determine equality of thread data"))
    end

    if t == "table" then
        if level < 1 then return true end

        traversed[a] = traversed[a] or {}
        traversed[a][b] = true
        traversed[b] = traversed[b] or {}
        traversed[b][a] = true

        if #a ~= #b then
            return false
        end

        -- TODO can I use mt ~= mt here? genuinely unsure!
        -- check mt
        if not deep_equals(getmetatable(a), getmetatable(b), level, traversed) then
            return false
        end

        -- check keys
        local keys_ok, exotic_b = fchk_table_keys(a, b, traversed)
        if not keys_ok then
            return false
        end

        -- keys must match so we can walk a
        for k, value_a in pairs(a) do
            if not is_primitive(k) then
                local has_key_match = false

                for _, k_b in pairs(exotic_b) do
                    if deep_equals(k, k_b, level, traversed) then
                        if not deep_equals(value_a, b[k_b], level, traversed) then
                            return false
                        end

                        has_key_match = true
                        break
                    end
                end

                if not has_key_match then
                    return false
                end
            elseif not deep_equals(value_a, b[k], level, traversed) then
                return false
            end
        end

        return true
    end

    return false
end

local table_insert = table.insert
local table_remove = table.remove

--- Fast check table keys: check all keys of two tables, ignoring values
--- O(a + b) for primitive keys, O(ab) for exotic keys
---@param a table
---@param b table
---@param traversed table
---@return boolean key_match
---@return table exotic_keys
fchk_table_keys = function(a, b, traversed)
    local primitive_keys_a = {}
    local exotic_keys_a = {}
    for k in pairs(a) do
        if is_primitive(k) then
            primitive_keys_a[k] = true
        else
            table_insert(exotic_keys_a, k)
        end
    end

    local exotic_keys_b = {}
    for k_b in pairs(b) do
        if is_primitive(k_b) then
            if not primitive_keys_a[k_b] then
                return false, exotic_keys_b
            end
            primitive_keys_a[k_b] = nil
        else
            table_insert(exotic_keys_b, k_b)

            local has_match = false
            for i, k_a in ipairs(exotic_keys_a) do
                if deep_equals(k_a, k_b, nil, traversed) then
                    has_match = true
                    table_remove(exotic_keys_a, i)

                    break
                end
            end
            if not has_match then
                return false, exotic_keys_b
            end
        end
    end
    return next(primitive_keys_a) == nil and # exotic_keys_a == 0, exotic_keys_b
end

local debug_getupvalue = (debug or {}).getupvalue
local debug_getinfo = (debug or {}).getinfo
local string_dump = string.dump

---@param a function
---@param b function
---@param level number
---@param traversed table
---@return boolean
fchk_functions = function(a, b, level, traversed)
    -- do a basic check for location, if debug exists
    if debug_getinfo then
        local i_a = debug_getinfo(a, "S")
        local i_b = debug_getinfo(b, "S")

        if i_a.source ~= i_b.source or i_a.linedefined ~= i_b.linedefined then
            return false
        end
    end

    -- check function content
    local str_a = string_dump(a)
    local str_b = string_dump(b)
    if str_a ~= str_b then
        return false
    end

    -- check if upvalues are out of sync.
    if debug_getupvalue then
        local i = 1

        while true do
            local name_a, val_a = debug_getupvalue(a, i)
            local name_b, val_b = debug_getupvalue(b, i)

            if name_a ~= name_b or not deep_equals(val_a, val_b, level, traversed) then
                return false
            end

            if name_a == nil then
                break
            end

            i = i + 1
        end

        return true
    elseif level <= 2 then
        return false
    else
        error("Unable to determine function equality: missing function ")
    end
end


return deep_equals

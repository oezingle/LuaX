local pairs = pairs
local next = next
local type = type
local getmetatable = getmetatable

---@type fun(a: table, b: table): boolean
local fchk_table_keys

--- Check if a value is a primitive
---@param value any
---@return boolean
local function is_primitive(value)
    local t = type(value)
    return t == "nil" or t == "string" or t == "number" or t == "boolean"
end

---@param a any
---@param b any
---@param shallow boolean?
local function any_equals(a, b, shallow)
    shallow = shallow or false
    if a == b then
        return true
    end
    local t = type(a)
    -- Type mismatch
    if t ~= type(b) then
        return false
    end

    if t == "function" then
        --[[
            experimenting with bytecode, I found that Lua's format is far too
            variable for me to reasonably expect that I can determine function
            equality. This is for sure going to bite me in the ass in the near
            future.

            Lua 5.1 Bytecode:
                https://usermanual.wiki/Pdf/A20No20Frill20s20Intro20To20Lua205120VM20Instructions.560214948
        ]]
        return shallow or error("Cannot determine equality of function data")
    end

    if t == "userdata" then
        if shallow then
            return true
        end

        if not any_equals(getmetatable(a), getmetatable(b), false) then
            return false
        end

        -- make sure we have pairs
        if getmetatable(a).__pairs then
            if not fchk_table_keys(a, b) then
                return false
            end

            for k, value_a in pairs(a) do
                local value_b = b[k]

                if not any_equals(value_a, value_b, false) then
                    return false
                end
            end
        elseif getmetatable(a).__ipairs and getmetatable(a).__len then
            if #a ~= #b then
                return false
            end

            for i, value_a in ipairs(a) do
                local value_b = b[i]

                if not any_equals(value_a, value_b, false) then
                    return false
                end
            end
        end

        return true
    end

    if t == "thread" then
        return shallow or error("Cannot determine equality of thread data")
    end

    if t == "table" then
        if shallow then return true end

        if #a ~= #b then
            return false
        end

        -- TODO can I use mt ~= mt here? genuinely unsure!
        -- check mt
        if not any_equals(getmetatable(a), getmetatable(b), false) then
            return false
        end

        -- check keys
        if not fchk_table_keys(a, b) then
            return false
        end

        -- keys must match so we can walk a
        for k, value_a in pairs(a) do
            local value_b = b[k]
            if not any_equals(value_a, value_b, false) then
                return false
            end
        end

        return true
    end

    return false
end

--- Fast check table keys: check all keys of two tables, ignoring values
--- O(a + b) for primitive keys, O(ab) for exotic keys
--- @param a table
--- @param b table
---@return boolean
fchk_table_keys = function(a, b)
    local primitive_keys_a = {}
    local exotic_keys_a = {}
    for k in pairs(a) do
        if is_primitive(k) then
            primitive_keys_a[k] = true
        else
            table.insert(exotic_keys_a, k)
        end
    end

    for k in pairs(b) do
        if is_primitive(k) then
            if not primitive_keys_a[k] then
                return false
            end
            primitive_keys_a[k] = nil
        else
            local has_match = false
            for i, k_a in ipairs(exotic_keys_a) do
                if any_equals(k_a, b, false) then
                    has_match = true
                    table.remove(exotic_keys_a, i)

                    break
                end
            end
            if not has_match then
                return false
            end
        end
    end
    return next(primitive_keys_a) == nil and # exotic_keys_a == 0
end

return any_equals

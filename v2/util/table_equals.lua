--- Shallowly or deeply check two tables (or any) for equality
---
--- You'd think shallow is exceptionally faster,
--- but it only is in worst-case scenarios.
---@param a any
---@param b any
---@param shallow boolean
---@return boolean
local function table_equals(a, b, shallow)
    -- could happen
    if a == b then
        return true
    end

    if type(a) ~= type(b) then
        return false
    end

    if type(a) == "table" then
        for key, value in pairs(a) do
            local value_b = b[key]

            if type(value) == "table" then
                if type(value_b) ~= "table" then
                    return false
                end

                -- shallow equals ignores tables as equivalent tables
                -- could have different memory locations
                if not (shallow or a == b) then
                    if not table_equals(value, value_b, shallow) then
                        return false
                    end
                end
            elseif value ~= value_b then
                return false
            end
        end

        for key, _ in pairs(b) do
            if not a[key] then
                return false
            end
        end

        return true
    else
        return a == b
    end
end

return table_equals

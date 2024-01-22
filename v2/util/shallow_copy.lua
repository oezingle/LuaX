
--- Shallow copy any table
---@generic T
---@param table T
---@return T copy
local function shallow_copy (table)
    local ret = {}

    for k, v in pairs(table) do
        ret[k] = v
    end

    return ret
end

return shallow_copy
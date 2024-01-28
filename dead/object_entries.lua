
---@generic K, T
---@param object { K: T }
---@return { [0]: K, [1]: T }[]
local function object_entries (object)
    local ret = {}

    for key, value in pairs(object) do
        table.insert(ret, { key, value })
    end

    return ret
end 

return object_entries
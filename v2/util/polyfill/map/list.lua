---@generic T, K
---@param list T[]
---@param fn fun(T): K
---@return K[]
local function map_list(list, fn)
    local ret = {}

    for i, item in ipairs(list) do
        ret[i] = fn(item)
    end

    return ret
end

return map_list

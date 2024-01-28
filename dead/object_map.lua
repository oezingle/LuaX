
---@generic T, K, R
---@param object { K: T }
---@param fn fun(T): R
---@return { K: R }
local function map_object(object, fn)
    local ret = {}

    for key, value in pairs(object) do
        ret[key] = fn(value)
    end

    return ret
end

return map_object


---@generic T
---@param list T[]
---@return table<T, true>
local function list_to_map (list)
    local map = {}

    for _, item in pairs(list) do
        map[item] = true
    end

    return map
end

---@param text string
---@return table<string, true>
local collect_locals = function (text)
    
end

return collect_locals
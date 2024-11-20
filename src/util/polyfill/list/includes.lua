
---@param list any
---@param item any
---@return number | false
local function includes (list, item)
    for i, v in pairs(list) do
        if v == item then
            return i
        end
    end

    return false
end

return includes
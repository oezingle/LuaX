--- Can't be tested because of warn() usage
---@nospec

local warn_history = {}

--- Like warn(), but will cache previous warnings.
---@param ... any
local function warn_once (...)
    local strs = {}
    for i, sub in ipairs(...) do
        strs[i] = tostring(sub)
    end
    
    local hash = table.concat(strs)

    if not warn_history[hash] then
        warn(...)

        warn_history[hash] = true
    end
end

return warn_once
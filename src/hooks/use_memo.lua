local use_state = require "src.hooks.use_state"
local use_effect= require "src.hooks.use_effect"

---@generic T
---@param callback fun(): T
---@param deps any[]
---@return T
local function use_memo (callback, deps)
    local result, set_result = use_state()

    use_effect(function ()
        set_result(callback())
    end, deps)

    return result
end

return use_memo
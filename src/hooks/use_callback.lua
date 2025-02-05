local use_memo = require("src.hooks.use_memo")

---@generic T
---@alias LuaX.Hooks.UseCallback fun (callback: T, deps: any[]): T

---@type LuaX.Hooks.UseCallback
local function use_callback (cb, deps)
    return use_memo(function ()
        return cb
    end, deps)
end

return use_callback
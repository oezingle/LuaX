local HookState = require("src.util.HookState")

---@param cb fun()
---@param change_listener LuaX.HookState.Listener?
local function with_virtual_hookstate(cb, change_listener)
    return function()
        local old_luax = LuaX

        local hookstate = HookState()

        if change_listener then
            hookstate:add_listener(change_listener)
        end

        _G.LuaX = {
            _hookstate = hookstate
        }

        cb()

        _G.LuaX = old_luax
    end
end

return with_virtual_hookstate
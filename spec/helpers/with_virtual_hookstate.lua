local HookState = require("src.util.HookState")

---@param cb fun()
---@param change_listener LuaX.HookState.Listener?
local function with_virtual_hookstate(cb, change_listener)
    local old_luax = _G.LuaX

    local hookstate = HookState()

    if change_listener then
        hookstate:set_listener(change_listener)
    end

    _G.LuaX = {
        _hookstate = hookstate
    }

    cb()

    _G.LuaX = old_luax
end

return with_virtual_hookstate

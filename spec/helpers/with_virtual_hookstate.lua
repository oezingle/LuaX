local HookState = require("src.util.HookState")

---@param cb fun()
---@param change_listener LuaX.HookState.Listener?
local function with_virtual_hookstate(cb, change_listener)
    local hookstate = HookState()

    if change_listener then
        hookstate:set_listener(change_listener)
    end

    local prev = HookState.global.set(hookstate)

    cb()

    HookState.global.set(prev)
end

return with_virtual_hookstate

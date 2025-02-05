local DrawGroup = require "src.util.Renderer.DrawGroup"
local use_memo  = require "src.hooks.use_memo"

---@alias LuaX.Hooks.UseSuspense fun(): (suspend: fun(), resolve: fun())

---@type LuaX.Hooks.UseSuspense
local function use_suspense()
    local group = use_memo(function()
        return DrawGroup.current()
    end, {})

    return function ()
        DrawGroup.ref(group)
    end, function ()
        DrawGroup.unref(group)
    end
end

return use_suspense

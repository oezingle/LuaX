local use_ref        = require("src.hooks.use_ref")

-- TODO FIXME does not work at all
-- TODO move to a helper
local HookState = require("src.util.HookState")
---@param cb fun()
---@param change_listener LuaX.HookState.Listener?
--- TODO argument 2 should let users handle HookState changes (to check for re-render calls without a full Renderer setup)
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

describe("use_ref", function()
    it("takes implicit nil as a default", with_virtual_hookstate(function()
        local ref = use_ref()

        assert.equal(nil, ref.current)
    end))

    it("takes non-nil as a default", with_virtual_hookstate(function()
        local ref = use_ref("Hello world!")

        assert.equal("Hello world!", ref.current)
    end))

    it("doesn't call a re-render on change", with_virtual_hookstate(function()
        local ref = use_ref("Hello world!")

        ref.current = "Goodbye world!"
    end, function()
        print("uh-oh!")

        error("ref called re-render")
    end))
end)

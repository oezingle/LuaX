
local HookState = require("src.util.HookState")

describe("HookState", function ()
    it("acts as a list", function ()
        local hello_world = "Hello World!"

        local hookstate = HookState()

        local index = hookstate:get_index()

        hookstate:set_value(index, hello_world)

        hookstate:set_index(index + 1)

        assert.equal(hello_world, hookstate:get_value(index))
    end)

    it("listens for changes", function ()
        local hello_world = "Hello World!"

        local hookstate = HookState()
        hookstate:set_listener(function (_, value)
            assert.equal(hello_world, value)
        end)

        local index = hookstate:get_index()

        hookstate:set_value(index, hello_world)
    end)

    -- to past me - why not?
    --[[
    it("ignores the same value", function ()
        local hello_world = "Hello World!"

        local listener_calls = 0

        local hookstate = HookState()
        hookstate:add_listener(function (index, value)
            listener_calls = listener_calls + 1
        end)

        local index = hookstate:get_index()
        hookstate:set_value(index, hello_world)
        hookstate:set_value(index, hello_world)

        assert.equal(1, listener_calls)
    end)
    ]]

    -- TODO FIXME test context functionality
end)
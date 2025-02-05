local use_state = require("src.hooks.use_state")
local with_virtual_hookstate = require("spec.helpers.with_virtual_hookstate")
local HookState = require("src.util.HookState")

describe("use_state", function()
    it("has a default value", function()
        with_virtual_hookstate(function()
            local v, set_v = use_state(0)

            assert.equal(0, v)
            assert.Function(set_v)
        end)
    end)

    it("triggers hookstate changes on value changes", function()
        local changes = 0

        with_virtual_hookstate(function()
            local v, set_v = use_state(0)

            set_v(1)
        end, function(index, value)
            changes = changes + 1
        end)

        assert.equal(1, changes)
    end)

    it("does not trigger hookstate changes without value change", function()
        local changes = 0

        with_virtual_hookstate(function()
            local v, set_v = use_state(0)

            set_v(0)
        end, function(index, value)
            changes = changes + 1
        end)

        assert.equal(0, changes)
    end)

    it("recycles setter", function()
        with_virtual_hookstate(function()
            local _, set_1 = use_state()

            HookState.global.get():reset()

            local _, set_2 = use_state()

            assert.equal(set_1, set_2)
        end)
    end)
end)

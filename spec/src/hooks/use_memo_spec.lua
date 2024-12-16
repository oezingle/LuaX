local use_memo       = require("src.hooks.use_memo")
local create_element = require("src.create_element")
local use_effect     = require("src.hooks.use_effect")
local use_state      = require("src.hooks.use_state")
local render_set_up  = require("spec.helpers.render_set_up")

describe('use_memo', function()
    it("only fires once", function()
        local hook_calls = 0

        local function fc()
            local ret = use_memo(function()
                hook_calls = hook_calls + 1

                return hook_calls
            end, {})

            assert.is_not_nil(ret)

            return create_element("LITERAL_NODE", { value = ret })
        end

        local _, render = render_set_up(fc)

        render()
        assert.equal(1, hook_calls)
        render()
        assert.equal(1, hook_calls)
    end)

    it("triggers a state reload", function()
        local total = 0

        local function fc()
            local value, set_value = use_state(0)

            local derived = use_memo(function()
                return value * 2
            end, { value })

            use_effect(function()
                total = total + derived
            end, { derived })

            use_effect(function()
                set_value(function(value)
                    return value + 1
                end)
            end, {})
        end

        local _, render = render_set_up(fc)

        render()
        assert.equal(total, 2)
        render()
        assert.equal(total, 2)
    end)
end)

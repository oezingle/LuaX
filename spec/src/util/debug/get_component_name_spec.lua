local get_component_name = require("src.util.debug.get_component_name")
local Inline = require("src.util.parser.Inline")

describe("get_component_name", function()
    it("gets the name of a classical component", function()
        local Component = function()
            return nil
        end

        assert.equal("Component", get_component_name(Component):match("^%S+"))
    end)

    it("gets the name of a transpiled component", function()
        local Component = Inline:transpile_decorator(function()
            return [[
                <>

                </>
            ]]
        end)

        assert.equal("Component", get_component_name(Component):match("^%S+"))

        collectgarbage("collect")

        -- make sure our weak table is fine and dandy
        assert.equal("Component", get_component_name(Component):match("^%S+"))
    end)
end)

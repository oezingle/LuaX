local get_element_name = require("src.util.debug.get_element_name")
local create_element = require("src.create_element")
local Inline = require("src.util.parser.Inline")

describe("get_element_name", function()
    it("handles string ElementNodes", function()
        local element = create_element("root", {})

        assert.equal("root", get_element_name(element))
    end)

    it("handles function ElementNodes", function()
        local function function_component ()

        end

        local element = create_element(function_component, {})

        local name = get_element_name(element)

        assert.truthy(name:match("function_component"))
    end)

    it("handles literal nodes", function ()
        local element = create_element("root", { children = "Hello World!" })

        local name = get_element_name(element.props.children[1])

        assert.equal("Literal", name)
    end)

    it("handles inline Function Components", function ()
        local Function = Inline:transpile(function ()
            return nil
        end)

        local element = create_element(Function, {})

        local name = get_element_name(element)

        assert.is_not_match("Inline", name)

        assert.is_match("^Function", name)
    end)

    -- TODO test Components / NativeElements
end)

local get_element_name = require("src.util.Renderer.helper.get_element_name")

local create_element = require("src.create_element")

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

        assert.truthy(name:match("Function defined at"))
    end)

    
    -- TODO test NativeElements
end)

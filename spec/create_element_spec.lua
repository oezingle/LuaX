
local create_element = require("v3.create_element")

describe("create_element", function ()
    it("returns an expected lua table", function ()
        local element = create_element("test_element", {
            prop1 = true,
            prop2 = 2
        })

        assert.equal(element.type, "test_element")

        assert.equal(element.props.prop1, true)
        assert.equal(element.props.prop2, 2)
    end)

    it("turns a single child into a children array", function ()
        local element_str_child = create_element("test_element", {
            children = "Hello world!"
        })

        assert.is_table(element_str_child.props.children)

        local element_element_child = create_element("test_element", {
            children = create_element("child_element", {})
        })

        assert.Nil(element_element_child.props.children.type)

        local element_no_child = create_element("test_element", {})

        assert.Nil(element_no_child.props.children)
    end)

    it("doesn't turn an array of children into an array of an array of children", function ()
        local element_array_child = create_element("test_element", {
            children = {
                create_element("inner", {})
            }
        })

        assert.truthy(element_array_child.props.children[1].type)

        local element_array_children = create_element("test_element", {
            children = {
                create_element("inner", {}),
                create_element("inner", {})
            }
        })

        assert.truthy(element_array_children.props.children[1].type)
        assert.truthy(element_array_children.props.children[2].type)
    end)

    it("turns strings into special elements", function ()
        local element_str_child = create_element("test_element", {
            children = "Hello world!"
        })

        assert.table(element_str_child.props.children[1])
    end)

    --[[
    it("is immutable", function ()
        local element = create_element("test_element", {})

        local success = pcall(function ()
            element.type = "newtype"
        end)
        assert.falsy(success)

        local success = pcall(function ()
            element.props = {}
        end)
        assert.falsy(success)
        
        local success = pcall(function ()
            element.props.children = nil
        end)
        assert.falsy(success)
    end)
    ]]
end)
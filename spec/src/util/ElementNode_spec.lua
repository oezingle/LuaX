local ElementNode = require("src.util.ElementNode")

describe("ElementNode", function()
    describe("clean_children", function()
        local literal_element = ElementNode.create(ElementNode.LITERAL_NODE, { value = "Hello World!" })

        describe("takes single", function()
            it("string", function()
                local children = "Hello World!"
                local expected = { literal_element }

                ---@diagnostic disable-next-line:invisible
                local cleaned = ElementNode.clean_children(children)

                assert.are.same(expected, cleaned)
            end)

            it("ElementNode", function()
                local children = ElementNode.create("nil", {})
                local expected = { ElementNode.create("nil", {}) }

                ---@diagnostic disable-next-line:invisible
                local cleaned = ElementNode.clean_children(children)

                assert.are.same(expected, cleaned)
            end)

            it("nil", function()
                local children = nil
                local expected = {}

                ---@diagnostic disable-next-line:invisible
                local cleaned = ElementNode.clean_children(children)

                assert.are.same(expected, cleaned)
            end)

            it("false", function()
                local children = false
                local expected = {}

                ---@diagnostic disable-next-line:invisible
                local cleaned = ElementNode.clean_children(children)

                assert.are.same(expected, cleaned)
            end)
        end)

        describe("takes multiple", function()
            it("strings", function()
                local children = { "Hello World!" }
                local expected = { literal_element }

                ---@diagnostic disable-next-line:invisible
                local cleaned = ElementNode.clean_children(children)

                assert.are.same(expected, cleaned)
            end)

            it("false", function()
                local children = { false, "Hello World!" }
                local expected = { nil, literal_element }

                ---@diagnostic disable-next-line:invisible
                local cleaned = ElementNode.clean_children(children)

                assert.are.same(expected, cleaned)
            end)
        end)
    end)

    it("returns an expected lua table", function()
        local element = ElementNode.create("test_element", {
            prop1 = true,
            prop2 = 2
        })

        assert.equal(element.type, "test_element")

        assert.equal(element.props.prop1, true)
        assert.equal(element.props.prop2, 2)
    end)

    it("gives metatable still", function()
        local node = ElementNode.create("test_element", {})

        assert.equal(ElementNode, node.element_node)
    end)

    -- TODO FIXME move to special/
    it("doesn't waste memory", function()
        local a = ElementNode.create("div", {})
        local b = ElementNode.create("div", {})

        assert.equal(a.element_node, b.element_node)
    end)
end)

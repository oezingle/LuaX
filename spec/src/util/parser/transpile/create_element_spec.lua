--- Tests are brief here because a very large majority of the work is done by stringify_table

local transpile_create_element = require("src.util.parser.transpile.create_element")
local create_element           = require("src.create_element")
local Fragment                 = require("src.components.Fragment")
local ElementNode              = require("src.util.ElementNode")

describe("transpile_create_element", function()
    it("converts nicely", function()
        local type = "Fragment"
        local props = {
            awesome = true,
            children = {}
        }

        local transpiled = transpile_create_element(nil, type, props)

        local get_element, err = load("return " .. transpiled, "transpiled create_element", "t", {
            create_element = create_element,
            Fragment = Fragment
        })

        if not get_element then
            error(err or "Unknown load() error")
        end

        local element = get_element()

        assert.equal(Fragment, element.type)

        assert.equal(0, #element.props.children)

        assert.True(element.props.awesome)
    end)

    it("gets the right value", function ()
        local transpiled = transpile_create_element(nil, "\"LUAX_LITERAL_NODE\"", { value = "{props.message}" })

        local get_element, err = load("return " .. transpiled, "transpiled create_element", "t", {
            create_element = create_element,
            props = { message = "Hello World!" }
        })

        if not get_element then
            error(err or "Unknown load() error")
        end

        local element = get_element()

        assert.equal(ElementNode.LITERAL_NODE, element.type)
        assert.equal("Hello World!", element.props.value)
    end)
end)

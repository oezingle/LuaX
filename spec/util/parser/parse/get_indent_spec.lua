
local remove_default_indent = require("src.util.parser.parse.remove_default_indent")
local get_indent = require("src.util.parser.parse.get_indent")

describe("get_indent", function ()
    it("works in a basic case", function ()
        local xml = remove_default_indent([[
            <Element>
                <ChildElement />
            </Element>
        ]])

        local indent = get_indent(xml)

        assert.equal("    ", indent)
    end)

    it("works for fragment of text", function ()
        local xml = remove_default_indent([[
            <>
                Text in here!
            </>
        ]])

        local indent = get_indent(xml)

        assert.equal("    ", indent)
    end)
end)
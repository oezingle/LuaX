
local remove_default_indent = require("v3.util.xml.remove_default_indent")
local get_indent = require("v3.util.xml.get_indent")

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
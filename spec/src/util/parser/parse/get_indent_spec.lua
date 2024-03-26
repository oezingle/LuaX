
local get_indent = require("src.util.parser.parse.get_indent")

describe("get_indent", function ()
    it("works in a basic case", function ()
        local luax_code = [[
<Element>
    <ChildElement />
</Element>
        ]]

        local indent = get_indent(luax_code)

        assert.equal("    ", indent)
    end)

    it("works for fragment of text", function ()
        local luax_code = [[
<>
    Text in here!
</>
        ]]

        local indent = get_indent(luax_code)

        assert.equal("    ", indent)
    end)
end)
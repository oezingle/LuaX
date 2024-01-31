
local remove_default_indent = require("src.util.parser.parse.remove_default_indent")

describe("remove_default_indent", function ()
    it("works for a simple string", function ()
        local str = [[
            Hello world!]] .. "\n"

        local unindented = remove_default_indent(str)

        assert.equal(unindented, "Hello world!\n")
    end)

    it("works for multiple lines", function ()
        local str = [[
            Hello world!
            Goodbye world!]] .. "\n"

        local unindented = remove_default_indent(str)

        assert.equal("Hello world!\nGoodbye world!\n", unindented)
    end)

    it("works for a given XML string", function ()
        local xml = [[
            <Element>
                I am text 1!

                <Child>
                    I am text 2!
                </Child>

                <Child>I am text 3!</Child>
            </Element>
        ]]

        local unindented = remove_default_indent(xml)

        -- The string ends with \t\t, but that's ok because SLAXML ignores it
        local expected = [[<Element>
    I am text 1!

    <Child>
        I am text 2!
    </Child>

    <Child>I am text 3!</Child>
</Element>
        ]]
        
        assert.equal(expected, unindented)
    end)
end)
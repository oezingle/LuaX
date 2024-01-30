
local htmlparser = require("lib.htmlparser")
local pprint     = require("lib.pprint")

describe("htmlparser", function ()
    it("parses implicit props", function ()
        local root = htmlparser.parse("<div container />")

        --- Implicit prop is set to ""
        assert.truthy(root.nodes[1].attributes.container)
    end)

    it("parses literal props without fuckups", function ()
        local root = htmlparser.parse("<div onclick=\"{function () print('Hello world!') end}\" />")

        local expected = "{function () print('Hello world!') end}"

        assert.equal(expected, root.nodes[1].attributes.onclick)
    end)

    it("parses comments good", function ()
        local root = htmlparser.parse([[
            <div>
                <!-- I'm a comment! -->
            </div>
        ]])
        
        assert.equal(0, #root.nodes[1].nodes)
    end)

    it("parses should-be illegal tags", function ()
        local root = htmlparser.parse([[
            <wibox.widget.textbox
                value = "Hello world"
            />
        ]])

        assert.equal("wibox.widget.textbox", root.nodes[1].name)
    end)
end)

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

    it("parses text nodes", function ()
        local root = htmlparser.parse([[
            <div>
                Hello world!

                <div>
                    Goodbye world!
                </div>
            </div>
        ]])


        pprint(root.nodes[1].nodes[1]:gettext())
    end)
end)
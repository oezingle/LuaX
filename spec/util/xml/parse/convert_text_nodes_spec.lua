
local htmlparser = require("lib.htmlparser")
local convert_text_nodes =require("src.util.xml.parse.convert_text_nodes")
local pprint             = require("lib.pprint")

describe("convert_text_nodes", function ()
    it("adds text with no child nodes", function ()
        local html = htmlparser.parse([[
            <div>
                Hello world!
            </div>
        ]])

        local root = convert_text_nodes(html, "   ", 3)

        local str = root.nodes[1].nodes[1].attributes.value

        assert.truthy(str:match("^%s*Hello world!%s*$"))
    end)

    it("adds text with child nodes", function ()
        local html = htmlparser.parse([[
            <div>
                Hello world!

                <a>
                    Link
                </a>

                Goodbye world!
            </div>
        ]])

        local root = convert_text_nodes(html, "    ", 3)

        local div = root.nodes[1]

        assert.equal(3, #div.nodes)


        local hello = div.nodes[1].attributes.value
        assert.truthy(hello:match("^%s*Hello world!%s*$"))
        assert.equal("Hello world!", hello)


        assert.equal("a", div.nodes[2].name)


        local goodbye = div.nodes[3].attributes.value
        assert.truthy(goodbye:match("^%s*Goodbye world!%s*$"))
    end)
end)
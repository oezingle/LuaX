
local LuaXParser = require("src.util.parser.LuaXParser")
local pprint     = require("lib.pprint")

describe("LuaXParser", function ()
    it("parses tags with neither children nor props nicely", function ()
        local parser = LuaXParser([[
            <br />
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("br", node.name)
    end)

    it("parsse tags with no props", function ()
        local parser = LuaXParser([[
            <br></br>
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("br", node.name)
    end)

    it("parses tags with no children nicely", function ()
        local parser = LuaXParser([[
            <wibox.widget.textbox text="Hello world"/>
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("wibox.widget.textbox", node.name)

        assert.equal("Hello world", node.props.text)
    end)

    it("parses tags with children nicely", function ()
        local parser = LuaXParser([[
            <wibox.layout.margin margin={2}>
                <wibox.widget.textbox signal::button::press={function () print("Hello world!") end}>
                    I am a text!
                </wibox.widget.textbox>
            </wibox.layout.margin>
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("wibox.layout.margin", node.name)

        -- this is a string because the Parser by default is static.
        assert.equal('{2}', node.props.margin)
        assert.equal(1, #node.children)

        local textbox = node.children[1]

        assert.equal([[{function () print("Hello world!") end}]], textbox.props["signal::button::press"])
        
        assert.equal(1, #textbox.children)

        -- TODO check child literal, and its value (after indent fixes)
    end)

    it("parses fragments", function ()
        local parser = LuaXParser([[
            <>
                Hello world!
            </>
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal(1, #node.children)

        -- TODO check child literal, and its value (after indent fixes)
    end)

    it("parses implicit props", function ()
        local parser = LuaXParser([[ <div container /> ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("{true}", node.props.container)
    end)
end)
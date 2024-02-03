local LuaXParser = require("src.util.parser.LuaXParser")

describe("LuaXParser", function()
    it("parses tags with neither children nor props nicely", function()
        local parser = LuaXParser([[
            <br />
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("br", node.name)
    end)

    it("parsse tags with no props", function()
        local parser = LuaXParser([[
            <br></br>
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("br", node.name)
    end)

    it("parses tags with no children nicely", function()
        local parser = LuaXParser([[
            <wibox.widget.textbox text="Hello world"/>
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("wibox.widget.textbox", node.name)

        assert.equal("Hello world", node.props.text)
    end)

    it("parses tags with children nicely", function()
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

        local text = textbox.children[1]

        assert.equal("I am a text!", text.value)
    end)

    it("parses fragments", function()
        local parser = LuaXParser([[
            <>
                Hello world!
            </>
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("element", node.type)
        assert.equal(LuaXParser.FRAGMENT_AUTO_IMPORT_NAME, node.name)

        assert.equal(1, #node.children)

        local text = node.children[1]

        assert.equal("literal", text.type)
        assert.equal("Hello world!", text.value)
    end)

    it("parses implicit props", function()
        local parser = LuaXParser([[ <div container /> ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("{true}", node.props.container)
    end)

    it("runs parse_all without issue", function()
        local node = LuaXParser([[


            <div meep />
        ]]):parse_all()

        assert.equal("div", node.name)
        assert.equal("{true}", node.props.meep)
    end)

    it("fails parse_all with multiple parents", function()
        local success = pcall(function()
            LuaXParser([[
                <div meep />

                end text
            ]]):parse_all()
        end)

        assert.False(success)
    end)

    it("parses literal children", function()
        local parser = LuaXParser([[
            <>
                {props.message}
            </>
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("{props.message}", node.children[1].value)
    end)

    it("parses literal children", function()
        local parser = LuaXParser([[
            <>
                {props.message}
            </>
        ]])

        local start = parser:skip_whitespace()

        local node = parser:parse_tag(start)

        assert.equal("{props.message}", node.children[1].value)
    end)

    it("parses wholeass files", function()
        -- require("src.util.replace_warn")

        -- TODO FIXME whitespace issues.
        local transpiled = LuaXParser([[
            local Fragment = require("src.components.Fragment")

            local function Component (props)
                return (
                    <>
                        {props.message}
                    </>
                )
            end

            return Component
        ]]):parse_file()

        -- print(transpiled)

        local run_transpiled, err = load(transpiled, "transpiled LuaX")

        if not run_transpiled then
            error(err)
        end

        local Component = run_transpiled()

        local element = Component({ message = "a string!" })

        assert.equal("a string!", element.props.children[1].props.value)
    end)
end)

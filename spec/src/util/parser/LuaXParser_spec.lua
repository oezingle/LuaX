local LuaXParser = require("src.util.parser.LuaXParser")
local log = require("lib.log")

-- local pprint = require("lib.pprint")

describe("LuaXParser (v2)", function()
    it("parses fragments", function()
        local parser = LuaXParser()

        local code = "<></>"

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal(LuaXParser.imports.auto.FRAGMENT.name, node.name)
        assert.equal(#code, end_pos)
    end)

    it("parses tags that don't have props", function()
        local parser = LuaXParser()

        local code = "<wibox.widget.textbox></wibox.widget.textbox>"

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal("wibox.widget.textbox", node.name)
        assert.equal(#code, end_pos)
    end)

    it("parses literals in quotes", function()
        local parser = LuaXParser()

        local code = "<div class=\"{variable}\"></div>"

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal("{variable}", node.props.class)
        assert.equal(#code, end_pos)
    end)

    it("parses tags with explicit props", function()
        local parser = LuaXParser()

        local code = "<div class=\"a-class\"></div>"

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal("a-class", node.props.class)
        assert.equal(#code, end_pos)
    end)

    it("parses tags with implicit props", function()
        local parser = LuaXParser()

        local code = "<Box container></Box>"

        local node, end_pos = parser:parse_tag(code, 0)

        assert.True(node.props.container)
        assert.equal(#code, end_pos)
    end)

    it("Parses tags with no children with no whitespace", function()
        local parser = LuaXParser()

        local code = "<Box/>"

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal(0, #node.children)
        assert.equal(#code, end_pos)
    end)

    -- TODO doesn't track whitespace here goodly.
    it("Parses tags with no children", function()
        local parser = LuaXParser()

        local code = "<Box />"

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal(0, #node.children)
        assert.equal(#code, end_pos)
    end)

    it("parses Fragments that could have children, but do not", function()
        local parser = LuaXParser()

        local code = [[<>

        </>]]

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal(0, #node.children)
        assert.equal(LuaXParser.imports.auto.FRAGMENT.name, node.name)

        assert.equal(#code, end_pos)
    end)

    it("parses tags that could have children, but do not", function()
        local parser = LuaXParser()

        local code = [[<Box>

        </Box>]]

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal(0, #node.children)
        assert.equal("Box", node.name)

        assert.equal(#code, end_pos)
    end)

    it("parses children", function()
        local parser = LuaXParser()

        local code = [[<>
                <Box />

                This is a text!
            </>]]

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal(2, #node.children)
        assert.equal(LuaXParser.imports.auto.FRAGMENT.name, node.name)
        assert.equal(#code, end_pos)

        -- pprint(node.children[2])

        assert.equal("literal", node.children[2].type)
    end)

    it("splits literals", function()
        local parser = LuaXParser()

        parser.indent = "    "
        -- parser.default_indent = ""

        local code = [[<>
    Hello {location}!
        </>]]

        local node, end_pos = parser:parse_tag(code, 0)

        assert.equal(3, #node.children)

        -- pprint(node.children)

        assert.equal("Hello ", node.children[1].value)
        assert.equal("location", node.children[2])
        assert.equal("!", node.children[3].value)
    end)

    it("transpiles strings", function()
        local parser = LuaXParser()

        local code = [[<>

        </>]]

        local transpiled = parser:transpile_tag(code, 1, {
            [parser.imports.auto.FRAGMENT.name] = true,
            div = true
        }, "local")

        assert.equal("_LuaX_create_element(_LuaX_Fragment, {  })", transpiled)
    end)

    it("parses complex props", function()
        local parser = LuaXParser()

        local code = [[<wibox.widget.textbox
                signal::button::press={function ()
                    set_render(function (render) return not render end)
                end}
            >
                {render and "Rendering children (click)" or "Not rendering children (click)"}

                I'm not lua!
            </wibox.widget.textbox>]]

        parser.indent = "    "

        local node, end_pos = parser:parse_tag(code, 3)

        assert.Truthy(node.props['signal::button::press'])

        assert.equal(#code, end_pos)
    end)

    it("parses literal children", function()
        local parser = LuaXParser()

        local code = [[<text>{message}</text>]]

        local node = parser:parse_tag(code, 0)

        assert.equal('message', node.children[1])
    end)

    it("Parses children without spaces", function ()
        local parser = LuaXParser()

        local code = [[<text>Message!</text>]]

        local node = parser:parse_tag(code, 0)

        assert.equal("Message!", node.children[1].value)
    end)

    it("transpiles files", function()
        local parser = LuaXParser()

        local transpiled = parser:transpile_file([[
            local Fragment = require("src.components.Fragment")

            local function Component (props)
                return (
                    <>
                        {props.message}
                    </>
                )
            end

            return Component
        ]])

        local run_transpiled, err = load(transpiled, "transpiled LuaX")

        if not run_transpiled then
            error(err)
        end

        local Component = run_transpiled()

        local element = Component({ message = "a string!" })

        assert.equal("a string!", element.props.children[1].props.value)
    end)

    it("transpiles files with inline calls", function()
        local parser = LuaXParser()

        local code = [[
            local Fragment = require("src.components.Fragment")

            local Component = function (props)
                return ]] .. "LuaX([[" .. [[

                    <>
                        {props.message}
                    </>
                ]] .. "]])" .. [[
            end

            return Component
        ]]

        local transpiled = parser:transpile_file(code)

        local run_transpiled, err = load(transpiled, "transpiled LuaX")

        if not run_transpiled then
            error(err)
        end

        local Component = run_transpiled()

        local element = Component({ message = "a string!" })

        assert.equal("a string!", element.props.children[1].props.value)
    end)

    it("transpiles files with inline functions", function()
        local parser = LuaXParser()

        local code = [[
            local Fragment = require("src.components.Fragment")

            local Component = LuaX(function (props)
                return ]] .. "[[" .. [[

                    <>
                        {props.message}
                    </>
                ]] .. "]]" .. [[
            end)

            return Component
        ]]


        local transpiled = parser:transpile_file(code)

        local run_transpiled, err = load(transpiled, "transpiled LuaX")

        if not run_transpiled then
            error(err)
        end

        local Component = run_transpiled()

        local element = Component({ message = "a string!" })

        assert.equal("a string!", element.props.children[1].props.value)
    end)

    -- TODO FIXME - spec for parsing comment literals - eg {--[[ Hello World! ]]}
end)

local LuaXParser = require("src.util.parser.LuaXParser")

---@diagnostic disable:invisible

describe("LuaXParser (v3)", function()
    it("parses fragments", function()
        local code = "<></>"

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal(LuaXParser.vars.FRAGMENT.name, node.name)
        assert.equal(#code + 1, parser:get_cursor())
    end)

    it("parses tags that don't have props", function()
        local code = "<wibox.widget.textbox></wibox.widget.textbox>"

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal("wibox.widget.textbox", node.name)
        assert.equal(#code + 1, parser:get_cursor())
    end)

    it("parses literals in quotes", function()
        local code = "<div class=\"{variable}\"></div>"

        local parser = LuaXParser()
            :set_text(code)


        local node = parser:parse_tag(0)

        assert.equal("{variable}", node.props.class)
        assert.equal(#code + 1, parser:get_cursor())
    end)

    it("parses tags with explicit props", function()
        local code = "<div class=\"a-class\"></div>"

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal("a-class", node.props.class)
        assert.equal(#code + 1, parser:get_cursor())
    end)

    it("parses tags with implicit props", function()
        local code = "<Box container></Box>"

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.True(node.props.container)
        assert.equal(#code + 1, parser:get_cursor())
    end)

    it("Parses tags with no children with no whitespace", function()
        local code = "<Box/>"

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal(0, #node.children)
        assert.equal(#code + 1, parser:get_cursor())
    end)

    -- TODO doesn't track whitespace here goodly.
    it("Parses tags with no children", function()
        local code = "<Box />"

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal(0, #node.children)
        assert.equal(#code + 1, parser:get_cursor())
    end)

    it("parses Fragments that could have children, but do not", function()
        local code = [[<>

        </>]]

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal(0, #node.children)
        assert.equal(LuaXParser.vars.FRAGMENT.name, node.name)

        assert.equal(#code + 1, parser:get_cursor())
    end)

    it("parses tags that could have children, but do not", function()
        local code = [[<Box>

        </Box>]]

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal(0, #node.children)
        assert.equal("Box", node.name)

        assert.equal(#code + 1, parser:get_cursor())
    end)

    it("parses children", function()
        local code = [[<>
                <Box />
                This is a text!
            </>]]

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal(2, #node.children)
        assert.equal(LuaXParser.vars.FRAGMENT.name, node.name)
        assert.equal(#code + 1, parser:get_cursor())

        assert.string(node.children[2])
    end)

    it("splits literals", function()
        local code = [[
            <>
                Hello {location}!
            </>
        ]]

        local parser = LuaXParser()
            :set_text(code)
        parser.indent = "    "

        local node = parser:parse_tag(0)

        assert.equal(3, #node.children)

        assert.equal("\"Hello \"", node.children[1])
        assert.equal("location", node.children[2])
        assert.equal("\"!\"", node.children[3])
    end)

    it("transpiles strings", function()
        local code = [[<>

        </>]]

        local parser = LuaXParser()
            :set_text(code)
            :set_components({
                [LuaXParser.vars.FRAGMENT.name] = true,
                div = true
            }, "local")

        parser:transpile_tag()

        assert.equal("_LuaX_create_element(_LuaX_Fragment, {  })", parser.text)
    end)

    it("parses complex props", function()
        local code = [[
            <wibox.widget.textbox
                signal::button::press={function ()
                    set_render(function (render) return not render end)
                end}
            >
                {render and "Rendering children (click)" or "Not rendering children (click)"}

                I'm not lua!
            </wibox.widget.textbox>
        ]]

        local parser = LuaXParser()
            :set_text(code)
            :set_components({
                "wibox.widget.textbox"
            }, "global")

        parser.indent = "    "

        local node = parser:parse_tag(3)

        assert.Truthy(node.props['signal::button::press'])

        -- TODO FIXME i have no idea what's up here
        -- assert.equal(#code + 1, parser:get_cursor())
    end)

    it("parses literal children", function()
        local code = [[<text>{message}</text>]]

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal('message', node.children[1])
    end)

    it("Parses children without spaces", function()
        local code = [[<text>Message!</text>]]

        local parser = LuaXParser()
            :set_text(code)

        local node = parser:parse_tag(0)

        assert.equal("\"Message!\"", node.children[1])
    end)

    it("transpiles files", function()
        local parser = LuaXParser.from_file_content([[
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

        local transpiled = parser:transpile()

        local run_transpiled, err = load(transpiled, "transpiled LuaX")

        if not run_transpiled then
            error(err)
        end

        local Component = run_transpiled()

        local element = Component({ message = "a string!" })

        assert.equal("a string!", element.props.children[1].props.value)
    end)

    it("transpiles files with inline calls", function()
        local parser = LuaXParser.from_file_content([[
            local LuaX = require("src")

            local Component = function (props)
                return ]] .. "LuaX([[" .. [[

                    <>
                        {props.message}
                    </>
                ]] .. "]])" .. [[
            end

            return Component
        ]])

        local transpiled = parser:transpile()

        local run_transpiled, err = load(transpiled, "transpiled LuaX")

        if not run_transpiled then
            error(err)
        end

        local Component = run_transpiled()

        local element = Component({ message = "a string!" })

        assert.equal("a string!", element.props.children[1].props.value)
    end)

    it("transpiles files with inline functions", function()
        local parser = LuaXParser.from_file_content([[
            local LuaX = require("src")

            local Component = LuaX(function (props)
                return ]] .. "[[" .. [[

                    <>
                        {props.message}
                    </>
                ]] .. "]]" .. [[
            end)

            return Component
        ]])

        local transpiled = parser:transpile()

        local run_transpiled, err = load(transpiled, "transpiled LuaX")

        if not run_transpiled then
            error(err)
        end

        local Component = run_transpiled()

        local element = Component({ message = "a string!" })

        assert.equal("a string!", element.props.children[1].props.value)
    end)

    -- TODO FIXME - spec for parsing comment literals - eg {--[[ Hello World! ]]}

    do
        -- local function read_file(path)
        --     local f = io.open(path)
        --     assert(f, "no file handle")
        --     return f:read("a")
        -- end

        local components = {
            -- TODO these files were valid af!
            -- Button = read_file("awesome/Button.luax"),
            -- Test = read_file("awesome/Test.luax"),
            NoWhitespace = [[return <Test>Message!</Test>]],
            NoWhitespaceNested = [[return <><div>Hello!</div></>]],
            NoWhitespaceNestedDynamic = [[return <><div>Hello {location}!</div></>]],
            NoChildrenNoWhitespace = [[return <Box/>]],
            NoChildren = [[return <Box />]],
            PropLiteralQuoted = [[return <div class="{variable}"></div>]],
            MixedChildren = [[return <>
                <Box />
                This is a text!
            </>]],
            LiteralChildrenNoWhitespace = [[return <text>{message}</text>]],
            ComponentWithComments = [[return <text
                -- I am a comment!
            />
            ]]
        }


        local expected = {}
        expected.NoChildren = "return _LuaX_create_element(Box, {  })"
        expected.NoChildrenNoWhitespace = expected.NoChildren
        -- expected.Button = [[
        -- local function Button (props)
        --     local function press (widget, lx, ly, button, mods, metadata)
        --         if button ~= 4 and button ~= 5 then
        --             props.onclick(widget, lx, ly, button, mods, metadata)
        --         end
        --     end
        --
        --     return (_LuaX_create_element("wibox.widget.textbox", { ["signal::button::press"]=press, ["children"]={ props.children } }))
        -- end
        --
        -- return Button]]
        expected.PropLiteralQuoted = [[return _LuaX_create_element("div", { ["class"]=variable })]]
        expected.MixedChildren =
        [[return _LuaX_create_element(_LuaX_Fragment, { ["children"]={ _LuaX_create_element(Box, {  }), "This is a text!" } })]]

        for name, component in pairs(components) do
            it("Successfully transpiles component " .. name, function()
                LuaXParser()
                    :set_text(component)
                    :set_components({
                        "Test", "Box"
                    }, "local")
                    :transpile()
            end)

            -- TODO FIXME don't transpile - just parse and match.
            if expected[name] then
                it("Accurately transpiles component " .. name, function()
                    local parser = LuaXParser()
                        :set_text(component)
                        :set_components({
                            "Test", "Box"
                        }, "local")

                    local transpiled = parser:transpile()

                    assert.equal(expected[name], transpiled)
                end)
            end
        end
    end
end)

---@diagnostic enable:invisible

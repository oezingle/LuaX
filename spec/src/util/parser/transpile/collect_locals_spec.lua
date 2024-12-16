local LuaXParser = require("src.util.parser.LuaXParser")
local collect_locals = require("src.util.parser.transpile.collect_locals")(LuaXParser)

describe("collect_locals", function()
    it("uses lua-parser to collect definitions", function()
        local locals = collect_locals([[
            local Fragment = require("src.components.Fragment")

            do
                print("Hello world!")
            end
        ]])

        assert.True(locals.Fragment)
    end)

    describe("parses LuaX", function()
        it("multiline", function()
            local locals = collect_locals([[
                local Fragment = require("src.components.Fragment")

                local function Component ()
                    return (
                        <>
                            <Typography>
                                I'm a text!
                            </Typography>

                            I'm also text!
                        </>
                    )
                end
            ]])

            assert.True(locals["Fragment"])

            assert.True(locals["Component"])
        end)

        it("single line return", function()
            local locals = collect_locals([[
                local function Component ()
                    return <>I'm a text!</>
                end
            ]])

            assert.True(locals.Component)
        end)

        it("single line assign", function()
            local locals = collect_locals([[
                local function Component ()
                    local element = <>I'm a text!</>

                    return element
                end
            ]])

            assert.True(locals.Component)
        end)
    end)
end)

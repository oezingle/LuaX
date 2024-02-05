local collect_locals = require("src.util.parser.transpile.collect_locals")

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

    describe("parses LuaX source code:", function ()
        it("multiline", function()
            -- TODO FIXME TokenStack catches the ' in I'm and thinks its a string. Boo!
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
    
            assert.True(locals.Fragment)
    
            assert.True(locals.Component)
        end)        

        it("single line return", function ()
            local locals = collect_locals([[
                local function Component ()
                    return <>I'm a text!</>
                end
            ]])
    
            assert.True(locals.Component)
        end)

        it("single line assign", function ()
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

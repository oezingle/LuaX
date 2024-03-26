local inline_transpile = require("src.util.parser.inline.inline_transpile")
local Fragment = require("src.components.Fragment")

describe("inline_transpile", function()
    it("takes strings", function()
        local code = [[
            <>
                Hello World!
            </>
        ]]

        local element = inline_transpile(code)

        assert.equal("Hello World!", element.props.children[1].props.value)
    end)

    it("takes components", function()
        local OuterComponent = Fragment

        local Component = inline_transpile(function()
            return [[
                <OuterComponent>
                    Hello World!
                </OuterComponent>
            ]]
        end)

        local element = Component({})

        if not element then
            error("no element!")
        end

        assert.equal("Hello World!", element.props.children[1].props.value)
    end)
end)

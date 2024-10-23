local LuaX = require("src.init")

local expected_types = {
    Renderer = "table",
    Parser = "table",
    transpile = "table",
    Fragment = "function",
    create_element = "function",
    use_state = "function",
    use_effect = "function",
    use_memo = "function",
    register = "function"
}

describe("LuaX init", function()
    for name, expected_type in pairs(expected_types) do
        it("exports user API" .. name, function()
            local t = type(LuaX[name])

            assert.equal(expected_type, t)
        end)
    end

    it("is callable as an inline parser", function()
        local node = LuaX([[
            <>
                Hello World!
            </>
        ]])

        assert.equal("Hello World!", node.props.children[1].props.value)
    end)
end)

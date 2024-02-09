local LuaX = require("src.init")

local expected_types = {
    Renderer = "table",
    Fragment = "function",
    create_element = "function",
    use_state = "function",
    use_effect = "function",
    use_memo = "function",
    register = "function"
}

describe("LuaX init", function()
    it("has custom pairs handler", function()
        local keys = {}

        for k, _ in pairs(LuaX) do
            table.insert(keys, k)
        end

        assert.truthy(#keys > 0)
    end)

    it("exports user APIs", function()
        for key, expected_type in pairs(expected_types) do
            local t = type(LuaX[key])

            assert.equal(expected_type, t)
        end
    end)

    it("is callable as an inline parser", function()
        local node = LuaX([[
            <>
                Hello World!
            </>
        ]])

        assert.equal("Hello World!", node.props.children[1].props.value)
    end)
end)

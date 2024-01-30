
local TokenStack = require("src.util.xml.parse.TokenStack")

describe("TokenStack", function ()
    it("knows valid tokens", function ()    
        local tokenstack = TokenStack()
        
        local tokens = { "<", ">", "{", "}", "[", "]", "(", ")" }

        for _, token in ipairs(tokens) do
            assert.True(tokenstack:is_token(token))
        end
    end)

    it("can get opposite tokens", function ()
        assert.equal(">", TokenStack.get_opposite("<"))
        assert.equal("<", TokenStack.get_opposite(">"))

        assert.equal("}", TokenStack.get_opposite("{"))
        assert.equal("{", TokenStack.get_opposite("}"))

        assert.equal("]", TokenStack.get_opposite("["))
        assert.equal("[", TokenStack.get_opposite("]"))

        assert.equal(")", TokenStack.get_opposite("("))
        assert.equal("(", TokenStack.get_opposite(")"))
    end)

    it("adds and removes", function ()
        local tokenstack = TokenStack()

        tokenstack:add("<")
        tokenstack:add(">")

        assert.equal(0, #tokenstack:get())
    end)
end)
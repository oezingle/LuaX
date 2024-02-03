local TokenStack = require("src.util.parser.TokenStack")

describe("TokenStack", function()
    it("knows valid tokens", function()
        local tokens = { "{", "}", "[", "]", "(", ")" }
        local text = table.concat(tokens, "")

        local tokenstack = TokenStack(text)

        for _ in ipairs(tokens) do
            assert.True(tokenstack:is_token())

            tokenstack:set_pos(tokenstack.pos + 1)
        end
    end)

    it("can get opposite tokens", function()
        assert.equal("}", TokenStack.get_opposite("{"))
        assert.equal("{", TokenStack.get_opposite("}"))

        assert.equal("]", TokenStack.get_opposite("["))
        assert.equal("[", TokenStack.get_opposite("]"))

        assert.equal(")", TokenStack.get_opposite("("))
        assert.equal("(", TokenStack.get_opposite(")"))
    end)

    it("adds and removes", function()
        local tokenstack = TokenStack("<>")

        tokenstack:run_once()
        tokenstack:run_once()

        assert.truthy(tokenstack:is_empty())
    end)

    it("works with backslashes", function ()
        local text = [["I would like to say \"Hello world!\""]]

        local tokenstack = TokenStack(text)

        tokenstack:run_once()
        tokenstack:run_until_empty()

        assert.equal(39, tokenstack.pos)
    end)

    it("ignores tokens in strings", function ()
        local text = "\"({[\""

        local tokenstack = TokenStack(text)

        tokenstack:run_once()
        tokenstack:run_until_empty()

        assert.truthy(tokenstack:is_empty())
    end)
end)

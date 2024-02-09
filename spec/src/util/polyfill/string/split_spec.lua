
local string_split = require("src.util.polyfill.string.split")

describe("string_split", function ()
    it("splits strings", function ()
        local chars = string_split("a b c d e f g", " ")

        local expected_list = { "a", "b", "c", "d", "e", "f", "g"}

        assert.equal(#expected_list, #chars)

        for i, expected in ipairs(expected_list) do
            assert.equal(expected, chars[i])
        end
    end)

    it("splits multiple seps", function ()
        local chars = string_split("a  b  c", " ")

        local expected_list = { "a", "b", "c"}

        assert.equal(#expected_list, #chars)

        for i, expected in ipairs(expected_list) do
            assert.equal(expected, chars[i])
        end
    end)

    it("splits with sep at end", function ()
        local chars = string_split("a b c ", " ")

        local expected_list = { "a", "b", "c"}

        assert.equal(#expected_list, #chars)

        for i, expected in ipairs(expected_list) do
            assert.equal(expected, chars[i])
        end
    end)
end)
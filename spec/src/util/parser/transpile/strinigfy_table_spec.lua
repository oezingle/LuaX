
local stringify_table = require("src.util.parser.transpile.stringify_table")

describe("stringify_table", function ()
    it("stringifies simple table", function ()
        local list = {}
        
        local stringified = stringify_table(list)
        local expected = "{  }"

        assert.equal(expected, stringified)
    end)

    it("stringifies 1, 2, 3", function ()
        local list = { 1, 2, 3 }

        local stringified = stringify_table(list)
        local expected = "{ [1]=1, [2]=2, [3]=3 }"

        assert.equal(expected, stringified)
    end)

    it("stringifies a, b, c", function ()
        local list = { "a", "b", "c" }

        local stringified = stringify_table(list)
        local expected = "{ [1]=\"a\", [2]=\"b\", [3]=\"c\" }"

        assert.equal(expected, stringified)
    end)

    it("stringifies { a = 1, b = 2, c = 3 }", function ()
        local object = { a = 1, b = 2, c = 3 }
        
        -- string keys in tables iterate at random
        local get_stringified, err = load("return " .. stringify_table(object), "stringified chunk")

        if not get_stringified then
            error(err or "unknown load() error")
        end

        local stringified = get_stringified()

        for k, v in pairs(object) do
            assert.equal(v, stringified[k])
        end
    end)

    -- holy awesome!! does mean that tables need to be double brackets but that's standard to React too.
    it("is chill asf about literals", function ()
        local gross_list = { "{function () error('evil shit') end}" }

        local stringified = stringify_table(gross_list)
        local expected = "{ [1]=function () error('evil shit') end }"

        assert.equal(expected, stringified)
    end)
end)
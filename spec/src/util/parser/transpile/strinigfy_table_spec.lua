
local stringify_table = require("src.util.parser.transpile.stringify_table")

-- spec changed here recently and i feel i should give reason 
-- passing nil into create_element by index doesn't work as expected!
-- as such, indexed properties are just tossed into the table in order.

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
        local expected = "{ 1, 2, 3 }"

        assert.equal(expected, stringified)
    end)

    it("stringifies a, b, c", function ()
        local list = { "a", "b", "c" }

        local stringified = stringify_table(list)
        local expected = "{ \"a\", \"b\", \"c\" }"

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

    it("is chill about literals", function ()
        local gross_list = { "{function () error('evil') end}" }

        local stringified = stringify_table(gross_list)
        local expected = "{ function () error('evil') end }"

        assert.equal(expected, stringified)
    end)

    -- TODO FIXME finish test.
    -- honestly wrote this in because of its usage in HookState - might be useful regardless
    --[[
        it("stringifies functions", function ()
        local table = { function () return true end }

        local stringified = stringify_table(table)
    end)
    ]]
end)
local key_add = require("src.util.key.key_add")
local key_first = require("src.util.key.key_first")

describe("Key helpers", function()
    describe("key_add", function()
        it("adds values to a copy list", function()
            local key = { 1, 2 }

            local key_added = key_add(key, 3)

            assert.equal(3, #key_added)
            assert.equal(2, #key)
        end)
    end)

    describe("key_first", function()
        it("removes values from copies without affecting original", function()
            local key = { 1, 2, 3 }

            local first, key_removed = key_first(key)

            assert.equal(1, first)

            assert.equal(2, #key_removed)
            assert.equal(3, #key)
        end)

        it("handles empty keys with grace", function ()
            local key = {}

            local first, key_removed = key_first(key)

            assert.equal(first, nil)
            assert.table(key_removed)
            assert.equal(0, #key_removed)
        end)
    end)
end)

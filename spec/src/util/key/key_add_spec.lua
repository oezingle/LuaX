local key_add = require("src.util.key.key_add")

describe("Key helpers", function()
    describe("key_add", function()
        it("adds values to a copy list", function()
            local key = { 1, 2 }

            local key_added = key_add(key, 3)

            assert.equal(3, #key_added)
            assert.equal(2, #key)
        end)
    end)
end)

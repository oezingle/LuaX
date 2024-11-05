local table_equals = require("src.util.table_equals")

describe("table_equals", function()
    it("catches type mismatch", function()
        assert.False(table_equals(nil, false))
    end)

    it("takes numbers", function()
        assert.True(table_equals(1, 1))
        assert.False(table_equals(0, 1))
    end)

    it("takes floats", function()
        assert.True(table_equals(0.9, 0.9))
        assert.False(table_equals(0.9, 0.99))
    end)

    it("takes booleans", function()
        assert.True(table_equals(false, false))
        assert.False(table_equals(false, true))
    end)

    it("takes strings", function()
        assert.True(table_equals("hello", "hello"))
        assert.False(table_equals("hello", "world"))
    end)

    --[[
    it("takes functions", function()
        local a = function() print("Hello world!") end
        local b = function() print("Hello world!") end

        assert.True(table_equals(a, b))
    end)
    ]]

    it("Takes nil vs table", function ()
        assert.False(table_equals(nil, {}))
        assert.False(table_equals({}, nil))
    end)

    it("Takes empty table", function()
        assert.True(table_equals({}, {}))
    end)

    it("Works with missing primitive keys in a", function()
        assert.False(table_equals({}, { 1 }))
    end)

    it("Works with missing primitive keys in b", function()
        assert.False(table_equals({ 1 }, {}))
    end)
end)

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

    it("Doesn't hang for self-referencing tables", function ()
        local parent = { child = {} }
        parent.child.parent = parent

        local parent2 = { child = {} }
        parent2.child.parent = parent2

        assert.True(table_equals(parent, parent2))
    end)

    it("Doesn't hang for self-referencing keys", function ()
        local child = {}        
        local parent = { [child] = "Hello World!" }
        child.parent = parent

        local child2 = {} 
        local parent2 = { [child2] = "Hello World!" }
        child2.parent = parent2

        assert.True(table_equals(parent, parent2))
    end)

    it("Doesn't allow traversed table to ignore unequal values", function ()
        local k_a_1 = {}
        local k_a_2 = { "bruh" }
        local a = { k_a_1, k_a_2, k_a_2 }

        local k_b_1 = {}
        local k_b_2 = { "bruh" }
        local b = { k_b_1, k_b_2, k_b_1 }

        assert.False(table_equals(a, b))
    end)
end)

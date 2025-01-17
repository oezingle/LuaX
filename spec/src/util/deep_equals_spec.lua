local deep_equals = require("src.util.deep_equals")

describe("deep_equals", function()
    it("catches type mismatch", function()
        assert.False(deep_equals(nil, false))
    end)

    it("takes numbers", function()
        assert.True(deep_equals(1, 1))
        assert.False(deep_equals(0, 1))
    end)

    it("takes floats", function()
        assert.True(deep_equals(0.9, 0.9))
        assert.False(deep_equals(0.9, 0.99))
    end)

    it("takes booleans", function()
        assert.True(deep_equals(false, false))
        assert.False(deep_equals(false, true))
    end)

    it("takes strings", function()
        assert.True(deep_equals("hello", "hello"))
        assert.False(deep_equals("hello", "world"))
    end)

    it("Takes nil vs table", function ()
        assert.False(deep_equals(nil, {}))
        assert.False(deep_equals({}, nil))
    end)

    it("Takes empty table", function()
        assert.True(deep_equals({}, {}))
    end)

    it("Works with missing primitive keys in a", function()
        assert.False(deep_equals({}, { 1 }))
    end)

    it("Works with missing primitive keys in b", function()
        assert.False(deep_equals({ 1 }, {}))
    end)

    it("Doesn't hang for self-referencing tables", function ()
        local parent = { child = {} }
        parent.child.parent = parent

        local parent2 = { child = {} }
        parent2.child.parent = parent2

        assert.True(deep_equals(parent, parent2))
    end)

    it("Doesn't hang for self-referencing keys", function ()
        local child = {}        
        local parent = { [child] = "Hello World!" }
        child.parent = parent

        local child2 = {} 
        local parent2 = { [child2] = "Hello World!" }
        child2.parent = parent2

        assert.True(deep_equals(parent, parent2))
    end)

    it("Doesn't allow traversed table to ignore unequal values", function ()
        local k_a_1 = {}
        local k_a_2 = { "bruh" }
        local a = { k_a_1, k_a_2, k_a_2 }

        local k_b_1 = {}
        local k_b_2 = { "bruh" }
        local b = { k_b_1, k_b_2, k_b_1 }

        assert.False(deep_equals(a, b))
    end)
end)


local table_equals = require("src.util.table_equals")

describe("table_equals", function ()
    it("knows true from false", function ()
        local equal1 = table_equals(false, true)
        local equal2 = table_equals(true, false)
        
        assert.falsy(equal1)
        assert.falsy(equal2)
    end)

    it("knows empty table from nil", function ()
        local equal = table_equals({}, nil)

        assert.falsy(equal)
    end)
end)
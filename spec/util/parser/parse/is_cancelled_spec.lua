
local is_cancelled = require("src.util.parser.parse.is_cancelled")

describe("is_cancelled", function ()
    it("knows when chars are cancelled", function ()
        local cancelled = is_cancelled("\\<", 2)

        assert.truthy(cancelled)
    end)

    it("knows when chars are not cancelled", function ()
        local cancelled = is_cancelled("\\\\<", 3)

        assert.falsy(cancelled)
    end)
end)
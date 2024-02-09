
local sep = require("src.util.polyfill.path.sep")

describe("sep", function ()
    it("is one character long", function ()
        assert.equal(1, #sep)
    end)

    it("is a slash", function ()
        assert.truthy(sep:match("[/\\]"))
    end)
end)
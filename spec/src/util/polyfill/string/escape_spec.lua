local string_escape = require "src.util.polyfill.string.escape"

describe("string_escape", function ()
    it("escapes special characters", function ()
        local escaped = string_escape("%d")

        assert.has.match(escaped, "%d")
        assert.has_no.match(escaped, "1")
    end)
end)
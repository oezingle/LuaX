local list_filter = require("src.util.polyfill.list.filter")

describe("string_filter", function()
    it("filters elements based on a callback", function()
        local initial = { "a", 1, "b", 2, "c", 3 }
        local filtered = list_filter(initial, function (item)
            return type(item) == "string"
        end)

        for _, item in pairs(filtered) do
            assert.equal("string", type(item))
        end
    end)
end)

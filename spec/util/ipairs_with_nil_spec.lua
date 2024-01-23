
local ipairs_with_nil = require("v3.util.ipairs_with_nil")

describe("ipairs_with_nil", function ()
    it("iterates through normal lists", function ()
        local list = { 1, 2, 3 }

        local sum = 0

        for _, item in ipairs_with_nil(list) do
            sum = sum + item
        end

        assert.equal(6, sum)
    end)

    it("iterates with nil values", function ()
        local list = { 1, nil, 2, nil, 3 }

        local sum = 0

        for _ ,item in ipairs_with_nil(list) do
            if item ~= nil then
                sum = sum + item
            end
        end

        assert.equal(6, sum)
    end)
end)
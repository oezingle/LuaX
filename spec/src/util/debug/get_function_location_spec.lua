local get_function_location = require "src.util.debug.get_function_location"

describe("get_function_location", function ()
    it("knows where a function is defined", function ()
        local fn = function () end

        assert.matches("%S+%.lua:%d+", get_function_location(fn))
    end)
end)
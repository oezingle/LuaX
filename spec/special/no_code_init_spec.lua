describe("Putting no code in init.lua", function()
    collectgarbage("stop")

    it("saves memory", function ()
        local memory_initial = collectgarbage("count")

        local NativeElement1 = require("v3.util.NativeElement")

        local memory_first_require = collectgarbage("count")

        ---@diagnostic disable-next-line:different-requires
        local NativeElement2 = require("v3.util.NativeElement.init")

        local memory_final = collectgarbage("count")

        local first_require_size = memory_first_require - memory_initial
        local allowed_increase = first_require_size / 2

        assert.truthy(memory_final <= memory_first_require + allowed_increase)
    end)

    collectgarbage("restart")
end)

describe("lua_parser", function()
    describe("loading shim", function()
        it("doesn't bleed lua-ext into _G.package.require", function()
            require("lib.lua-parser")

            assert.Nil(package.loaded["ext.op"])
        end)
    end)
end)

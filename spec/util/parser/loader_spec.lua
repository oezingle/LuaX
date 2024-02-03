
local luax_loader = require("src.util.parser.loader").loader

local luax_loader_register = require("src.util.parser.loader").register


describe("LuaX loader", function ()
    it("loads files (duh)", function ()
        local get_module = luax_loader("spec.util.parser.loadable")

        assert.equal("function", type(get_module))

        local module = get_module()

        assert.truthy(module)
    end)

    it("registers", function ()
        luax_loader_register()

        local module = require("spec.util.parser.loadable")

        assert.equal("function", type(module))

        assert.truthy(module)
    end)
end)
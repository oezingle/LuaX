
local luax_loader = require("src.util.parser.loader")

describe("LuaX loader", function ()
    it("loads files (duh)", function ()
        local get_module = luax_loader("spec.src.util.parser.loader.loadable")

        assert.equal("function", type(get_module))

        local module = get_module()

        assert.truthy(module)
    end)
end)
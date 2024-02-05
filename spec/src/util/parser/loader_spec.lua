
local luax_loader = require("src.util.parser.loader").loader
local get_element_name = require("src.util.Renderer.helper.get_element_name")

local luax_loader_register = require("src.util.parser.loader").register


describe("LuaX loader", function ()
    it("loads files (duh)", function ()
        local get_module = luax_loader("spec.src.util.parser.loadable")

        assert.equal("function", type(get_module))

        local module = get_module()

        assert.truthy(module)
    end)

    it("registers", function ()
        luax_loader_register()

        local module = require("spec.src.util.parser.loadable")

        assert.equal("function", type(module))

        assert.truthy(module)
    end)

    it("attaches filenames nicely to loaded code", function ()
        local Component = require("spec.src.util.parser.loadable")

        local name = get_element_name(Component)

        assert.truthy(name:match("spec.src.util.parser.loadable%.luax"))
    end)
end)
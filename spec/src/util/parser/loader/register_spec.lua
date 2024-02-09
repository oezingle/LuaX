
local luax_loader_register = require("src.util.parser.loader.register")
local get_element_name = require("src.util.Renderer.helper.get_element_name")

describe("LuaX loader register", function ()
    it("registers", function ()
        luax_loader_register()

        local module = require("spec.src.util.parser.loader.loadable")

        assert.equal("function", type(module))

        assert.truthy(module)
    end)

    it("attaches filenames nicely to loaded code", function ()
        local Component = require("spec.src.util.parser.loader.loadable")

        local name = get_element_name(Component)

        assert.truthy(name:match("spec.src.util.parser.loader.loadable%.luax"))
    end)
end)
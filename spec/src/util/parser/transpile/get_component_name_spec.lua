local get_component_name = require("src.util.parser.transpile.get_component_name")

describe("get_component_name", function()
    describe("gets a local", function()
        it("in global mode", function()
            local name = get_component_name({}, "global", "element")

            assert.equal("element", name)
        end)

        it("in local mode", function()
            local name = get_component_name({ element = true }, "local", "element")

            assert.equal("element", name)
        end)
    end)

    describe("gets a global", function()
        it("in global mode", function()
            local name = get_component_name({ element = true }, "global", "element")

            assert.equal("\"element\"", name)
        end)

        it("in local mode", function()
            local name = get_component_name({}, "local", "element")

            assert.equal("\"element\"", name)
        end)
    end)

    describe("treats a name prefixed with \"LuaX.\" as a global", function()
        it("in global mode", function()
            local name = get_component_name({ element = true }, "global", "LuaX.element")

            assert.equal("\"element\"", name)
        end)

        it("in local mode", function()
            local name = get_component_name({ element = true }, "local", "LuaX.element")

            assert.equal("\"element\"", name)
        end)
    end)
end)

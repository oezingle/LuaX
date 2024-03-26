local transpile_cache = require("src.util.parser.inline.transpile_cache")

describe("transpile_cache", function()
    local not_valid_lua = "hoo hee haha"
    local luax_code = "<div />"

    describe("finds", function()
        it("set values", function()
            transpile_cache.clear()

            transpile_cache.set(luax_code, not_valid_lua)

            assert.equal(not_valid_lua, transpile_cache.find(luax_code))
        end)

        it("unset values", function()
            transpile_cache.clear()

            assert.equal(nil, transpile_cache.find(luax_code))
        end)
    end)


    it("transpiles LuaX", function()
        transpile_cache.clear()

        local transpiled = transpile_cache.get(luax_code, {})

        assert.equal("return _LuaX_create_element(\"div\", {  })", transpiled)
    end)

    it("caches results", function()
        transpile_cache.clear()

        transpile_cache.set(luax_code, not_valid_lua)

        local transpiled = transpile_cache.get(luax_code, {})

        assert.equal(not_valid_lua, transpiled)
    end)

    describe("clears", function()
        it("without tag specifier", function()
            transpile_cache.set(luax_code, not_valid_lua)

            transpile_cache.clear()

            assert.are_not_equal(not_valid_lua, transpile_cache.get(luax_code, {}))
        end)

        it("with tag specifier", function()
            transpile_cache.set(luax_code, not_valid_lua)

            transpile_cache.clear(luax_code)

            assert.are_not_equal(not_valid_lua, transpile_cache.get(luax_code, {}))
        end)
    end)
end)

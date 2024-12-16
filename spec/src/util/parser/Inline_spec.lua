
local Inline = require("src.util.parser.Inline")
local Fragment = require("src.components.Fragment")

describe("Inline", function ()
    describe("transpiles", function ()
        it("strings", function ()
            local a = "Hello World"
            
            local node = Inline:transpile([[
                <>
                    Local variable "a": {a}
                </>
            ]])
    
            assert.equal("Hello World", node.props.children[2].props.value)
        end)

        it("components", function()
            local OuterComponent = Fragment
    
            local Component = Inline:transpile(function()
                return [[
                    <OuterComponent>
                        Hello World!
                    </OuterComponent>
                ]]
            end)
    
            local element = Component({})
    
            if not element then
                error("no element!")
            end
    
            assert.equal("Hello World!", element.props.children[1].props.value)
        end)
    end)

    describe("cache", function()
        local not_valid_lua = "hoo hee haha"
        local luax_code = "<div />"
    
        describe("finds", function()
            it("set values", function()
                Inline:cache_clear()
    
                Inline:cache_set(luax_code, not_valid_lua)
    
                assert.equal(not_valid_lua, Inline:cache_find(luax_code))
            end)
    
            it("unset values", function()
                Inline:cache_clear()
    
                assert.equal(nil, Inline:cache_find(luax_code))
            end)
        end)
    
    
        it("transpiles LuaX", function()
            Inline:cache_clear()
    
            local transpiled = Inline:cache_get(luax_code, {})
    
            assert.equal("return _LuaX_create_element(\"div\", {  })", transpiled)
        end)
    
        it("caches results", function()
            Inline:cache_clear()
    
            Inline:cache_set(luax_code, not_valid_lua)
    
            local transpiled = Inline:cache_get(luax_code, {})
    
            assert.equal(not_valid_lua, transpiled)
        end)
    
        describe("clears", function()
            it("without tag specifier", function()
                Inline:cache_set(luax_code, not_valid_lua)
    
                Inline:cache_clear()
    
                assert.are_not_equal(not_valid_lua, Inline:cache_get(luax_code, {}))
            end)
    
            it("with tag specifier", function()
                Inline:cache_set(luax_code, not_valid_lua)
    
                Inline:cache_clear(luax_code)
    
                assert.are_not_equal(not_valid_lua, Inline:cache_get(luax_code, {}))
            end)
        end)
    end)
end)
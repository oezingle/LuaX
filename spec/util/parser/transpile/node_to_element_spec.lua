
local transpile_node_to_element = require("src.util.parser.transpile.node_to_element")
local LuaXParser = require("src.util.parser.LuaXParser")

describe("transpile_node_to_element", function ()
    describe("handles global components", function ()
        local expected = "create_element(\"div\", {  })"

        it("in global mode", function ()
            local xml = LuaXParser([[
                <div />
            ]]):parse_all()
    
            local transpiled = transpile_node_to_element(xml, { div = true }, "global")

            assert.equal(expected, transpiled)
        end)
    
        it("in local mode", function ()
            local xml = LuaXParser([[
                <div />
            ]]):parse_all()
    
            local transpiled = transpile_node_to_element(xml, {}, "local")

            assert.equal(expected, transpiled)
        end)
    end)

    describe("handles local components", function ()
        local expected = "create_element(div, {  })"

        it("in global mode", function ()
            local xml = LuaXParser([[
                <div />
            ]]):parse_all()
    
            local transpiled = transpile_node_to_element(xml, { }, "global")

            assert.equal(expected, transpiled)
        end)
    
        it("in local mode", function ()
            local xml = LuaXParser([[
                <div />
            ]]):parse_all()
    
            local transpiled = transpile_node_to_element(xml, { div = true }, "local")

            assert.equal(expected, transpiled)
        end)
    end)

    it("handles string props", function ()
        local xml = LuaXParser([[
            <div
                class="container"
            />
        ]]):parse_all()

        local transpiled = transpile_node_to_element(xml, {}, "local")
        local expected = 'create_element("div", { ["class"]="container" })'

        assert.equal(expected, transpiled)
    end)

    it("handles literal props", function ()
        local xml = LuaXParser([[
            <div
                on_click="{function() print('Hello world!') end}"
            />
        ]]):parse_all()

        local transpiled = transpile_node_to_element(xml, {}, "local")
        local expected = 'create_element("div", { ["on_click"]=function() print(\'Hello world!\') end })'

        assert.equal(expected, transpiled)
    end)

    it("handles implicit props", function ()
        local xml = LuaXParser([[
            <div
                container
            />
        ]]):parse_all()

        local transpiled = transpile_node_to_element(xml, {}, "local")
        local expected = 'create_element("div", { ["container"]=true })'

        assert.equal(expected, transpiled)
    end)
end)
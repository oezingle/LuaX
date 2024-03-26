
local transpile_node_to_element = require("src.util.parser.transpile.node_to_element")
local parse = require("spec.helpers.parser_parse")

-- TODO FIXME this file has a lot of errors. put simply the matching pattern for LuaXParser:parse_props has some issues still
describe("transpile_node_to_element", function ()
    describe("handles global components", function ()
        local expected = "create_element(\"div\", {  })"

        it("in global mode", function ()
            local element = parse([[
                <div />
            ]])

            local transpiled = transpile_node_to_element(element, { div = true }, "global", "create_element")

            assert.equal(expected, transpiled)
        end)
    
        it("in local mode", function ()
            local element = parse([[
                <div />
            ]])
    
            local transpiled = transpile_node_to_element(element, {}, "local", "create_element")

            assert.equal(expected, transpiled)
        end)
    end)

    describe("handles local components", function ()
        local expected = "create_element(div, {  })"

        it("in global mode", function ()
            local element = parse([[
                <div />
            ]])
    
            local transpiled = transpile_node_to_element(element, { }, "global", "create_element")

            assert.equal(expected, transpiled)
        end)
    
        it("in local mode", function ()
            local element = parse([[
                <div />
            ]])
    
            local transpiled = transpile_node_to_element(element, { div = true }, "local", "create_element")

            assert.equal(expected, transpiled)
        end)
    end)

    it("handles string props", function ()
        local element = parse([[
            <div
                class="container"
            />
        ]])

        local transpiled = transpile_node_to_element(element, {}, "local", "create_element")
        local expected = 'create_element("div", { ["class"]="container" })'

        assert.equal(expected, transpiled)
    end)

    it("handles literal props", function ()
        local element = parse([[
            <div
                on_click="{function() print('Hello world!') end}"
            />
        ]])

        local transpiled = transpile_node_to_element(element, {}, "local", "create_element")
        local expected = 'create_element("div", { ["on_click"]=function() print(\'Hello world!\') end })'

        assert.equal(expected, transpiled)
    end)

    it("handles implicit props", function ()
        local element = parse([[
            <div
                container
            />
        ]])

        local transpiled = transpile_node_to_element(element, {}, "local", "create_element")
        local expected = 'create_element("div", { ["container"]=true })'

        assert.equal(expected, transpiled)
    end)
end)
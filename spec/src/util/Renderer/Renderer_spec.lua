local XMLElement            = require("src.util.NativeElement.XMLElement")
local Renderer              = require("src.util.Renderer")
local create_element        = require("src.create_element")
local print_children_by_key = require("spec.debug.print_children_by_key")
local use_effect            = require("src.hooks.use_effect")
local LuaX                  = require("src.init")
local ElementNode           = require("src.util.ElementNode")

-- require("lib.log").level = "trace"

describe("Renderer", function()
    local r = Renderer()

    describe("renders function components", function()
        local hook_calls = 0
        local function incrementer()
            use_effect(function()
                hook_calls = hook_calls + 1
            end, {})

            return create_element("div", {})
        end

        local root = XMLElement.get_root()
        local app = create_element(incrementer, {})

        it("once", function()
            r:render(app, root)

            assert.equal(1, hook_calls)

            assert.equal(1, #root.children)
            assert.equal("div", root.children[1].type)
        end)

        it("twice", function()
            r:render(app, root)

            assert.equal(1, hook_calls)

            assert.equal(1, #root.children)
            assert.equal("div", root.children[1].type)
        end)
    end)

    -- Prove that function components are respective if they return nil
    describe("renders function components that return nil", function()
        local hook_calls = 0
        local function incrementer()
            use_effect(function()
                hook_calls = hook_calls + 1
            end, {})

            return nil
        end

        local root = XMLElement.get_root()
        local app = create_element(incrementer, {})

        it("once", function()
            r:render(app, root)

            assert.equal(1, hook_calls)
        end)

        it("twice", function()
            r:render(app, root)

            assert.equal(1, hook_calls)
        end)
    end)

    -- Prove that VirtualElements do not rely on root element
    describe("renders nested function components", function()
        local hook_calls = 0
        local function incrementer()
            use_effect(function()
                hook_calls = hook_calls + 1
            end, {})

            return nil
        end

        local root = XMLElement.get_root()
        local app = LuaX([[
            <div>
                <incrementer />

                This hook has been called {hook_calls} times
            </div>
        ]])

        it("once", function()
            r:render(app, root)

            assert.equal(1, hook_calls)
        end)

        it("twice", function()
            r:render(app, root)

            assert.equal(1, hook_calls)
        end)
    end)

    -- Prove that VirtualElements do not rely on ElementNodes
    it("renders recreated function components", function ()
        local hook_calls = 0
        local function incrementer()
            use_effect(function()
                hook_calls = hook_calls + 1
            end, {})

            return nil
        end

        local code = [[
            <div>
                <incrementer />

                This hook has been called {hook_calls} times
            </div>
        ]]

        local root = XMLElement.get_root()

        do
            local App = LuaX(function ()
                return code
            end)
            
            r:render(create_element(App, {}), root)
        end

        do
            local App = LuaX(function ()
                return code
            end)
            
            r:render(create_element(App, {}), root)
        end

        assert.equal(1, hook_calls)
    end)

    describe("renders", function()
        local function bruh()
            return create_element("bruh", {})
        end

        local native = false

        local root = XMLElement.get_root()
        local app = LuaX(function()
            return [[
                <>
                    {native and <div/> or <bruh />}
                </>
            ]]
        end)

        it("a function", function ()
            r:render(app(), root)
        end)
        it("a function, then native", function ()
            native = not native
            r:render(app(), root)
        end)
        it("a function, then native, then a function", function ()
            native = not native
            r:render(app(), root)
        end)
    end)
end)
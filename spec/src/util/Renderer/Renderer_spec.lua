local XMLElement     = require("spec.helpers.XMLElement")
local Renderer       = require("src.util.Renderer")
local create_element = require("src.create_element")
local use_state      = require('src.hooks.use_state')
local use_effect     = require("src.hooks.use_effect")
local LuaX           = require("src.init")

-- require("lib.log").level = "trace"

describe("Renderer", function()
    local r = Renderer()

    if false then
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
    end

    -- Prove that VirtualElements do not rely on ElementNodes
    it("renders recreated function components", function()
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
            local App = LuaX(function()
                return code
            end)

            r:render(create_element(App, {}), root)
        end

        do
            local App = LuaX(function()
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

        it("a function", function()
            r:render(app(), root)
        end)
        it("a function, then native", function()
            native = not native
            r:render(app(), root)
        end)
        it("a function, then native, then a function", function()
            native = not native
            r:render(app(), root)
        end)
    end)

    -- bug that I found in AwesomeWM doftiles here - older versions of Renderer
    -- would revert the props sent to the node to their initial values, because
    -- we only set node:on_change at node creation.
    it("Doesn't force old props onto old VirtualElements", function()
        ---@type LuaX.Hooks.UseState.Dispatch<boolean>
        local set_child_hook = function() end
        ---@type LuaX.Hooks.UseState.Dispatch<boolean>
        local set_parent_hook = function() end

        local parent_state_values = {}
        local child_state_values = {}

        local Child = LuaX(function(props)
            local hook, set_hook = use_state(false)

            -- This is evil
            set_child_hook = set_hook

            table.insert(parent_state_values, props.state)
            table.insert(child_state_values, hook)

            return [[
                <>
                    Bruh {tostring(props.state)}
                </>
            ]]
        end)

        local App = LuaX(function()
            local hook, set_hook = use_state(false)

            set_parent_hook = set_hook

            return [[
                <div>
                    <Child state={hook} />
                </div>
            ]]
        end)

        local root = XMLElement.get_root()

        local app = create_element(App, {})
        r:render(app, root)

        set_parent_hook(true)
        set_child_hook(true)
        set_child_hook(false)

        assert.False(parent_state_values[1])

        assert.True(parent_state_values[2])
        assert.True(parent_state_values[3])
        assert.True(parent_state_values[4])
    end)

    describe("Fails if", function()
        local root = XMLElement.get_root()

        local app = create_element("div", {})

        describe("self is", function()
            it("omitted", function()
                ---@diagnostic disable-next-line
                local ok, err = pcall(r.render, app, root)

                assert.False(ok)
                assert.match("\"self\"", err)
                assert.match("instance of class 'Renderer'", err)
            end)

            it("a table", function()
                ---@diagnostic disable-next-line
                local ok, err = pcall(r.render, {}, app, root)

                assert.False(ok)
                assert.match("\"self\"", err)
                assert.match("instance of class 'Renderer'", err)
            end)
        end)

        describe("component is", function ()
            it("omitted", function()
                ---@diagnostic disable-next-line
                local ok, err = pcall(r.render, r, root)

                assert.False(ok)
                assert.match("\"component\"", err)
                assert.match("type table", err)
            end)
        end)

        describe("container is", function ()
            it("omitted", function()
                ---@diagnostic disable-next-line
                local ok, err = pcall(r.render, r, app)

                assert.False(ok)
                assert.match("\"container\"", err)
                assert.match("instance of class 'NativeElement'", err)
            end)

            it("a table", function()
                ---@diagnostic disable-next-line
                local ok, err = pcall(r.render, r, app, {})

                assert.False(ok)
                assert.match("\"container\"", err)
                assert.match("instance of class 'NativeElement'", err)
            end)
        end)
    end)
end)

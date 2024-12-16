local LuaX = require("src.init")
local Portal = require("src.Portal")
local render_set_up = require("spec.helpers.render_set_up")
local create_element = require("src.create_element")

describe("Portal", function()
    local get_app = function(MyPortal)
        local PortalFC = LuaX(function(props)
            return [[
                <MyPortal.Inlet>
                    {props.id}
                </MyPortal.Inlet>
            ]]
        end)

        local App = LuaX(function(props)
            return [[
                <>
                    <MyPortal.Outlet />

                    <div>
                        <PortalFC id="A" />

                        {props.both and <PortalFC id="B" />}
                    </div>
                </>
            ]]
        end)

        return App
    end

    it("renders singular children", function()
        local MyPortal = Portal()
        local App = get_app(MyPortal)
        
        local app = create_element(App, { both = false })

        local root, render = render_set_up(app)

        render()

        assert.equal("A", root.children[1].props.value)
    end)

    it("renders two children", function()
        local MyPortal = Portal()
        local App = get_app(MyPortal)
        
        local app = create_element(App, { both = true })

        local root, render = render_set_up(app)

        render()

        assert.equal("A", root.children[1].props.value)
        assert.equal("B", root.children[2].props.value)
    end)

    it("renders two, then one, child", function ()
        local MyPortal = Portal()
        local App = get_app(MyPortal)

        local app = create_element(App, { both = true })

        local root, render = render_set_up(app)

        render()

        assert.equal("A", root.children[1].props.value)
        assert.equal("B", root.children[2].props.value)

        app.props.both = false

        render()

        assert.equal("A", root.children[1].props.value)
        assert.equal("div", root.children[2].type)
    end)

    it("renders one, then two, children", function ()
        local MyPortal = Portal()
        local App = get_app(MyPortal)

        local app = create_element(App, { both = false })

        local root, render = render_set_up(app)

        render()

        assert.equal("A", root.children[1].props.value)
        assert.equal("div", root.children[2].type)

        app.props.both = true

        render()

        assert.equal("A", root.children[1].props.value)
        assert.equal("B", root.children[2].props.value)
    end)
end)

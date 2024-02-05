
local Context = require("src.context.Context")
local use_context = require("src.hooks.use_context")
local create_element = require("src.create_element")
local static_render  = require("spec.helpers.static_render")
-- local pprint         = require("lib.pprint")

describe("Context", function ()
    it("passes data deeply", function ()
        ---@type LuaX.Context<{ message: string }>
        local MessageContext = Context({ message = "Hello World!" })

        local function DeepChild ()
            local context = use_context(MessageContext)
        

            return create_element("p", { children = context.message })
        end

        local function SpacerChild (props)
            return create_element("div", {
                children = props.children
            })
        end

        local function App ()
            return create_element(MessageContext.Provider, {
                children = {
                    create_element(SpacerChild, {
                        children = {
                            create_element(SpacerChild, {
                                children = {
                                    create_element(DeepChild, {})
                                }
                            })
                        }
                    })
                }
            })
        end

        local root = static_render(create_element(App, {}))

        assert.equal("Hello World!", root.children[1].children[1].children[1].props.value)
    end)

    -- TODO more tests
end)
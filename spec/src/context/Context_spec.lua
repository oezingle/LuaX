local Context        = require("src.context.Context")
local use_context    = require("src.hooks.use_context")
local create_element = require("src.create_element")
local static_render  = require("spec.helpers.static_render")
local Fragment       = require("src.components.Fragment")

describe("Context", function()
    ---@type LuaX.Context<{ message: string }>
    local MessageContext = Context("Hello World!")

    local function DeepChild()
        local message = use_context(MessageContext)

        return create_element("p", { children = message })
    end

    local function SpacerChild(props)
        return create_element("div", {
            children = props.children
        })
    end

    it("passes data deeply", function()
        local function App()
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

    it("passes context to mulitple elements without overlap", function()
        local function App()
            return create_element("div", {
                children = {
                    create_element(MessageContext.Provider, {
                        value = "Hello!",
                        children = create_element(DeepChild, {})
                    }),
                    create_element(MessageContext.Provider, {
                        value = "Goodbye!",
                        children = create_element(DeepChild, {})
                    })
                }
            })
        end

        local root = static_render(create_element(App, {}))

        assert.equal("Hello!", root.children[1].children[1].props.value)
        assert.equal("Goodbye!", root.children[2].children[1].props.value)
    end)
end)

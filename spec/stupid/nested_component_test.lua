local Renderer   = require("src.util.Renderer.Profiled")
local XMLElement = require("src.util.NativeElement.XMLElement")
local use_effect = require("src.hooks.use_effect")
local use_state  = require("src.hooks.use_state")
local create_element = require("src.create_element")

local renderer = Renderer()

local function outer_function_component(props)
    local should_render, set_should_render = use_state(props.default or false)

    use_effect(function()
        set_should_render(function(current)
            return not current
        end)
    end, {})

    if not should_render then
        return nil
    end

    return props.children[1]
end

local function inner_function_component(props)
    return create_element("inner", { index = props.index })
end

local element = create_element("div", {
    class = "container",
    children = {
        create_element(outer_function_component, {
            default = false,
            children = {
                create_element(inner_function_component, { index = 1})
            }            
        }),
        create_element(outer_function_component, {
            default = true,
            children = {
                create_element(inner_function_component, { index = 2 })
            }
        }),
    }
})

local root = XMLElement.get_root({
    type = "root",
    children = {}
})

renderer:render(element, root)

print(root)

print(renderer.calls, "calls to render()")
local Renderer       = require("src.util.Renderer.init")
local XMLElement     = require("src.util.NativeElement.XMLElement")
local use_effect     = require("src.hooks.use_effect")
local use_state      = require("src.hooks.use_state")
local create_element = require("src.create_element")

require("src.util.replace_warn")

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

    return create_element("inner", {})
end


local element = create_element(outer_function_component, {
    default = true
})

local root = XMLElement.get_root({
    type = "root",
    children = {}
})

renderer:render(element, root)

print(root)

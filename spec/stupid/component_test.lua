local Renderer       = require("v3.util.Renderer")
local XMLElement     = require("v3.util.NativeElement.XMLElement")
local use_effect     = require("v3.hooks.use_effect")
local use_memo       = require("v3.hooks.use_memo")
local create_element = require("v3.create_element")

require("v3.util.replace_warn")

local renderer = Renderer()

local render = renderer:get_render()

local function function_component(props)
    local msg = use_memo(function()
        return "Hello world!"
    end, {})

    use_effect(function()
        print(msg)
    end, { msg })

    return create_element("child", {
        index = props.index
    })
end

local element = create_element("div", {
    class = "container",
    children = {
        create_element(function_component, { index = 1 }),
        create_element(function_component, { index = 2 }),
    }
})

local root = XMLElement.get_root({
    type = "root",
    children = {}
})

render(element, root)

print(root)

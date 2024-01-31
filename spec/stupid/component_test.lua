local Renderer       = require("src.util.Renderer")
local XMLElement     = require("src.util.NativeElement.XMLElement")
local use_effect     = require("src.hooks.use_effect")
local use_memo       = require("src.hooks.use_memo")
local create_element = require("src.create_element")

require("src.util.replace_warn")

local renderer = Renderer()

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

renderer:render(element, root)

print(root)

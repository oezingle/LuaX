local Renderer = require("v3.Renderer")
local XMLElement = require("v3.util.NativeElement.XMLElement")

require("v3.util.replace_warn")

local renderer = Renderer()

local render = renderer:get_render()

local element = {
    type = "div",
    props = {
        class = "container",
        children = {
            
        }
    },
}

local root = XMLElement.get_root({
    type = "root",
    children = {}
})

render(element, root)

print(root)

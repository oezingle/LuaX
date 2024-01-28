local Renderer = require("src.util.Renderer.init")
local XMLElement = require("src.util.NativeElement.XMLElement")

require("src.util.replace_warn")

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

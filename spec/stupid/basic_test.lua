local Renderer = require("src.util.Renderer")
local XMLElement = require("src.util.NativeElement.XMLElement")

require("src.util.replace_warn")

local renderer = Renderer()

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

renderer:render(element, root)

print(root)

local Renderer       = require("v3.Renderer")
local XMLElement     = require("v3.util.NativeElement.XMLElement")
local create_element = require("v3.create_element")

require("v3.util.replace_warn")

local renderer = Renderer()

local render = renderer:get_render()

local element = create_element("div", {
    class = "container",
    children = "Hello World!"
})

local root = XMLElement.get_root({
    type = "root",
    children = {}
})

render(element, root)

print(root)

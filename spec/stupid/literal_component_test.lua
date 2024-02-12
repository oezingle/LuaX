local Renderer       = require("src.util.Renderer")
local XMLElement     = require("src.util.NativeElement.XMLElement")
local create_element = require("src.create_element")

require("src.util.replace_warn")

local renderer = Renderer()

local element = create_element("div", {
    class = "container",
    children = "Hello World!"
})

local root = XMLElement.get_root({
    type = "root",
    children = {}
})

renderer:render(element, root)

print(root)

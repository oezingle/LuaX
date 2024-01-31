
local Fragment = require("src.components.Fragment")
local XMLElement = require("src.util.NativeElement.XMLElement")
local renderer = require("src.util.Renderer.Profiled")()
local create_element = require("src.create_element")

require("src.util.replace_warn")

-- TODO test how Fragment performs on unmonut

local element = create_element("div", {
    class = "container",
    children = {
        create_element(Fragment, {
            children = {
                create_element("fragged", { index = 1 }),
                create_element("fragged", { index = 2}),
                create_element("fragged", { index = 3}),
            },
        }),
        create_element("notfragged", { index = 4 }),
    }
})

local root = XMLElement.get_root({
    type = "root",
    children = {}
})

renderer:render(element, root)

print(root)

print(renderer.calls, "calls to render()")
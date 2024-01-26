
local Fragment = require("v3.components.Fragment")
local XMLElement = require("v3.util.NativeElement.XMLElement")
local renderer = require("v3.util.Renderer.Profiled")()
local create_element = require("v3.create_element")

require("v3.util.replace_warn")

local render = renderer:get_render()

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

render(element, root)

print(root)

print(renderer.calls, "calls to render()")
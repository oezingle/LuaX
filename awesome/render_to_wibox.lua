local WiboxElement = require("v3.util.NativeElement.WiboxElement")
local Renderer   = require("v3.util.Renderer")
-- local use_effect = require("v3.hooks.use_effect")
-- local use_state  = require("v3.hooks.use_state")
local create_element = require("v3.create_element")

require("v3.util.replace_warn")

local function render_to_wibox(container)
    local renderer = Renderer()
    local render = renderer:get_render()

    local element = create_element("wibox.layout.flex.horizontal", {
        children = {
            "HELLO I AM TEXT NODE!!"
        }
    })

    local root = WiboxElement.get_root(container)

    render(element, root)
end

return render_to_wibox

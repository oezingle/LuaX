
local render_set_up = require("spec.helpers.render_set_up")

---@param element LuaX.ElementNode
---@param options { profiled?: boolean }?
local function static_render (element, options)
    local root, render = render_set_up(element, options)

    render()

    return root.children[1]
end

return static_render
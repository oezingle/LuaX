
local render_set_up = require("spec.helpers.render_set_up")

---@param element LuaX.ElementNode
local function static_render (element)
    local root, render = render_set_up(element)

    render()

    return root.children[1]
end

return static_render
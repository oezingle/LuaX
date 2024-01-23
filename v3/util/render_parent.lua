local call_component = require "v3.util.call_component"


--- TODO can probably work for both children and parent
---@param element LuaX.ElementNode
---@param container LuaX.NativeComponent
local function render_parent (element, container)
    local string_element = call_component(element)

    container:set_child(0, string_element)

    -- TODO then render all this element's children
end

return render_parent
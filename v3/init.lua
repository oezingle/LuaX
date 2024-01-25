local Renderer       = require("v3.Renderer")
local create_element = require("v3.create_element")
local use_state      = require("v3.hooks.use_state")
local use_effect     = require("v3.hooks.use_effect")
local use_memo       = require("v3.hooks.use_memo")

---@param workloop LuaX.WorkLoop?
local function init_LuaX (workloop) 
    local renderer = Renderer(workloop)

    return {
        render = renderer:get_render(),
        create_element = create_element,
        use_state = use_state,
        use_effect = use_effect,
        use_memo = use_memo,
    }
end

return init_LuaX
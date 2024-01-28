local Renderer       = require("src.util.Renderer")
local create_element = require("src.create_element")
local use_state      = require("src.hooks.use_state")
local use_effect     = require("src.hooks.use_effect")
local use_memo       = require("src.hooks.use_memo")

---@param workloop LuaX.WorkLoop?
local function init_LuaX (workloop) 
    -- TODO don't init until needed (see below)
    local renderer = Renderer(workloop)

    -- TODO this shit should be lazy as fuck (using __index)
    return {
        render = renderer:get_render(),
        create_element = create_element,
        use_state = use_state,
        use_effect = use_effect,
        use_memo = use_memo,
    }
end

return init_LuaX
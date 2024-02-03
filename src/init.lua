-- local use_state      = require("src.hooks.use_state")
-- local use_effect     = require("src.hooks.use_effect")
-- local use_memo       = require("src.hooks.use_memo")

-- TODO no way in hell this optimization gets bundled right
local imports = {
    Renderer = "src.util.Renderer",
    Fragment = "src.components.Fragment",
    create_element = "src.create_element",
    use_state = "src.hooks.use_state",
    use_effect = "src.hooks.use_effect",
    use_memo = "src.hooks.use_memo"
}

--[[
if not ... then
    error("this file must be require()'d")
end

local folder_of_this_file = (...):match("(.-)%.[^%.]+$") or ""
]]

return setmetatable({}, {
    __index = function(_, key)
        local src = imports[key]

        local mod = require(src)

        return mod
    end
})


local class = require("lib.30log")

---@class LuaX.ComponentInstance : Log.BaseFunctions
---@field render fun(self: self, props: LuaX.Props): (LuaX.ElementNode | nil)

---@class LuaX.FunctionComponentInstance : LuaX.ComponentInstance
---@field init fun(self: self, renderer: LuaX.FunctionComponent)
local FunctionComponentInstance = class("FunctionComponentInstance")

function FunctionComponentInstance:init(renderer)
    self.renderer = renderer
end

-- TODO yeah cache
function FunctionComponentInstance:render(props)
    local renderer = self.renderer

    return renderer(props)
end

return FunctionComponentInstance
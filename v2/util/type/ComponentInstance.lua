
local class = require("lib.30log")

--- An instance of a component
---@class LuaX.ComponentInstance : Log.BaseFunctions
---@field get_name fun(self: self): string
---
---@field render fun(self: self, props: LuaX.Props)
---
---@field name string?
---@field renderer function?
---
local ComponentInstance = class("ComponentInstance")

function ComponentInstance:init()

end

function ComponentInstance:get_name()
    if self.name then
        return self.name
    end

    if self.renderer then
        return debug.getinfo(self.renderer, "n").name or "UNKNOWN_FUNCTION"
    end

    error("No way to determine component name")
end

return ComponentInstance
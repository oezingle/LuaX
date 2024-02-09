
local NativeElement = require("src.util.NativeElement")

---@class LuaX.NativeTextElement : LuaX.NativeElement
---@field protected parent LuaX.NativeElement
---@field init fun (self: self, props: string, parent: LuaX.NativeElement)
---
-- ---@field get_prop fun(self: self, prop: string): any
---
--- Abstract fields
---@field set_value fun(self: self, value: string)
local NativeTextElement = NativeElement:extend("NativeTextElement")

NativeElement._dependencies.NativeTextElement = NativeTextElement

-- Doesn't export anything as this is a helper class for NativeElement subclasses
NativeTextElement.components = {}


function NativeTextElement:init (value, parent)

    self.parent = parent

    self:set_value(value)
end

function NativeTextElement:set_prop(prop, value)
    if prop ~= "value" then
        error("Literal nodes do not support props other than value")
    end

    self:set_value(value)
end

--[[
function NativeTextElement:set_value(value)
    self.parent:set_prop("value", value)
end
]]

function NativeTextElement:insert_child()
    error("NativeTextElement may not have children")
end
function NativeTextElement:delete_child()
    error("NativeTextElement may not have children")
end

function NativeTextElement:get_type()
    return "LITERAL_NODE"
end

return NativeTextElement
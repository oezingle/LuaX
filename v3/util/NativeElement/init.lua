local class = require("lib.30log")
-- local ipairs_with_nil = require("v3.util.ipairs_with_nil")
-- local FunctionComponentInstance = require("v3.util.FunctionComponentInstance")

--- TODO this class needs to handle rendering, or outsource rendering to render() - watch changes on components

---@class LuaX.NativeElement : Log.BaseFunctions
--- Abstract Methods
---@field set_prop fun(self: self, prop: string, value: any)
---@field set_child fun(self: self, index: number, element: LuaX.NativeElement | nil)
---
---@field create_element fun(type: string): LuaX.NativeElement
---
---@field get_root fun(native: any): LuaX.NativeElement Convert a passed object to a root node
---
---@operator call : LuaX.NativeElement
local NativeElement = class("NativeElement")

function NativeElement:init(native)
    self.native = native
end

function NativeElement.create_element(element_type)
    if type(element_type) ~= "string" then
        error("NativeElement cannot render non-pure component")
    end

    return NativeElement()
end

--- Get class. Don't even think about overriding this.
---@return LuaX.NativeElement
function NativeElement:get_class()
    return self.class
end

--- Set class of this instance
function NativeElement:set_props(props)
    for prop, value in pairs(props) do
        if prop ~= "children" then
            self:set_prop(prop, value)
        end
    end
end

return NativeElement


-- Virtual element - class to hold, eg, FunctionComponentInstance.

local class = require("lib.30log")
local FunctionComponentInstance = require("src.util.FunctionComponentInstance")
local table_equals              = require("src.util.table_equals")

---@class LuaX.NativeElement.Virtual : Log.BaseFunctions
---@field component LuaX.ComponentInstance
local VirtualElement = class("LuaX.VirtualElement")

function VirtualElement:init (component)
    if type(component) == "function" then
        self.instance = FunctionComponentInstance(component)
        self.type = component
    else
        self.instance = component
    end
end

function VirtualElement:get_type ()
    return self.type
end 

function VirtualElement:on_change(callback)
    self.instance:on_change(callback)
end

function VirtualElement:insert_child()
    error("A VirtualElement should never interact with children")
end
VirtualElement.delete_child = VirtualElement.insert_child

function VirtualElement.create_element (type) 
    return VirtualElement(type)
end

function VirtualElement.get_root()
    error("VirtualElements exist to host non-native components, and therefore cannot be used as root elements")
end

function VirtualElement:set_props (props)
    if table_equals(props, self.props) then
        -- no change to props, no rerender, ignore!
        return
    end
    
    self.props = props

    -- self.instance:render(props)
end

---@return boolean did_render, LuaX.ElementNode | LuaX.ElementNode[] | nil result
function VirtualElement:render ()
    local element = self.instance:render(self.props)

    if not self.instance.requests_rerender then
        return true, element
    end

    return false, nil
end

function VirtualElement:cleanup() 
    self.instance:cleanup()
end

return VirtualElement
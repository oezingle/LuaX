
-- Virtual element - class to hold, eg, FunctionComponentInstance.

local class = require("lib.30log")
local FunctionComponentInstance = require("src.util.FunctionComponentInstance")
local table_equals              = require("src.util.table_equals")

--- This class doesn't actually extend NativeElement because
---  1. VirtualElement's minimal API is all that is needed for its specific use
---     case 
--- 2. This minimal API saves memory 
--- 3. There are some diamond dependencies that would be created by importing
---    NativeElement
--- 
--- I didn't create a LuaX.NativeElement.Minimal class or anything because I am
--- in somewhat of a spat with the language server's types system
--- 
---@class LuaX.NativeElement.Virtual : LuaX.NativeElement
---@field component LuaX.ComponentInstance
---
---@field render function()
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

function VirtualElement:set_on_change(callback)
    self.instance:set_on_change(callback)
end

function VirtualElement:insert_child()
    error("A VirtualElement should never interact with children")
end
VirtualElement.delete_child = VirtualElement.insert_child

---@return LuaX.NativeElement.Virtual
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
    return self.instance:render(self.props)
end

function VirtualElement:cleanup()     
    self.instance:cleanup()
end

return VirtualElement